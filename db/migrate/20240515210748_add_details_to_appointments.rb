class AddDetailsToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :purpose, :string
    add_column :appointments, :description, :text
    add_column :appointments, :communication_preferences, :string
  end
end
