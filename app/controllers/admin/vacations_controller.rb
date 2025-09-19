class Admin::VacationsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_employee, only: [:show, :edit, :update]

  def index
    @employees_on_vacation = Employee.where('vacation_date IS NOT NULL')
                                   .order(:vacation_date)
    
    @current_vacations = @employees_on_vacation.where(
      vacation_date: (Date.current - 7.days)..(Date.current + 7.days)
    )
    
    @upcoming_vacations = @employees_on_vacation.where(
      'vacation_date > ?', Date.current + 7.days
    ).limit(10)
    
    @expired_vacations = @employees_on_vacation.where(
      'vacation_date < ?', Date.current - 7.days
    )
    
    @vacation_stats = {
      total_employees: Employee.count,
      on_vacation_now: @current_vacations.count,
      upcoming_30_days: @employees_on_vacation.where(
        vacation_date: Date.current..(Date.current + 30.days)
      ).count,
      expired_count: @expired_vacations.count,
      no_vacation_set: Employee.where(vacation_date: nil).count
    }
  end

  def show
    @vacation_history = [] # Aquí podrías agregar historial si tienes una tabla separada
  end

  def edit
  end

  def update
    if @employee.update(employee_params)
      redirect_to admin_vacation_path(@employee), notice: 'Vacaciones actualizadas correctamente.'
    else
      render :edit
    end
  end

  def bulk_update
    employees_updated = 0
    
    if params[:mark_expired_as_taken]
      expired_employees = Employee.where('vacation_date < ?', Date.current - 30.days)
      expired_employees.update_all(vacation_date: nil)
      employees_updated = expired_employees.count
      
      redirect_to admin_vacations_path, 
                  notice: "#{employees_updated} empleados con vacaciones vencidas han sido actualizados."
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

  def add_vacation_request_form
    return if @data.empty?
    
    employee = @data.is_a?(Array) ? @data.first : @data.first
    
    # Fecha de ingreso exactamente como está en la BDD (sin ajustar fines de semana)
    hire_date = employee&.hire_date || Date.new(2024, 2, 1)
    
    # Fechas de vacaciones desde datos del empleado
    vacation_start = employee&.vacation_date || Date.new(2025, 9, 15)
    vacation_end = vacation_start + 15.days

    # Reincorporación: día siguiente a la fecha "HASTA", ajustado a día hábil
    reincorporation_date = vacation_end + 1.day
    if reincorporation_date.saturday?
      reincorporation_date = reincorporation_date + 2.days  # sábado + 2 = lunes
    elsif reincorporation_date.sunday?
      reincorporation_date = reincorporation_date + 1.day   # domingo + 1 = lunes
    end
    
    # Título principal - exactamente como en la imagen
    @pdf.text "SOLICITUD DE VACACIONES", size: 14, style: :bold, align: :center
    @pdf.move_down 15
    
    # Tabla 1: Información del empleado - formato exacto de la imagen
    employee_name = employee&.names ? "#{employee.surnames} #{employee.names}" : 'Guerra Ascanio Geminis Andreina'
    employee_id = employee&.identification_number || '28695744'
    
    # Primera fila: Apellidos y nombres / Cédula
    @pdf.table([
      [
        { content: "APELLIDOS Y NOMBRES DEL EMPLEADO", font_style: :bold, align: :center },
        { content: "CÉDULA DE IDENTIDAD", font_style: :bold, align: :center }
      ],
      [{ content: employee_name, align: :center }, { content: employee_id, align: :center }]
    ], width: @pdf.bounds.width, cell_style: { 
      size: 9, padding: [4, 6, 4, 6], border_width: 1, border_color: '000000'
    }) do
      rows(0).style(font_style: :bold)
    end
    
    @pdf.move_down 2
    
    # Segunda fila: Cargo, Dependencia, Fecha de ingreso - formato exacto de la imagen
    @pdf.table([
      [
        { content: "CARGO", font_style: :bold, align: :center },
        { content: employee&.position || "programador", align: :center },
        { content: "CODIGO #{employee&.code || '105'}", font_style: :bold, align: :center }
      ],
      [
        { content: "DEPENDENCIA", font_style: :bold, align: :center },
        { content: "ALMACEN", align: :center, colspan: 2 }
      ]
    ], width: @pdf.bounds.width, cell_style: { 
      size: 9, padding: [4, 6, 4, 6], border_width: 1, border_color: '000000'
    }) do
      rows(0).style(font_style: :bold)
      rows(1).style(font_style: :bold)
      columns(0).style(width: 80)   # CARGO más estrecho
      columns(1).style(width: 197)  # OPERADOR INTEGRAL - ancho específico
    end
    
    @pdf.move_down 2
    
    # Tabla unificada - formato exacto de la imagen (9 columnas)
    @pdf.table([
      [
        { content: "FECHA DE INGRESO", font_style: :bold, align: :center, colspan: 3 },
        { content: "PERÍODO DE DISFRUTE SOLICITADO", font_style: :bold, align: :center, colspan: 6 }
      ],
      [
        { content: "DIA", font_style: :bold, align: :center },
        { content: "MES", font_style: :bold, align: :center },
        { content: "AÑO", font_style: :bold, align: :center },
        { content: "CORRESPONDIENTE AL AÑO 2025", font_style: :bold, align: :center, colspan: 6 }
      ],
        [
          { content: hire_date.day.to_s.rjust(2, '0'), font_style: :bold, align: :center },
          { content: hire_date.month.to_s.rjust(2, '0'), font_style: :bold, align: :center },
          { content: hire_date.year.to_s, font_style: :bold, align: :center },
        { content: "DIAS A DISFRUTAR", font_style: :bold, align: :center },
        { content: "DIAS PENDIENTES", font_style: :bold, align: :center },
        { content: "DESDE", font_style: :bold, align: :center, colspan: 3 },
        { content: "HASTA", font_style: :bold, align: :center, colspan: 3 }
      ],
      [
        { content: "DIAS VENCIDOS", font_style: :bold, align: :center, colspan: 3 },
        { content: "", align: :center, borders: [] },
        { content: "", align: :center, borders: [] },
        { content: "DIA", font_style: :bold, align: :center },
        { content: "MES", font_style: :bold, align: :center },
        { content: "AÑO", font_style: :bold, align: :center },
        { content: "DIA", font_style: :bold, align: :center },
        { content: "MES", font_style: :bold, align: :center },
        { content: "AÑO", font_style: :bold, align: :center }
      ],
        [
          { content: (employee&.expired_vacations || 15).to_s, align: :center, colspan: 3, borders: [:left, :right, :bottom] },
          { content: (employee&.vacation_days || 15).to_s, align: :center, borders: [:left, :right, :bottom] },
          { content: "0", align: :center, borders: [:left, :right, :bottom] },
          { content: vacation_start.day.to_s.rjust(2, '0'), align: :center, borders: [:left, :right, :bottom] },
          { content: vacation_start.month.to_s.rjust(2, '0'), align: :center, borders: [:left, :right, :bottom] },
          { content: vacation_start.year.to_s, align: :center, borders: [:left, :right, :bottom] },
          { content: vacation_end.day.to_s.rjust(2, '0'), align: :center, borders: [:left, :right, :bottom] },
          { content: vacation_end.month.to_s.rjust(2, '0'), align: :center, borders: [:left, :right, :bottom] },
          { content: vacation_end.year.to_s, align: :center, borders: [:left, :right, :bottom] }
        ]
    ], width: @pdf.bounds.width, cell_style: { 
      size: 9, padding: [4, 6, 4, 6], border_width: 1, border_color: '000000'
    }) do
      rows(0).style(font_style: :bold)
      rows(1).style(font_style: :bold)
      rows(2).style(font_style: :bold)
      rows(3).style(font_style: :bold)
      # Columnas DIA, MES, AÑO para FECHA DE INGRESO (columnas 0, 1, 2)
      columns(0).style(width: 30)  # DIA
      columns(1).style(width: 30)  # MES
      columns(2).style(width: 40)  # AÑO
      # Columnas DIA, MES, AÑO para DESDE (columnas 5, 6, 7)
      columns(5).style(width: 30)  # DIA DESDE
      columns(6).style(width: 30)  # MES DESDE
      columns(7).style(width: 40)  # AÑO DESDE
      # Columnas DIA, MES, AÑO para HASTA (columnas 8, 9, 10)
      columns(8).style(width: 30)  # DIA HASTA
      columns(9).style(width: 30)  # MES HASTA
      columns(10).style(width: 40)  # AÑO HASTA
    end
    
    @pdf.move_down 5
    
    # Tabla de reincorporación efectiva del trabajador
    @pdf.table([
      [
        { content: "REINCORPORACIÓN EFECTIVA DEL TRABAJADOR", font_style: :bold, align: :center, colspan: 6 }
      ],
      [
        { content: "", align: :center, colspan: 3 },
        { content: "DIA", font_style: :bold, align: :center },
        { content: "MES", font_style: :bold, align: :center },
        { content: "AÑO", font_style: :bold, align: :center }
      ],
      [
        { content: "", align: :center, colspan: 3, borders: [:left, :right, :bottom] },
        { content: reincorporation_date.day.to_s.rjust(2, '0'), align: :center, borders: [:left, :right, :bottom] },
        { content: reincorporation_date.month.to_s.rjust(2, '0'), align: :center, borders: [:left, :right, :bottom] },
        { content: reincorporation_date.year.to_s, align: :center, borders: [:left, :right, :bottom] }
      ]
    ], width: @pdf.bounds.width, cell_style: { 
      size: 9, padding: [4, 6, 4, 6], border_width: 1, border_color: '000000'
    }) do
      rows(0).style(font_style: :bold)
      rows(1).style(font_style: :bold)
      # Distribuir el ancho para que tome todo el espacio disponible
      columns(0).style(width: 200)  # Parte de la celda vacía colspan 3
      columns(1).style(width: 200)  # Parte de la celda vacía colspan 3
      columns(2).style(width: 200)  # Parte de la celda vacía colspan 3
      columns(3).style(width: 80)   # DIA
      columns(4).style(width: 80)   # MES
      columns(5).style(width: 80)   # AÑO
    end
    
    @pdf.move_down 5
    
    # Tabla de días de vacaciones - formato exacto de la imagen
    @pdf.table([
      [
        { content: "DIAS HABILES", font_style: :bold, align: :center, colspan: 1 },
        { content: "DIAS PENDIENTES", font_style: :bold, align: :center, colspan: 1 },
        { content: "DESDE", font_style: :bold, align: :center, colspan: 1 },
        { content: "DIA", font_style: :bold, align: :center, colspan: 1 },
        { content: "MES", font_style: :bold, align: :center, colspan: 1 },
        { content: "AÑO", font_style: :bold, align: :center, colspan: 1 },
        { content: "HASTA", font_style: :bold, align: :center, colspan: 1 },
        { content: "DIA", font_style: :bold, align: :center, colspan: 1 },
        { content: "MES", font_style: :bold, align: :center, colspan: 1 },
        { content: "AÑO", font_style: :bold, align: :center, colspan: 1 }
      ],
      [
        { content: "15", align: :center, colspan: 1 },
        { content: "0", align: :center, colspan: 1 },
        { content: "", align: :center, colspan: 1 },
        { content: "15", align: :center, colspan: 1 },
        { content: "06", align: :center, colspan: 1 },
        { content: "2015", align: :center, colspan: 1 },
        { content: "", align: :center, colspan: 1 },
        { content: "30", align: :center, colspan: 1 },
        { content: "10", align: :center, colspan: 1 },
        { content: "2015", align: :center, colspan: 1 }
      ],
      [
        { content: "REINCORPORACIÓN EFECTIVA DEL TRABAJADOR", font_style: :bold, align: :center, colspan: 4 },
        { content: "DIA", font_style: :bold, align: :center, colspan: 1 },
        { content: "MES", font_style: :bold, align: :center, colspan: 1 },
        { content: "AÑO", font_style: :bold, align: :center, colspan: 1 },
        { content: "", align: :center, colspan: 3 }
      ],
      [
        { content: "", align: :center, colspan: 4 },
        { content: "08", align: :center, colspan: 1 },
        { content: "10", align: :center, colspan: 1 },
        { content: "2015", align: :center, colspan: 1 },
        { content: "", align: :center, colspan: 3 }
      ]
    ], width: @pdf.bounds.width, cell_style: { 
      size: 9, padding: [4, 6, 4, 6], border_width: 1, border_color: '000000'
    }) do
      rows(0).style(font_style: :bold)
      rows(2).style(font_style: :bold)
    end
    
    @pdf.move_down 10
    
    # Observaciones - formato exacto de la imagen
    @pdf.table([
      [
        { content: "OBSERVACIONES:", font_style: :bold, align: :center },
        { content: (employee&.vacation_notes || "SOLO PARA EFECTOS DE DISFRUTE"), align: :center }
      ]
    ], width: @pdf.bounds.width, cell_style: { 
      size: 9, padding: [4, 6, 4, 6], border_width: 1, border_color: '000000'
    }) do
      columns(0).style(font_style: :bold, width: 120)
    end
    
    @pdf.move_down 10
    
    # Sección de firmas - formato exacto de la imagen
    @pdf.table([
      [
        { content: "FIRMA DEL TRABAJADOR", font_style: :bold, align: :center, valign: :bottom },
        { content: "", align: :center },
        { content: "VERIFICACIÓN DE DATOS CONFORME", font_style: :bold, align: :center, valign: :bottom }
      ],
      [
        { content: "\n\n\n", height: 50 },
        { content: "", height: 50 },
        { content: "\n\n\n", height: 50 }
      ],
      [
        { content: "CONFORME", font_style: :bold, align: :center },
        { content: "", align: :center },
        { content: "GESTION HUMANA", font_style: :bold, align: :center }
      ],
      [
        { content: "JEFE INMEDIATO", font_style: :bold, align: :center },
        { content: "", align: :center },
        { content: "\n\n", height: 35 }
      ]
    ], width: @pdf.bounds.width, cell_style: { 
      size: 9, padding: [6, 10, 6, 10], border_width: 1, border_color: '000000'
    }) do
      rows(0).style(font_style: :bold)
      rows(2).style(font_style: :bold)
      rows(3).style(font_style: :bold)
    end
  end
end
