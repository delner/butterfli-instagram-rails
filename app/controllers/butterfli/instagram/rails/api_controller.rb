class Butterfli::Instagram::Rails::ApiController < Butterfli::Controller
  layout nil
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }

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

  protected
  def client
    @client ||= Butterfli.configuration.providers(:instagram).client
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