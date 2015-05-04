class Dashboard::ApiController < Dashboard::BaseController

  def countries
    countries = Spree::Country.select(:id, :name)
    process_collection(countries)
  end

  def states
    states = Spree::State.select(:id, :name)
    process_collection(states)
  end

  private

  def process_collection(collection, *methods)
    collection = collection.ransack(params[:q]).result.order('name ASC')
    collection = collection.where(id: params[:ids].split(",")) if params[:ids].present?

    render json: collection.order(:name).to_json(methods: methods)
  end

end
