desc 'log sql queries from rakes, ex: rake log db:migrate'
task log: :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
