class AddUrlToConfigration < ActiveRecord::Migration[5.2]
  def change
    add_column :configrations, :web_url, :string
    add_column :configrations, :config_url, :string
  end
end
