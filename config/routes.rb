Guisso::Application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: 'omniauth_callbacks', sessions: 'sessions'}

  match 'openid/login'       => 'open_id#login',     via: [:get, :post]
  post  'openid/decision'    => 'open_id#decision'
  match 'openid'             => 'open_id#index',     via: [:get, :post]
  match 'openid/xrds'        => 'open_id#idp_xrds',  via: [:get, :post]
  match 'openid/:email'      => 'open_id#user_page', via: [:get, :post], email: /[^\/]+/
  match 'openid/:email/xrds' => 'open_id#user_xrds', via: [:get, :post], email: /[^\/]+/

  post 'oauth2/token', :to => proc { |env| Oauth2::TokenEndpoint.new.call(env) }

  resources :trusted_roots

  root to: 'trusted_roots#index'
end
