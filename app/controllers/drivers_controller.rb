class DriversController < ApplicationController
  before_action :set_driver, only: %i[ show edit update destroy ]

  # GET /drivers or /drivers.json
  def index
    @drivers = Driver.all
  end

  # GET /drivers/1 or /drivers/1.json
  def show
  end

  # GET /drivers/new
  def new
    @driver = Driver.new
  end

  # GET /drivers/1/edit
  def edit
  end

  # POST /drivers or /drivers.json
  def create
    # transform any comma-separated shifts into arrays:
    if params[:driver][:shifts].present?
      params[:driver][:shifts].each do |day_key, shift_string|
        # Split the input by commas, trim whitespace, remove empties
        # Example: "am, pm" => ["am", "pm"]
        # Blank or nil becomes an empty array
        splits = shift_string.to_s.split(",").map(&:strip).reject(&:blank?)
        params[:driver][:shifts][day_key] = splits
      end
    end

    @driver = Driver.new(driver_params)

    respond_to do |format|
      if @driver.save
        format.html { redirect_to drivers_path, notice: "Driver was successfully created." }
        format.json { render :show, status: :created, location: @driver }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @driver.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /drivers/1 or /drivers/1.json
  def update
    respond_to do |format|
      if @driver.update(driver_params)
        format.html { redirect_to edit_driver_path(@driver), notice: "Driver was successfully updated." }
        format.json { render :show, status: :ok, location: @driver }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @driver.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /drivers/1 or /drivers/1.json
  def destroy
    @driver.destroy!

    respond_to do |format|
      format.html { redirect_to drivers_path, status: :see_other, notice: "Driver was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_driver
      @driver = Driver.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def driver_params
      params.require(:driver).permit(:name, :phone, :email, :active, shifts: {})
    end
end
