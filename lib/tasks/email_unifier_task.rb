module EmailUnifierTask
  class EmailTemplate < ActiveRecord::Base
  end

  def templates(path)
    EmailTemplate.where("path like ?", path).tap do |results|
      puts "Found #{results.count} templates for: #{path}"
    end
  end

  def workflow_alerts(path)
    WorkflowAlert.where("template_path like ?", path).tap do |results|
      puts "Found #{results.count} alerts for: #{path}"
    end
  end

  def update(fields, from, to)
    Array(fields).each { |field| field.gsub!(/\b#{from}\b\.(\b[a-z]+)/, "#{to}.\\1") }
  end
end
