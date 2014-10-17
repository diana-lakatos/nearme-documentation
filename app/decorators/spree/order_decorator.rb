class Spree::OrderDecorator < Draper::Decorator
  include MoneyRails::ActionViewExtension
  include Draper::LazyHelpers

  delegate_all

  def my_order_status_info
    status_info("Pending payment")
  end

  private

  def status_info(text)
    unless completed?
      tooltip(text, "<span class='tooltip-spacer'>i</span>".html_safe, {class: 'ico-pending'}, nil)
    else
      "<i class='ico-check'></i>".html_safe
    end
  end
end
