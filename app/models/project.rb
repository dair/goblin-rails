class Project < ActiveRecord::Base
  set_table_name "project"
  attr_accessible :key, :description, :money, :name, :status
  has_many :project_team, :class_name => "ProjectTeam"
  has_one :project_leader, :class_name => "ProjectTeam", :conditions => { :status => 'L'}
  
  def self.generateKey()
    found = true
    key = 0
    begin
      key = rand(10000000..99999999)
      r = where(:key => key)
      found = (r.size > 0)
    end while found
    
    return key
  end
  
  def self.getItemByKey(key)
    r = where(:key => key, :status => 'A').order("created_at DESC").limit(1)
    if (r.size > 0)
      return r[0]
    else
      return nil
    end
  end
  
  def self.editItem(key, name, description, personId)
    transaction do
      money = 0
      if (key > 0)
        r = where(:key => key, :status => 'A')
        for i in r
          money = i[:money]
          i[:status] = 'H'
          i.save
        end
      end
      
      item = Hash.new
      item[:name] = name
      item[:description] = description
      item[:money] = money
      if (key == 0)
        item[:key] = self.generateKey()
      else
        item[:key] = key
      end 
      row = Project.new(item)
      row.save
    end
  end
  
  
end
