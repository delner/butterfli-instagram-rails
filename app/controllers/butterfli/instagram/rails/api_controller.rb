class Butterfli::Instagram::Rails::ApiController < Butterfli::Controller
  layout nil
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }

  protected
  def client
    @client ||= Butterfli.configuration.providers(:instagram).client
  end
end