# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Crear permisos por defecto
puts "🔐 Creando permisos del sistema..."
Permission.create_default_permissions
puts "✅ Permisos creados: #{Permission.count}"

# Crear roles por defecto
puts "\n👔 Creando roles del sistema..."

super_admin_role = Role.find_or_create_by!(name: "super_admin") do |role|
  role.description = "Administrador supremo con todos los permisos"
  role.active = true
end

admin_role = Role.find_or_create_by!(name: "admin") do |role|
  role.description = "Administrador del sistema con permisos de gestión"
  role.active = true
end

manager_role = Role.find_or_create_by!(name: "manager") do |role|
  role.description = "Gerente con permisos de supervisión"
  role.active = true
end

employee_role = Role.find_or_create_by!(name: "employee") do |role|
  role.description = "Empleado con permisos básicos"
  role.active = true
end

viewer_role = Role.find_or_create_by!(name: "viewer") do |role|
  role.description = "Solo lectura"
  role.active = true
end

puts "✅ Roles creados: #{Role.count}"

# Asignar permisos a roles
puts "\n⚙️ Asignando permisos a roles..."

# Super Admin - todos los permisos
super_admin_role.permissions = Permission.all

# Admin - casi todos los permisos excepto gestión de super admins
admin_permissions = Permission.where.not(resource: "super_admin")
admin_role.permissions = admin_permissions

# Manager - permisos de gestión de empleados y reportes
manager_permissions = Permission.where(
  action: %w[read update create],
  resource: %w[employees dashboard reports]
)
manager_role.permissions = manager_permissions

# Employee - solo lectura básica
employee_permissions = Permission.where(
  action: "read",
  resource: %w[dashboard employees]
)
employee_role.permissions = employee_permissions

# Viewer - solo lectura
viewer_permissions = Permission.where(action: "read")
viewer_role.permissions = viewer_permissions

puts "✅ Permisos asignados a roles"

# Crear usuarios del sistema
puts "\n👤 Creando usuarios del sistema..."

# Super Admin
super_admin = User.find_or_create_by!(email: "superadmin@rab.com") do |user|
  user.first_name = "Super"
  user.last_name = "Admin"
  user.password = "123456"
  user.password_confirmation = "123456"
  user.active = true
end
super_admin.roles << super_admin_role unless super_admin.roles.include?(super_admin_role)

# Admin del sistema
admin_user = User.find_or_create_by!(email: "admin@rab.com") do |user|
  user.first_name = "Admin"
  user.last_name = "Sistema"
  user.password = "123456"
  user.password_confirmation = "123456"
  user.active = true
end
admin_user.roles << admin_role unless admin_user.roles.include?(admin_role)

# Manager
manager_user = User.find_or_create_by!(email: "manager@rab.com") do |user|
  user.first_name = "Gerente"
  user.last_name = "Principal"
  user.password = "123456"
  user.password_confirmation = "123456"
  user.active = true
end
manager_user.roles << manager_role unless manager_user.roles.include?(manager_role)

puts "✅ Usuarios creados: #{User.count}"
puts "📧 Credenciales de acceso:"
puts "   - Super Admin: superadmin@rab.com / 123456"
puts "   - Admin: admin@rab.com / 123456"
puts "   - Manager: manager@rab.com / 123456"

# Crear administrador por defecto (mantener compatibilidad)
admin_email = "admin@rab.com"
admin_password = "123456"

unless Admin.exists?(email: admin_email)
  Admin.create!(
    email: admin_email,
    password: admin_password,
    password_confirmation: admin_password
  )
  puts "✅ Administrador (Admin model) creado para compatibilidad"
else
  puts "⚠️  El administrador (Admin model) ya existe"
end

# Crear empleados de prueba
puts "\n🧑‍💼 Creando empleados de prueba..."

employee1 = Employee.find_or_create_by!(identification_number: "12345678") do |emp|
  emp.names = "Juan Carlos"
  emp.surnames = "Pérez García"
  emp.birth_date = Date.new(1985, 3, 15)
  emp.hire_date = Date.new(2020, 1, 10)
  emp.home_address = "Av. Principal #123, Caracas"
  emp.vacation_date = Date.new(2024, 12, 15)
  emp.expired_vacations = 5
  emp.skills_abilities = "Programación, Liderazgo de equipos, Inglés avanzado"
