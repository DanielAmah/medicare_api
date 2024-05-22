class ChangeInvoiceAssociationToPatient < ActiveRecord::Migration[6.1]
  def change
    remove_reference :invoices, :user, index: true, foreign_key: true
    add_reference :invoices, :patient, null: true, index: true, foreign_key: true
  end
end
