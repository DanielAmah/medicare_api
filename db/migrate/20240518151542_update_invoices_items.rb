class UpdateInvoicesItems < ActiveRecord::Migration[6.1]
  def change
    # Add a reference to services in the invoice_items table
    add_reference :invoice_items, :service, null: true, foreign_key: true

    # Remove the price, total and item_name column from invoice_items if it exists
    remove_column :invoice_items, :price, :integer if column_exists?(:invoice_items, :price)
    remove_column :invoice_items, :total, :integer if column_exists?(:invoice_items, :total)
    remove_column :invoice_items, :item_name, :string if column_exists?(:invoice_items, :item_name)
  end
end
