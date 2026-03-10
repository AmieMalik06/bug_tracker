Rails.application.routes.draw do
  devise_for :users

  resources :projects do
    resources :bugs
    member do
      get :assign_users
      patch :update_users
    end
  end

  get "dashboard", to: "dashboard#index", as: :dashboard

  devise_scope :user do
    root to: "devise/sessions#new"
  end
end
