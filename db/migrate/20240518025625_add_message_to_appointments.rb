class AddMessageToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :message, :text
  end
end
