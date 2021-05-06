class AddDateRangeToConfigration < ActiveRecord::Migration[5.2]
  def change
    add_column :configrations, :start_from, :string
    add_column :configrations, :to_end, :string
  end
end
