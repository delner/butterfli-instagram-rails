module Butterfli
  module Instagram
    module Rails
      class Railtie < ::Rails::Railtie
        railtie_name :butterfli_instagram

        # For some reason this is causing Rake tasks to load twice...
        # Maybe because we're already loading as an engine?
        # rake_tasks do
        #   load "tasks/instagram.rake"
        # end
      end
    end
  end
end