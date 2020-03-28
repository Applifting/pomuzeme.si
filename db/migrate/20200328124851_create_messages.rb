class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.references :volunteer, null: false, foreign_key: true
      t.string :text, null: false
      t.references :created_by, null: true, foreign_key: { to_table: :users }
      t.references :request, foreign_key: true
      t.boolean :read, default: false
      t.integer :status, null: false

      t.timestamps
    end
  end
end
