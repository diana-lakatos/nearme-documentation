class PaymentGateway < ActiveRecord::Base
  validates :name, :settings, presence: true
  serialize :settings, Hash

  before_save :set_method_name

  def set_method_name
    self.method_name = name.downcase.gsub(" ", "_")
  end

  METHODS = [:balanced, :paypal, :stripe]

  METHODS.each do | method |
    define_singleton_method(method) do
      where(method_name: method).first
    end
  end

  def self.modes
    [:test, :live]
  end
end
