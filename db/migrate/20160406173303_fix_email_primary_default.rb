class FixEmailPrimaryDefault < ActiveRecord::Migration
  def change
    change_column_null :email_addresses, :primary, false
    change_column_default :email_addresses, :primary, false
  end
end
