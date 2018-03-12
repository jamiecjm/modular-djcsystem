require 'subdomain'
require 'host'
Rails.application.routes.draw do
	constraints(Subdomain) do
	  devise_for :users, ActiveAdmin::Devise.config
	  ActiveAdmin.routes(self)
	  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

	  root 'dashboard#index'
	  get '*path' => redirect('/')
	end

	constraints(Host) do
		root 'pages#main'
		get '*path' => redirect('/')
	end

end
