class AddPartnerSignupFieldsToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :signup_partial_name, :string
    add_column :groups, :signup_cta_button_text, :string
    add_column :groups, :signup_tagline_text, :string
  end
end
