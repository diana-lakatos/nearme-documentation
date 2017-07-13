# frozen_string_literal: true
class Api::V3::MarketplaceReleasesController < Api::BaseController
  def create
    release = MarketplaceRelease.create!(
      name: 'User import',
      status: 'ready_for_import',
      creator: "#{current_user.name} (#{current_user.id})",
      zip_file: params[:marketplace_builder][:zip_file],
      options: { force_mode: params[:marketplace_builder][:force_mode] }
    )

    NewMarketplaceBuilder::Jobs::MarketplaceBuilderJob.perform(release.id)
    render json: release, status: :ok

  rescue NewMarketplaceBuilder::Converters::ConverterError
    render json: { error: $ERROR_INFO.details }, status: 500
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
  rescue
    render json: { error: $ERROR_INFO.details }, status: 500
  end
end
