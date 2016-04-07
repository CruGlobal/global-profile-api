# frozen_string_literal: true
Rails.application.routes.draw do
  get 'monitors/lb'

  api_version(module: 'V1', path: { value: 'v1' }) do
    resources :countries, only: [:index]
    resources :languages, only: [:index]
    resources :ministries, only: [:index]
    resources :people, only: [:index, :show, :create, :update, :destroy]
  end
end
