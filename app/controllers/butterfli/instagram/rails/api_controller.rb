class Butterfli::Instagram::Rails::ApiController < Butterfli::Controller
  def client
    @client ||= Butterfli.configuration.providers(:instagram).client
  end
end