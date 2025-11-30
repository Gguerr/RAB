class Admin::VacationsController < ApplicationController
  include AdminAuthentication
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_employee, only: [:show, :edit, :update, :generate_pdf, :approve]

  def index
    # Obtener todos los empleados con vacaciones programadas
    # Asegurarse de que ambos campos estén presentes y no sean nulos
    employees_with_vacations = Employee.where.not(vacation_date: nil)
                                       .where.not(vacation_days: nil)
                                       .where('vacation_days > 0')
                                       .order(:vacation_date)
    
    # Clasificar vacaciones correctamente
    @current_vacations = []
    @upcoming_vacations = []
    @expired_vacations = []
    
    today = Date.current
    
    employees_with_vacations.each do |employee|
      next unless employee.vacation_date.present? && employee.vacation_days.present?
      
      vacation_start = employee.vacation_date
      vacation_days = employee.vacation_days.to_i
      next if vacation_days <= 0
      
      vacation_end = vacation_start + vacation_days.days
      
      # Clasificar vacaciones:
      # 1. Si están aprobadas → "Empleados de vacaciones" (sin importar si ya comenzaron o no)
      if employee.vacation_approved?
        @current_vacations << employee
      # 2. Si NO están aprobadas y la fecha de inicio es hoy o futura → "Próximas"
      elsif vacation_start >= today
        @upcoming_vacations << employee
      # 3. Si ya pasó la fecha de fin → "Vencidas"
      elsif vacation_end < today
        @expired_vacations << employee
      end
    end
    
    # Ordenar las listas
    @current_vacations.sort_by! { |e| e.vacation_date }
    @upcoming_vacations.sort_by! { |e| e.vacation_date }
    @expired_vacations.sort_by! { |e| e.vacation_date }.reverse!
    
    # Calcular estadísticas
    @vacation_stats = {
      total_employees: Employee.count,
      on_vacation_now: @current_vacations.count,
      upcoming_30_days: @upcoming_vacations.select { |e| e.vacation_date <= today + 30.days }.count,
      expired_count: @expired_vacations.count,
      no_vacation_set: Employee.where(vacation_date: nil).or(Employee.where(vacation_days: nil)).or(Employee.where(vacation_days: 0)).count
    }
  end

  def show
    @vacation_history = [] # Aquí podrías agregar historial si tienes una tabla separada
  end

  def edit
  end

  def update
    # El modelo calculará automáticamente los días vencidos con el callback before_save
    if @employee.update(employee_params)
      # Verificar el estado de las vacaciones después de actualizar
      today = Date.current
      vacation_start = @employee.vacation_date
      vacation_days = @employee.vacation_days.to_i
      
      if vacation_start.present? && vacation_days > 0
        vacation_end = vacation_start + vacation_days.days
        
        # Si se actualizaron las vacaciones, resetear la aprobación
        @employee.update(vacation_approved: false) if @employee.vacation_approved?
        
        if vacation_start <= today && today <= vacation_end
          # El empleado está actualmente en el rango de vacaciones (pero necesita aprobación)
          notice_message = "✅ Vacaciones actualizadas. ⏳ Pendiente de aprobación. El empleado está en el rango de vacaciones (hasta #{vacation_end.strftime('%d/%m/%Y')})."
        elsif vacation_start > today
          # Vacaciones futuras
          days_until = (vacation_start - today).to_i
          notice_message = "✅ Vacaciones actualizadas. ⏳ Pendiente de aprobación. El empleado tiene vacaciones programadas para dentro de #{days_until} día#{'s' if days_until != 1} (inicio: #{vacation_start.strftime('%d/%m/%Y')})."
        elsif vacation_end < today
          # Vacaciones vencidas
          notice_message = "✅ Vacaciones actualizadas. ⚠️ Estas vacaciones ya vencieron (finalizaron el #{vacation_end.strftime('%d/%m/%Y')})."
        else
          notice_message = '✅ Vacaciones actualizadas correctamente.'
        end
      else
        notice_message = '✅ Vacaciones actualizadas correctamente.'
      end
      
      redirect_to admin_vacation_path(@employee), notice: notice_message
    else
      render :edit
    end
  end

  def approve
    if @employee.vacation_date.blank? || @employee.vacation_days.blank?
      redirect_to admin_vacation_path(@employee), alert: 'No se puede aprobar: las vacaciones no están configuradas correctamente.'
      return
    end
    
    @employee.update(vacation_approved: true)
    
    today = Date.current
    vacation_start = @employee.vacation_date
    vacation_end = vacation_start + @employee.vacation_days.days
    
    if vacation_start <= today && today <= vacation_end
      notice_message = "✅ Vacaciones aprobadas. El empleado está ahora EN VACACIONES (hasta #{vacation_end.strftime('%d/%m/%Y')})."
    elsif vacation_start > today
      days_until = (vacation_start - today).to_i
      notice_message = "✅ Vacaciones aprobadas. El empleado comenzará sus vacaciones en #{days_until} día#{'s' if days_until != 1} (inicio: #{vacation_start.strftime('%d/%m/%Y')})."
    else
      notice_message = "✅ Vacaciones aprobadas. ⚠️ Nota: Estas vacaciones ya vencieron (finalizaron el #{vacation_end.strftime('%d/%m/%Y')})."
    end
    
    redirect_to admin_vacation_path(@employee), notice: notice_message
  end

  def generate_pdf
    require 'prawn'
    require 'prawn/table'
    
    pdf = Prawn::Document.new(page_size: 'A4', margin: [20, 20, 20, 20])
    
    # Usar el método del ReportPdfGenerator para generar el formulario
    generator = Admin::ReportsController::ReportPdfGenerator.new([@employee], 'vacation_request', {})
    generator.instance_variable_set(:@pdf, pdf)
    generator.send(:add_vacation_request_form)
    
    send_data pdf.render, 
              filename: "solicitud_vacaciones_#{@employee.identification_number}_#{Date.current.strftime('%Y%m%d')}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
  end

  def bulk_update
    if params[:mark_expired_as_taken].present? || params[:mark_expired_as_taken] == "1" || params[:mark_expired_as_taken] == true
      today = Date.current
      employees_updated = 0
      
      # Buscar empleados con vacaciones vencidas (fecha fin ya pasó)
      Employee.where('vacation_date IS NOT NULL')
              .where('vacation_days IS NOT NULL')
              .find_each do |employee|
        vacation_end = employee.vacation_date + (employee.vacation_days || 0).days
        
        if vacation_end < today
          # Calcular días que tenía derecho vs días que tomó
          days_entitled = employee.calculate_vacation_days(employee.vacation_date)
          days_taken = employee.vacation_days || 0
          days_not_taken = days_entitled - days_taken
          
          # Si el empleado tomó todos los días a los que tenía derecho, limpiar las vacaciones
          if days_not_taken <= 0
            # El empleado tomó todos sus días, limpiar las vacaciones
            employee.update(
              vacation_date: nil,
              vacation_days: nil,
              vacation_notes: nil,
              expired_vacations: 0
            )
            employees_updated += 1
          elsif days_not_taken > 0
            # El empleado no tomó todos sus días, pero ya pasó el período
            # Marcar los días no tomados como vencidos y limpiar las vacaciones
            employee.update(
              vacation_date: nil,
              vacation_days: nil,
              vacation_notes: nil,
              expired_vacations: days_not_taken
            )
            employees_updated += 1
          end
        end
      end
      
      if employees_updated > 0
        redirect_to admin_vacations_path, 
                    notice: "#{employees_updated} empleado#{'s' if employees_updated != 1} con vacaciones vencidas #{employees_updated == 1 ? 'ha sido' : 'han sido'} actualizado#{'s' if employees_updated != 1}."
      else
        redirect_to admin_vacations_path, 
                    notice: 'No hay vacaciones vencidas para actualizar.'
      end
    else
      redirect_to admin_vacations_path, alert: 'No se especificó una acción válida.'
    end
  end

  def calendar
    @month = params[:month] ? Date.parse(params[:month]) : Date.current.beginning_of_month
    @employees_by_date = {}
    
    # Obtener empleados con vacaciones en el mes
    start_date = @month.beginning_of_month
    end_date = @month.end_of_month
    
    employees_in_month = Employee.where(vacation_date: start_date..end_date)
    
    employees_in_month.each do |employee|
      date_key = employee.vacation_date.strftime('%Y-%m-%d')
      @employees_by_date[date_key] ||= []
      @employees_by_date[date_key] << employee
    end
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:vacation_date, :vacation_days, :vacation_notes)
  end
end
