class AddKbarPeriodToConfigration < ActiveRecord::Migration[5.2]
  def change
    add_column :configrations, :kbar_period, :integer
  end
end
