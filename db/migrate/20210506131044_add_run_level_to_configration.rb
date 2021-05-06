class AddRunLevelToConfigration < ActiveRecord::Migration[5.2]
  def change
    add_column :configrations, :run_level, :string
  end
end
