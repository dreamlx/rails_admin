class AddMemoToConfigration < ActiveRecord::Migration[5.2]
  def change
    add_column :configrations, :memo, :text
  end
end
