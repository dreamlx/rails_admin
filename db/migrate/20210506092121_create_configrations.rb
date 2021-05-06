class CreateConfigrations < ActiveRecord::Migration[5.2]
  def change
    create_table :configrations do |t|
      t.string :run_status
      t.string :symbol

      t.timestamps
    end
  end
end
