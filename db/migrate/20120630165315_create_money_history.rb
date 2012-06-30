class CreateMoneyHistory < ActiveRecord::Migration
  def change
    create_table :money_history, :id => false do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.timestamp :tdate
      t.integer :value
    end
    
    add_foreign_key(:money_history, :person, column: :sender_id)
    add_foreign_key(:money_history, :person, column: :receiver_id)
    add_index :money_history, :sender_id
    add_index :money_history, :receiver_id
    add_index :money_history, :tdate
  end
end
