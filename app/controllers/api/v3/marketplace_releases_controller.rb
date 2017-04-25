# frozen_string_literal: true
class Api::V3::MarketplaceReleasesController < Api::BaseController
  def create
    release = MarketplaceRelease.create!(
      name: 'User import',
      status: 'ready_for_import',
      creator: "#{current_user.name} (#{current_user.id})",
      zip_file: params[:marketplace_builder][:zip_file]
    )

    NewMarketplaceBuilder::Jobs::MarketplaceBuilderJob.perform(release.id)
    render json: release, status: :ok
  end

  def backup
    release = MarketplaceRelease.create!(
      name: 'User export',
      status: 'ready_for_export',
      creator: "#{current_user.name} (#{current_user.id})"
    )

    NewMarketplaceBuilder::Jobs::MarketplaceBuilderJob.perform(release.id)
    render json: release, status: :ok
  end

  def show
    release = MarketplaceRelease.find params[:id]
    render json: release, status: :ok
  end

  def sync
    NewMarketplaceBuilder::Interactors::ImportInteractor.new(PlatformContext.current.instance.id, params).execute!
    render json: {}, status: :ok
  end
end
