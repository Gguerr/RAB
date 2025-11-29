module AdminAuthentication
  extend ActiveSupport::Concern

  private

  def authenticate_admin!
    # Si ya hay un admin autenticado (modelo Admin), permitir acceso
    return if defined?(current_admin) && current_admin.present?
    
    # Si hay un usuario autenticado (modelo User) y está activo, permitir acceso
    if defined?(current_user) && current_user.present?
      if current_user.active?
        return
      else
        redirect_to new_admin_session_path, alert: 'Tu cuenta no está activa. Contacta al administrador.'
        return
      end
    end
    
    # Si no hay ninguna autenticación válida, redirigir al login
    redirect_to new_admin_session_path, alert: 'Debes iniciar sesión para continuar.'
  end

  def current_admin_or_user
    return current_admin if defined?(current_admin) && current_admin.present?
    return current_user if defined?(current_user) && current_user.present? && current_user.active?
    nil
  end
end

