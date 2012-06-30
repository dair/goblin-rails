class MoneyHistory < ActiveRecord::Base
  set_table_name "money_history"
  attr_accessible :sender_id, :receiver_id, :tdate, :value
  set_primary_key :sender_id, :receiver_id, :tdate
  has_one :Person, :foreign_key => :sender_id
  has_one :Person, :foreign_key => :receiver_id
end
