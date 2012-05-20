class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string :email, null: false, :default => ''
      t.string :login
      t.string :authentication_token
      t.string :name
      t.string :gravatar_id
      t.string :type
      t.string :github_id
      t.string :github_token

      t.timestamps
    end

    add_index :users, :email
    add_index :users, :login, unique: true
  end
end
