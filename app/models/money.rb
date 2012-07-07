class Money < ActiveRecord::Base
  set_primary_key :id
  belongs_to :person, :foreign_key => "id"
  attr_accessible :balance, :failures, :pin
  
  def self.checkCredentials(id, pwd)
    ret = false
    begin
      line = find(id)
      ret = (line.pin == pwd)
    rescue ActiveRecord::RecordNotFound
      
    end
    return ret
  end
end
