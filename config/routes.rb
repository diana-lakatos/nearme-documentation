DesksnearMe::Application.routes.draw do
  resources :workplaces do
    resources :photos
  end

  scope "/coming_soon", :as => :coming_soon do
    match "stop" => "coming_soon#stop", :as => :start
    match "start" => "coming_soon#start", :as => :stop
  end

  match "/search", :to => "search#index", :as => :search

  root :to => "public#index"

end
