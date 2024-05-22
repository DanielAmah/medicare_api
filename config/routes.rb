Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users, only: %i[create index show destroy]
  resource :users, only: [] do
    post 'create_doctor', on: :collection
  end
  post 'login', to: 'sessions#create'
  resource :dashboards, only: [] do
    get 'statistics', on: :collection
    get 'earnings', on: :collection
  end

  resource :patients, only: [] do
    get 'recent', on: :collection
    get 'patient_dashboard_cards', on: :collection
    get 'index', on: :collection
  end
  resources :patients, only: %i[show destroy create]
  resource :transactions, only: [] do
    get 'recent', on: :collection
    get 'summary', on: :collection
  end
  resource :appointments, only: [] do
    get 'total', on: :collection
    get 'index', on: :collection
    get 'today', on: :collection
  end
  resources :appointments, only: %i[create]
  resources :invoices, only: %i[index]
  resources :services, only: %i[index]
end
