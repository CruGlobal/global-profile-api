class RemoveEmploymentColumnsFromPerson < ActiveRecord::Migration
  def change
    remove_columns :people, :organizational_status, :funding_source, :date_joined_staff, :date_left_staff
  end
end
