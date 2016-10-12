require 'test_helper'
require './lib/tasks/email_unifier_task'

class EmailUnifierTaskTest < ActiveSupport::TestCase
  include EmailUnifierTask
  context 'updating' do
    should 'succeed' do
      content = '{{owner.first_name}}, {{ user.first_name }} decided to be no longer collaborator on {{ transactable.name }}'

      update([content], 'user', 'enquirer')
      update([content], 'owner', 'lister')

      assert_equal content, '{{lister.first_name}}, {{ enquirer.first_name }} decided to be no longer collaborator on {{ transactable.name }}'
    end

    should 'skip' do
      content = '{{owner.first_name}}, user decided to be {{lister.last_name}} no longer {{owner.super_other_name}} collaborator on {{ transactable.name }} account.'

      update([content], 'user', 'enquirer')
      update([content], 'owner', 'lister')
      update([content], 'account', 'membership')

      assert_equal content, '{{lister.first_name}}, user decided to be {{lister.last_name}} no longer {{lister.super_other_name}} collaborator on {{ transactable.name }} account.'
    end
  end
end
