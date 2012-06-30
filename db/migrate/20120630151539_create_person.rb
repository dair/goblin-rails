class CreatePerson < ActiveRecord::Migration
  def change
    create_table :person do |t|
      t.integer :id
      t.string :name, :limit => 50, :null => false
      t.string :gender, :limit => 1, :null => false
      t.string :race, :limit => 1, :null => false, :default => "H"
    end
    add_index :person, :id
  end
end
