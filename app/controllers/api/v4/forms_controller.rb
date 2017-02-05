# frozen_string_literal: true
module Api
  module V4
    class UsersController < Api::V4::BaseController
      skip_before_action :require_authentication
      skip_before_action :require_authorization
      skip_before_action :redirect_unverified_user, only: [:verify]
      before_action :build_form, only: [:new, :create]

      def create
        if @form.validate(params[:form])
          @form.save
          redirect_to @form.redirection_url.presence || root_path
        else
          raise NotImplementedError if params[:page_id].blank?
          @page = Page.find(params[:page_id])
          render template: 'posts/show'
        end
      end

      protected

      def build_form
        @form = FormConfiguration.find(params[:form_id]).build
      end
    end
  end
end
