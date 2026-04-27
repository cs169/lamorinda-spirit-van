# frozen_string_literal: true

class PassengersController < ApplicationController
  before_action :set_passenger, only: %i[ show edit update destroy ]
  before_action -> { require_role("admin", "dispatcher") }

  # GET /passengers or /passengers.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: passengers_datatable }
    end
  end

  # GET /passengers/1 or /passengers/1.json
  def show
  end

  # GET /passengers/new
  def new
    @passenger = Passenger.new
    # since creating new passenger also have address,
    # this will also create new address record and associates it
    @passenger.build_address

    # For the "Back" button - secure URL validation
    @safe_return_url = safe_return_url || passengers_path
  end

  # GET /passengers/1/edit
  def edit
    # For the "Back" button - secure URL validation
    @safe_return_url = safe_return_url || passengers_path
  end

  # POST /passengers or /passengers.json
  def create
    @passenger = Passenger.new(passenger_params)

    respond_to do |format|
      if @passenger.save
        format.html { redirect_to passenger_create_redirect_url, notice: "Passenger created." }
        format.json { render :show, status: :created, location: @passenger }
      else
        @safe_return_url = safe_return_url || passengers_path
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @passenger.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /passengers/1 or /passengers/1.json
  def update
    @passenger = Passenger.find(params[:id])

    respond_to do |format|
      if @passenger.update(passenger_params)
        format.html { redirect_to edit_passenger_path(@passenger), notice: "Passenger updated." }
        format.json { render :show, status: :ok, location: @passenger }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @passenger.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /passengers/1 or /passengers/1.json
  def destroy
    @passenger.destroy!

    respond_to do |format|
      format.html { redirect_to passengers_path, status: :see_other, notice: "Passenger deleted." }
      format.json { head :no_content }
    end
  end

  private
  # ---------------------------------------------------------------------------
  # DataTables server-side processing
  # ---------------------------------------------------------------------------

  # Maps DataTables column index → SQL expression for ORDER BY
  DT_SORT_COLUMNS_PASSENGERS = {
    1  => "passengers.name",
    2  => "passengers.name",
    4  => "addresses.street",
    5  => "addresses.city",
    6  => "addresses.zip_code",
    7  => "passengers.phone",
    8  => "passengers.alternative_phone",
    9  => "passengers.birthday",
    10 => "passengers.race",
    11 => "passengers.hispanic",
    12 => "passengers.wheelchair",
    13 => "passengers.low_income",
    14 => "passengers.disabled",
    15 => "passengers.need_caregiver",
    16 => "passengers.notes",
    17 => "passengers.email",
    18 => "passengers.date_registered",
    19 => "passengers.audit",
    20 => "passengers.lmv_member",
    21 => "passengers.mail_updates",
    22 => "passengers.rqsted_newsletter"
  }.freeze

  # Maps DataTables column index → Arel column node for WHERE LIKE filtering.
  DT_FILTER_COLUMNS_PASSENGERS = {
    1  => Arel::Table.new("passengers")[:name],
    2  => Arel::Table.new("passengers")[:name],
    4  => Arel::Table.new("addresses")[:street],
    5  => Arel::Table.new("addresses")[:city],
    6  => Arel::Table.new("addresses")[:zip_code],
    7  => Arel::Table.new("passengers")[:phone],
    8  => Arel::Table.new("passengers")[:alternative_phone],
    16 => Arel::Table.new("passengers")[:notes],
    17 => Arel::Table.new("passengers")[:email],
    19 => Arel::Table.new("passengers")[:audit],
    21 => Arel::Table.new("passengers")[:mail_updates],
    22 => Arel::Table.new("passengers")[:rqsted_newsletter]
  }.freeze

  def passengers_datatable
    base = Passenger.left_outer_joins(:address)

    records_total = base.count

    base = apply_passenger_dt_column_filters(base)
    records_filtered = base.count

    col_idx   = params.dig(:order, "0", :column).to_i
    direction = params.dig(:order, "0", :dir) == "asc" ? "ASC" : "DESC"
    sort_col  = DT_SORT_COLUMNS_PASSENGERS[col_idx] || "passengers.name"
    base      = base.order(Arel.sql("#{sort_col} #{direction}"))

    start  = params[:start].to_i
    length = [params[:length].to_i, 1].max

    passengers = base.includes(:address).offset(start).limit(length)

    {
      draw:            params[:draw].to_i,
      recordsTotal:    records_total,
      recordsFiltered: records_filtered,
      data:            passengers.map { |p| dt_passenger_row(p) }
    }
  end

  def apply_passenger_dt_column_filters(scope)
    cols = params[:columns] || {}

    # Column 9: birthday range encoded as "YYYY-MM-DD|YYYY-MM-DD"
    birthday_val = cols.dig("9", :search, :value).to_s.strip
    if birthday_val.include?("|")
      from, to = birthday_val.split("|")
      scope = scope.where("passengers.birthday >= ?", from) if from.present?
      scope = scope.where("passengers.birthday <= ?", to)   if to.present?
    end

    # String columns: wrap in LOWER() via an Arel NamedFunction so no column
    # name is ever interpolated into a SQL string.
    DT_FILTER_COLUMNS_PASSENGERS.each do |idx, arel_col|
      val = cols.dig(idx.to_s, :search, :value).to_s.strip
      next if val.blank?

      lower_col = Arel::Nodes::NamedFunction.new("LOWER", [arel_col])
      scope = scope.where(lower_col.matches("%#{val.downcase}%"))
    end

    scope
  end

  def dt_passenger_row(passenger)
    full_name  = passenger.name.to_s.strip
    name_parts = full_name.split(" ")
    last_name  = name_parts.length > 1 ? name_parts.last : nil
    first_name = name_parts.length > 1 ? name_parts[0...-1].join(" ") : name_parts.first

    [
      dt_passenger_actions_cell(passenger),
      last_name  || "N/A",
      first_name || "N/A",
      passenger.full_address || "",
      passenger.address&.street || "",
      passenger.address&.city || "",
      passenger.address&.zip_code || "",
      passenger.phone || "",
      passenger.alternative_phone || "",
      passenger.birthday&.to_date&.to_s || "",
      passenger.race.to_s,
      dt_bool_badge(passenger.hispanic?),
      dt_bool_badge(passenger.wheelchair),
      dt_bool_badge(passenger.low_income),
      dt_bool_badge(passenger.disabled),
      dt_bool_badge(passenger.need_caregiver),
      dt_truncated_cell(passenger.notes),
      passenger.email || "",
      passenger.date_registered&.to_date&.to_s || "",
      dt_truncated_cell(passenger.audit),
      dt_bool_badge(passenger.lmv_member?),
      dt_truncated_cell(passenger.mail_updates),
      dt_newsletter_badge(passenger.rqsted_newsletter)
    ]
  end

  def dt_passenger_actions_cell(passenger)
    btn    = "btn btn-sm"
    edit   = %(<a href="#{edit_passenger_path(passenger, return_url: passengers_path)}" class="#{btn} btn-primary">Edit</a>)
    delete = %(<a href="#{passenger_path(passenger)}" data-turbo-method="delete" data-turbo-confirm="Are you sure?" class="#{btn} btn-danger">Delete</a>)
    %(<div class="d-flex flex-column gap-2 align-items-center">#{edit}#{delete}</div>)
  end

  def dt_bool_badge(value)
    css   = value ? "bg-success" : "bg-danger"
    label = value ? "Yes" : "No"
    %(<span class="badge #{css}">#{label}</span>)
  end

  def dt_newsletter_badge(value)
    case value&.downcase
    when "opt-in"  then %(<span class="badge bg-success">Opt-In</span>)
    when "neutral" then %(<span class="badge bg-warning text-dark">Neutral</span>)
    when "opt-out" then %(<span class="badge bg-danger">Opt-Out</span>)
    else                %(<span class="badge bg-secondary">Not Set</span>)
    end
  end

  def dt_truncated_cell(text)
    return "" unless text.present?
    truncated = text.length > 20 ? "#{text[0, 20]}…" : text
    %(<span title="#{ERB::Util.html_escape(text)}">#{ERB::Util.html_escape(truncated)}</span>)
  end

  # ---------------------------------------------------------------------------

  # Use callbacks to share common setup or constraints between actions.
  def set_passenger
    @passenger = Passenger.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def passenger_params
    params.require(:passenger).permit(:name, :phone, :alternative_phone, :birthday, :race, :hispanic, :wheelchair, :low_income, :disabled, :need_caregiver, :email, :notes, :date_registered, :audit,
                                      :lmv_member, :mail_updates, :rqsted_newsletter,
                                      address_attributes: [:street, :city, :zip_code])
  end

  def passenger_create_redirect_url
    return passengers_path unless safe_return_url

    uri = URI.parse(safe_return_url)
    query_params = Rack::Utils.parse_nested_query(uri.query)
    query_params["selected_passenger_id"] = @passenger.id
    uri.query = query_params.to_query
    uri.to_s
  rescue URI::InvalidURIError
    passengers_path
  end
end
