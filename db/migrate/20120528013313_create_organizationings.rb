class CreateOrganizationings < ActiveRecord::Migration
  def change
    create_table :organizationings do |t|
      t.integer :owner_id
      t.integer :organization_id
    end
  end
end
