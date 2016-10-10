Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time        = 1.day

class Delayed::Job < ActiveRecord::Base
  belongs_to :platform_context_detail, polymorphic: true
end
