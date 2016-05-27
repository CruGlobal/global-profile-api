class AddGrIdToChild < ActiveRecord::Migration
  def change
    add_column :children, :gr_id, :uuid, unique: true
    add_reference :children, :person, index: true
    drop_table :people_children
  end
end
