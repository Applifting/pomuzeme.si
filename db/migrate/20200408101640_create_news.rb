class CreateNews < ActiveRecord::Migration[6.0]
  def change
    create_table :news do |t|
      t.string :title, null: false
      t.text :body
      t.integer :publication_type, null: false
      t.string :url
      t.string :outlet

      t.timestamps
    end
  end
end
