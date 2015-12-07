class CreateCommunityReportingAggregates < ActiveRecord::Migration
  def change
    create_table :community_reporting_aggregates do |t|
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.integer :instance_id, null: false
      t.hstore :statistics, default: '', null: false
      t.datetime :created_at,         :null => false
      t.datetime :updated_at,         :null => false
    end

    add_index :community_reporting_aggregates, [:instance_id, :start_date, :end_date], unique: true, name: 'index_community_reporting_aggregates_on_dates'
  end
end
