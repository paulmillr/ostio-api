class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.integer :user_id, null: false
      t.string :name

      t.timestamps
    end
  end
end
