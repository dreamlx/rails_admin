class AddMajorPeriodToConfigration < ActiveRecord::Migration[5.2]
  def change
    add_column :configrations, :major_period, :integer
    add_column :configrations, :minor_period, :integer
  end
end
