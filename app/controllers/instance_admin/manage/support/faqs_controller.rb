class InstanceAdmin::Manage::Support::FaqsController < InstanceAdmin::Manage::BaseController
  inherit_resources
  defaults :resource_class => Support::Faq

  def index
    @faqs = Support::Faq.scoped.rank(:position)
  end

  def create
    @faq = Support::Faq.new(params[:support_faq])
    @faq.created_by_id = current_user.id
    create! do |format|
      format.html do
        redirect_to action: 'index'
      end
      format.json do
        render :nothing => true
      end
    end
  end

  def update
    @faq = Support::Faq.find(params[:id])
    @faq.update_attribute(:updated_by_id, current_user.id)
    update! do |format|
      format.html do
        redirect_to action: 'index'
      end
      format.json do
        render :nothing => true
      end
    end
  end

  def destroy
    @faq = Support::Faq.find(params[:id])
    @faq.update_attribute(:deleted_by_id, current_user.id)
    destroy!
  end

  def new
    @faq = Support::Faq.new
  end

  def permitting_controller_class
    'support'
  end
end
