Rails.application.routes.draw do

  mount JogTracker::API => '/'

  root :to => 'main#index'
  match '(*all)', to: 'main#index', via: :all
end
