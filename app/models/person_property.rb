class PersonProperty < ActiveRecord::Base
  set_table_name "person_property"
  attr_accessible :person, :property, :value
end
