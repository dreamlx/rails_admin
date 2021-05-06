class AddTitleToConfigration < ActiveRecord::Migration[5.2]
  def change
    add_column :configrations, :title, :string
  end
end
