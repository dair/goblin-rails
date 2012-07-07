class CreateProjectTeam < ActiveRecord::Migration
  def change
    create_table :project_team, :id => false do |t|
      t.integer :project_key, :null => false
      t.references :person, :null => false
      t.string :status, :limit => 1

      t.timestamps
    end
    
    add_foreign_key(:project_team, :person)
    add_foreign_key(:project_team, :project_key, :column => "project_key", :primary_key => :key)
    
    add_index :project_team, :project_key
    add_index :project_team, :person_id
  end
end
