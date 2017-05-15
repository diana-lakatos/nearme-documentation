# frozen_string_literal: true
module Instances
  module InstanceFinder
    INSTANCE_IDS = { # use them in data migrations
      bronxchange: 5014,
      devmesh:     132,
      hallmark:    5011,
      litvault:    198,
      localdriva:  211, # toodoooolooooo
      spacerau:    130,
      spacercom:   5020,
      thevolte:    194,
      toodooloo:   211,
      uot:         195,
      ninjunu:     175,

    }.freeze

    # use it in data migrations ex. Instances::InstanceFinder.get(:uot).each
    def self.get(*instance_names)
      Instance.where(id: INSTANCE_IDS.slice(*instance_names).values)
    end
  end
end
