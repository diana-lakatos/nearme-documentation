class Domain < ActiveRecord::Base
  attr_accessible :name

  belongs_to :instance

end
