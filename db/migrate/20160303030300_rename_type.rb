class RenameType < ActiveRecord::Migration
  def change
    rename_column :users, :type, :typeof
  end
end
