class Admins::SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    # Primero intentar autenticar como Admin
    admin = Admin.find_by(email: params[:admin][:email])
    
    if admin&.valid_password?(params[:admin][:password])
      # Autenticar como Admin normalmente
      super
      # Después de la autenticación, recargar el admin para obtener los valores actualizados
      admin.reload
      # Si existe un User con el mismo email, sincronizar su último acceso
      user = User.find_by(email: admin.email)
      if user && admin.last_sign_in_at
        user.update_columns(
          last_sign_in_at: admin.last_sign_in_at,
          current_sign_in_at: admin.current_sign_in_at,
          sign_in_count: admin.sign_in_count,
          last_sign_in_ip: admin.last_sign_in_ip,
          current_sign_in_ip: admin.current_sign_in_ip
        )
      end
    else
      # Si no es Admin, buscar en Users - permitir a cualquier usuario activo
      user = User.find_by(email: params[:admin][:email])
      
      if user&.valid_password?(params[:admin][:password])
        if user.active?
          # Iniciar sesión como usuario y permitir acceso al panel admin
          # Manejar remember_me si está presente
          remember_me = params[:admin][:remember_me] == "1" || params[:admin][:remember_me] == true
          sign_in(user, scope: :user, remember_me: remember_me)
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

