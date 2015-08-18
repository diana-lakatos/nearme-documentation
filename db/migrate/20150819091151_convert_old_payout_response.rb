class ConvertOldPayoutResponse < ActiveRecord::Migration

  class Payout < ActiveRecord::Base
    attr_encrypted :old_response, :key => DesksnearMe::Application.config.secret_token, :attribute => 'encrypted_response'
    attr_encrypted :response, :key => DesksnearMe::Application.config.secret_token, marshal: true
  end

  def up
    Payout.all.each do |payout| 
      begin
        payout.response = payout.old_response
        payout.save
        puts "Successfuly encrypted payout - #{payout.id}"
      rescue
        puts "Respone read failed"
      end
    end
  end

  def down

  end
end
