class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.integer :repo_id, null: false
      t.integer :user_id, null: false
      t.integer :number, null: false
      t.string :title, null: false

      t.timestamps
    end

    add_index :topics, :number
  end
end
