class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  # Validations
  validates :user_id, uniqueness: { scope: :role_id, 
                                   message: "ya tiene este rol asignado" }

  # Scopes
  scope :active_roles, -> { joins(:role).where(roles: { active: true }) }
end
