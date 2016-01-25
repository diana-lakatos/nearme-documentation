class CheckoutExtraFields < Form

  attr_accessor :user, :buyer_profile

  def initialize(user, attributes)
    # ugly fix for custom properties issue
    # otherwise it can't save the object
    @user = User.find(user.id) if user.present?
    @attributes = attributes
    @secured_params = SecuredParams.new
    @all_attachments_present = true
    @all_approval_requests_messages_present = true
    @buyer_profile = @user.try(:get_buyer_profile)
  end

  def are_fields_present?
    if @user.blank? || @attributes.blank? || @attributes['user'].blank?
      return false
    end

    true
  end

  def assign_attributes!
    @user_attributes = @attributes.require(:user).permit(@secured_params.user)
    @user_attributes.each do |key, value|
      @user.send("#{key}=", value)
    end

    public_attributes = UserProfile.public_custom_attributes_names(PlatformContext.current.instance.default_profile_type.try(:id))
    if @attributes['user'].present? && @attributes['user']['properties'].present?
      @attributes['user']['properties'].each do |key, value|
        next if !public_attributes.include?(key)
        @user.properties.send("#{key}=", value)
      end
    end

    public_attributes = UserProfile.public_custom_attributes_names(PlatformContext.current.instance.buyer_profile_type.try(:id))
    if @attributes['user'].present? && @attributes['user']['buyer_profile_attributes'].present?
      @buyer_profile.category_ids = ((@buyer_profile.category_ids || []).map(&:to_s) + @attributes['user']['buyer_profile_attributes']['category_ids']).uniq if @attributes['user']['buyer_profile_attributes']['category_ids'].present?
      if @attributes['user']['buyer_profile_attributes']['properties'].present?
        @attributes['user']['buyer_profile_attributes']['properties'].each do |key, value|
          next if !public_attributes.include?(key)
          @buyer_profile.properties[key] = value
        end
      end
    end

    if @user_attributes['mobile_number'].present? && @user.phone.blank?
      @user.phone = @user_attributes['mobile_number']
    end

    #TODO code related to approval_request does not make any sense, to be removed
    @all_attachments_present = true
    @all_approval_requests_messages_present = true
    if approval_request = @user.current_approval_requests.first
      if approval_request.approval_request_template.required_written_verification && approval_request.message.blank?
        @all_approval_requests_messages_present = false
      end

      approval_request.approval_request_template.approval_request_attachment_templates.each do |attachment_template|
        next if !attachment_template.required?
        attachment = @user.approval_request_attachments.for_request_or_free(approval_request.id).for_attachment_template(attachment_template.id).first
        if !attachment
          @all_attachments_present = false
          break
        end
      end
    end

  end

  def valid?
    @user.valid? && @all_attachments_present && @all_approval_requests_messages_present
  end

  def errors
    @user.errors
  end

  def save!
    if @all_attachments_present && @all_approval_requests_messages_present
      @user.save!
      @buyer_profile.save!
    else
      # We do this to avoid a successful booking/purchase if the documents are not present
      # user errors are required in order to have the document upload notice in the form
      if !@all_attachments_present
        @user.errors.add(:base, I18n.t('approval_request_attachments.please_upload_document'))
      end

      if !@all_approval_requests_messages_present
        @user.errors.add(:base, I18n.t('approval_request_attachments.please_fill_in_message'))
      end

      raise ActiveRecord::RecordInvalid, @user
    end
  end

end

