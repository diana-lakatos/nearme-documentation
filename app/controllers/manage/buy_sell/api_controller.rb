class Manage::BuySell::ApiController < Manage::BuySell::BaseController

  def countries
    countries = Spree::Country.select(:id, :name)
    process_collection(countries)
  end

  def states
    states = Spree::State.select(:id, :name)
    process_collection(states)
  end

  private

  def process_collection(collection)
    collection = collection.ransack(params[:q]).result.order('name ASC')
    collection = collection.where(id: params[:ids].split(",")) if params[:ids].present?

    if params[:page] || params[:per_page]
      collection = collection.paginate(page:params[:page], per_page: params[:per_page])
    end

    render json: collection.order(:name).to_json
  end
end
