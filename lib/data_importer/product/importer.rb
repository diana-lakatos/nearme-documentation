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
    @data_upload.parsing_result_log = ""
    @log_entries = []
    @new_users = {}
    @all_users = []
    @imported_products = []
    @current_row = 0
  end

  def import
    while params = get_params
      unless params.empty?
        quantity = params[:'spree/product'].has_key?(:total_on_hand) ? params[:'spree/product'].delete(:total_on_hand).to_i : 1
        price    = params[:'spree/product'].delete(:price).to_f if params[:'spree/product'].has_key?(:price)
        import_company(params[:company]) do |company|
          import_user(params[:user], company) do |user|
            import_shipping_category(params[:'spree/shipping_category'], user, company) do |shipping_category|
              import_product(params[:'spree/product'], user, company, shipping_category, price) do |product|
                import_master_variant(params[:'spree/variant'], product, price) do |variant|
                  import_stock_item(company, variant, quantity) if quantity
                  import_image(params[:'spree/image'], variant) if params[:'spree/image'].present?
                end
              end
            end
          end
        end
      end
      store_log
    end

    finish
    delete_absent_entities if @data_upload.sync_mode
    send_invitation_emails if @data_upload.send_invitational_email
    send_notification
  end

  private

  def get_params
    @current_row += 1
    @product_csv.process_next_row
  rescue
    add_error('Error parsing CSV file at line')
    {}
  end

  def import_company(params)
    external_id = params.delete(:external_id)
    if external_id.nil?
      add_error('Missing mandatory parameter: company external_id')
      return
    end
    company = find_or_initialize_by_and_assign(Company, external_id: external_id) do |company|
      company.restore! if company.deleted?
      company.assign_attributes(params)
    end

    if company.save
      yield(company)
    else
      log_validation_error(company)
    end
  end

  def import_user(params, company)
    email = params.delete(:email).try(:downcase)
    if email.nil?
      add_error('Missing mandatory parameter: user email')
      return
    end
    user = User.with_deleted.find_or_initialize_by(email: email) do |u|
      password = SecureRandom.hex(8)
      @new_users[u.email] = password
      u.password = u.password_confirmation = password
      u.country_name = 'United States'
    end
    user.restore! if user.deleted?
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
      @all_users << user unless @all_users.include?(user)
      yield(user)
    else
      log_validation_error(user)
      company.destroy
    end
  end

  def import_shipping_category(params, user, company, &block)
    import_entity(block) do
      if !params[:name].present? && category = Spree::ShippingCategory.find_by(id: @data_upload.default_shipping_category_id)
        category
      else
        params[:name] ||= 'Default'
        params.merge!(instance_id: PlatformContext.current.instance.id, user_id: user.id, company_id: company.id)
        find_or_initialize_by_and_assign(Spree::ShippingCategory, params)
      end
    end
  end

  def assign_product_categories(categories_text, product)
    if categories_text.present?
      categories_text.split(/\s*,\s*/).each do |category_permalink|
        category = Category.find_by_permalink(category_permalink)
        product.categories << category if category.present?
      end
    end
  end

  def import_product(params, user, company, shipping_category, price, &block)
    external_id = params.delete(:external_id)
    if external_id.nil?
      add_error('Missing mandatory parameter: product external_id')
      return
    end
    if params[:name].present? && params[:name].size > 255
      add_warning("Product name is too long: #{params[:name]}")
      params[:name] = params[:name][0..251] + '...'
    end
    product_categories = params.delete(:product_categories)
    product = import_entity(block) do
      find_or_initialize_by_and_assign(Spree::Product, external_id: external_id, company_id: company.id) do |product|
        unless product.deleted_at.nil?
          product.update_column(:deleted_at, nil)
          product.master.update_column(:deleted_at, nil)
          product.stock_items.update_all(deleted_at: nil)
        end
        product.assign_attributes(params)
        product.action_rfq = @data_upload.enable_rfq
        product.product_type = @data_upload.importable
        product.user = user
        product.price = price
        product.shipping_category = shipping_category
      end
    end
    # We do this here, after the product is saved to the DB because manipulating
    # the categories association will force the committing of the product to the DB
    assign_product_categories(product_categories.to_s, product)
  end


  def import_master_variant(params, product, price, &block)
    import_entity(block) do
      find_or_initialize_by_and_assign(Spree::Variant, product_id: product.id) do |variant|
        variant.assign_attributes(params)
        variant.user_id = product.user_id
        variant.company_id = product.company_id
        variant.price = price
      end
    end
  end

  def import_stock_item(company, variant, quantity, &block)
    stock_location = company.stock_locations.first || company.stock_locations.create(propagate_all_variants: false, name: "Default")
    item = import_entity(block) do
      find_or_initialize_by_and_assign(Spree::StockItem, variant_id: variant.id, stock_location_id: stock_location.id, backorderable: false)
    end
    item.stock_movements.create(quantity: quantity - item.stock_movements.sum(:quantity))
  end

  def import_image(params, variant)
    import_entity do
      Spree::Image.find_or_initialize_by(
        viewable: variant,
        image_original_url: params.delete(:image_original_url)
      )
    end
  end

  def import_entity(block = nil)
    entity = yield
    if entity.new_record? && entity.save
      entity_created(entity)
    elsif (entity.changed? || (entity.is_a?(Spree::Variant) && entity.default_price.changed?)) && entity.save
      entity_updated(entity)
    end

    if entity.errors.empty?
      @imported_products << entity.id if entity.is_a?(Spree::Product)
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
    entity = (klass.respond_to?(:with_deleted) ? klass.with_deleted : klass).find_or_initialize_by(params)
    entity.restore! if entity.respond_to?(:deleted_at) && entity.deleted?
    yield(entity) if block_given?
    entity
  end

  %i(created updated).each do |action|
    define_method("entity_#{action}") do |entity|
      model = entity.class.name.underscore.to_sym
      @entities_counters[action][model] += 1 if @entities_counters[action].has_key?(model)
    end
  end

  def log_validation_error(entity)
    add_error("Validation error for #{entity.class.name}: #{entity.errors.full_messages.to_sentence}.")
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

  def add_error(error)
    @log_entries << "Error on line #{@current_row}. #{error}"
  end

  def add_warning(warning)
    @log_entries << "Warning on line #{@current_row}. #{warning}"
  end

  def store_log
    unless @log_entries.empty?
      @data_upload.parsing_result_log += (@log_entries.join("\n") << "\n")
      @data_upload.save(validate: false)
      @log_entries = []
    end
  end

  def finish
    if @imported_products.uniq.size == @current_row
      @data_upload.finish!
    elsif !@imported_products.empty?
      @data_upload.finish_with_validation_errors!
    else
      @data_upload.failure!
    end

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
