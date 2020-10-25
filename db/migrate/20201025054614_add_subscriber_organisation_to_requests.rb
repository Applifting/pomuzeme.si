class AddSubscriberOrganisationToRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :subscriber_organisation, :string
  end
end
