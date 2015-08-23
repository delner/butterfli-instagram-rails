# NOTE: We're overriding with Rails-specific behavior
#       Doing this only for 1.9.3. Otherwise we'd prepend.
module Butterfli::Instagram::Tasks
  def self.configure
    puts "** Loading Rails environment... **"
    Rake::Task["environment"].invoke
    Butterfli.configuration
  end
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
