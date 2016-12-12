# frozen_string_literal: true
class InstanceAdmin::Theme::GraphQueriesController < InstanceAdmin::Theme::BaseController
  def index
    @graph_queries = graph_queries
  end

  def new
    @graph_query = graph_queries.build
  end

  def edit
    graph_query
  end

  def create
    @graph_query = graph_queries.build(graph_query_params)
    if @graph_query.save
      flash[:success] = t 'flash_messages.instance_admin.manage.graph_queries.created'
      redirect_to action: :index
    else
      flash.now[:error] = @graph_query.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    if graph_query.update_attributes(graph_query_params)
      flash[:success] = t 'flash_messages.instance_admin.manage.graph_queries.updated'
      redirect_to action: :index
    else
      flash.now[:error] = @graph_query.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    graph_query.destroy
    flash[:success] = t 'flash_messages.instance_admin.manage.graph_queries.deleted'
    redirect_to action: :index
  end

  private

  def graph_query_params
    params.require(:graph_query).permit(:query_string, :name)
  end

  def graph_query
    @graph_query = graph_queries.find(params[:id])
  end

  def graph_queries
    platform_context.instance.graph_queries
  end
end
