Rails.application.routes.draw do
  # Home
  root "pages#home"

  # Event details
  resources :events, only: [ :index ]

  # RSVP — search by name, pick your household, RSVP for everyone in it
  get "rsvp",        to: "rsvps#search", as: :rsvp
  get "rsvp/search", to: "rsvps#results", as: :rsvp_search
  resources :invite_groups, only: [ :show ], path: "rsvp" do
    member do
      get   :form
      patch :form, action: :submit
    end
  end

  # Static pages
  get "travel", to: "travel#index", as: :travel
  get "registry", to: "registry#index", as: :registry
  get "recommendations", to: "recommendations#index", as: :recommendations

  # Tiny homes — intentionally not linked from public nav; shared directly with guests
  get "weecasa", to: "pages#weecasa", as: :weecasa

  # Admin (intentionally not linked from public nav)
  namespace :admin, path: "manage" do
    resources :guests, only: [ :index, :edit, :update ]
    resources :invite_groups, only: [ :show, :edit, :update, :destroy ]
    resource :guest_import, only: [ :new, :create ]
    resources :events
    root to: "events#index"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
