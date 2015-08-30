class Butterfli::Instagram::Rails::ApiController < Butterfli::Controller
  before_action :is_signed?

  def client
    @client ||= Butterfli.configuration.providers(:instagram).client
  end

  private
  def is_signed?
    client.validate_update(request.body, headers)
  end
end