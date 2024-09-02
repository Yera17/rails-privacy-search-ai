class AddDocumentRefToPeople < ActiveRecord::Migration[7.1]
  def change
    add_reference :people, :document, null: false, foreign_key: true
  end
end
