class PlatformContact < ActiveRecord::Base
  validates :email, presence: true, email: true
  validates_presence_of :name

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |model|
        csv << model.attributes.values_at(*column_names)
      end
    end
  end
end
