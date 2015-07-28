namespace :transactable_types do
  desc "Fixes reviews/rating systems."
  task :fix_rating_systems => [:environment] do

    @stats = {}
    
    @stats[:success] = @stats[:deleted] = 0

    ActiveRecord::Base.transaction do

        RatingSystem.find_in_batches do |rating_systems|
          rating_systems.each do |rating_system|
            identifier = "Rating System ##{rating_system.id}"
            output "Working on ##{identifier}"

            begin
              transactable_type_name = rating_system.subject

              unless %w(guest host).include?(transactable_type_name)

                # First attempt: Find it via name.
                #
                # This may raise ActiveRecord::RecordNotFound for orphaned records,
                # or records that changed it's translation, so we may want to try to find
                # them via id.
                #
                @transactable_type = TransactableType.find_by(
                  name: transactable_type_name, 
                  instance_id: rating_system.instance_id
                )

                if @transactable_type.present?
                  # We just want to ensure the transactable type is set
                  # correctly for that specific record. Just in case there are
                  # records with a name set, but without a transactable_type_id set.
                  #
                  rating_system.transactable_type_id = @transactable_type.id
                else
                  # Second attempt: 
                  #
                  # This may raise ActiveRecord::RecordNotFound again, when the transactable was
                  # deleted. We may just want to delete 
                  #
                  @transactable_type = TransactableType.find(rating_system.transactable_type_id)
                end

                # Update the column to transactable to make interactions via transactable_type
                # association when needed.
                #
                rating_system.subject = "transactable"
                rating_system.save!
              end

              @stats[:success] += 1
              output "Record #{identifier} was successfully created/updated.", 2

            rescue ActiveRecord::RecordNotFound
              # If not found on second attempt, lets just delete the record.
              # 
              output "Record #{identifier} wasn't found. Deleting it.", 2
              @stats[:deleted] += 1
              rating_system.destroy

            rescue => e
              output "Something bad happened with #{identifier}.", 2
              raise e
            end
          end
        end

      formatted_stats

    end
  end

  def output(message, nesting=1)
    indent = " " * nesting * 2
    puts "#{indent} => #{message}"
  end

  def formatted_stats
    10.times { puts }
    puts "-------------------------"
    p @stats
    puts "-------------------------"
    10.times { puts }
  end
end
