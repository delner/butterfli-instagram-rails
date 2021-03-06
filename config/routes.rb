Butterfli::Instagram::Rails::Engine.routes.draw do
  namespace :instagram do
    namespace :subscription do
      namespace :geography do
        get 'callback', to: '/butterfli/instagram/rails/subscription/geography#setup'
        post 'callback', to: '/butterfli/instagram/rails/subscription/geography#callback'
      end
      namespace :location do
        get 'callback', to: '/butterfli/instagram/rails/subscription/location#setup'
        post 'callback', to: '/butterfli/instagram/rails/subscription/location#callback'
      end
      namespace :tag do
        get 'callback', to: '/butterfli/instagram/rails/subscription/tag#setup'
        post 'callback', to: '/butterfli/instagram/rails/subscription/tag#callback'
      end
    end
  end
end