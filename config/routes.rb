Rails.application.routes.draw do
  get 'people/index'
  get 'people/show'
  get 'documents/new'
  get 'documents/create'
  get 'documents/index'
  get 'documents/destroy'
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  resources :documents, only: [:create, :index] do
    resources :people, only: [:index, :show]
  end
  resources :documents, only: [:destroy]
   get 'test_particles', to: 'pages#test_particles'
end
