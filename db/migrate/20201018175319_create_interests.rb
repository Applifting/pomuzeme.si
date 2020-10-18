class CreateInterests < ActiveRecord::Migration[6.0]
  def change
    create_table :interests do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :description

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        ['asistence pro invalidy', 'dovoz a donáška', 'výpomoc v sociálních službách', 'dobročinné akce'].each do |name|
          Interest.create name: name, code: I18n.transliterate(name).split(' ').join('_')
        end
      end
    end
  end
end
