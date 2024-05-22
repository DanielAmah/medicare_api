class AddEmailToPatients < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :email, :string
    add_column :patients, :age, :integer
    add_column :patients, :gender, :string
    add_column :patients, :blood_type, :string
  end
end
