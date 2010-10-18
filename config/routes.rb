DesksnearMe::Application.routes.draw do

  resources :workplaces do
    resources :photos
    resources :bookings, :only => [:new, :create, :update], :controller => "workplaces/bookings" do
      post :confirm
      post :reject
    end
  end

  match '/auth/:provider/callback' => 'authentications#create'
  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'sessions' }

  resources :bookings, :only => :update

  match "/dashboard", :to => "dashboard#index", :as => :dashboard

  match "/search", :to => "search#index", :as => :search
  match "/search/results", :to => "search#query", :as => :search_results

  resources :authentications

  root :to => "public#index"

end
