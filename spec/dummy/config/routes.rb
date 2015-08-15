Dummy::Application.routes.draw do
  mount Butterfli::Instagram::Rails::Engine => "/"
end
