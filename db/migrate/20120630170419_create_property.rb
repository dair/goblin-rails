class CreateProperty < ActiveRecord::Migration
  def change
    create_table :property do |t|
      t.string :name, :limit => 50, :null => false
      t.string :police, :limit => 1, :null => false
    end
  end
end
