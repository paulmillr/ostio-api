class ForeignKeys < ActiveRecord::Migration
  def change
    change_table :topics do |t|
      t.foreign_key :repos
      t.foreign_key :users
    end

    change_table :repos do |t|
      t.foreign_key :users
    end

    change_table :posts do |t|
      t.foreign_key :topics
      t.foreign_key :users
    end

    change_table :organizationings do |t|
      t.foreign_key :users, column: :owner_id
      t.foreign_key :users, column: :organization_id
    end
  end
end
