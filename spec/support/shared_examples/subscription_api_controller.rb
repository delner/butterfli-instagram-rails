# For testing realtime APIs
RSpec.shared_examples "an Instagram subscription controller" do |controller_class, short_name|
  # Configure the Instagram client...
  before do
    configure_for_instagram
    Butterfli.configuration.writer :syndicate
  end
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
      Butterfli.cache.clear
    end

    context "when called with a typical Instagram callback request" do
      context "while configured for synchronous processing" do
        let(:req) { request_fixture("subscription/#{short_name}/callback/default") }
        subject { execute_fixtured_action(:callback, req) }
        it do
          VCR.use_cassette("subscription/#{short_name}/callback/default") do
            expect(target).to receive(:share)
            expect(subject).to have_http_status(:ok)
            expect(subject.body).to be_empty
          end
        end
      end
      context "while configured for asynchronous processing" do
        before do
          configure_for_instagram
          Butterfli.configuration.writer :syndicate
          Butterfli.configuration.processor :monolith
        end
        let(:processor) { double('processor') }
        let(:req) { request_fixture("subscription/#{short_name}/callback/default") }
        subject { execute_fixtured_action(:callback, req) }
        before(:each) do
          # Sanity check that we aren't changing the argument list with our stub
          expect(Butterfli::Processing::Processor.new(nil)).to respond_to(:enqueue).with(2).arguments
          allow(processor).to receive(:enqueue)
          Butterfli.processor = processor
        end
        after(:each) { Butterfli.processor = nil }
        it do
          VCR.use_cassette("subscription/#{short_name}/callback/default") do
            expect(processor).to receive(:enqueue).with(:stories, Butterfli::Instagram::Job)
            expect(subject).to have_http_status(:ok)
            expect(subject.body).to be_empty
          end
        end
      end
      context "while configured with a jobs policy" do
        before(:each) do
          configure_for_instagram do |provider|
            provider.policy :jobs do |jobs|
              jobs.throttle short_name.to_sym do |t|
                t.matching obj_id: obj_id
                t.limit 1
                t.per_seconds 60
              end
            end
          end
          Butterfli.configuration.writer :syndicate
        end
        after(:each) { Butterfli::Instagram::Regulation.policies = nil }
        let(:req) { request_fixture("subscription/#{short_name}/callback/default") }
        let(:obj_id) { JSON.parse(req['body']['string']).first['object_id'] }
        subject { execute_fixtured_action(:callback, req) }
        context "which permits the job" do
          it do
            VCR.use_cassette("subscription/#{short_name}/callback/default") do
              expect(target).to receive(:share)
              expect(subject).to have_http_status(:ok)
              expect(subject.body).to be_empty
            end
          end
        end
        context "which doesn't permit the job" do
          before(:each) { Butterfli::Instagram::Data::Cache.for.subscription(short_name.to_sym, obj_id).field(:last_time_queued).write(Time.now - 30) }
          it do
            VCR.use_cassette("subscription/#{short_name}/callback/default") do
              expect(target).to_not receive(:share)
              expect(subject).to have_http_status(:ok)
              expect(subject.body).to be_empty
            end
          end
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