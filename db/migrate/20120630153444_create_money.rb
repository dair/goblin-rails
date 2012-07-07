class CreateMoney < ActiveRecord::Migration
  def change
    create_table :money, :id => false do |t|
      t.integer :id, :null => false
      t.integer :balance, :null => false, :default => 0
      t.string :pin, :limit => 10, :null => false
      t.integer :failures, :null => false, :default => 0
    end
    primary_key(:money, :id)
    add_foreign_key(:money, :person, column: :id)
    add_index :money, :id
  end
end
