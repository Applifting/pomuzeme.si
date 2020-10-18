class AddOtherSkillsAndInterestsToVolunteers < ActiveRecord::Migration[6.0]
  def change
    add_column :volunteers, :other_skills, :string
    add_column :volunteers, :other_interests, :string
  end
end
