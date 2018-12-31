# frozen_string_literal: true
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'monitors/lb'

  api_version(module: 'V1', path: { value: 'v1' }) do
    resources :countries, only: [:index]
    resources :languages, only: [:index]
    resources :ministries, only: [:index]
    resources :people, only: [:index, :show, :create, :update, :destroy]
    resource :user, only: [:show]
  end
end
