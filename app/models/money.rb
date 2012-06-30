class Money < ActiveRecord::Base
  set_table_name "money"
  attr_accessible :balance, :failures, :id, :pin
  set_primary_key "id"
  has_one :Person, :foreign_key => "id"
  
  def self.check_credentials(id, pin)
    ret = false
    begin
      row = find(id)
      if (row["pin"] == pin)
        ret = true
      end
    rescue ActiveRecord::RecordNotFound       
    end
    
    return ret
  end
end
