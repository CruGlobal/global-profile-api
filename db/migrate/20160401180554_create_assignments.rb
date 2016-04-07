class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.references :person, index: true, foreign_key:  { on_delete: :restrict, on_update: :cascade }
      t.references :ministry, index: true, foreign_key:  { on_delete: :restrict, on_update: :cascade }
      t.uuid :gr_id
      t.integer :mcc, default: 0, null: false
      t.integer :position_role, default: 0, null: false
      t.integer :scope, default: 0, null: false

      t.timestamps null: false
    end
    add_index :assignments, :gr_id, unique: true
  end
end
