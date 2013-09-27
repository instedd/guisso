Guisso::Application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: 'omniauth_callbacks'}


  match 'openid/login'       => 'open_id#login',     via: [:get, :post]
  post  'openid/decision'    => 'open_id#decision'
  match 'openid'             => 'open_id#index',     via: [:get, :post]
  match 'openid/xrds'        => 'open_id#idp_xrds',  via: [:get, :post]
  match 'openid/:email'      => 'open_id#user_page', via: [:get, :post], email: /[^\/]+/
  match 'openid/:email/xrds' => 'open_id#user_xrds', via: [:get, :post], email: /[^\/]+/

  root to: 'home#index'
end
