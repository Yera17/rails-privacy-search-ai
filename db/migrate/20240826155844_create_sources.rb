class CreateSources < ActiveRecord::Migration[7.1]
  def change
    create_table :sources do |t|
      t.text :url
      t.references :person, null: false, foreign_key: true

      t.timestamps
    end
  end
end
