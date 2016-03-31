# frozen_string_literal: true
Rails.application.routes.draw do
  get 'monitors/lb'

  api_version(module: 'V1', path: { value: 'v1' }) do
    resources :whq_ministries, only: [:index]
  end
end
