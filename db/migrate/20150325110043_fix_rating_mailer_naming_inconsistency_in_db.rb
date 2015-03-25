class FixRatingMailerNamingInconsistencyInDb < ActiveRecord::Migration
  def self.up
    WorkflowAlert.where(template_path: "rating_mailer/request_rating_of_host_and_product_from_guest").update_all(template_path: "rating_mailer/request_rating_of_host_from_guest")
  end

  def self.down
  end
end
