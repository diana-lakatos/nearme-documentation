# frozen_string_literal: true
class SubmitForm
  class OrderActions
    def initialize(controller)
      @controller = controller
    end

    def notify(form:, **)
      @form = form
      lister_confirm
      schedule_expiry
      return unless form.try(:with_charge)
      if create_item?
        create_item
      elsif payment.present?
        capture_payment
      end
    end

    protected

    def lister_confirm
      model.lister_confirmed! if @form.try(:lister_confirm) && lister?
    end

    def schedule_expiry
      model.schedule_expiry if @form.try(:schedule_expiry)
    end

    def create_item?
      model.recurring? || model.payment_subscription
    end

    def create_item
      Order::OrderItemCreator.new(model).create
    end

    def capture_payment
      payment.authorized? ? payment.capture! : payment.purchase!
    end

    def model
      @form.send(:model)
    end

    def lister?
      @controller.send(:lister?)
    end

    def payment
      @controller.send(:payment)
    end
  end
end
