class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.integer :repo_id, null: false
      t.integer :number, null: false
      t.string :title, null: false
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end

    add_index :topics, :number
  end
end
