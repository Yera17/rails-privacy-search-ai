class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents do |t|
      t.string :file_name
      t.text :text
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
