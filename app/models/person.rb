class Person < ActiveRecord::Base
  set_table_name 'person'
  attr_accessible :gender, :id, :name
end
