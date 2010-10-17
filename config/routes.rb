DesksnearMe::Application.routes.draw do

  resources :workplaces do
    resources :photos
    resources :bookings, :controller => "workplaces/bookings"
  end

  match '/auth/:provider/callback' => 'authentications#create'
  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'sessions' }
  
  resources :bookings, :only => [:index, :destroy]

  match "/dashboard", :to => "dashboard#index", :as => :dashboard

  scope "/coming_soon", :as => :coming_soon do
    match "stop" => "coming_soon#stop", :as => :start
    match "start" => "coming_soon#start", :as => :stop
  end

  match "/search", :to => "search#index", :as => :search

  resources :authentications

  root :to => "public#index"

end
