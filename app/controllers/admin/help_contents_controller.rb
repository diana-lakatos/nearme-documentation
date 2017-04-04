# frozen_string_literal: true
class Admin::HelpContentsController < Admin::BaseController
  layout 'admin/config'

  before_action :find_help_content, only: [:edit, :update, :show]

  def edit
  end

  def show
    render text: @help_content.content
  end

  def update
    # do not allow to change path for now
    if @help_content.update(help_content_params)
      if request.xhr?
        markdown = MarkdownWrapper.new(@help_content.content)
        render json: { result: 'success', data: markdown.to_html }
      else
        flash[:success] = t 'admin.flash_messages.manage.help_contents.updated'
        redirect_to edit_admin_help_content_path(@help_content)
      end
    else
      if request.xhr?
        render json: { result: 'fail', data: @help_content.errors.full_messages }
      else
        flash.now[:error] = @help_content.errors.full_messages.to_sentence
        render :edit
      end
    end
  end

  private

  def help_content_params
    params.require(:help_content).permit(secured_params.help_content)
  end

  def find_help_content
    @help_content ||= HelpContent.find(params[:id])
  end
end
