class Admin::EmployeesController < ApplicationController
  include AdminAuthentication
  before_action :authenticate_admin!
  before_action :set_employee, only: [:show, :edit, :update, :destroy, :manage_accounts, :manage_sizes, :manage_cards, :manage_family]
  layout 'admin'

  def index
    @employees = Employee.includes(:payment_accounts, :worker_size, :party_card, :psuv_card, :family_members)
                        .order(:surnames, :names)
    @employees = @employees.where("LOWER(names) LIKE ? OR LOWER(surnames) LIKE ? OR identification_number LIKE ?", 
                                 "%#{params[:search].downcase}%", "%#{params[:search].downcase}%", "%#{params[:search]}%") if params[:search].present?
  end

  def show
    @payment_accounts = @employee.payment_accounts.order(:is_primary)
    @worker_size = @employee.worker_size
    @party_card = @employee.party_card
    @psuv_card = @employee.psuv_card
    @family_members = @employee.family_members.order(:birth_date)
  end

  def new
    @employee = Employee.new
    build_associated_records
  end

  def create
    @employee = Employee.new(employee_params)
    
    # Si tiene fecha de ingreso anterior al año actual y no tiene fecha de vacaciones,
    # el callback before_save calculará automáticamente para el año actual
    # Si tiene fecha de vacaciones pero no tiene días, calcular automáticamente
    if @employee.vacation_date.present? && @employee.vacation_days.blank?
      @employee.vacation_days = @employee.calculate_vacation_days(@employee.vacation_date)
    end
    
    if @employee.save
      create_associated_records
      redirect_to admin_employee_path(@employee), notice: 'Empleado creado exitosamente.'
    else
      build_associated_records
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    build_associated_records
    # Si tiene fecha de vacaciones pero no tiene días, calcular automáticamente para mostrar en el formulario
    if @employee.vacation_date.present? && @employee.vacation_days.blank?
      @employee.vacation_days = @employee.calculate_vacation_days(@employee.vacation_date)
    end
  end

  def update
    Rails.logger.info "EMPLOYEE PARAMS: #{employee_params.inspect}"
    
    # Si tiene fecha de vacaciones pero no tiene días, calcular automáticamente
    if employee_params[:vacation_date].present? && employee_params[:vacation_days].blank?
      vacation_date = Date.parse(employee_params[:vacation_date])
      calculated_days = @employee.calculate_vacation_days(vacation_date)
      @employee.assign_attributes(employee_params)
      @employee.vacation_days = calculated_days
    else
      @employee.assign_attributes(employee_params)
    end
    
    if @employee.save
      update_associated_records
      redirect_to admin_employee_path(@employee), notice: 'Empleado actualizado exitosamente.'
    else
      build_associated_records
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy
    redirect_to admin_employees_path, notice: 'Empleado eliminado exitosamente.'
  end

  def manage_accounts
    @payment_accounts = @employee.payment_accounts.order(:is_primary)
  end

  def manage_sizes
    @worker_size = @employee.worker_size || @employee.build_worker_size
  end

  def manage_cards
    @party_card = @employee.party_card || @employee.build_party_card
    @psuv_card = @employee.psuv_card || @employee.build_psuv_card
  end

  def manage_family
    @family_members = @employee.family_members.order(:birth_date)
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(
      :identification_number, :names, :surnames, :birth_date, :hire_date,
      :home_address, :vacation_date, :vacation_days, :vacation_notes, :expired_vacations, :skills_abilities, :active,
      :email, :phone_number, :position, :code, :voting_center, :work_location,
      
      # Worker size attributes
      worker_size_attributes: [:id, :shirt_size, :shoes_size, :pants_size],
      
      # Party card attributes
      party_card_attributes: [:id, :code, :serial_number],
      
      # PSUV card attributes
      psuv_card_attributes: [:id, :code, :serial_number],
      
      # Payment accounts attributes
      payment_accounts_attributes: [:id, :account_type, :account_number, :mobile_payment_number, 
                                   :bank_name, :is_primary, :active, :_destroy],
      
      # Family members attributes
      family_members_attributes: [:id, :names, :birth_date, :education_level, :specific_grade, :gender, :_destroy]
    )
  end

  def build_associated_records
    @employee.build_worker_size unless @employee.worker_size
    @employee.build_party_card unless @employee.party_card
    @employee.build_psuv_card unless @employee.psuv_card
    
    # Only build one empty record if none exist (for new employees)
    @employee.payment_accounts.build if @employee.payment_accounts.empty? && @employee.new_record?
    @employee.family_members.build if @employee.family_members.empty? && @employee.new_record?
  end

  def create_associated_records
    # Handle nested attributes creation (Rails handles this automatically with accepts_nested_attributes_for)
  end

  def update_associated_records
    # Handle nested attributes update (Rails handles this automatically with accepts_nested_attributes_for)
  end
end

