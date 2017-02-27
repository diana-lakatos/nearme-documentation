class WorkflowStep::OfferWorkflow::BaseStep < WorkflowStep::BaseStep
  def self.belongs_to_transactable_type?
    true
  end

  def initialize(offer_id)
    @offer = Order.find_by(id: offer_id)
    @lister = @offer&.host
    @enquirer = @offer&.owner
  end

  def workflow_type
    'offer'
  end

  def transactable
    @offer.transactables.first
  end

  def collaborators
    transactable.try(:collaborators_email_recipients)
  end

  # offer:
  #   Offer object
  # enquirer:
  #   enquirer User object
  # lister:
  #   listing User object
  # listing:
  #   Transactable object
  def data
    {
      offer: @offer,
      enquirer: enquirer,
      lister: lister,
      listing: transactable,
      transactable: transactable
    }
  end

  def transactable_type_id
    transactable.try(:transactable_type_id)
  end

  def should_be_processed?
    @offer.present?
  end
end
