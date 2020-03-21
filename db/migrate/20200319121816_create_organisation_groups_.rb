class CreateOrganisationGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :organisation_groups do |t|
      t.references :group, null: false, foreign_key: true, index: false
      t.references :organisation, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :organisation_groups, %i[group_id organisation_id], unique: true
  end
end
