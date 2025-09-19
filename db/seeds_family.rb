# Datos de ejemplo basados en el Excel HIJOS R A ESTUDIANDO 2025

puts "🔄 Creando datos de ejemplo de empleados y sus hijos..."

# Limpiar datos existentes de family_members
FamilyMember.destroy_all

# Empleado 1: PEDRO J. AÑEZ
employee1 = Employee.find_or_create_by(identification_number: "26813793") do |emp|
  emp.names = "PEDRO J."
  emp.surnames = "AÑEZ"
  emp.hire_date = Date.current - 5.years
  emp.active = true
end

# Hijos de Pedro Añez
employee1.family_members.create!([
  {
    names: "OSMARY AÑEZ CONTRERAS",
    birth_date: Date.current - 2.years,
    gender: "femenino",
    education_level: "preescolar"
  },
  {
    names: "PAOLA AÑEZ CONTRERAS",
    birth_date: Date.current - 5.years,
    gender: "femenino", 
    education_level: "preescolar"
  },
  {
    names: "DIEGO CONTRERAS",
    birth_date: Date.current - 9.years,
    gender: "masculino",
    education_level: "primaria"
  },
  {
    names: "NICOOL CONTRERAS",
    birth_date: Date.current - 8.years,
    gender: "femenino",
    education_level: "primaria"
  }
])

# Empleado 2: JOSE JORDÁN
employee2 = Employee.find_or_create_by(identification_number: "10973270") do |emp|
  emp.names = "JOSE"
  emp.surnames = "JORDÁN"
  emp.hire_date = Date.current - 7.years
  emp.active = true
end

employee2.family_members.create!([
  {
    names: "EDYMAR JORDAN",
    birth_date: Date.current - 5.years,
    gender: "femenino",
    education_level: "primaria"
  }
])

# Empleado 3: OLYMAR MARIN
employee3 = Employee.find_or_create_by(identification_number: "21155742") do |emp|
  emp.names = "OLYMAR"
  emp.surnames = "MARIN"
  emp.hire_date = Date.current - 3.years
  emp.active = true
end

employee3.family_members.create!([
  {
    names: "SANTIAGO MEDINA MARIN",
    birth_date: Date.current - 9.years,
    gender: "masculino",
    education_level: "primaria"
  }
])

# Empleado 4: JOSENNYS CHIRINO
employee4 = Employee.find_or_create_by(identification_number: "27005478") do |emp|
  emp.names = "JOSENNYS"
  emp.surnames = "CHIRINO"
  emp.hire_date = Date.current - 4.years
  emp.active = true
end

employee4.family_members.create!([
  {
    names: "JHOSSUAN CHIRINO",
    birth_date: Date.current - 4.years,
    gender: "masculino",
    education_level: "preescolar"
  },
  {
    names: "ANTHONELLA CHIRINO",
    birth_date: Date.current - 7.years,
    gender: "femenino",
    education_level: "primaria"
  },
  {
    names: "ALONDRA GUTIERREZ CH",
    birth_date: Date.current - 2.years,
    gender: "femenino",
    education_level: "preescolar"
  },
  {
    names: "LIAN GUTIERREZ CH",
    birth_date: Date.current - 1.year,
    gender: "masculino",
    education_level: "preescolar"
  }
])

# Empleado 5: PAOLA LUQUEZ
employee5 = Employee.find_or_create_by(identification_number: "20797932") do |emp|
  emp.names = "PAOLA"
  emp.surnames = "LUQUEZ"
  emp.hire_date = Date.current - 6.years
  emp.active = true
end

employee5.family_members.create!([
  {
    names: "LUCIA HERNANDEZ L",
    birth_date: Date.current - 9.years,
    gender: "femenino",
    education_level: "primaria"
  },
  {
    names: "LUCIANA HERNANDEZ L",
    birth_date: Date.current - 8.years,
    gender: "femenino",
    education_level: "primaria"
  },
  {
    names: "ANGELES LLAMOZAS LUQUEZ",
    birth_date: Date.current - 15.years,
    gender: "femenino",
    education_level: "secundaria"
  },
  {
    names: "LEONEXY LLAMOZAS LUQUEZ",
    birth_date: Date.current - 17.years,
    gender: "femenino",
    education_level: "universitario"
  }
])

puts "✅ Datos de ejemplo creados exitosamente!"
puts "📊 Estadísticas:"
puts "   👥 Total empleados: #{Employee.count}"
puts "   👶 Total hijos: #{FamilyMember.count}"
puts "   👦 Hijos masculinos: #{FamilyMember.where(gender: 'masculino').count}"
puts "   👧 Hijas femeninas: #{FamilyMember.where(gender: 'femenino').count}"

