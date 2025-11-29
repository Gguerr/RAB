class Admins::SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    # Primero intentar autenticar como Admin
    admin = Admin.find_by(email: params[:admin][:email])
    
    if admin&.valid_password?(params[:admin][:password])
      # Autenticar como Admin normalmente
      super
    else
      # Si no es Admin, buscar en Users - permitir a cualquier usuario activo
      user = User.find_by(email: params[:admin][:email])
      
      if user&.valid_password?(params[:admin][:password])
        if user.active?
          # Iniciar sesión como usuario y permitir acceso al panel admin
          sign_in(user, scope: :user)
          flash[:notice] = I18n.t('devise.sessions.signed_in')
          redirect_to admin_root_path
        else
          flash[:alert] = I18n.t('devise.failure.inactive')
          redirect_to new_admin_session_path
        end
      else
        # Credenciales inválidas - usar el comportamiento por defecto de Devise
        self.resource = Admin.new
        flash[:alert] = I18n.t('devise.failure.invalid')
        render :new, status: :unprocessable_entity
      end
    end
  end
end

