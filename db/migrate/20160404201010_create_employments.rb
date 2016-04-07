class CreateEmployments < ActiveRecord::Migration
  def change
    create_table :employments do |t|
      t.references :person, index: true, foreign_key: true
      t.references :ministry, index: true, foreign_key: true
      t.uuid :gr_id
      t.date :date_joined_staff
      t.date :date_left_staff
      t.integer :organizational_status
      t.integer :funding_source

      t.timestamps null: false
    end
    add_index :employments, :gr_id, unique: true
  end
end
