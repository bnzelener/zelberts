Rails.application.routes.draw do
  # Home
  root "pages#home"

  # Event details
  resources :events, only: [ :index ]

  # RSVP
  resources :rsvps, only: [ :new, :create, :show ]

  # Static pages
  get "travel", to: "travel#index", as: :travel

  # Admin
  namespace :admin do
    resources :guests, only: [ :index ]
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
