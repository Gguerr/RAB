class Admin::RolesController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_role, only: [:show, :edit, :update, :destroy, :activate, :deactivate, :manage_permissions, :update_permissions]

  def index
    @roles = Role.includes(:users, :permissions).order(:name)
    @roles = @roles.where("name ILIKE ? OR description ILIKE ?", 
                         "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
    
    case params[:status]
    when 'active'
      @roles = @roles.where(active: true)
    when 'inactive'
      @roles = @roles.where(active: false)
    end
  end

  def show
    @role_permissions = @role.permissions.order(:resource, :action)
    @role_users = @role.users.active.order(:last_name, :first_name)
  end

  def new
    @role = Role.new
    @permissions = Permission.order(:resource, :action)
    @permission_groups = @permissions.group_by(&:resource)
  end

  def create
    @role = Role.new(role_params)
    
    if @role.save
      assign_permissions if permission_ids.present?
      redirect_to admin_role_path(@role), notice: 'Rol creado exitosamente.'
    else
      @permissions = Permission.order(:resource, :action)
      @permission_groups = @permissions.group_by(&:resource)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @permissions = Permission.order(:resource, :action)
    @permission_groups = @permissions.group_by(&:resource)
    @role_permission_ids = @role.permission_ids
  end

  def update
    if @role.update(role_params)
      assign_permissions if permission_ids.present?
      redirect_to admin_role_path(@role), notice: 'Rol actualizado exitosamente.'
    else
      @permissions = Permission.order(:resource, :action)
      @permission_groups = @permissions.group_by(&:resource)
      @role_permission_ids = @role.permission_ids
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @role.users.any?
      redirect_to admin_roles_path, alert: 'No se puede eliminar un rol que tiene usuarios asignados.'
    elsif @role.destroy
      redirect_to admin_roles_path, notice: 'Rol eliminado exitosamente.'
    else
      redirect_to admin_roles_path, alert: 'No se pudo eliminar el rol.'
    end
  end

  def activate
    @role.activate!
    redirect_to admin_roles_path, notice: 'Rol activado exitosamente.'
  end

  def deactivate
    @role.deactivate!
    redirect_to admin_roles_path, notice: 'Rol desactivado exitosamente.'
  end

  def manage_permissions
    @permissions = Permission.order(:resource, :action)
    @permission_groups = @permissions.group_by(&:resource)
    @role_permission_ids = @role.permission_ids
  end

  def update_permissions
    @role.permission_ids = permission_ids
    redirect_to admin_role_path(@role), notice: 'Permisos actualizados exitosamente.'
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name, :description, :active)
  end

  def permission_ids
    params[:role][:permission_ids]&.reject(&:blank?) || []
  end

  def assign_permissions
    @role.permission_ids = permission_ids
  end
end
