class AddPositionSizeToConfigration < ActiveRecord::Migration[5.2]
  def change
    add_column :configrations, :position_size, :integer
  end
end
