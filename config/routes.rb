Guisso::Application.routes.draw do
  mount InsteddTelemetry::Engine => '/instedd_telemetry'
  devise_for :users, controllers: {
    omniauth_callbacks: 'omniauth_callbacks',
    sessions: 'sessions',
    registrations: 'registrations',
    passwords: 'passwords'
  }

  match 'openid/login'       => 'open_id#login',     via: [:get, :post]
  post  'openid/decision'    => 'open_id#decision'
  match 'openid'             => 'open_id#index',     via: [:get, :post]
  match 'openid/xrds'        => 'open_id#idp_xrds',  via: [:get, :post]
  match 'openid/:email'      => 'open_id#user_page', via: [:get, :post], email: /[^\/]+/
  match 'openid/:email/xrds' => 'open_id#user_xrds', via: [:get, :post], email: /[^\/]+/

  post 'oauth2/token', to: proc { |env| Oauth2::TokenEndpoint.new.call(env) }
  get 'oauth2/trusted_token' => 'oauth2#trusted_token'
  get 'oauth2/authorize' => 'oauth2#authorize'
  post 'oauth2/create_authorization' => 'oauth2#create_authorization', as: :create_authorization

  get 'basic/check' => 'basic#check'
  get 'home' => 'home#index'

  resources :trusted_roots
  resources :applications
  resources :access_tokens, only: [:index, :destroy]

  root to: 'trusted_roots#index'
end
