# frozen_string_literal: true
class Dashboard::Api::BaseController < Dashboard::BaseController
  private

  def process_collection(collection, *methods)
    collection = collection.where('lower(name) like ?', "%#{params.dig(:q, :name_cont).to_s.downcase}%").order('name ASC')
    collection = collection.where(id: params[:ids].split(',')) if params[:init_selection].present?
    render json: collection.order(:name).to_json(methods: methods)
  end
end
