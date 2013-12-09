Asciinema::Application.routes.draw do

  get "/browse" => "asciicasts#index", :as => :browse
  get "/browse/:category" => "asciicasts#index", :as => :category

  resources :asciicasts, :path => 'a' do
    member do
      get :raw
      get :example
    end
  end

  get "/~:nickname" => "users#show", :as => :profile

  get "/docs" => "docs#show", :page => 'getting-started', :as => :docs_index
  get "/docs/:page" => "docs#show", :as => :docs

  get "/auth/browser_id/callback" => "sessions#create"
  get "/auth/:provider/callback" => "account_merges#create"
  get "/auth/failure" => "sessions#failure"

  get "/login" => "sessions#new"
  get "/logout" => "sessions#destroy"

  get "/connect/:user_token" => "user_tokens#create"

  resource :user

  namespace :api do
    resources :asciicasts
  end

  root 'home#show'

  get '/about' => 'pages#show', page: :about, as: :about
  get '/privacy' => 'pages#show', page: :privacy, as: :privacy
  get '/tos' => 'pages#show', page: :tos, as: :tos
  get '/contributing' => 'pages#show', page: :contributing, as: :contributing
end
