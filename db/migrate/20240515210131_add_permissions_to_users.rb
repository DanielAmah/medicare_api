class AddPermissionsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :patient_permissions, :integer, default: 0
    add_column :users, :appointment_permissions, :integer, default: 0
    add_column :users, :invoice_permissions, :integer, default: 0
    add_column :users, :payment_permissions, :integer, default: 0
  end
end
