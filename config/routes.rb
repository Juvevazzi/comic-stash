Rails.application.routes.draw do
  # Logged in home page
  get "dashboard", to: "dashboard#show", as: :dashboard
  root to: redirect("/dashboard")

  # Account accessed
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"
  get "forgot-password", to: "passwords#new", as: :forgot_password
  post "forgot-password", to: "passwords#create"
  get "forgot-password/sent", to: "passwords#sent", as: :password_reset_sent
  delete "logout", to: "sessions#destroy", as: :logout

  resources :passwords, param: :token, only: %i[edit update]

  # Collection full CRUD
  # create, bulk and destroy are front-end stubs for now (they redirect back).
  resources :comics, only: %i[index show new create update destroy] do
    post :bulk, on: :collection # POST /comics/bulk -> comics#bulk
  end
  resources :series, only: :index
  get "gaps", to: "gaps#index", as: :gaps
  get "search", to: "search#index", as: :search

  # Your profile: details (update), delete account (destroy), preferences and the CSV export.
  resource :profile, only: %i[show update destroy] do
    resource :preferences, only: :update # PATCH /profile/preferences
    resource :export, only: :show # GET /profile/export.csv
  end

  # Static content
  get "help", to: "pages#help", as: :help
  get "terms", to: "pages#terms", as: :terms
  get "privacy", to: "pages#privacy", as: :privacy

  # Branded error pages (config.exceptions_app in config/application.rb).
  # via: :all because a failed POST or PATCH arrives here with its own method.
  %w[404 422 500].each do |code|
    match code, to: "errors#show", defaults: { code: code }, via: :all
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
