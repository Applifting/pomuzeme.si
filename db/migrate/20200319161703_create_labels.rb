class CreateLabels < ActiveRecord::Migration[6.0]
  def change
    create_table :labels do |t|
      t.string :name
      t.string :description
      t.references :organisation_group

      t.timestamps
    end
  end
end
