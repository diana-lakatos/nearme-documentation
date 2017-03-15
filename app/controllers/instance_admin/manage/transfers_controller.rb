class InstanceAdmin::Manage::TransfersController < InstanceAdmin::Manage::BaseController
  skip_before_filter :check_if_locked
  defaults resource_class: PaymentTransfer, collection_name: 'transfers', instance_name: 'transfer'

  def index
    respond_to do |format|
      format.html do
        transfers = transfers_from_params.paginate(page: params[:page], per_page: reports_per_page)
        @payment_transfers = PaymentTransferDecorator.decorate_collection(transfers)
      end

      format.csv { send_data generate_csv(PaymentTransferDecorator.decorate_collection(transfers_from_params)) }
    end
  end

  def not_failed
    resource.update_attribute(:failed_at, nil)
    flash[:notice] = t('flash_messages.payments.marked_as_not_failed')
    redirect_to instance_admin_manage_transfer_path(resource)
  end

  def transferred
    resource.mark_transferred
    flash[:notice] = t('flash_messages.payments.marked_transferred')
    redirect_to instance_admin_manage_transfer_path(resource)
  end

  def generate
    if Company.needs_payment_transfer.any?
      Company.needs_payment_transfer.uniq.find_each do |company|
        SchedulePaymentTransferJob.perform(company.id)
      end
      flash[:notice] = t('flash_messages.instance_admin.settings.payments.payment_transfers.generated')
    else
      flash[:error] = t('flash_messages.instance_admin.settings.payments.payment_transfers.no_new_transfers')
    end
    redirect_to action: :index
  end

  def payout
    if resource.transferred?
      flash[:notice] = t('flash_messages.payments.payout_already_successful')
    else
      if resource.pending?
        flash[:warning] = t('flash_messages.payments.payout_pending_verification')
      else
        resource.payout
        if resource.transferred?
          flash[:notice] = t('flash_messages.payments.payout_successful')
        elsif resource.payout_attempts.last
          if resource.payout_attempts.last.confirmation_url.present?
            flash[:warning] = t('flash_messages.payments.payout_need_confirmation')
          end
        else
          flash[:error] = t('flash_messages.payments.payout_failed')
        end
      end
    end
    redirect_to instance_admin_manage_transfer_path(resource)
  end

  protected

  def transfers_from_params
    transfers_scope = PaymentTransfer.includes(:payout_attempts).order('created_at DESC')
    scope_search_form = InstanceAdmin::PaymentTransferSearchForm.new
    scope_search_form.validate(params)

    SearchService.new(transfers_scope).search(scope_search_form.to_search_params)
  end

  def collection_allowed_scopes
    %w(pending transferred)
  end

  def collection
    @transfers ||= end_of_association_chain.order('created_at DESC').paginate(page: params[:page])
  end

  private

  def generate_csv(transfers)
    CSV.generate do |csv|
      csv << PaymentTransferDecorator.column_headings_for_report

      transfers.each do |resource|
        csv << resource.column_values_for_report
      end
    end
  end

end
