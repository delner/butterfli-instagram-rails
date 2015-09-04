# NOTE: We're overriding with Rails-specific behavior
#       Doing this only for 1.9.3. Otherwise we'd prepend.
module Butterfli::Instagram::Tasks
  include Butterfli::Rails::Tasks

  engine Butterfli::Instagram::Rails::Engine
  controller :geography, "Butterfli::Instagram::Rails::Subscription::GeographyController"
  controller :location, "Butterfli::Instagram::Rails::Subscription::LocationController"
  controller :tag, "Butterfli::Instagram::Rails::Subscription::TagController"

  # NOTE: Must be forcefully overidden to use the Rails module...
  def self.configure; super; end
  def self.url_for(host, options = {}); super; end
end

# TODO: When we drop support for Ruby 1.9.3
#       and go 2.0+, prepend this module instead
# module Butterfli::Instagram::Rails::Tasks
#   def self.prepended(base)
#     class << base
#       prepend ClassMethods
#     end
#   end
# end
# 
# Butterfli::Instagram::Tasks.prepend(Butterfli::Instagram::Rails::Tasks)
