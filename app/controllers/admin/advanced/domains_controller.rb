# frozen_string_literal: true
require 'nearme/r53'

class Admin::Advanced::DomainsController < Admin::Advanced::BaseController
  before_action :find_domain, only: [:edit, :update, :destroy]

  def index
    @domains = DomainDecorator.decorate_collection(domains)
  end

  def show
    @domain = DomainDecorator.decorate(find_domain)
  end

  def new
    @domain = domains.new
  end

  def create
    @domain = domains.build(domain_params)
    if @domain.save
      flash[:success] = if @domain.secured?
                          t('flash_messages.instance_admin.settings.domain_preparing')
                        else
                          t('flash_messages.instance_admin.settings.domain_created')
                        end
      redirect_to instance_admin_settings_domains_path
    else
      flash.now[:error] = @domain.errors.full_messages.to_sentence
      render :new
    end
  end

  def update
    if @domain.update_attributes(domain_params)
      flash[:success] = t('flash_messages.instance_admin.settings.settings_updated')
      redirect_to instance_admin_settings_domains_path
    else
      flash.now[:error] = @domain.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    if @domain.try(:deletable?) && @domain.try(:destroy)
      flash[:success] = t('flash_messages.instance_admin.settings.domain_deleted')
    else
      flash[:error] = t('flash_messages.instance_admin.settings.domain_not_deleted')
    end
    redirect_to instance_admin_settings_domains_path
  end

  private

  def domains
    @domains ||= @instance.domains
  end

  def find_domain
    @domain ||= @instance.domains.find(params[:id])
  end

  def domain_params
    params.require(:domain).permit(secured_params.domain)
  end
end
