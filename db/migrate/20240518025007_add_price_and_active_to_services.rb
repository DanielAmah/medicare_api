class AddPriceAndActiveToServices < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :price, :decimal, precision: 10, scale: 2
    add_column :services, :active, :boolean, default: true
  end
end
