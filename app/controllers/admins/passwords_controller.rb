class Admins::PasswordsController < Devise::PasswordsController
  # POST /resource/password
  def create
    email = params[:admin][:email] if params[:admin]
    email ||= resource_params[:email]
    
    # Primero buscar como Admin (igual que el controlador de sesiones)
    admin = Admin.find_by(email: email) if email.present?
    
    if admin
      # Si encontramos el admin, usar el comportamiento por defecto de Devise
      params[:admin][:email] = admin.email if params[:admin]
      super
    else
      # Si no es Admin, buscar en Users (igual que el controlador de sesiones)
      user = User.find_by(email: email) if email.present?
      
      if user
        # Si encontramos el usuario, enviar instrucciones de recuperación usando el modelo User
        user.send_reset_password_instructions
        self.resource = user
        yield resource if block_given?
        
        if successfully_sent?(resource)
          respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
        else
          respond_with(resource)
        end
      else
        # Si no encontramos ni admin ni usuario, mostrar error
        self.resource = Admin.new(email: email)
        resource.errors.add(:email, :not_found)
        respond_with(resource, status: :unprocessable_entity)
      end
    end
  end

  protected

  def after_resetting_password_path_for(resource)
    new_admin_session_path
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    new_admin_session_path
  end
end

