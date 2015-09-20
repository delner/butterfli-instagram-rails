class Butterfli::Instagram::Rails::Subscription::GeographyController < Butterfli::Instagram::Rails::SubscriptionController
  def callback
    # Step #1: Callback to Instagram and retrieve the media metadata
    client.process_subscription(request.raw_post) do |handler|
      handler.on_geography_changed do |id, data|
        # Get last object ID from the cache:
        min_id = Butterfli::Instagram::Data::Cache.for.subscription(:geography, id).field(:max_obj_id).read
        job = Butterfli::Instagram::Jobs::GeographyRecentMedia.new(obj_id: id, min_id: min_id)

        # If there is no jobs policy, or the policy permits the job
        if Butterfli::Instagram::Regulation.policies(:jobs).nil? || Butterfli::Instagram::Regulation.policies(:jobs).permits?(job)
          # If processor is available, queue the job. Otherwise run in synchronously (slow)
          last_time_queued = Butterfli::Instagram::Data::Cache.for.subscription(:geography, id).field(:last_time_queued)
          if Butterfli.processor
            Butterfli.processor.enqueue(:stories, job)
            last_time_queued.write(Time.now)
          else
            last_time_queued.write(Time.now)
            job.work
          end
        end
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