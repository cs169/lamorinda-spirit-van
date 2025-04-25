# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  namespace :admin do
    resources :users, only: [:index, :edit, :update, :destroy] do
      collection do
        delete :destroy_unassigned
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "drivers#index"

  # blazer - data reporting
  authenticate :user, ->(user) { user.admin? } do
    mount Blazer::Engine, at: "blazer", as: "blazer"
  end

  resources :feedbacks
  resources :passengers

  resources :rides do
    collection do
      get "filter"
      get "filter_results"
    end
  end

  resources :shifts do
    collection do
      get "read_only"
      post "fill_from_template"
      post "clear_month"
    end
    member do
      get "feedback"
    end
  end

  resources :shift_templates, only: [:new, :create, :edit, :update, :destroy]

  resources :drivers do
    member do
      get "all_shifts"
      get "today"
    end
  end
end
