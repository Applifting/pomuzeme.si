# frozen_string_literal: true

class CreateRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :requests do |t|
      t.references :created_by, null: false, references: :users
      t.references :closed_by, references: :users
      t.references :coordinator, references: :users
      t.references :organisation, null: false
      t.integer :required_volunteer_count, null: false
      t.integer :state, null: false, default: 1
      t.integer :closed_state
      t.string :text, limit: 160, null: false
      t.string :subscriber, limit: 150, null: false
      t.string :subscriber_phone, limit: 20, null: false
      t.string :closed_note, limit: 500
      t.datetime :fullfillment_date
      t.datetime :closed_at
      t.datetime :state_last_updated_at

      t.timestamps
    end
  end
end

