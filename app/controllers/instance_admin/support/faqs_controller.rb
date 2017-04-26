class InstanceAdmin::Support::FaqsController < InstanceAdmin::Manage::BaseController
  skip_before_filter :check_if_locked
  inherit_resources
  defaults resource_class: ::Support::Faq

  def index
    @faqs = ::Support::Faq.for_current_locale.rank(:position)
  end

  def create
    @faq = ::Support::Faq.new(faq_params.merge(language: I18n.locale))
    @faq.created_by_id = current_user.id
    create! do |format|
      format.html do
        redirect_to action: 'index'
      end
      format.json do
        render nothing: true
      end
    end
  end

  def update
    @faq = ::Support::Faq.find(params[:id])
    @faq.update_attribute(:updated_by_id, current_user.id)
    update! do |format|
      format.html do
        redirect_to action: 'index'
      end
      format.json do
        render nothing: true
      end
    end
  end

  def destroy
    @faq = ::Support::Faq.find(params[:id])
    @faq.update_attribute(:deleted_by_id, current_user.id)
    destroy!
  end

  def new
    @faq = ::Support::Faq.new
  end

  private

  def permitting_controller_class
    'support'
  end

  def faq_params
    params.require(:support_faq).permit(secured_params.support_faq)
  end
end
