class Property < ActiveRecord::Base
  set_table_name "property"
  attr_accessible :name, :police
  
  has_many :person_property, :class_name => "PersonProperty", :foreign_key => :prop_id
end
