class Person < ActiveRecord::Base
  set_table_name 'person'
  attr_accessible :gender, :id, :name, :race
  set_primary_key 'id'
  validates :name, :id, :presence => true
  validates :name, :length => { :maximum => 50 }
  validates :gender, :length => { :is => 1 }
  validates :gender, :inclusion => { :in => %w(M F), :message => "Invalid GENDER: only M or F" }, :allow_nil => true
  validates :race, :length => { :is => 1 }, :allow_nil => true
  
  def self.getName(id)
    ret = ''
    begin
      row = find(id)
      ret = row["name"]
    rescue ActiveRecord::RecordNotFound
    end
    return ret
  end
end
