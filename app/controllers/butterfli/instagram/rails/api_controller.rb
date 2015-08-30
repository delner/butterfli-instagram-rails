class Butterfli::Instagram::Rails::ApiController < Butterfli::Controller
  layout nil
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }

  before_action :is_signed?

  protected
  def client
    @client ||= Butterfli.configuration.providers(:instagram).client
  end

  private
  def is_signed?
    client.validate_update(request.body, headers)
  end
end