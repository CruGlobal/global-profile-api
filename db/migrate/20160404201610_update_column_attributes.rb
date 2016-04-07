class UpdateColumnAttributes < ActiveRecord::Migration
  def change
    change_column_default :employments, :organizational_status, 0
    change_column_default :employments, :funding_source, 0
    change_column_null :employments, :organizational_status, false
    change_column_null :employments, :funding_source, false
  end
end
