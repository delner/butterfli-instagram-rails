require 'spec_helper'

describe Butterfli::Instagram::Rails::ApiController do
  subject { Butterfli::Instagram::Rails::ApiController.new }

  context "when configured" do
    context "with a client ID and secret" do
      let(:client_id) { "client_id" }
      let(:client_secret) { "client_secret" }
      before { configure_for_instagram(client_id, client_secret) }
    end
  end
end