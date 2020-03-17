class CreateRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :requests do |t|
      t.string :text, null: false, limit: 160
      t.integer :required_volunteer_count, null: false
      t.string :subscriber, null: false
      t.string :subscriber_phone, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :coordinator, foreign_key: { to_table: :users }
      t.references :organisation, null: false, foreign_key: true
      t.string :status, null: false, default: 'new'
      t.datetime :fulfillment_date, null: false
      t.string :closed_note
      t.datetime :closed_at
      t.string :closed_status
      t.references :closed_by, foreign_key: { to_table: :users }
      t.boolean :is_published, null: false, default: false

      t.timestamps
    end
  end
end

