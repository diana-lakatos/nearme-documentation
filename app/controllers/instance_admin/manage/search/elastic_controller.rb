class InstanceAdmin::Manage::Search::ElasticController < InstanceAdmin::Manage::BaseController
  before_action :find_instance
  before_action :find_previous_job, only: :update

  COMPLETED = 'COMPLETED'.freeze
  RUNNING = 'RUNNING'.freeze
  ERROR = 'ERROR'.freeze

  def show
    job = Delayed::Job.where(id: @instance.last_index_job_id).last
    @job_status = job ? (job.last_error ? ERROR : RUNNING) : COMPLETED
  end

  def update
    if @last_index_job
      flash[:success] = t('flash_messages.search.setting_saved')
      redirect_to instance_admin_manage_search_elastic_path
    else
      @instance.last_index_job_id = ElasticInstanceIndexerJob.perform(update_type: 'rebuild').id
      if @instance.save
        flash[:success] = t('flash_messages.search.setting_saved')
        redirect_to instance_admin_manage_search_elastic_path
      else
        flash[:error] = @instance.errors.full_messages.to_sentence
        render :show
      end
    end
  end

  private

  def find_previous_job
    @last_index_job = Delayed::Job.find_by(id: @instance.last_index_job_id)
  end

  def permitting_controller_class
    self.class.to_s.deconstantize.deconstantize.demodulize
  end

  def find_instance
    @instance = platform_context.instance
  end
end
