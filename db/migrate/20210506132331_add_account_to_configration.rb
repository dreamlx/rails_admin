class AddAccountToConfigration < ActiveRecord::Migration[5.2]
  def change
    add_column :configrations, :sim_account, :string
    add_column :configrations, :sim_pwd, :string
    add_column :configrations, :future_account, :string
    add_column :configrations, :future_pwd, :string
    add_column :configrations, :future_company, :string
  end
end
