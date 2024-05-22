class CreateInvoiceItems < ActiveRecord::Migration[6.1]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string :item_name
      t.decimal :price
      t.integer :quantity
      t.decimal :total

      t.timestamps
    end
  end
end
