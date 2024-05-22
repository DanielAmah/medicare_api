class AddDetailsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :title, :string
    add_column :users, :phone, :string
  end
end
