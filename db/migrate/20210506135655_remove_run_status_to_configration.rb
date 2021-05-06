class RemoveRunStatusToConfigration < ActiveRecord::Migration[5.2]
  def change
    remove_column :configrations, :run_status
  end
end
