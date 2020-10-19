class CreateSkills < ActiveRecord::Migration[6.0]
  def change
    create_table :skills do |t|
      t.string :name, null: false
      t.string :code, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        ['řidičský průkaz B', 'všeobecná sestra', 'ošetřovatel/ošetřovatelka', 'sanitář'].each do |name|
          Skill.create name: name, code: I18n.transliterate(name).split(' ').map(&:downcase).join('_')
        end
      end
    end
  end
end
