class AddComapanyNameToPerson < ActiveRecord::Migration[7.1]
  def change
    add_column :people, :company_name, :string
  end
end
