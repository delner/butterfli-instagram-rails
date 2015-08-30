class Butterfli::Instagram::Rails::ApiController < Butterfli::Controller
  layout nil
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }

  before_action :is_signed?

  def setup
    response = client.meet_challenge(params) { |token| true }
    respond_to do |format|
      format.html { render text: response }
      format.json { render text: response }
      format.text { render text: response }
    end
  end

  protected
  def client
    @client ||= Butterfli.configuration.providers(:instagram).client
  end

  private
  def is_signed?
    client.validate_update(request.body, headers)
  end
end