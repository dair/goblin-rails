class MoneyHistory < ActiveRecord::Base
  set_table_name "money_history"
  attr_accessible :receiver_id, :sender_id, :tdate, :value
  belongs_to :person, :foreign_key => "receiver_id"
  belongs_to :person, :foreign_key => "sender_id"
end
