class Dashboard::Company::OffersController < Dashboard::Company::BaseController
  before_filter :find_offer_type
  before_filter :find_offer, except: [:index, :new, :create]
  before_filter :set_form_components, only: [:new, :create, :edit, :update]

  def index
    @offers = @offer_type.offers.where(creator_id: current_user.id).
      search_by_query([:name, :description], params[:query]).
        order('created_at DESC').paginate(page: params[:page], per_page: 20)
  end

  def new
    @offer = @offer_type.offers.build(creator: current_user)
    @photos = current_user.photos.where(owner_id: nil)
    @attachments = current_user.attachments.where(assetable_id: nil)
  end

  def create
    @offer = @offer_type.offers.build(offer_params)
    @offer.creator = current_user
    @offer.draft_at = Time.now if params[:save_for_later]
    @offer.attachment_ids = params[:attachment_ids]
    if @offer.save
      flash[:success] = t('flash_messages.manage.offers.created', bookable_noun: @offer_type.translated_bookable_noun)
      redirect_to dashboard_company_offer_type_offers_path(@offer_type)
    else
      flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@offer.errors.full_messages)
      @photos = @offer.photos
      render :new
    end
  end

  def show
    redirect_to action: :edit
  end

  def edit
    @photos = @offer.photos
    @attachments = @offer.attachments
  end

  def update
    @offer.assign_attributes(offer_params)
    draft = @offer.draft_at
    @offer.draft_at = nil if params[:submit]
    respond_to do |format|
      format.html {
        if @offer.save
          flash[:success] = t('flash_messages.manage.offers.updated')
          redirect_to dashboard_company_offer_type_offers_path(@offer_type)
        else
          flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@offer.errors.full_messages)
          @photos = @offer.photos
          @offer.draft_at = draft
          render :edit
        end
      }
      format.json {
        if @offer.save
          render :json => { :success => true }
        else
          render :json => { :errors => @offer.errors.full_messages }, :status => 422
        end
      }
    end
  end

  def destroy
    @offer.destroy
    flash[:deleted] = t('flash_messages.manage.offers.deleted')
    redirect_to dashboard_company_offer_type_offers_path(@offer_type)
  end

  private

  def set_form_components
    @form_components = @offer_type.form_components.where(form_type: FormComponent::OFFER_ATTRIBUTES).rank(:rank)
  end

  def find_offer
    begin
      @offer = @offer_type.offers.where(creator_id: current_user.id).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise Offer::NotFound
    end
  end

  def find_offer_type
    @offer_type = OfferType.find(params[:offer_type_id])
  end

  def offer_params
    params.require(:offer).permit(secured_params.offer(@offer_type))
  end

end
