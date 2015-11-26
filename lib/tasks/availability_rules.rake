namespace :availability_rules do

  desc 'converts availability rules to new format'
  task convert: :environment do
    obj_count = ActiveRecord::Base.connection.execute("
      SELECT COUNT( DISTINCT(target_type, target_id, open_hour, open_minute, close_hour, close_minute))
      FROM availability_rules ar
      WHERE deleted_at IS NULL AND array_length(days, 1) IS NULL AND
      NOT EXISTS ( SELECT 1 FROM availability_rules ar_sub WHERE ar.target_type = ar_sub.target_type AND ar.target_id = ar_sub.target_id AND ar.open_hour = ar_sub.open_hour AND ar.open_minute = ar_sub.open_minute AND ar.close_hour = ar_sub.close_hour AND ar.close_minute = ar_sub.close_minute AND array_length(days, 1) > 0);
    ")
    p "Objects to create: #{obj_count.first['count']}"
    result = ActiveRecord::Base.connection.execute("
      INSERT INTO availability_rules (target_type, target_id, open_hour, open_minute, close_hour, close_minute, days, created_at, updated_at)
      SELECT target_type, target_id, open_hour, open_minute, close_hour, close_minute, array_agg(DISTINCT(ar.day) ORDER BY ar.day) AS days, NOW(), NOW()
      FROM availability_rules ar
      WHERE deleted_at IS NULL AND array_length(days, 1) IS NULL AND
      NOT EXISTS ( SELECT 1 FROM availability_rules ar_sub WHERE ar.target_type = ar_sub.target_type AND ar.target_id = ar_sub.target_id AND ar.open_hour = ar_sub.open_hour AND ar.open_minute = ar_sub.open_minute AND ar.close_hour = ar_sub.close_hour AND ar.close_minute = ar_sub.close_minute AND array_length(days, 1) > 0)
      GROUP BY target_type, target_id,open_hour, open_minute, close_hour, close_minute;
    ")
    p "Objects created: #{result.cmd_status}"
  end

  desc 'sets deleted_at to old availability_rules'
  task delete_old: :environment do
    result = ActiveRecord::Base.connection.execute "
      UPDATE availability_rules SET deleted_at = NOW()
      WHERE deleted_at IS NULL AND array_length(days, 1) IS NULL AND availability_rules.day IS NOT NULL;
    "
    p "Objects updated: #{result.cmd_status}"
  end

end