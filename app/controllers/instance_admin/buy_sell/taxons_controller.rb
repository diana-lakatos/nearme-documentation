class InstanceAdmin::BuySell::TaxonsController < InstanceAdmin::BuySell::BaseController
  before_filter :find_taxonomy
  before_filter :find_taxon, except: [:create, :index]

  def index
    if @taxonomy
      @taxons = @taxonomy.root.children
    else
      if params[:ids]
        @taxons = Spree::Taxon.includes(:children).where(id: params[:ids].split(','))
      else
        @taxons = Spree::Taxon.includes(:children).order(:taxonomy_id, :lft).ransack(params[:q]).result
      end
    end

    @taxons = @taxons.page(params[:page]).per(params[:per_page])
  end

  def jstree
  end

  def show
  end

  def create
    @taxon = @taxonomy.taxons.new(taxon_params)
    @taxon.parent_id = @taxonomy.root.id unless params[:taxon][:parent_id]

    if @taxon.save
      render action: :show
    else
      invalid_resource!(@taxon)
    end
  end

  def update
    respond_to do |format|
      if @taxon.update_attributes(taxon_params)
        format.json { render action: :show }
        format.html do 
          flash[:success] = t('flash_messages.buy_sell.taxon_updated')
          redirect_to edit_instance_admin_buy_sell_taxonomy_path(@taxonomy)
        end
      else
        format.json { invalid_resource!(@taxon) }
        format.html { render 'edit_taxon' }
      end
    end
  end

  def destroy
    @taxon.destroy
    render json: @taxon, status: 204
  end

  private

  def find_taxonomy
    @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
  end

  def find_taxon
    @taxon = @taxonomy.taxons.find(params[:id])
  end

  def taxon_params
    params.require(:taxon).permit(secured_params.taxon)
  end

  def invalid_resource!(taxon)
    render json: { errors: taxon.errors.to_hash }, status: 422
  end

end
