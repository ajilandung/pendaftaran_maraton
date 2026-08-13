Rails.application.routes.draw do
  root "categories#index"

  resources :registrations, only: [ :new, :create, :show ]

  get "status", to: "status#show"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  namespace :admin do
    resources :registrations, only: [ :index, :destroy ] do
      member do
        patch :mark_paid
        patch :mark_unpaid
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
