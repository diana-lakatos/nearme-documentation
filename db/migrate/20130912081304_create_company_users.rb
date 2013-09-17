class CreateCompanyUsers < ActiveRecord::Migration

  class User < ActiveRecord::Base
  end

  class Company < ActiveRecord::Base
    belongs_to :creator, :class_name => "CreateCompanyUsers::User"

    has_many :company_users, :dependent => :destroy, :class_name => "CreateCompanyUsers::CompanyUser"
    has_many :users, :through => :company_users
  end

  class CompanyUser < ActiveRecord::Base
    belongs_to :company, :class_name => "CreateCompanyUsers::Company"
    belongs_to :user, :class_name => "CreateCompanyUsers::User"
  end


  def change
    create_table :company_users do |t|
      t.belongs_to :company
      t.belongs_to :user

      t.timestamps
    end
    add_index :company_users, :company_id
    add_index :company_users, :user_id

    # Add companies creators as company users
    Company.all.each do |company|
      company.users << company.creator if company.creator.present? and !company.users.include?(company.creator)
    end
  end 
end
