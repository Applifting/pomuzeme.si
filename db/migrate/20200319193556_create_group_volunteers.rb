class CreateGroupVolunteers < ActiveRecord::Migration[6.0]
  def change
    create_table :group_volunteers do |t|
      t.references :group, null: false, foreign_key: true
      t.references :volunteer, null: false, foreign_key: true
      t.integer :recruitment_status
      t.integer :source
      t.boolean :is_exclusive, default: false
      t.bigint :coordinator_id, foreign_key: { to_table: :users }
      t.text :comments

      t.timestamps
    end
  end
end
