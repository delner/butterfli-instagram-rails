require 'spec_helper'

RSpec.describe Butterfli::Instagram::Rails::Subscription::TagController, type: :controller do
  routes { Butterfli::Instagram::Rails::Engine.routes }

  # Default examples
  it_behaves_like "an Instagram subscription controller", Butterfli::Instagram::Rails::Subscription::TagController, "tag"
end
