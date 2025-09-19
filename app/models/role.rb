class Role < ApplicationRecord
  # Associations
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }, 
            length: { minimum: 2, maximum: 50 }
  validates :description, length: { maximum: 500 }, allow_blank: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Instance methods
  def users_count
    users.count
  end

  def permissions_count
    permissions.count
  end

  def has_permission?(action, resource)
    permissions.where(action: action, resource: resource).exists?
  end

  def activate!
    update!(active: true)
  end

  def deactivate!
    update!(active: false)
  end

  # Class methods
  def self.default_roles
    %w[super_admin admin manager employee viewer]
  end
end
