class PersonProp < ActiveRecord::Base
  set_table_name "person_prop"
  attr_accessible :pers_id, :prop_id, :value
  
  belongs_to :person, :class_name => "Person", :foreign_key => :pers_id
  belongs_to :property, :class_name => "Property", :foreign_key => :prop_id
end
