class FixWorkflowStepsAfterRename < ActiveRecord::Migration
  def up
    WorkflowStep.unscoped.where('associated_class like ?', "%Workflow::Guest%").find_each do |ws|
      ws.update_column(:associated_class, ws.associated_class.gsub('Workflow::Guest', 'Workflow::Enquirer'))
    end

    WorkflowStep.unscoped.where('associated_class like ?', "%Workflow::Host%").find_each do |ws|
      ws.update_column(:associated_class, ws.associated_class.gsub('Workflow::Host', 'Workflow::Lister'))
    end

  end

  def down
  end
end
