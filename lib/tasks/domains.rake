# frozen_string_literal: true
namespace :domains do
  task :create_stack, [:stack_name] => :environment do |_t, args|
    stack_name = case args[:stack_name]
                 when 'nm-qa-2' then 'qa-2'
                 when 'nm-qa-1' then 'qa-1'
                 when 'nm-qa-3' then 'qa-3'
                 when 'nm-staging' then 'staging'
                 when 'nm-staging-oregon' then 'oregon-staging'
                 end

    if stack_name.blank?
      puts "Stack name can't be blank"
    else
      Instance.find_each do |instance|
        instance.domains.where(name: "#{instance.name.to_url}.#{stack_name}.near-me.com", instance: instance).first_or_create! do |domain|
          domain.use_as_default = !instance.domains.default.where.not(id: domain.id).exists?
        end
      end
      Domain.all.select { |d| d.name.include?("#{stack_name}.near-me.com") }.each { |d| d.update_column(:secured, true) }

      dnm = Instance.first
      dnm.domains.where(name: "#{stack_name}.near-me.com", instance: dnm).first_or_create! do |domain|
        domain.use_as_default = true
      end.update_column(:secured, true)

      puts 'Stack domains created.'
    end
  end

  desc 'Adds lvh.me domains'
  task create_dev: :environment do
    Domain.find_each do |d|
      d.update_column(:name, d.name.gsub('near-me.com', 'lvh.me'))
      puts d.name
    end
  end
end
