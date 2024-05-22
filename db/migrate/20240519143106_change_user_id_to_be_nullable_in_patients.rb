class ChangeUserIdToBeNullableInPatients < ActiveRecord::Migration[6.1]
  def change
    change_column_null :patients, :user_id, true
  end
end
