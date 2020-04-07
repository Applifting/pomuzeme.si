class AddSubscriberEmailToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :subscriber_email, :string
  end
end
