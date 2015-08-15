Butterfli::Instagram::Rails::Engine.routes.draw do
  namespace :instagram do
    namespace :subscription do
      namespace :geography do
        get 'callback', to: '/butterfli/instagram/rails/subscription/geography#setup'
        post 'callback', to: '/butterfli/instagram/rails/subscription/geography#callback'
      end
    end
  end
end