end

employee2 = Employee.find_or_create_by!(identification_number: "87654321") do |emp|
  emp.names = "María Elena"
  emp.surnames = "González Rodríguez"
  emp.birth_date = Date.new(1990, 7, 22)
  emp.hire_date = Date.new(2021, 5, 20)
  emp.home_address = "Calle 5 #456, Valencia"
  emp.vacation_date = Date.new(2024, 11, 1)
  emp.expired_vacations = 0
  emp.skills_abilities = "Administración, Recursos Humanos, Contabilidad"
end

puts "✅ Empleados creados: #{Employee.count}"

# Crear cuentas de pago
puts "\n💳 Creando cuentas de pago..."

PaymentAccount.find_or_create_by!(employee: employee1, account_type: "bank") do |account|
  account.account_number = "01020123456789012345"
  account.bank_name = "Banco de Venezuela"
  account.is_primary = true
end

PaymentAccount.find_or_create_by!(employee: employee1, account_type: "mobile_payment") do |account|
  account.mobile_payment_number = "04141234567"
  account.is_primary = false
end

PaymentAccount.find_or_create_by!(employee: employee2, account_type: "bank") do |account|
  account.account_number = "01340987654321098765"
  account.bank_name = "Banesco"
  account.is_primary = true
end

puts "✅ Cuentas de pago creadas: #{PaymentAccount.count}"

# Crear tallas de trabajadores
puts "\n👕 Creando tallas de trabajadores..."

WorkerSize.find_or_create_by!(employee: employee1) do |size|
  size.shirt_size = "L"
  size.shoes_size = "42"
  size.pants_size = "34"
end

WorkerSize.find_or_create_by!(employee: employee2) do |size|
  size.shirt_size = "M"
  size.shoes_size = "38"
  size.pants_size = "30"
end

puts "✅ Tallas creadas: #{WorkerSize.count}"

# Crear carnets del partido
puts "\n🪪 Creando carnets del partido..."

PartyCard.find_or_create_by!(employee: employee1) do |card|
  card.code = "PSUV001"
  card.serial_number = "ABC123456"
end

puts "✅ Carnets del partido creados: #{PartyCard.count}"

# Crear carnets PSUV
puts "\n🔴 Creando carnets PSUV..."

PsuvCard.find_or_create_by!(employee: employee1) do |card|
  card.code = "PSUV2024001"
  card.serial_number = "PSV789012"
end

puts "✅ Carnets PSUV creados: #{PsuvCard.count}"

# Crear familiares
puts "\n👨‍👩‍👧‍👦 Creando carga familiar..."

FamilyMember.find_or_create_by!(employee: employee1, names: "Ana María") do |member|
  member.birth_date = Date.new(2010, 5, 12)
  member.education_level = "primary"
  member.relationship = "daughter"
end

FamilyMember.find_or_create_by!(employee: employee1, names: "Carlos José") do |member|
  member.birth_date = Date.new(2008, 9, 8)
  member.education_level = "secondary"
  member.relationship = "son"
end

FamilyMember.find_or_create_by!(employee: employee2, names: "Luis Miguel") do |member|
  member.birth_date = Date.new(2015, 2, 28)
  member.education_level = "preschool"
  member.relationship = "son"
end

puts "✅ Familiares creados: #{FamilyMember.count}"

puts "\n🎉 ¡Seeds completados exitosamente!"
puts "📊 Resumen:"
puts "   - Usuarios del sistema: #{User.count}"
puts "   - Roles: #{Role.count}"
puts "   - Permisos: #{Permission.count}"
puts "   - Administradores (compatibilidad): #{Admin.count}"
puts "   - Empleados: #{Employee.count}"
puts "   - Cuentas de pago: #{PaymentAccount.count}"
puts "   - Tallas: #{WorkerSize.count}"
puts "   - Carnets partido: #{PartyCard.count}"
puts "   - Carnets PSUV: #{PsuvCard.count}"
puts "   - Familiares: #{FamilyMember.count}"