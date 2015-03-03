class DataImporter::Product::Importer

  # reverse order to destroy starting on children entities to track deleted entities
  SYNC_MODELS = %i(spree/shipping_category spree/product spree/variant spree/image).reverse.freeze

  def initialize(data_upload, product_csv)
    @data_upload = data_upload
    @product_csv = product_csv
    entities_hash = DataImporter::Product::CsvFile::MODELS.inject({}) { |hsh, model| hsh[model] = 0; hsh }
    @entities_counters = {created: entities_hash.dup, updated: entities_hash.dup}
    @entities_counters[:deleted] = SYNC_MODELS.inject({}) { |hsh, model| hsh[model] = 0; hsh }
    @processed_entities_ids = {}
    @validation_errors = []
    @new_users = {}
    @all_users = []
    @imported_products = 0
    @processed_rows = 0
  end

  def import
    while params = @product_csv.process_next_row
      begin
        import_industry(params[:industry]) do |industry|
          import_company(params[:company], industry) do |company|
            import_user(params[:user], company) do |user|
              import_shipping_category(params[:'spree/shipping_category'], user, company) do |shipping_category|
                import_product(params[:'spree/product'], user, company, shipping_category) do |product|
                  import_variant(params[:'spree/variant'], product) do |variant|
                    import_image(params[:'spree/image'], variant)
                  end
                end
              end
            end
          end
        end
      ensure
        @processed_rows += 1
        @data_upload.update_column(:progress_percentage, (@processed_rows.to_f * 100 / @data_upload.num_rows).floor)
      end
    end

    delete_absent_entities if @data_upload.sync_mode
    send_invitation_emails if @data_upload.send_invitational_email
    store_log
    send_notification
  end

  private

  def import_industry(params, &block)
    import_entity(block) do
      Industry.find_or_create_by(name: params[:name])
    end
  end

  def import_company(params, industry)
    company = find_or_initialize_by_and_assign(Company, external_id: params.delete(:external_id)) do |company|
      company.assign_attributes(params)
      company.industries << industry
    end

    if company.save
      yield(company)
    else
      log_validation_error(company)
    end
  end

  def import_user(params, company)
    user = User.find_or_initialize_by(email: params.delete(:email).downcase) do |u|
      password = SecureRandom.hex(8)
      @new_users[u.email] = password
      u.password = u.password_confirmation = password
      u.country_name = 'United States'
    end
    user.assign_attributes(params)

    if user.new_record? && user.save
      entity_created(user)
    elsif user.changed? && user.save
      entity_updated(user)
    end

    if user.errors.empty?
      company.creator_id = user.id if company.creator_id.nil?
      company.users << user unless company.users.include?(user)
      company.save!
      entity_created(company)
      @all_users << user unless @all_users.include?(user)
      yield(user)
    else
      log_validation_error(user)
      company.destroy
    end
  end

  def import_shipping_category(params, user, company, &block)
    import_entity(block) do
      params.merge!(instance_id: PlatformContext.current.instance.id, user_id: user.id, company_id: company.id)
      find_or_initialize_by_and_assign(Spree::ShippingCategory, params)
    end
  end

  def import_product(params, user, company, shipping_category, &block)
    import_entity(block) do
      find_or_initialize_by_and_assign(Spree::Product, external_id: params.delete(:external_id), company_id: company.id) do |product|
        product.assign_attributes(params)
        product.user = user
        product.shipping_category = shipping_category
      end
    end
  end


  def import_variant(params, product, &block)
    import_entity(block) do
      find_or_initialize_by_and_assign(Spree::Variant, product_id: product.id) do |variant|
        variant.assign_attributes(params)
        variant.user_id = product.user_id
        variant.company_id = product.company_id
      end
    end
  end

  def import_image(params, variant)
    import_entity do
      find_or_initialize_by_and_assign(Spree::Image, image_original_url: params.delete(:image_original_url)) do |image|
        image.viewable = variant
      end
    end
  end

  def import_entity(block = nil)
    entity = yield
    if entity.new_record? && entity.save
      entity_created(entity)
    elsif entity.changed? && entity.save
      entity_updated(entity)
    end

    if entity.errors.empty?
      @imported_products += 1 if entity.is_a?(Spree::Product)
      block.call(entity) if block
    else
      log_validation_error(entity)
    end

    model = entity.class.name.underscore.to_sym
    if SYNC_MODELS.include?(model)
      @processed_entities_ids[model] ||= []
      @processed_entities_ids[model] << entity.id
    end

    entity
  end

  def find_or_initialize_by_and_assign(klass, params)
    entity = klass.find_or_initialize_by(params)
    yield(entity) if block_given?
    entity
  end

  %i(created updated).each do |action|
    define_method("entity_#{action}") do |entity|
      instance_variable_get("@entities_counters")[action][entity.class.name.underscore.to_sym] += 1
    end
  end

  def log_validation_error(entity)
    @validation_errors << "Validation error for #{entity.class.name}: #{entity.errors.full_messages.to_sentence}."
  end

  def send_invitation_emails
    User.where(email: @new_users.keys).find_each do |user|
      WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::CreatedViaBulkUploader, user.id, @new_users[user.email])
    end
  end

  def delete_absent_entities
    @all_users.each do |user|
      SYNC_MODELS.each do |model|
        klass = model.to_s.classify.constantize
        @entities_counters[:deleted][model] = unless model == :'spree/image'
          klass.where("user_id = ? AND id NOT IN (?)", user.id, @processed_entities_ids[model])
        else
          image_ids = user.products.map(&:images).flatten.map(&:id)
          klass.where("id IN (?) AND id NOT IN (?)", image_ids, @processed_entities_ids[model])
        end.destroy_all.size
      end
    end
  end

  def store_log
    if @validation_errors.empty? && @imported_products == @processed_rows
      @data_upload.finish!
    elsif @imported_products != 0
      @data_upload.finish_with_validation_errors!
    else
      @data_upload.fail!
    end

    @data_upload.parsing_result_log = @validation_errors.join('\n')
    @data_upload.parse_summary = {
      new:     @entities_counters[:created],
      updated: @entities_counters[:updated],
      deleted: @entities_counters[:deleted]
    }
    @data_upload.save!
    @data_upload.touch(:imported_at)
  end

  def send_notification
    if @data_upload.succeeded? || @data_upload.partially_succeeded?
      WorkflowStepJob.perform(WorkflowStep::DataUploadWorkflow::Finished, @data_upload.id)
    elsif @data_upload.failed?
      WorkflowStepJob.perform(WorkflowStep::DataUploadWorkflow::Failed, @data_upload.id)
    end
  end

end
