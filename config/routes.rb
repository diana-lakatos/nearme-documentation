DesksnearMe::Application.routes.draw do

  resources :workplaces do
    resources :photos
    resources :bookings, :controller => "workplaces/bookings" do
      post :confirm
      post :reject
    end
  end

  match '/auth/:provider/callback' => 'authentications#create'
  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'sessions' }
  
  resources :bookings, :only => [:index, :destroy]

  match "/dashboard", :to => "dashboard#index", :as => :dashboard

  match "/search", :to => "search#index", :as => :search

  resources :authentications

  root :to => "public#index"

end
