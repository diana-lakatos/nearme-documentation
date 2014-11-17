class InstanceAdmin::BuySell::TaxonomiesController < InstanceAdmin::BuySell::BaseController

  def index
    @taxonomies = taxonomy_scope.all
  end

  def new
    @taxonomy = taxonomy_scope.new
  end

  def create
    @taxonomy = taxonomy_scope.new(taxonomy_params)
    if @taxonomy.save
      flash[:success] = t('flash_messages.buy_sell.taxonomy_added')
      redirect_to edit_instance_admin_buy_sell_taxonomy_path(@taxonomy)
    else
      render :new
    end
  end

  def edit
    @taxonomy = taxonomy_scope.find(params[:id])
  end

  def update
    @taxonomy = taxonomy_scope.find(params[:id])
    if @taxonomy.update_attributes(taxonomy_params)
      flash[:success] = t('flash_messages.buy_sell.taxonomy_updated')
      redirect_to instance_admin_buy_sell_taxonomies_path
    else
      render 'edit'
    end
  end

  def destroy
    @taxonomy = taxonomy_scope.find(params[:id])
    @taxonomy.destroy
    flash[:success] = t('flash_messages.buy_sell.taxonomy_deleted')
    redirect_to instance_admin_buy_sell_taxonomies_path
  end

  def edit_taxon
    @taxonomy = taxonomy_scope.find(params[:id])
    @taxon = @taxonomy.taxons.find(params[:taxon_id])
  end

  def update_taxon
    @taxonomy = taxonomy_scope.find(params[:id])
    @taxon = @taxonomy.taxons.find(params[:taxon_id])
    if @taxon.update_attributes(taxon_params)
      flash[:success] = t('flash_messages.buy_sell.taxon_updated')
      redirect_to edit_instance_admin_buy_sell_taxonomy_path(@taxonomy)
    else
      render 'edit_taxon'
    end
  end

  private

  def taxonomy_scope
    Spree::Taxonomy
  end

  def taxonomy_params
    params.require(:taxonomy).permit(secured_params.taxonomy)
  end

  def taxon_params
    params.require(:taxon).permit(secured_params.taxon)
  end
end
