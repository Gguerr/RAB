class Admin::UsersController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :activate, :deactivate, :manage_roles, :update_roles]

  def index
    @users = User.includes(:roles).order(:last_name, :first_name)
    @users = @users.where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?", 
                         "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
    
    case params[:status]
    when 'active'
      @users = @users.where(active: true)
    when 'inactive'
      @users = @users.where(active: false)
    end
  end

  def show
    @user_roles = @user.roles.includes(:permissions)
  end

  def new
    @user = User.new
    @roles = Role.active.order(:name)
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      assign_roles if role_ids.present?
      redirect_to admin_user_path(@user), notice: 'Usuario creado exitosamente.'
    else
      @roles = Role.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @roles = Role.active.order(:name)
    @user_role_ids = @user.role_ids
  end

  def update
    if @user.update(user_params)
      assign_roles if role_ids.present?
      redirect_to admin_user_path(@user), notice: 'Usuario actualizado exitosamente.'
    else
      @roles = Role.active.order(:name)
      @user_role_ids = @user.role_ids
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      redirect_to admin_users_path, notice: 'Usuario eliminado exitosamente.'
    else
      redirect_to admin_users_path, alert: 'No se pudo eliminar el usuario.'
    end
  end

  def activate
    @user.activate!
    redirect_to admin_users_path, notice: 'Usuario activado exitosamente.'
  end

  def deactivate
    @user.deactivate!
    redirect_to admin_users_path, notice: 'Usuario desactivado exitosamente.'
  end

  def manage_roles
    @roles = Role.active.order(:name)
    @user_role_ids = @user.role_ids
  end

  def update_roles
    @user.role_ids = role_ids
    redirect_to admin_user_path(@user), notice: 'Roles actualizados exitosamente.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :active, :password, :password_confirmation)
  end

  def role_ids
    params[:user][:role_ids]&.reject(&:blank?) || []
  end

  def assign_roles
    @user.role_ids = role_ids
  end
end
