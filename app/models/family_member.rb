class FamilyMember < ApplicationRecord
  belongs_to :employee

  # Validations
  validates :names, presence: true
  validates :birth_date, presence: true
  validates :gender, presence: true, inclusion: { 
    in: %w[masculino femenino],
    message: "debe ser masculino o femenino"
  }
  validates :education_level, presence: true, inclusion: { 
    in: %w[maternal preescolar primaria secundaria bachillerato tecnico universitario postgrado],
    message: "debe ser un nivel educativo válido"
  }
  
  # validates :specific_grade, presence: true, if: :requires_specific_grade_validation?

  # Scopes - Ahora todos son hijos, solo diferenciamos por género
  scope :masculinos, -> { where(gender: 'masculino') }
  scope :femeninos, -> { where(gender: 'femenino') }
  scope :by_age, -> { order(:birth_date) }
  
  # Métodos de clase para opciones en español
  def self.gender_options
    [
      ['Masculino', 'masculino'],
      ['Femenino', 'femenino']
    ]
  end
  
  def self.education_level_options
    [
      ['Maternal', 'maternal'],
      ['Preescolar', 'preescolar'],
      ['Primaria', 'primaria'], 
      ['Secundaria', 'secundaria'],
      ['Bachillerato', 'bachillerato'],
      ['Técnico', 'tecnico'],
      ['Universitario', 'universitario'],
      ['Postgrado', 'postgrado']
    ]
  end
  
  def self.primary_grade_options
    [
      ['1er Grado', '1er_grado'],
      ['2do Grado', '2do_grado'],
      ['3er Grado', '3er_grado'],
      ['4to Grado', '4to_grado'],
      ['5to Grado', '5to_grado'],
      ['6to Grado', '6to_grado']
    ]
  end
  
  def self.secondary_grade_options
    [
      ['1er Año', '1er_año'],
      ['2do Año', '2do_año'],
      ['3er Año', '3er_año'],
      ['4to Año', '4to_año'],
      ['5to Año', '5to_año']
    ]
  end
  
  def age
    return nil unless birth_date
    
    today = Date.current
    age = today.year - birth_date.year
    age -= 1 if today < birth_date + age.years
    age
  end
  
  # Método para obtener el género en formato legible
  def gender_humanized
    case gender
    when 'masculino'
      'Masculino'
    when 'femenino'
      'Femenino'
    else
      gender&.capitalize
    end
  end
  
  # Método para obtener el nivel educativo en formato legible
  def education_level_humanized
    case education_level
    when 'maternal'
      'Maternal'
    when 'preescolar'
      'Preescolar'
    when 'primaria'
      'Primaria'
    when 'secundaria'
      'Secundaria'
    when 'bachillerato'
      'Bachillerato'
    when 'tecnico'
      'Técnico'
    when 'universitario'
      'Universitario'
    when 'postgrado'
      'Postgrado'
    else
      education_level&.capitalize
    end
  end
  
  # Método para determinar si necesita grado específico
  def requires_specific_grade?
    %w[primaria secundaria].include?(education_level)
  end
  
  # Método para validación más flexible
  def requires_specific_grade_validation?
    # Solo requerir si seleccionó primaria o secundaria Y ya hay datos en el formulario
    requires_specific_grade? && !new_record?
  end
  
  # Método para obtener el grado completo para mostrar
  def full_education_level
    if requires_specific_grade? && specific_grade.present?
      case education_level
      when 'primaria'
        specific_grade.gsub('_', ' ').upcase
      when 'secundaria'
        specific_grade.gsub('_', ' ').upcase
      else
        education_level_humanized
      end
    else
      education_level_humanized
    end
  end
  
  # Método para obtener el grado específico humanizado
  def specific_grade_humanized
    return nil unless specific_grade.present?
    specific_grade.gsub('_', ' ').split.map(&:capitalize).join(' ')
  end
end
