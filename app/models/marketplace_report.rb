# frozen_string_literal: true
class MarketplaceReport < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  mount_uploader :zip_file, MarketplaceReportUploader

  belongs_to :instance

  belongs_to :creator, class_name: 'User'

  serialize :report_parameters, Hash

  state_machine :state, initial: :ready_to_create do
    event :created                    do transition ready_to_create: :created; end
    event :failed                     do transition ready_to_create: :failed; end
  end

  def create_report!
    MarketplaceReports::MarketplaceReportsGenerator.new(type: report_type,
                                                        params: report_parameters).generate_report_file do |generated_report|
      File.open(generated_report, 'r') do |f|
        update! zip_file: f
      end
    end

    created!
  rescue StandardError => e
    self.error = e.message
    failed!
  end

  def to_liquid
    @marketplace_report_drop ||= MarketplaceReportDrop.new(self)
  end
end
