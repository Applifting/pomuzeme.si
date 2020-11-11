class RelaxRequestsNullConstraints < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :source, :integer, default: 1

    reversible do |dir|
      dir.up do
        change_column :requests, :created_by_id, :integer, null: true
        change_column :requests, :organisation_id, :integer, null: true
      end

      dir.down do
        change_column :requests, :created_by_id, :integer, null: false
        change_column :requests, :organisation_id, :integer, null: false
      end
    end
  end
end
