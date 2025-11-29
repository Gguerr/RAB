class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Protect from CSRF attacks
  protect_from_forgery with: :exception

  # Redirigir después del login según el tipo de usuario
  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      # Todos los usuarios van al panel administrativo
      admin_root_path
    elsif resource.is_a?(Admin)
      admin_root_path
    else
      super
    end
  end
end
