class CancellationPoliciesCondition < ActiveRecord::Base
  include Modelable

  belongs_to :cancellation_policy
  belongs_to :condition, class_name: CancellationPolicyCondition
end
