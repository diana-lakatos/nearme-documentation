class Dashboard::Api::BaseController < Dashboard::BaseController
  private

  def process_collection(collection, *methods)
    collection = collection.ransack(params[:q]).result.order('name ASC')
    collection = collection.where(id: params[:ids].split(',')) if params[:init_selection].present?
    render json: collection.order(:name).to_json(methods: methods)
  end
end
