class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission

  # Validations
  validates :role_id, uniqueness: { scope: :permission_id, 
                                   message: "ya tiene este permiso asignado" }
end
