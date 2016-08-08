class WorkflowStep::OfferWorkflow::BaseStep < WorkflowStep::BaseStep

  def self.belongs_to_transactable_type?
    true
  end

  def initialize(offer_id)
    @offer = Order.find_by_id(offer_id)
  end

  def workflow_type
    'offer'
  end

  def lister
    @offer.host
  end

  def enquirer
    @offer.owner
  end

  # offer:
  #   Offer object
  # user:
  #   listing User object
  # host:
  #   enquiring User object
  # listing:
  #   Transactable object
  def data
    { offer: @offer, user: lister, host: enquirer, listing: @offer.transactable }
  end

  def transactable_type_id
    @offer.try(:listing).try(:transactable_type_id)
  end

  def should_be_processed?
    @offer.present?
  end

end
