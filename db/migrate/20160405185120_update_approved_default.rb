class UpdateApprovedDefault < ActiveRecord::Migration
  def change
    change_column_null :people, :approved, false
    change_column_default :people, :approved, true
    change_column_null :people, :is_secure, false
    change_column_default :people, :is_secure, false
  end
end
