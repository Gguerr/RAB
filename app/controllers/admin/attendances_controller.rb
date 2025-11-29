class Admin::AttendancesController < ApplicationController
  include AdminAuthentication
  before_action :authenticate_admin!
  before_action :set_attendance, only: [:show, :edit, :update, :destroy]
  layout 'admin'

  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @employees = Employee.active.includes(:attendances)
    @attendances = Attendance.for_date(@date).includes(:employee).to_a

    # Crear registros de asistencia para empleados que no tienen registro para la fecha
    @employees.each do |employee|
      unless @attendances.any? { |attendance| attendance.employee_id == employee.id }
        @attendances << Attendance.new(employee: employee, attendance_date: @date, present: false)
      end
    end
  end

  def show
  end

  def new
    @attendance = Attendance.new
  end

  def create
    @attendance = Attendance.new(attendance_params)

    if @attendance.save
      redirect_to admin_attendances_path(date: @attendance.attendance_date), 
                  notice: 'Asistencia registrada exitosamente.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @attendance.update(attendance_params)
      redirect_to admin_attendances_path(date: @attendance.attendance_date), 
                  notice: 'Asistencia actualizada exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @attendance.destroy
    redirect_to admin_attendances_path(date: @attendance.attendance_date), 
                notice: 'Asistencia eliminada exitosamente.'
  end

  def bulk_update
    @date = Date.parse(params[:date])
    @action = params[:action_type]
    
    case @action
    when 'mark_all_present'
      Attendance.mark_all_present(@date)
      flash[:notice] = 'Todos los empleados marcados como presentes.'
    when 'mark_all_absent'
      Attendance.mark_all_absent(@date)
      flash[:notice] = 'Todos los empleados marcados como ausentes.'
    when 'individual'
      update_individual_attendances
    end
    
    redirect_to admin_attendances_path(date: @date)
  end

  def physical_form
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @plan_type = params[:plan_type] || 'daily' # 'daily' o 'weekly'
    @work_location = params[:work_location] # 'sala', 'galpon', o nil (todos)
    
    # Filtrar empleados por ubicación si se especifica
    @employees = Employee.active.order(:names, :surnames)
    @employees = @employees.where(work_location: @work_location) if @work_location.present?
    
    respond_to do |format|
      format.html
      format.pdf do
        filename = if @plan_type == 'weekly'
          start_date = @date.beginning_of_week
          end_date = @date.end_of_week
          "planilla_asistencia_semanal_#{start_date.strftime('%Y%m%d')}_#{end_date.strftime('%Y%m%d')}.pdf"
        else
          "planilla_asistencia_diaria_#{@date.strftime('%Y%m%d')}.pdf"
        end
        filename = "#{@work_location}_#{filename}" if @work_location.present?
        
        send_data generate_physical_form_pdf, 
                  filename: filename,
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  def report
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @employees = Employee.active.order(:names, :surnames)
    
    # Crear objetos de asistencia para todos los empleados activos
    @attendances = @employees.map do |employee|
      attendance = Attendance.find_by(employee: employee, attendance_date: @date)
      attendance || Attendance.new(employee: employee, attendance_date: @date, present: false)
    end
    
    @summary = Attendance.daily_summary(@date)

    respond_to do |format|
      format.html
      format.pdf do
        send_data generate_daily_report_pdf,
                  filename: "reporte_asistencia_diaria_#{@date.strftime('%Y%m%d')}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def monthly_report
    @year = params[:year].present? ? params[:year].to_i : Date.current.year
    @month = params[:month].present? ? params[:month].to_i : Date.current.month
    @attendances = Attendance.for_month(@year, @month).includes(:employee)
    @summary = Attendance.monthly_summary(@year, @month)

    respond_to do |format|
      format.html
      format.pdf do
        send_data generate_monthly_report_pdf,
                  filename: "reporte_asistencia_mensual_#{@year}_#{@month.to_s.rjust(2, '0')}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def yearly_report
    @year = params[:year].present? ? params[:year].to_i : Date.current.year
    @attendances = Attendance.for_year(@year).includes(:employee)
    @summary = Attendance.yearly_summary(@year)

    respond_to do |format|
      format.html
      format.pdf do
        send_data generate_yearly_report_pdf,
                  filename: "reporte_asistencia_anual_#{@year}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  private

  def set_attendance
    @attendance = Attendance.find(params[:id])
  end

  def generate_physical_form_pdf
    require 'prawn'
    
    pdf = Prawn::Document.new(page_size: 'A4', margin: [15, 15, 15, 15])
    
    if @plan_type == 'weekly'
      start_date = @date.beginning_of_week
      end_date = @date.end_of_week
      location_text = @work_location.present? ? " - #{@work_location.capitalize}" : ""
      title = "PLANILLA DE ASISTENCIA SEMANAL"
      subtitle = "#{start_date.strftime('%d/%m/%Y')} al #{end_date.strftime('%d/%m/%Y')}"
      draw_pdf_header(pdf, title, [subtitle])
      
      # Tabla para planilla semanal con columnas por día (cada día tiene [ ] y Hora)
      # Días de la semana en español
      dias_semana = {
        0 => 'DOM',
        1 => 'LUN',
        2 => 'MAR',
        3 => 'MIE',
        4 => 'JUE',
        5 => 'VIE',
        6 => 'SAB'
      }
      
      header_row = ["#", "Cédula", "Nombres", "Apellidos"]
      (start_date..end_date).each do |day|
        day_name = "#{dias_semana[day.wday]} #{day.strftime('%d/%m')}"
        header_row << day_name
        header_row << "Hora"
      end
      header_row << "Firma"
      
      table_data = [header_row]
      
      @employees.each_with_index do |employee, index|
        row = [
          (index + 1).to_s,
          employee.identification_number,
          employee.names,
          employee.surnames
        ]
        # Agregar casilla [ ] y campo de hora para cada día de la semana
        (start_date..end_date).each do
          row << "[ ]"
          row << "_____"
        end
        row << "________________"
        table_data << row
      end
      
      # Calcular anchos de columnas proporcionales
      total_width = pdf.bounds.width
      num_days = (start_date..end_date).count
      
      # Anchos fijos para columnas base
      fixed_widths = 25 + 60 + 80 + 80  # #, Cédula, Nombres, Apellidos
      
      # Anchos para días (cada día tiene 2 columnas: [ ] y Hora) + Firma
      remaining_width = total_width - fixed_widths
      num_day_cols = (num_days * 2) + 1  # (día + hora) * días + Firma
      
      # Distribuir el ancho restante proporcionalmente
      base_day_width = remaining_width / num_day_cols
      
      col_widths = []
      col_widths << 25  # #
      col_widths << 60  # Cédula
      col_widths << 80  # Nombres
      col_widths << 80  # Apellidos
      
      # Anchos para días (cada día tiene 2 columnas: [ ] y Hora)
      (start_date..end_date).each do
        col_widths << (base_day_width * 0.65).round(2)  # Columna del día [ ]
        col_widths << (base_day_width * 0.35).round(2)  # Columna de hora
      end
      col_widths << (base_day_width * 1.2).round(2)  # Firma (más ancha)
      
      # Ajustar para que sume exactamente el ancho total
      total_calculated = col_widths.sum
      if total_calculated != total_width
        diff = total_width - total_calculated
        col_widths[-1] += diff  # Ajustar la última columna (Firma)
      end
      
      pdf.table(table_data, header: true, width: pdf.bounds.width, column_widths: col_widths) do
        row(0).font_style = :bold
        row(0).background_color = 'E0E0E0'
        cells.borders = [:left, :right, :top, :bottom]
        cells.border_color = '000000'
        cells.border_width = 0.5
        
        # Fuente legible
        cells.font_size = 8
        row(0).font_size = 7
        
        # Padding adecuado
        cells.padding = [4, 3, 4, 3]
        row(0).padding = [5, 3, 5, 3]
        
        # Alineación
        cells.valign = :center
        cells.align = :center
        
        # Columnas de texto (nombres, apellidos) alineadas a la izquierda
        columns(2).align = :left
        columns(3).align = :left
        columns(2).padding_left = 5
        columns(3).padding_left = 5
        
        # Ajustar altura de filas
        rows(1..-1).height = 25
        row(0).height = 30
      end
    else
      location_text = @work_location.present? ? " - #{@work_location.capitalize}" : ""
      title = "PLANILLA DE ASISTENCIA DIARIA"
      draw_pdf_header(pdf, title, [@date.strftime('%d/%m/%Y')])
      
      # Tabla para planilla diaria
      table_data = [["#", "Cédula", "Nombres", "Apellidos", "Presente", "Hora", "Firma"]]
      
      @employees.each_with_index do |employee, index|
        table_data << [
          (index + 1).to_s,
          employee.identification_number,
          employee.names,
          employee.surnames,
          "[ ]",
          "_____",
          "________________"
        ]
      end
      
      # Anchos proporcionales para planilla diaria
      total_width = pdf.bounds.width
      col_widths = [
        30,   # #
        80,   # Cédula
        120,  # Nombres
        120,  # Apellidos
        50,   # Presente
        60,   # Hora
        total_width - 460  # Firma (el resto)
      ]
      
      pdf.table(table_data, header: true, width: pdf.bounds.width, column_widths: col_widths) do
        row(0).font_style = :bold
        row(0).background_color = 'E0E0E0'
        cells.borders = [:left, :right, :top, :bottom]
        cells.border_color = '000000'
        cells.border_width = 0.5
        
        # Fuente legible
        cells.font_size = 9
        row(0).font_size = 8
        
        # Padding adecuado
        cells.padding = [5, 4, 5, 4]
        row(0).padding = [6, 4, 6, 4]
        
        # Alineación
        cells.valign = :center
        cells.align = :center
        
        # Columnas de texto alineadas a la izquierda
        columns(2).align = :left
        columns(3).align = :left
        columns(2).padding_left = 6
        columns(3).padding_left = 6
        
        # Ajustar altura de filas
        rows(1..-1).height = 30
        row(0).height = 35
      end
    end
    
    # Espacio final
    pdf.move_down 10
    
    pdf.render
  end

  def generate_daily_report_pdf
    require 'prawn'
    require 'prawn/table'

    pdf = Prawn::Document.new(page_size: 'A4', margin: [20, 20, 20, 20])
    draw_pdf_header(pdf, 'REPORTE DIARIO DE ASISTENCIA', ["Fecha: #{@date.strftime('%d/%m/%Y')}"])

    table_data = [["Cédula", "Nombres", "Apellidos", "Presente", "Observaciones"]]
    @attendances.each do |attendance|
      table_data << [
        attendance.employee.identification_number,
        attendance.employee.names,
        attendance.employee.surnames,
        attendance.present? ? "Sí" : "No",
        attendance.notes.to_s
      ]
    end
    pdf.table(table_data, header: true, width: pdf.bounds.width)


    pdf.render
  end

  def generate_monthly_report_pdf
    require 'prawn'
    require 'prawn/table'

    pdf = Prawn::Document.new(page_size: 'A4', margin: [20, 20, 20, 20])
    draw_pdf_header(pdf, 'REPORTE MENSUAL DE ASISTENCIA', ["Periodo: #{@year}-#{@month.to_s.rjust(2, '0')}"])

    table_data = [["Fecha", "Empleado", "Presente"]]
    @attendances.each do |attendance|
      table_data << [attendance.attendance_date.strftime('%d/%m/%Y'),
                     "#{attendance.employee.names} #{attendance.employee.surnames}",
                     attendance.present? ? "Sí" : "No"]
    end
    pdf.table(table_data, header: true, width: pdf.bounds.width)

    pdf.move_down 10
    pdf.text "Resumen mensual", style: :bold
    pdf.text "Días contabilizados: #{@summary[:days]}"
    pdf.text "Total registros: #{@attendances.count}"

    pdf.render
  end

  def generate_yearly_report_pdf
    require 'prawn'
    require 'prawn/table'

    pdf = Prawn::Document.new(page_size: 'A4', margin: [20, 20, 20, 20])
    draw_pdf_header(pdf, 'REPORTE ANUAL DE ASISTENCIA', ["Año: #{@year}"])

    # Obtener todos los empleados activos
    @employees = Employee.active.order(:surnames, :names)
    
    # Nombres de meses en español
    meses_espanol = {
      1 => 'Enero', 2 => 'Febrero', 3 => 'Marzo', 4 => 'Abril',
      5 => 'Mayo', 6 => 'Junio', 7 => 'Julio', 8 => 'Agosto',
      9 => 'Septiembre', 10 => 'Octubre', 11 => 'Noviembre', 12 => 'Diciembre'
    }

    # Generar reporte mes por mes
    1.upto(12) do |month|
      # Título del mes
      pdf.start_new_page unless month == 1
      pdf.text "#{meses_espanol[month]} #{@year}", size: 14, style: :bold, align: :center
      pdf.move_down 10

      # Obtener asistencias del mes
      month_attendances = @attendances.select { |a| a.attendance_date.month == month }
      attendance_by_employee = month_attendances.group_by(&:employee_id)

      # Crear tabla para el mes
      table_data = [["#", "Cédula", "Nombre Completo", "Días Presentes", "Días Ausentes", "Total Días"]]
      
      @employees.each_with_index do |employee, index|
        employee_attendances = attendance_by_employee[employee.id] || []
        present_count = employee_attendances.count { |a| a.present? }
        absent_count = employee_attendances.count { |a| !a.present? }
        total_days = employee_attendances.count
        
        # Si no hay registros, mostrar como "Sin registros"
        if total_days == 0
          present_count = "-"
          absent_count = "-"
          total_days = "Sin registros"
        end

        table_data << [
          (index + 1).to_s,
          employee.identification_number,
          "#{employee.names} #{employee.surnames}",
          present_count.to_s,
          absent_count.to_s,
          total_days.to_s
        ]
      end

      # Calcular anchos de columnas proporcionales
      total_width = pdf.bounds.width
      # Anchos fijos más pequeños para dejar más espacio al nombre
      fixed_widths = 25 + 70 + 60 + 60 + 60  # Suma de anchos fijos
      name_width = [total_width - fixed_widths, 150].max  # Ancho mínimo de 150 para nombre
      
      col_widths = [
        25,         # #
        70,         # Cédula
        name_width, # Nombre Completo (el resto)
        60,         # Días Presentes
        60,         # Días Ausentes
        60          # Total Días
      ]
      
      # Ajustar si la suma excede el ancho disponible
      sum_widths = col_widths.sum
      if sum_widths > total_width
        ratio = total_width.to_f / sum_widths
        col_widths = col_widths.map { |w| (w * ratio).round }
      end

      pdf.table(table_data, header: true, width: total_width, column_widths: col_widths) do
        row(0).font_style = :bold
        cells.borders = [:left, :right, :top, :bottom]
        cells.border_color = '000000'
        cells.border_width = 0.5
        cells.font_size = 7
        row(0).font_size = 8
        cells.padding = [3, 2, 3, 2]
        row(0).padding = [4, 2, 4, 2]
        cells.valign = :center
        cells.align = :center
        columns(2).align = :left  # Nombre alineado a la izquierda
        columns(2).padding_left = 4
      end

      # Resumen del mes
      pdf.move_down 10
      month_present = month_attendances.count { |a| a.present? }
      month_absent = month_attendances.count { |a| !a.present? }
      month_total = month_attendances.count
      month_rate = month_total > 0 ? (month_present.to_f / month_total * 100).round(2) : 0

      pdf.text "Resumen del mes: #{month_present} días presentes, #{month_absent} días ausentes, #{month_total} días registrados. Tasa de asistencia: #{month_rate}%", 
               size: 9, style: :italic
      
      pdf.move_down 15 unless month == 12
    end

    # Resumen anual al final
    pdf.start_new_page
    pdf.text "RESUMEN ANUAL", size: 14, style: :bold, align: :center
    pdf.move_down 10

    summary_data = [["Mes", "Días Presentes", "Días Ausentes", "Total Registros", "% Asistencia"]]
    
    1.upto(12) do |month|
      month_attendances = @attendances.select { |a| a.attendance_date.month == month }
      month_present = month_attendances.count { |a| a.present? }
      month_absent = month_attendances.count { |a| !a.present? }
      month_total = month_attendances.count
      month_rate = month_total > 0 ? (month_present.to_f / month_total * 100).round(2) : 0

      summary_data << [
        meses_espanol[month],
        month_present.to_s,
        month_absent.to_s,
        month_total.to_s,
        "#{month_rate}%"
      ]
    end

    # Totales
    total_present = @attendances.count { |a| a.present? }
    total_absent = @attendances.count { |a| !a.present? }
    total_registros = @attendances.count
    total_rate = total_registros > 0 ? (total_present.to_f / total_registros * 100).round(2) : 0

    summary_data << [
      "TOTAL ANUAL",
      total_present.to_s,
      total_absent.to_s,
      total_registros.to_s,
      "#{total_rate}%"
    ]

    pdf.table(summary_data, header: true, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(-1).font_style = :bold
      cells.borders = [:left, :right, :top, :bottom]
      cells.border_color = '000000'
      cells.border_width = 0.5
      cells.font_size = 9
      row(0).font_size = 10
      cells.padding = [5, 4, 5, 4]
      cells.valign = :center
      cells.align = :center
    end

    pdf.render
  end

  # Encabezado común para PDFs con estilo institucional similar al layout HTML
  def draw_pdf_header(pdf, title, info_lines = [])
    dark_text = '333333'

    # Banner institucional completo si existe
    begin
      header_path = Rails.root.join('app/assets/images/encabezado.png')
      if File.exist?(header_path)
        pdf.image header_path.to_s, width: pdf.bounds.width, position: :center
        pdf.move_down 8
      end
    rescue StandardError => e
      # ignorar si no hay encabezado
      Rails.logger.debug "No se pudo cargar el encabezado: #{e.message}"
    end

    pdf.fill_color dark_text
    pdf.text title, align: :center, size: 16, style: :bold
    pdf.move_down 5

    info_lines.each do |line|
      pdf.text line, size: 10, align: :center
    end
    pdf.move_down 8

    # Línea divisoria
    pdf.stroke_color '000000'
    pdf.stroke_horizontal_line 0, pdf.bounds.width, line_width: 1
    pdf.move_down 12
    pdf.fill_color '000000'
  end

  def attendance_params
    params.require(:attendance).permit(:employee_id, :attendance_date, :present, :signature, :notes)
  end

  def update_individual_attendances
    if params[:attendances].present?
      params[:attendances].each do |employee_id, attendance_data|
        employee = Employee.find(employee_id)
        attendance = Attendance.find_or_initialize_by(employee: employee, attendance_date: @date)
        attendance.present = attendance_data[:present] == '1'
        attendance.notes = attendance_data[:notes] if attendance_data[:notes].present?
        attendance.save
      end
      flash[:notice] = 'Asistencias individuales actualizadas exitosamente.'
    end
  end
end


