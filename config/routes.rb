Rails.application.routes.draw do
  devise_for :admins, path: 'admin', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'registro'
  }
  
  # Rutas administrativas
  namespace :admin do
    get "dashboard/index"
    root 'dashboard#index'
    get 'dashboard', to: 'dashboard#index'
    
    resources :employees do
      member do
        get :manage_accounts
        get :manage_sizes
        get :manage_cards
        get :manage_family
      end
    end
  end
  
  # Redireccionar root a login de admin
  root 'admin/dashboard#index'
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
