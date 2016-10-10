class InstanceAdmin::Settings::ResourceRecordsController < InstanceAdmin::Settings::BaseController
  respond_to :html, :json
  helper_method :domain, :resource

  def index
    respond_with collection
  end

  def new
    @resource = ResourceRecordForm.new(hosted_zone_name: domain.hosted_zone.name, hosted_zone_id: domain.hosted_zone.id, balancer: domain.balancer)
  end

  def show
    respond_with resource
  end

  def create
    @resource = create_resource

    if @resource.process
      flash[:notice] = 'Record has been created.'
      respond_with resource, location: instance_admin_settings_domain_path(domain)
    else
      flash[:error] = 'Problem with saving new record.'
      render :new
    end
  end

  def destroy
    if resource
      delete_resource
      flash[:notice] = 'DNS Record has been removed.'
    else
      flash[:error] = 'Record could not be removed. Record not found'
    end
  rescue Aws::Route53::Errors::ServiceError
    flash[:error] = $ERROR_INFO.to_s
  rescue Aws::Route53::Errors::HostedZoneNotEmpty
    flash[:error] = $ERROR_INFO.to_s
  ensure
    respond_with resource, location: instance_admin_settings_domain_path(domain)
  end

  private

  def create_resource
    @resource ||= ResourceRecordForm.new(params[:resource_record].merge(balancer: domain.balancer))
  end

  def delete_resource
    ResourceRecordRepository.delete_resource_record hosted_zone, resource
  end

  def resource
    @resource ||= ResourceRecordRepository
                  .find_by_zone_and_name_and_type(hosted_zone, *decode_resource_record_id)
  end

  def collection
    hosted_zone.records
  end

  def domain
    @domain = DomainDecorator.decorate Domain.find(params[:domain_id])
  end

  def hosted_zone
    domain.hosted_zone
  end

  def decode_resource_record_id
    params[:id].tr('_', '.').split('-')
  end

  def permitting_controller_class
    'AdministratorRestrictedAccess'
  end
end
