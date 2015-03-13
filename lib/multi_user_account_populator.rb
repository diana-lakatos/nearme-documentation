class MultiUserAccountPopulator

  class << self

    def run!
      includes = [
        {company_users: :company}, :created_companies, :instance_admins, :authentications,
        :tickets, :ticket_message_attachments, :authored_messages, :reservations
      ]
      User.not_admin.includes(includes).find_each do |u|
        process_association(u, :companies) do |new_user, company|
          company.company_users.find_by(user_id: u.id).update_attribute :user_id, new_user.id
          puts "Company #{company.id} user #{u.id} reassigned to new one #{new_user.id}"

          process_company_association(company, :locations)
          process_company_association(company, :listings)
        end
        process_association(u, :created_companies, :creator_id)
        process_association(u, :locations, :creator_id)
        process_association(u, :transactables, :creator_id)
        process_association(u, :instance_admins)
        process_association(u, :tickets)
        process_association(u, :ticket_message_attachments, :uploader_id)
        process_association(u, :authored_messages, :author_id)
        process_association(u, :reservations, :owner_id)
        process_association(u, :reservations, :creator_id)
      end
    end


    private

    def process_association(user, assoc, attribute_to_update = :user_id)
      user.send(assoc).each do |entity|
        next if entity.instance_id == user.instance_id
        new_user = find_or_create_new_user_for_instance(user, entity)
        if block_given?
          yield(new_user, entity)
        else
          update_entity_user_id(new_user, entity, attribute_to_update)
        end
      end
    end

    def process_company_association(company, assoc)
      company.send(assoc).each do |entity|
        next if company.instance_id == entity.instance_id && company.creator_id == entity.creator_id
        entity.update_columns(creator_id: company.creator_id, instance_id: company.instance_id)
      end
    end

    def find_or_create_new_user_for_instance(user, entity)
      new_user = User.find_by(instance_id: entity.instance_id, slug: user.slug)
      unless new_user
        new_user = User.new(user.attributes.except('id', 'properties'))
        new_user.instance_id = entity.instance_id
        new_user.instance_profile_type_id = Instance.find(entity.instance_id).instance_profile_types.first.try(:id) || Instance.find(entity.instance_id).instance_profile_types.create(name: 'User custom attribute').id
        new_user.save(validate: false)
        puts "Duplicated user #{user.id} for email #{user.email}, new user id is: #{new_user.id}"
      end
      new_user
    end

    def update_entity_user_id(new_user, entity, attribute_to_update)
      entity.update_attribute attribute_to_update, new_user.id
      puts "New user #{new_user.id} for #{entity.class.name.underscore} #{entity.id}"
    end

  end
end
