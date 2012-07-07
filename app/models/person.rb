class Person < ActiveRecord::Base
  set_table_name 'person'
  attr_accessible :gender, :id, :name
  has_one :money, :class_name => "Money", :foreign_key => :id
  has_many :person_property, :class_name => "PersonProperty", :foreign_key => :pers_id
  has_many :project_team, :class_name => "ProjectTeam", :foreign_key => :person_id 
end
