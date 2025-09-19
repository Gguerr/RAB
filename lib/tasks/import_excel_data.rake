namespace :data do
  desc "Importar datos del archivo Excel HIJOS R A ESTUDIANDO 2025"
  task import_excel: :environment do
    require 'roo'
    
    puts "🔄 Iniciando importación de datos del Excel..."
    
    begin
      excel = Roo::Spreadsheet.open('HIJOS R A ESTUDIANDO 2025.xlsx')
      sheet = excel.sheet(0)
      
      puts "📊 Archivo cargado exitosamente"
      puts "📋 Total de filas: #{sheet.last_row}"
      
      # Comenzar desde la fila 7 (primera fila de datos)
      current_employee = nil
      employee_counter = 0
      children_counter = 0
      
      (7..sheet.last_row).each do |row|
        # Leer datos de la fila
        employee_number = sheet.cell(row, 1)&.to_s&.strip
        employee_name = sheet.cell(row, 2)&.to_s&.strip
        employee_ci = sheet.cell(row, 3)&.to_s&.strip
        child_name = sheet.cell(row, 4)&.to_s&.strip
        is_male = sheet.cell(row, 5)&.to_s&.strip == '1'
        male_age = sheet.cell(row, 6)&.to_s&.strip
        is_female = sheet.cell(row, 7)&.to_s&.strip == '1'
        female_age = sheet.cell(row, 8)&.to_s&.strip
        education_level = sheet.cell(row, 9)&.to_s&.strip
        
        # Si hay número de empleado, es un nuevo empleado
        if employee_number.present? && employee_number != ''
          # Buscar o crear empleado
          current_employee = Employee.find_or_create_by(identification_number: employee_ci) do |emp|
            names_and_surnames = employee_name.split(' ')
            emp.names = names_and_surnames[0..1].join(' ')
            emp.surnames = names_and_surnames[2..-1]&.join(' ') || ''
            emp.hire_date = Date.current - rand(1..10).years
            emp.active = true
          end
          employee_counter += 1
          puts "👤 Empleado #{employee_counter}: #{current_employee.names} #{current_employee.surnames}"
        end
        
        # Agregar hijo si hay datos del niño
        if current_employee && child_name.present?
          # Determinar género y edad
          gender = is_male ? 'masculino' : 'femenino'
          age = is_male ? male_age.to_i : female_age.to_i
          birth_date = Date.current - age.years
          
          # Mapear nivel educativo
          mapped_education = map_education_from_excel(education_level)
          
          # Crear o actualizar hijo
          child = current_employee.family_members.find_or_create_by(names: child_name) do |fm|
            fm.birth_date = birth_date
            fm.gender = gender
            fm.education_level = mapped_education
          end
          
          children_counter += 1
          puts "  👶 Hijo #{children_counter}: #{child.names} (#{gender}, #{age} años, #{mapped_education})"
        end
      end
      
      puts "\n✅ Importación completada exitosamente!"
      puts "📊 Estadísticas:"
      puts "   👥 Empleados importados: #{employee_counter}"
      puts "   👶 Hijos importados: #{children_counter}"
      puts "   📋 Total empleados en BD: #{Employee.count}"
      puts "   👨‍👩‍👧‍👦 Total hijos en BD: #{FamilyMember.count}"
      
    rescue => e
      puts "❌ Error durante la importación: #{e.message}"
      puts e.backtrace.first(5).join("\n")
    end
  end
  
  private
  
  def map_education_from_excel(education_text)
    return 'preescolar' if education_text.blank?
    
    case education_text.upcase.strip
    when 'MATERNAL'
      'preescolar'
    when /\d+ER NIVEL/, /\d+DO NIVEL/, /\d+ER NIVEL/
      'preescolar'
    when /\d+ER GRADO/, /\d+DO GRADO/, /\d+TO GRADO/, /\d+TO GRADO/
      'primaria'
    when /\d+ER AÑO/, /\d+DO AÑO/, /\d+TO AÑO/
      'secundaria'
    when 'UNIVERSITARIO'
      'universitario'
    when 'TÉCNICO', 'TECNICO'
      'tecnico'
    when 'POSTGRADO'
      'postgrado'
    else
      'preescolar'
    end
  end
end
