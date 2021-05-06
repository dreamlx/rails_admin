class AddLongShortJudgmentToConfigration < ActiveRecord::Migration[5.2]
  def change
    add_column :configrations, :long_short_judgment, :string
  end
end
