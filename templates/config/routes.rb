Rails.application.routes.draw do
  resources :translations, only: [:index, :create]
  root to: "translations#index"
end
