class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.decimal :amount
      t.references :patient, null: false, foreign_key: true
      t.string :status
      t.string :payment_method

      t.timestamps
    end
  end
end
