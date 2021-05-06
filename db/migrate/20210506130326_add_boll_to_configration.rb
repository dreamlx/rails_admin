class AddBollToConfigration < ActiveRecord::Migration[5.2]
  def change
    add_column :configrations, :boll, :integer
  end
end
