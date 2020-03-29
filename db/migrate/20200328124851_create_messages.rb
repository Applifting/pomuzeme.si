class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      # References
      t.references :volunteer, null: true, foreign_key: true
      t.references :created_by, null: true, foreign_key: { to_table: :users }
      t.references :request, foreign_key: true

      # Non-nullable attributes
      t.string :text, null: false
      t.integer :state, null: false, default: 1 # pending
      t.integer :direction, null: false, default: 1 # outgoing

      # Nullable attributes
      t.integer :channel
      t.string :channel_msg_id
      t.datetime :read_at

      t.timestamps
    end
  end
end
