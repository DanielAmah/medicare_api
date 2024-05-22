class AddMoreDetailsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :secondary_email, :string
  end
end
