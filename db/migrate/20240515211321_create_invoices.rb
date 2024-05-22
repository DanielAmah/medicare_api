class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.decimal :subtotal
      t.decimal :discount
      t.decimal :tax_rate
      t.decimal :total
      t.text :notes

      t.timestamps
    end
  end
end
