class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # Associations
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  # Validations
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :phone, length: { maximum: 20 }, allow_blank: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def has_role?(role_name)
    roles.where(name: role_name, active: true).exists?
  end

  def has_permission?(action, resource)
    permissions.where(action: action, resource: resource).exists?
  end

  def permissions
    Permission.joins(roles: :users).where(users: { id: id }, roles: { active: true })
  end

  def activate!
    update!(active: true)
  end

  def deactivate!
    update!(active: false)
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :account_inactive
  end
end
