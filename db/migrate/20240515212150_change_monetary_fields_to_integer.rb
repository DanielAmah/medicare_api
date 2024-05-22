class ChangeMonetaryFieldsToInteger < ActiveRecord::Migration[6.1]
  def change
    change_column :invoices, :subtotal, :integer
    change_column :invoices, :discount, :integer
    change_column :invoices, :total, :integer
    change_column :invoice_items, :price, :integer
    change_column :invoice_items, :total, :integer
  end
end
