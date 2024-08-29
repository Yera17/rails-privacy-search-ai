class CreateSources < ActiveRecord::Migration[7.1]
  def change
    create_table :sources do |t|
      t.text :identification_method
      t.text :identified_text
      t.references :person, null: false, foreign_key: true

      t.timestamps
    end
  end
end
