Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :doses, only: %i[show edit destroy]
  resources :cocktails do
    resources :doses, only: %i[index create new update]
  end
end
