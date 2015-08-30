require 'spec_helper'

RSpec.describe Butterfli::Instagram::Rails::Subscription::LocationController, type: :controller do
  routes { Butterfli::Instagram::Rails::Engine.routes }

  # Configure the Instagram client...
  before { configure_for_instagram }

  # Define expected behaviors for each endpoint:
  describe "#setup" do
    context "when called with a typical Instagram setup request" do
      let(:req) { request_fixture("subscription/location/setup/default") }
      subject { execute_fixtured_action(:setup, req) }
      it do
        expect(subject).to have_http_status(:ok)
        expect(subject.body).to eq(req['query_string']['hub.challenge'])
      end
    end
  end
  describe "#callback" do
    let(:target) { double("callback_target") }

    before(:each) { Butterfli.subscribe { |stories| target.share(stories) } }
    after(:each) { Butterfli.unsubscribe_all }

    context "when called with a typical Instagram callback request" do
      let(:req) { request_fixture("subscription/location/callback/default") }
      subject { execute_fixtured_action(:callback, req) }

      it do
        VCR.use_cassette("subscription/location/callback/default") do
          expect(target).to receive(:share)
          expect(subject).to have_http_status(:ok)
          expect(JSON.parse(subject.body).length).to eq(2)
        end
      end
    end
  end
end
