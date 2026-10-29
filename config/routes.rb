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

  # Collection full CRUD
  # create, bulk and destroy are front-end stubs for now (they redirect back).
  resources :comics, only: %i[index show new create destroy] do
    post :bulk, on: :collection # POST /comics/bulk -> comics#bulk
  end
  resources :series, only: :index
  get "gaps", to: "gaps#index", as: :gaps
  get "search", to: "search#index", as: :search
  resource :profile, only: :show

  # Static content
  get "help", to: "pages#help", as: :help
  get "terms", to: "pages#terms", as: :terms
  get "privacy", to: "pages#privacy", as: :privacy

  get "up" => "rails/health#show", as: :rails_health_check
end
