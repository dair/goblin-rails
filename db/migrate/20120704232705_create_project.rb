class CreateProject < ActiveRecord::Migration
  def change
    create_table :project do |t|
      t.integer :key, :null => false
      t.string :name, :null => false
      t.text :description
      t.integer :money, :null => false, :default => 0
      t.string :status, :null => false, :default => 'A', :limit => 1

      t.timestamps
    end
    
    add_foreign_key(:project, :project_key, :column => "key", :primary_key => :key)
    add_index :project, :key
  end
end
