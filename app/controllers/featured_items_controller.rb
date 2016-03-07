class FeaturedItemsController < ApplicationController
	TARGET_WHITELIST = %w(services products projects topics users)
	before_filter :check_valid_target

	def index
		request.format = :html
		@amount = params[:amount].presence || 1
		@type = params[:type]
		@partial_name = "featured_items/#{@target}"
		@collection = get_target_collection
	end

	protected
		def klass
			{
				services: Transactable,
				products: Spree::Product,
				projects: Project
			}[@target.to_sym]
		end

		def parent_klass
			{
				services: ServiceType,
				products: Spree::ProductType,
				projects: ProjectType
			}[@target.to_sym]
		end

	private
		def get_target_collection
			if @target.in? %w(services products projects)
				if @type.present?
					parent = parent_klass.where("lower(name) = ?", @type.downcase).first
					klass.where(transactable_type_id: parent.id).featured.take(@amount)
				else
					klass.featured.take(@amount)
				end
			else
				@target.classify.constantize.featured.take(@amount)
			end
		end

		def check_valid_target
			if params[:target].in? TARGET_WHITELIST
				@target = params[:target]
			else
				render text: "Invalid target provided." && return
			end
		end
end
