class FamilyMember < ApplicationRecord
  belongs_to :employee

  # Validations
  validates :names, presence: true
  validates :birth_date, presence: true
  validates :relationship, presence: true, inclusion: { 
    in: %w[son daughter spouse father mother brother sister] 
  }
  validates :education_level, presence: true, inclusion: { 
    in: %w[preschool primary secondary high_school technical university graduate] 
  }

  # Scopes
  scope :children, -> { where(relationship: %w[son daughter]) }
  scope :by_age, -> { order(:birth_date) }
  
  def age
    return nil unless birth_date
    
    today = Date.current
    age = today.year - birth_date.year
    age -= 1 if today < birth_date + age.years
    age
  end
end
