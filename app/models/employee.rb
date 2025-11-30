class Employee < ApplicationRecord
  # Associations
  has_many :payment_accounts, dependent: :destroy
  has_one :worker_size, dependent: :destroy
  has_one :party_card, dependent: :destroy
  has_one :psuv_card, dependent: :destroy
  has_many :family_members, dependent: :destroy
  has_many :attendances, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :payment_accounts, allow_destroy: true, reject_if: proc { |attributes| attributes['account_type'].blank? }
  accepts_nested_attributes_for :worker_size, allow_destroy: true
  accepts_nested_attributes_for :party_card, allow_destroy: true
  accepts_nested_attributes_for :psuv_card, allow_destroy: true
  accepts_nested_attributes_for :family_members, allow_destroy: true, reject_if: proc { |attributes| attributes['names'].blank? }

  # Validations
  validates :identification_number, presence: true, uniqueness: true
  validates :names, presence: true
  validates :surnames, presence: true
  validates :birth_date, presence: true
  validates :hire_date, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  
  def full_name
    "#{names} #{surnames}"
  end
  
  def age
    return nil unless birth_date
    
    today = Date.current
    age = today.year - birth_date.year
    age -= 1 if today < birth_date + age.years
    age
  end
  
  # Calcular años de antigüedad desde la fecha de ingreso
  # Retorna los años completos trabajados (0 para el primer año, 1 para el segundo, etc.)
  # Un año completo se cuenta solo cuando ha pasado MÁS de 1 año desde la fecha de ingreso
  # Ejemplo: Si ingresó el 09/07/2024 y la fecha es 09/07/2025, tiene 0 años completos (aún en el primer año)
  #          Si ingresó el 09/07/2024 y la fecha es 10/07/2025, tiene 1 año completo (ya en el segundo año)
  def years_of_service(as_of_date = Date.current)
    return 0 unless hire_date
    
    # Calcular la diferencia en años
    years = as_of_date.year - hire_date.year
    
    # Calcular la fecha de aniversario para este año
    anniversary_date = hire_date + years.years
    
    # Si la fecha actual es menor o igual a la fecha de aniversario, aún no ha cumplido ese año completo
    # Por ejemplo: si ingresó 09/07/2024 y hoy es 09/07/2025, anniversary_date = 09/07/2025
    # Como as_of_date (09/07/2025) <= anniversary_date (09/07/2025), aún no ha cumplido 1 año completo
    if as_of_date <= anniversary_date
      years -= 1
    end
    
    # Asegurar que no sea negativo
    [years, 0].max
  end
  
  # Calcular días de vacaciones según diferencia de años
  # Si la diferencia entre fecha actual y fecha de ingreso es:
  # - 1 año → 15 días
  # - 2 años → 16 días (15 + 1)
  # - 3 años → 17 días (15 + 2)
  # - Y así sucesivamente, sumando 1 día por cada año adicional
  def calculate_vacation_days(as_of_date = Date.current)
    return 15 unless hire_date # Si no tiene fecha de ingreso, retorna el mínimo
    
    # Calcular la diferencia de años directamente (año actual - año de ingreso)
    years_diff = as_of_date.year - hire_date.year
    
    # Asegurar que no sea negativo
    years_diff = [years_diff, 0].max
    
    # Calcular días según la diferencia de años:
    # Si years_diff = 1 → 15 días
    # Si years_diff = 2 → 16 días (15 + 1)
    # Si years_diff = 3 → 17 días (15 + 2)
    # Fórmula: 15 + (diferencia - 1), con mínimo de 15
    if years_diff <= 1
      15 # Diferencia de 0 o 1 año → 15 días
    else
      15 + (years_diff - 1) # Diferencia de 2+ años → 15 + (años - 1)
    end
  end
  
  # Calcular días vencidos de vacaciones
  # Los días vencidos son días que el empleado tenía derecho a tomar pero NO tomó
  # Si el empleado tomó todos los días solicitados, no hay días vencidos
  def calculate_expired_vacations
    return 0 unless vacation_date.present? && vacation_days.present?
    
    # Calcular cuántos días tenía derecho según su antigüedad
    days_entitled = calculate_vacation_days(vacation_date)
    
    # Si tomó todos los días a los que tenía derecho, no hay días vencidos
    if vacation_days >= days_entitled
      return 0
    end
    
    # Si tomó menos días de los que tenía derecho, calcular la diferencia
    vacation_end = vacation_date + vacation_days.days
    today = Date.current
    
    # Solo contar como vencidos si ya pasó el período de vacaciones
    if vacation_end < today
      days_not_taken = days_entitled - vacation_days
      days_not_taken
    else
      0
    end
  end
  
  # Verificar si está de vacaciones actualmente
  # Solo cuenta si las vacaciones están aprobadas
  def on_vacation_now?
    return false unless vacation_date.present? && vacation_days.present?
    return false unless vacation_approved? # Solo cuenta si están aprobadas
    
    today = Date.current
    vacation_end = vacation_date + vacation_days.days
    
    vacation_date <= today && today <= vacation_end
  end
  
  # Verificar si las vacaciones están vencidas
  def vacation_expired?
    return false unless vacation_date.present? && vacation_days.present?
    
    vacation_end = vacation_date + vacation_days.days
    Date.current > vacation_end
  end
  
  # Verificar si las vacaciones son futuras
  def vacation_upcoming?
    return false unless vacation_date.present?
    
    vacation_date > Date.current
  end
  
  # Callback para calcular fecha de vacaciones automáticamente si la fecha de ingreso es anterior
  before_save :calculate_vacation_date_for_current_year
  
  # Callback para actualizar días vencidos antes de guardar
  before_save :update_expired_vacations
  
  private
  
  def calculate_vacation_date_for_current_year
    # Solo calcular si hay fecha de ingreso y no hay fecha de vacaciones configurada
    return unless hire_date.present? && vacation_date.blank?
    
    current_year = Date.current.year
    hire_year = hire_date.year
    
    # Si la fecha de ingreso es anterior al año actual, calcular para el año actual
    if hire_year < current_year
      # Usar el mismo día y mes de la fecha de ingreso, pero del año actual
      # Siempre usar el año actual, incluso si la fecha ya pasó (para cargar datos históricos)
      vacation_date_current_year = Date.new(current_year, hire_date.month, hire_date.day)
      
      # SIEMPRE usar el año actual, sin importar si la fecha ya pasó
      self.vacation_date = vacation_date_current_year
      
      # Calcular los días de vacaciones basándose en la fecha de vacaciones calculada
      # Usar la fecha de vacaciones para calcular la antigüedad correcta
      self.vacation_days = calculate_vacation_days(vacation_date)
    end
  end
  
  def update_expired_vacations
    if vacation_date.present? && vacation_days.present?
      # Calcular días vencidos basándose en los días que tenía derecho vs los que tomó
      self.expired_vacations = calculate_expired_vacations
    elsif vacation_date.nil? || vacation_days.nil?
      self.expired_vacations = 0
    end
  end
end
