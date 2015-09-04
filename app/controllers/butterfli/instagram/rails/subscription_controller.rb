class Butterfli::Instagram::Rails::SubscriptionController < Butterfli::Instagram::Rails::ApiController
  before_filter :validate_signature, except: [:setup]

  def setup
    verify_token = Butterfli.configuration.providers(:instagram).verify_token
    response = client.meet_challenge(params, verify_token)
    if response
      respond_to do |format|
        format.html { render text: response }
        format.json { render text: response }
        format.text { render text: response }
      end
    else
      render text: '{"message": "Invalid token."}', status: :unauthorized
    end
  end

  def self.subscriptions
    @subscriptions ||= {}
  end

  private
  def validate_signature
    is_valid = client.validate_update(request.body.string, request.headers)
    if is_valid.nil?
      render text: '{"message": "Missing signature."}', status: :unauthorized
    elsif is_valid == false
      render text: '{"message": "Invalid signature."}', status: :unauthorized
    end
  end
end