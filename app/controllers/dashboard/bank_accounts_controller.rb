class Dashboard::BankAccountsController < Dashboard::BaseController
  before_filter :find_payment_gateways
  before_filter :find_user_bank_accounts
  before_filter :find_bank_account, except: :index

  def index
  end

  def new
    @bank_account = @instance_client.bank_accounts.build(payment_gateway: @payment_gateway)
  end

  def create
    @bank_account = @instance_client.bank_accounts.build(bank_accounts_params)
    @bank_account.payment_gateway = @payment_gateway
    if @bank_account.save
      flash[:success] = t('flash_messages.manage.bank_accounts.added')
      redirect_to dashboard_payment_gateway_bank_accounts_path(@payment_gateway)
    else
      flash.now[:error] = t('flash_messages.manage.bank_accounts.not_added')
      render :new
    end
  end

  def destroy
    @bank_account.destroy
    flash[:deleted] = t('flash_messages.manage.bank_accounts.deleted')
    redirect_to dashboard_payment_gateway_bank_accounts_path(@payment_gateway)
  end

  def update
    @bank_account.attributes = bank_accounts_params
    if @bank_account.verify!
      flash[:success] = t('flash_messages.manage.bank_accounts.verified')
    else
      flash[:error] = t('flash_messages.manage.bank_accounts.not_verified')
      flash[:notice] = @bank_account.errors.full_messages.join("\n")
    end
    redirect_to action: :index
  end

  private

  def find_payment_gateways
    @payment_gateways = PaymentGateway.with_bank_accounts.mode_scope
  end

  def find_user_bank_accounts
    @bank_accounts = BankAccount.where(instance_client: current_user.instance_clients)
  end

  def find_bank_account
    @bank_account = @bank_accounts.find(params[:id])
  end

  def find_instance_clients
    @instance_clients = current_user.instance_clients
  end

  def bank_accounts_params
    params.require(:bank_account).permit(secured_params.bank_account)
  end
end
