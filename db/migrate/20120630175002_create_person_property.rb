class CreatePersonProperty < ActiveRecord::Migration
  def change
    create_table :person_property, :id => false do |t|
      t.integer :pers_id
      t.integer :prop_id
      t.text :value
    end
    
    add_index :person_property, :pers_id
    add_index :person_property, :prop_id
    add_foreign_key(:person_property, :person, column: :pers_id)
    add_foreign_key(:person_property, :property, column: :prop_id)
  end
end
