class CreateAppointments < ActiveRecord::Migration[6.1]
  def change
    create_table :appointments do |t|
      t.datetime :date
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
