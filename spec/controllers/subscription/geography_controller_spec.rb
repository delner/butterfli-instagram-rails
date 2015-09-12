require 'spec_helper'

RSpec.describe Butterfli::Instagram::Rails::Subscription::GeographyController, type: :controller do
  routes { Butterfli::Instagram::Rails::Engine.routes }

  # Configure the Instagram client...
  before do
    configure_for_instagram
    Butterfli.configuration.writer :syndicate
  end

  # Default examples
  it_behaves_like "an Instagram subscription controller", Butterfli::Instagram::Rails::Subscription::GeographyController, "geography"
end
