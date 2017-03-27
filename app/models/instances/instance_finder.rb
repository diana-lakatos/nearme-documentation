# frozen_string_literal: true
module Instances
  module InstanceFinder
    INSTANCE_IDS = { # use them in data migrations
      uot:         193,
      local_drive: 209,
      the_volter:  192,
      lit_volte:   196,
      hallmark:    5011,
      bronxchange: 5012,
      spacer:      5018
    }.freeze

    # use it in data migrations ex. Instances::InstanceFinder.get(:uot).each
    def self.get(*instance_names)
      Instance.where(id: INSTANCE_IDS.slice(*instance_names).values)
    end
  end
end
