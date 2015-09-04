# For testing realtime APIs
RSpec.shared_examples "an Instagram subscription controller" do |controller_class, short_name|
  # Define expected behaviors for each endpoint:
  describe "#setup" do
    context "when called with a typical Instagram setup request" do
      let(:req) { request_fixture("subscription/#{short_name}/setup/default") }
      subject { execute_fixtured_action(:setup, req) }
      it do
        expect(subject).to have_http_status(:ok)
        expect(subject.body).to eq(req['query_string']['hub.challenge'])
      end
    end
    context "when called with an unauthorized setup request" do
      # This request is missing the 'verify_token' parameter
      let(:req) { request_fixture("subscription/#{short_name}/setup/unauthorized_missing_token") }
      subject { execute_fixtured_action(:setup, req) }
      it do
        expect(subject).to have_http_status(:unauthorized)
        expect(JSON.parse(subject.body)['message']).to eq("Invalid token.")
      end
    end
  end
  describe "#callback" do
    let(:target) { double("callback_target") }

    before(:each) { Butterfli.subscribe { |stories| target.share(stories) } }
    after(:each) do
      Butterfli.unsubscribe_all
      controller_class.subscriptions.clear
    end

    context "when called with a typical Instagram callback request" do
      let(:req) { request_fixture("subscription/#{short_name}/callback/default") }
      subject { execute_fixtured_action(:callback, req) }
      it do
        VCR.use_cassette("subscription/#{short_name}/callback/default") do
          expect(target).to receive(:share)
          expect(subject).to have_http_status(:ok)
          expect(JSON.parse(subject.body).length).to eq(2)
        end
      end
    end
    context "when called with an unauthorized callback request" do
      context "missing a signature" do
        let(:req) { request_fixture("subscription/#{short_name}/callback/unauthorized_missing_signature") }
        subject { execute_fixtured_action(:callback, req) }
        it do
          expect(target).to_not receive(:share)
          expect(subject).to have_http_status(:unauthorized)
          expect(JSON.parse(subject.body)['message']).to eq("Missing signature.")
        end
      end
      context "with a bad signature" do
        let(:req) { request_fixture("subscription/#{short_name}/callback/unauthorized_bad_signature") }
        subject { execute_fixtured_action(:callback, req) }
        it do
          expect(target).to_not receive(:share)
          expect(subject).to have_http_status(:unauthorized)
          expect(JSON.parse(subject.body)['message']).to eq("Invalid signature.")
        end
      end
    end
  end
end