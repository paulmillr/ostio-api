class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.integer :github_id
      t.string :login
      t.string :authentication_token
      t.string :name
      t.string :email, default: ''
      t.string :gravatar_id
      t.string :type
      t.string :github_token

      t.timestamps
    end

    add_index :users, :login, unique: true
    add_index :users, :authentication_token
    add_index :users, :email
  end
end
