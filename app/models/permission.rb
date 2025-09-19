class Permission < ApplicationRecord
  # Associations
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }, 
            length: { minimum: 2, maximum: 100 }
  validates :action, presence: true, length: { minimum: 2, maximum: 50 }
  validates :resource, presence: true, length: { minimum: 2, maximum: 50 }
  validates :description, length: { maximum: 500 }, allow_blank: true

  # Validation for unique action-resource combination
  validates_uniqueness_of :action, scope: :resource, 
                         message: "ya existe para este recurso"

  # Scopes
  scope :by_resource, ->(resource) { where(resource: resource) }
  scope :by_action, ->(action) { where(action: action) }

  # Instance methods
  def roles_count
    roles.count
  end

  def display_name
    "#{action_in_spanish} #{resource_in_spanish}"
  end

  def action_in_spanish
    case action
    when 'create'
      'Crear'
    when 'read'
      'Leer'
    when 'update'
      'Actualizar'
    when 'delete'
      'Eliminar'
    when 'manage'
      'Gestionar'
    else
      action.humanize
    end
  end

  def resource_in_spanish
    case resource
    when 'users'
      'Usuarios'
    when 'roles'
      'Roles'
    when 'permissions'
      'Permisos'
    when 'employees'
      'Empleados'
    when 'dashboard'
      'Panel'
    when 'reports'
      'Reportes'
    else
      resource.humanize
    end
  end

  # Class methods
  def self.default_actions
    %w[create read update delete manage]
  end

  def self.default_resources
    %w[users roles permissions employees dashboard reports]
  end

  def self.create_default_permissions
    default_actions.product(default_resources).each do |action, resource|
      find_or_create_by(action: action, resource: resource) do |permission|
        permission.name = "#{action}_#{resource}"
        permission.description = generate_description(action, resource)
      end
    end
  end

  def self.generate_description(action, resource)
    action_spanish = case action
    when 'create'
      'crear'
    when 'read'
      'ver y listar'
    when 'update'
      'modificar'
    when 'delete'
      'eliminar'
    when 'manage'
      'gestionar completamente'
    else
      action
    end

    resource_spanish = case resource
    when 'users'
      'usuarios'
    when 'roles'
      'roles'
    when 'permissions'
      'permisos'
    when 'employees'
      'empleados'
    when 'dashboard'
      'el panel de control'
    when 'reports'
      'reportes'
    else
      resource
    end

    "Permite #{action_spanish} #{resource_spanish}"
  end
end
