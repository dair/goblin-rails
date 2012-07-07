class CreateProjectKey < ActiveRecord::Migration
  def change
    create_table :project_key, :id => false do |t|
#      t.integer :key, :null => false
      t.primary_key :key
    end
    
    add_index :project_key, :key
  end
end
