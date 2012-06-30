class Money < ActiveRecord::Base
  belongs_to :person, :foreign_key => "id" 
  attr_accessible :balance, :failures, :pin
end
