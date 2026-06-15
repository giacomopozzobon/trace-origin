# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    resources :orders, only: [:create] do
      collection do
        post :import
      end
    end
  end

  namespace :admin do
    resources :orders, only: [:create]
  end
end
