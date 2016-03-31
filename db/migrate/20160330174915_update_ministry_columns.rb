class UpdateMinistryColumns < ActiveRecord::Migration
  def change
    rename_column :ministries, :ministry_id, :gr_id
    add_reference :ministries, :area, foreign_key: { on_delete: :nullify, on_update: :cascade }
  end
end
