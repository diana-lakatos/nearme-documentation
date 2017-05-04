# frozen_string_literal: true
class InstanceAdmin::Manage::MarketplaceReleasesController < InstanceAdmin::Manage::BaseController
  before_action do
    @breadcrumbs_title = 'Marketplace Releases'
  end

  def index
    @releases = MarketplaceRelease.order('created_at DESC').first(10)
  end

  def show
    @release = MarketplaceRelease.find params[:id]
  end

  def create
    release = MarketplaceRelease.new(
      name: (params[:marketplace_builder][:name].presence || 'User import'),
      status: 'ready_for_import',
      creator: "#{current_user.name} (#{current_user.id})",
      zip_file: params[:marketplace_builder][:zip_file]
    )

    if release.save
      NewMarketplaceBuilder::Jobs::MarketplaceBuilderJob.perform(release.id)
      redirect_to instance_admin_manage_marketplace_releases_path, notice: 'Release ready for import.'
    else
      redirect_to instance_admin_manage_marketplace_releases_path, notice: release.errors.full_messages.join(', ')
    end
  end

  def backup
    release = MarketplaceRelease.create!(name: 'User export', status: 'ready_for_export', creator: "#{current_user.name} (#{current_user.id})")
    NewMarketplaceBuilder::Jobs::MarketplaceBuilderJob.perform(release.id)

    redirect_to instance_admin_manage_marketplace_releases_path, notice: 'Request to export current state added to job queue.'
  end

  def restore
    release = MarketplaceRelease.find params[:id]
    release.update! status: 'ready_for_import'

    NewMarketplaceBuilder::Jobs::MarketplaceBuilderJob.perform(release.id)
    redirect_to instance_admin_manage_marketplace_releases_path, notice: 'Release ready for import.'
  end
end
