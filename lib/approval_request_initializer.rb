class ApprovalRequestInitializer

  def initialize(object)
    @object = object
  end

  def process
    @object.approval_requests.to_a.reject! { |ar| !@object.approval_request_templates.pluck(:id).include?(ar.approval_request_template_id) }
    if (art = @object.approval_request_templates.first).present?
      unless ar = @object.approval_requests.find { |approval_request| approval_request.approval_request_template_id == art.id }
        ar = @object.approval_requests.build(approval_request_template_id: art.id)
        @object.approval_requests << ar
      end
      ar.required_written_verification = art.required_written_verification
      art.approval_request_attachment_templates.each do |arat|
        if ara = current_user.approval_request_attachments.for_request_or_free(ar.id).for_attachment_template(arat.id).first
          ar.approval_request_attachments << ara
        end
      end
    end
    @object
  end

end
