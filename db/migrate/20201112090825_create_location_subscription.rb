class CreateLocationSubscription < ActiveRecord::Migration[6.0]
  def change
    create_table :location_subscriptions do |t|
      t.integer :distance
      t.string :phone
      t.timestamps
    end
  end
end
