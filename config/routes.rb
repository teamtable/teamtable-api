Rails.application.routes.draw do
  devise_for :users,
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'sessions',
               registrations: 'registrations',
               confirmations: 'confirmations',
               passwords: 'passwords',
               password: 'password',
               users: 'users'
             },
             :defaults => { :format => :json }
  
  resources :projects
  resources :memberships, only: [:index, :create, :show, :destroy]
  get 'current-project', to: 'projects#current', as: :current_project
  get 'projects/:id/members', to: 'projects#members', as: :project_members
  get 'projects/:id/tags', to: 'projects#tags', as: :project_tags
  get 'projects/:id/lists', to: 'projects#lists', as: :project_lists

  resources :lists
  resources :list_memberships, only: [:index, :create, :show, :destroy]
  get 'lists/:id/members', to: 'lists#members', as: :list_members
  get 'lists/:id/tags', to: 'lists#tags', as: :list_tags
  get 'lists/:id/cards', to: 'lists#cards', as: :list_cards
  patch 'lists/:id/position', to: 'lists#update_position', as: :list_update_position

  patch 'list-positions', to: 'list_positions#update_all', as: :list_positions_update_all

  resources :cards
  resources :assignments, only: [:create, :update, :destroy]
  get 'cards/:id/assigned-users', to: 'cards#assigned_users', as: :card_assigned_users
  get 'cards/:id/doing-users', to: 'cards#doing_users', as: :card_doing_users
  get 'cards/:id/tags', to: 'cards#tags', as: :card_tags

  patch 'card-positions', to: 'card_positions#update_all', as: :card_positions_update_all

  resources :tags
  resources :attachments, only: [:create, :destroy]
  get 'tags/:id/cards', to: 'tags#cards', as: :tag_cards

  get 'users/:id/created-cards', to: 'users#created_cards', as: :user_created_cards
  get 'users/:id/assigned-cards', to: 'users#assigned_cards', as: :user_assigned_cards
  get 'users/:id/doing-cards', to: 'users#doing_cards', as: :user_doing_cards
  get 'users/:id/completed-cards', to: 'users#completed_cards', as: :user_completed_cards
end
