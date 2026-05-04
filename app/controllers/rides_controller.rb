# frozen_string_literal: true

class RidesController < ApplicationController
  before_action :set_ride, only: %i[ show edit update destroy ]
  before_action :set_active_drivers, only: %i[ new edit create update duplicate ]
  before_action :set_active_passengers, only: %i[ new edit create update duplicate ]
  before_action -> { require_role("admin", "dispatcher") }, only: %i[ index new edit create update destroy duplicate ]

  # Have only rides without previous rides (HEAD rides) be displayed
  # "Give me all rides whose id is not someone else's next_ride_id
  # — i.e., they're not the continuation of another ride."
  def index
    respond_to do |format|
      format.html
      format.json { render json: rides_datatable }
    end
  end

  def show
    @all_rides = @ride.get_all_linked_rides
  end

  # new (GET Request, displays form)
  def new
    session[:return_to] = request.referer
    @ride = Ride.new(params.permit(:date, :driver_id))
    @ride.build_start_address
    @ride.build_dest_address

    # For autofilling first stop's driver
    @ride.driver_id = params[:driver_id]

    # Load all passengers with their associations at once
    load_gon_data
  end

  def create
    ride_attrs, addresses, stops_data = Ride.extract_attrs_from_params(ride_params)

    begin
      new_rides = Ride.build_linked_rides!(ride_attrs, addresses, stops_data)

      new_rides.each(&:save!)
      @ride = new_rides.first

      session[:return_to] ||= rides_path
      redirect_to session[:return_to], notice: "Ride was successfully created."

    rescue ActiveRecord::RecordInvalid => e
      @ride = Ride.new(ride_attrs)
      flash.now[:alert] = "Creation failed: #{e.record.errors.full_messages.join('! ')}"
      render :new, status: :unprocessable_entity

    rescue => e
      flash[:alert] = "A system error occurred: #{e.message}"
      Rails.logger.error("System Error: #{e.backtrace.first(5)}")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # For driver dropdown list in creating / updating
    @all_rides = @ride.get_all_linked_rides

    # Load all passengers with their associations at once
    load_gon_data

    # Accessibility info is retrieved from the passenger
    sync_passenger_health_data
  end

  def update
    # Before destroying, copy feedback
    @feedback = @ride.feedback
    old_feedback_attrs = @feedback.attributes.except("id", "created_at", "updated_at", "ride_id") if @feedback

    all_rides = @ride.get_all_linked_rides
    ride_attrs, addresses, stops_data = Ride.extract_attrs_from_params(ride_params)

    begin
      new_rides = Ride.build_linked_rides!(ride_attrs, addresses, stops_data)

      ActiveRecord::Base.transaction do
        # Destroy old ride chain
        all_rides.reverse_each(&:destroy!)

        new_rides.each(&:save!)
        @ride = new_rides.first

        if old_feedback_attrs
          @ride.feedback&.destroy!
          @ride.create_feedback!(old_feedback_attrs)
        end
      end

      flash[:notice] = "Ride was successfully updated."
      redirect_to edit_ride_path(@ride)

    rescue ActiveRecord::RecordInvalid => e
      @all_rides = all_rides
      @ride = Ride.new(ride_attrs)
      flash.now[:alert] = "Update failed: #{e.record.errors.full_messages.join('! ')}"
      render :edit, status: :unprocessable_entity

    rescue => e
      Rails.logger.error("System Error: #{e.backtrace.first(5)}")
      raise e
    end
  end

  def destroy
    all_rides = @ride.get_all_linked_rides
    ActiveRecord::Base.transaction do
      all_rides.reverse_each(&:destroy!)
    end
    flash[:notice] = "Ride(s) were successfully removed."
    redirect_back(fallback_location: root_path)
  rescue ActiveRecord::RecordNotDestroyed
    flash[:alert] = "Failed to remove the ride."
    redirect_to rides_url, status: :unprocessable_entity
  end

  # duplicate (GET request, pre-fills new form with existing ride data)
  def duplicate
    @original_ride = Ride.find(params[:id])

    # 1. Create a memory-only copy of the ride and fetch the full ride chain
    original_chain = @original_ride.get_all_linked_rides
    @ride = @original_ride.dup

    # 2. Reset fields that shouldn't be copied
    @ride.status = "Pending"           # Reset status

    @ride.start_address = @original_ride.start_address&.dup
    @ride.dest_address  = @original_ride.dest_address&.dup

    # 3. DATA FOR STOP 1 & PASSENGER (The Fix)
    # We send this to JS to simulate the user typing/selecting
    @duplicate_info = {
      passenger_id: @original_ride.passenger_id,
      start_address: {
        name:   @original_ride.start_address&.name,
        street: @original_ride.start_address&.street,
        city:   @original_ride.start_address&.city,
        phone:  @original_ride.start_address&.phone
      }
    }

    # 4. Prepare "Extra Stops" (Stop 2, Stop 3, ...)
    # We skip the first ride (drop(1)) because its destination is already
    # handled by @ride.dest_address above
    @duplicated_stops = original_chain.drop(1).map do |linked_ride|
      dest = linked_ride.dest_address
      {
        name:      dest&.name,
        phone:     dest&.phone,
        street:    dest&.street,
        city:      dest&.city,
        van:       linked_ride.van,      # Keep the van from the original ride
        driver_id: linked_ride.driver_id # Keep the driver from the original ride
      }
    end

    # 5. Setup GON variables (Identical to 'new' action)
    # This is required for the frontend dropdowns to work on this page
    load_gon_data

    # 6. Render the 'new' template
    # This reuses existing 'new' form. Since @ride.new_record? is true (because we used .dup),
    # the form will automatically submit to the 'create' action
    render :new
  end


  private
  # ---------------------------------------------------------------------------
  # DataTables server-side processing
  # ---------------------------------------------------------------------------

  # Maps DataTables column index → SQL expression for ORDER BY
  DT_SORT_COLUMNS = {
    1  => "rides.date",
    2  => "drivers.name",
    3  => "rides.van",
    4  => "passengers.name",
    5  => "passengers.name",
    7  => "start_addresses.city",
    8  => "rides.appointment_time",
    10 => "rides.ride_type",
    11 => "rides.wheelchair",
    12 => "rides.disabled",
    13 => "rides.need_caregiver",
    14 => "rides.fare_type",
    15 => "rides.fare_amount",
    16 => "rides.notes_to_driver",
    17 => "rides.notes",
    18 => "rides.hours",
    19 => "rides.amount_paid",
    20 => "rides.status"
  }.freeze

  # Maps DataTables column index → Arel column node for WHERE LIKE filtering.
  # Using Arel nodes instead of raw SQL strings keeps column names out of any
  # interpolated string, which satisfies Brakeman's SQL injection checks.
  # The van column (3) is handled separately because it requires a CAST.
  DT_FILTER_COLUMNS = {
    2  => Arel::Table.new("drivers")[:name],
    4  => Arel::Table.new("passengers")[:name],
    5  => Arel::Table.new("passengers")[:name],
    7  => Arel::Table.new("start_addresses")[:city],
    10 => Arel::Table.new("rides")[:ride_type],
    14 => Arel::Table.new("rides")[:fare_type],
    16 => Arel::Table.new("rides")[:notes_to_driver],
    17 => Arel::Table.new("rides")[:notes],
    20 => Arel::Table.new("rides")[:status]
  }.freeze

  def rides_datatable
    is_export = params[:length].to_i == -1
    base = head_rides_base_scope

    records_total = base.count

    base = apply_dt_column_filters(base)
    records_filtered = base.count

    col_idx   = params.dig(:order, "0", :column).to_i
    direction = params.dig(:order, "0", :dir) == "asc" ? "ASC" : "DESC"
    sort_col  = DT_SORT_COLUMNS[col_idx] || "rides.date"
    base      = base.order(Arel.sql("#{sort_col} #{direction}"))

    rides = if is_export
      base.includes(:feedback, :driver, :passenger, :start_address, :dest_address, :next_ride)
    else
      start  = params[:start].to_i
      length = [params[:length].to_i, 1].max
      base
        .includes(:feedback, :driver, :passenger, :start_address, :dest_address, :next_ride)
        .offset(start)
        .limit(length)
    end

    {
      draw:            params[:draw].to_i,
      recordsTotal:    records_total,
      recordsFiltered: records_filtered,
      data:            rides.map { |ride| dt_ride_row(ride) }
    }
  end

  # Base scope with LEFT JOINs needed for sorting/filtering on associated columns.
  # LEFT JOINs ensure rides without a driver/passenger/address still appear.
  def head_rides_base_scope
    Ride
      .left_outer_joins(:driver, :passenger)
      .joins("LEFT JOIN addresses AS start_addresses ON start_addresses.id = rides.start_address_id")
      .where.not(id: Ride.select(:next_ride_id).where.not(next_ride_id: nil))
  end

  def apply_dt_column_filters(scope)
    cols = params[:columns] || {}

    # Column 1: date range encoded as "YYYY-MM-DD|YYYY-MM-DD"
    date_val = cols.dig("1", :search, :value).to_s.strip
    if date_val.include?("|")
      from, to = date_val.split("|")
      scope = scope.where("rides.date >= ?", from) if from.present?
      scope = scope.where("rides.date <= ?", to) if to.present?
    end

    # String columns: wrap in LOWER() via an Arel NamedFunction so no column
    # name is ever interpolated into a SQL string. Arel's matches() binds the
    # value as a parameter, so user input never touches the SQL structure.
    DT_FILTER_COLUMNS.each do |idx, arel_col|
      val = cols.dig(idx.to_s, :search, :value).to_s.strip
      next if val.blank?

      lower_col = Arel::Nodes::NamedFunction.new("LOWER", [arel_col])
      scope = scope.where(lower_col.matches("%#{val.downcase}%"))
    end

    # Column 3: van is an integer — cast to text first (literal SQL, no interpolation)
    van_val = cols.dig("3", :search, :value).to_s.strip
    scope = scope.where("CAST(rides.van AS TEXT) LIKE ?", "%#{van_val}%") if van_val.present?

    scope
  end

  def dt_ride_row(ride)
    all_rides  = ride.get_all_linked_rides
    full_name  = ride.passenger&.name.to_s.strip
    name_parts = full_name.split(" ")
    last_name  = name_parts.length > 1 ? name_parts.last : nil
    first_name = name_parts.length > 1 ? name_parts[0...-1].join(" ") : name_parts.first

    stop_count    = all_rides.length
    first_start   = all_rides.first&.start_address&.full_address
    last_dest     = all_rides.last&.dest_address&.full_address
    is_round_trip = first_start == last_dest && first_start.present?

    [
      dt_actions_cell(ride),
      ride.date.strftime("%m/%d/%Y"),
      all_rides.map { |r| r.driver&.name || "Unknown" }.uniq.join(", ").presence || "N/A",
      all_rides.filter_map(&:van).uniq.join(", ").presence || "N/A",
      last_name  || "N/A",
      first_name || "N/A",
      dt_stops_cell(stop_count, is_round_trip),
      ride.start_address&.full_address || "N/A",
      ride.appointment_time ? ride.appointment_time.strftime("%-I:%M %p") : "",
      dt_destinations_cell(ride, all_rides),
      ride.ride_type.to_s,
      dt_bool_badge(ride.wheelchair),
      dt_bool_badge(ride.disabled),
      dt_bool_badge(ride.need_caregiver),
      ride.fare_type.to_s,
      helpers.number_to_currency(ride.fare_amount),
      ride.notes_to_driver || "N/A",
      ride.notes || "N/A",
      ride.hours || 0,
      helpers.number_to_currency(ride.amount_paid),
      ride.status || "N/A"
    ]
  end

  def dt_actions_cell(ride)
    btn = "btn btn-sm"
    sty = "style=\"width:81.09px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;\""
    feedback = if ride.feedback
      %(<a href="#{feedback_path(ride.feedback)}" class="#{btn} btn-primary" #{sty}>Feedback</a>)
    else
      %(<span class="#{btn} btn-secondary disabled" #{sty}>No Feedback</span>)
    end
    edit      = %(<a href="#{edit_ride_path(ride)}" class="#{btn} btn-primary" #{sty}>Edit</a>)
    duplicate = %(<a href="#{duplicate_ride_path(ride)}" data-turbo="false" class="#{btn} btn-primary" #{sty}>Duplicate</a>)
    delete    = %(<a href="#{ride_path(ride)}" data-turbo-method="delete" data-turbo-confirm="Are you sure?" class="#{btn} btn-danger" #{sty}>Delete</a>)
    %(<div class="d-flex flex-column gap-2 align-items-center">#{feedback}#{edit}#{duplicate}#{delete}</div>)
  end

  def dt_stops_cell(stop_count, is_round_trip)
    html = +""
    html << %(<span class="badge bg-info text-dark">#{stop_count} stops</span>) if stop_count > 1
    html << %(<span class="badge bg-warning text-dark">Rt</span>)               if is_round_trip
    html << %(<span class="badge bg-secondary">One-way</span>)                  if stop_count == 1 && !is_round_trip
    html
  end

  def dt_destinations_cell(ride, all_rides)
    if ride.next_ride_id?
      items = all_rides.map { |r| "<li>#{r.dest_address&.address_no_zip}</li>" }.join
      "<ul class='mb-0 ps-3'>#{items}</ul>"
    else
      ride.dest_address&.full_address || "N/A"
    end
  end

  def dt_bool_badge(value)
    css   = value ? "bg-success" : "bg-danger"
    label = value ? "Yes" : "No"
    %(<span class="badge #{css}">#{label}</span>)
  end

  # ---------------------------------------------------------------------------

  def set_ride
    @ride = Ride.find(params[:id])
  end

  def set_active_drivers
    @drivers = Driver.active
                     .or(Driver.where(id: @ride.present? ? @ride.get_all_linked_rides.pluck(:driver_id) : []))
                     .order(:name)
                     .distinct
    gon.drivers = @drivers.map { |d| { id: d.id, name: d.name } }
  end

  def set_active_passengers
    @passengers = Passenger.active
                           .or(Passenger.where(id: @ride&.passenger_id))
                           .order(:name)
                           .distinct
    passengers_with_data = @passengers.includes(:address, :rides)
    gon.passengers = passengers_with_data.map { |p| {
      label: p.name, id: p.id, phone: p.phone, alt_phone: p.alternative_phone, wheelchair: p.wheelchair,
      disabled: p.disabled, need_caregiver: p.need_caregiver, low_income: p.low_income, lmv_member: p.lmv_member,
      notes: p.notes, ride_count: p.rides.length,
      street: p.address&.street, city: p.address&.city
    } }
  end

  def load_gon_data
    gon.addresses = Address.all.map { |a| { name: a.name, street: a.street, city: a.city, phone: a.phone } }
    gon.duplicate_info = @duplicate_info if @duplicate_info
    gon.duplicated_stops = @duplicated_stops if @duplicated_stops
  end

  def sync_passenger_health_data
    return unless @ride.passenger

    @ride.wheelchair      = @ride.passenger.wheelchair
    @ride.disabled        = @ride.passenger.disabled
    @ride.need_caregiver  = @ride.passenger.need_caregiver
  end

  def ride_params
    params.require(:ride).permit(
      :date,
      :van,
      :hours,
      :amount_paid,
      :status,
      :passenger_id,
      :driver_id,
      :notes,
      :notes_to_driver,
      :fare_type,
      :fare_amount,
      :appointment_time,
      :wheelchair,
      :disabled,
      :need_caregiver,
      :start_address_id,
      :dest_address_id,
      :ride_type,
      addresses_attributes: [:name, :street, :city, :phone],
      stops_attributes: [:driver_id, :van],
    )
  end
end
