class Property < ActiveRecord::Base
  set_table_name "property"
  attr_accessible :name, :police
end
