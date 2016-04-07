class UpdateIndexOnPeople < ActiveRecord::Migration
  def change
    remove_index :people, :gr_id
    add_index :people, [:gr_id, :ministry_id], unique: true
  end
end
