class Butterfli::Instagram::Rails::Subscription::GeographyController < Butterfli::Instagram::Rails::ApiController
  layout nil
  protect_from_forgery unless: -> { request.format.json? }


  def setup
    response = client.meet_challenge(params) { |token| true }
    respond_to do |format|
      format.html { render text: response }
      format.json { render text: response }
      format.text { render text: response }
    end
  end

  def callback
    geo_object_id = nil
    media_objects = nil

    # Step #1: Callback to Instagram and retrieve the media metadata
    client.process_subscription(request.raw_post) do |handler|
      handler.on_geography_changed do |id, data|
        geo_object_id = id
        media_objects = client.geography_recent_media(geo_object_id, min_id: subscriptions[geo_object_id])
      end
    end
    
    # Step #2: Filter images to uniques
    media_objects = media_objects.uniq { |item| item['id'] }

    stories = []
    if !media_objects.empty?
      # Step #3: Transform image metadata using Butterfli
      media_objects.each do |media_object|
        story = Butterfli::Instagram::Data::MediaObject.new(media_object).transform
        stories << story if story
      end
      
      # Step #3.1: Update the 'last seen photo ID', for 'pagination'
      # NOTE: If we're receiving objects from multiple overlapping geographies,
      #       it's entirely possible we'd be collecting duplicate stories...
      subscriptions[geo_object_id] = media_objects.collect(&:id).max
    end

    # Step #4: Notify Instagram subscribers
    Butterfli.syndicate(stories) if !stories.empty?

    # Step #5: Render output
    respond_to do |format|
      format.html { render text: "#{stories.to_json}" }
      format.json { render text: "#{stories.to_json}" }
      format.text { render text: "#{stories.to_json}" }
    end
  end
  private
  def subscriptions
    @@subscriptions ||= {}
  end
end