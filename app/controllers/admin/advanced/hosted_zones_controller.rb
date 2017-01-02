# frozen_string_literal: true
class Admin::Advanced::HostedZonesController < Admin::Advanced::BaseController
  respond_to :html

  def create
    SetupHostedZoneJob.perform(domain.id)
    redirect_to instance_admin_settings_domain_path(domain)
  end

  private

  def domain
    Domain.find(params[:domain_id])
  end
end
