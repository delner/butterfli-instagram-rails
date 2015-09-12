class Butterfli::Instagram::Rails::Subscription::TagController < Butterfli::Instagram::Rails::SubscriptionController
  def callback
    # Step #1: Callback to Instagram and retrieve the media metadata
    client.process_subscription(request.raw_post) do |handler|
      handler.on_tag_changed do |id, data|
        # Get last object ID from the cache:
        # TODO: Create intermediate Instagram cache layer to centralize cache key management
        min_tag_id = Butterfli.cache.read("Instagram:Subscription:Tag:#{id}:MaxObjectId")
        job = Butterfli::Instagram::Jobs::TagRecentMedia.new(obj_id: id, min_tag_id: min_tag_id)

        # If processor is available, queue the job. Otherwise run in synchronously (slow)
        Butterfli.processor ? Butterfli.processor.enqueue(job) : job.work
      end
    end

    # Step #2: Render output
    respond_to do |format|
      format.html { render text: "" }
      format.json { render text: "" }
      format.text { render text: "" }
    end
  end
end