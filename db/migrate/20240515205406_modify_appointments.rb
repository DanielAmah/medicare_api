class ModifyAppointments < ActiveRecord::Migration[6.1]
  def change
    remove_column :appointments, :date, :datetime
    add_column :appointments, :start_time, :datetime
    add_column :appointments, :end_time, :datetime
  end
end
