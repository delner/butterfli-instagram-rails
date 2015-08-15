require 'spec_helper'

describe Butterfli::Instagram::Rails::ApiController do
  subject { Butterfli::Instagram::Rails::ApiController.new }

  context "when configured" do
    context "with a client ID and secret" do
      let(:client_id) { "client_id" }
      let(:client_secret) { "client_secret" }
      before { configure_for_instagram(client_id, client_secret) }
      
      describe "#client" do
        subject { super().client }
        it { expect(subject).to be_a_kind_of(Instagram::Client) }
        it { expect(subject.client_id).to eq(client_id) }
        it { expect(subject.client_secret).to eq(client_secret) }
      end
    end
  end
end