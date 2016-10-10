module AttachmentsHelper
  def attachment_ids_for(transactable)
    unless params.key?(:attachment_ids)
      []
    else
      @attachment_ids ||= begin
        relation = SellerAttachment.where(user: current_user)
        if transactable.new_record?
          relation.where(assetable: nil)
        else
          relation.where('(assetable_id IS NULL) OR (assetable_id = ? AND assetable_type = ?)', transactable.id, transactable.class.name)
        end.map(&:id) & params[:attachment_ids].map(&:to_i)
      end
    end
  end
end
