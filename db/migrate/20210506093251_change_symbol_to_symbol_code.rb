class ChangeSymbolToSymbolCode < ActiveRecord::Migration[5.2]
  def change
    rename_column :configrations, :symbol, :symbol_code
  end
end
