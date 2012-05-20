class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :topic_id, null: false
      t.integer :user_id, null: false
      t.text :text
      t.datetime :created_at

      t.timestamps
    end
  end
end
