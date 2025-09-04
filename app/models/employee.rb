class Employee < ApplicationRecord
  # Associations
  has_many :payment_accounts, dependent: :destroy
  has_one :worker_size, dependent: :destroy
  has_one :party_card, dependent: :destroy
  has_one :psuv_card, dependent: :destroy
  has_many :family_members, dependent: :destroy

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
end
