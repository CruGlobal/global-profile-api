class AddStaffAccountToEmployment < ActiveRecord::Migration
  def change
    add_column :employments, :staff_account, :string
  end
end
