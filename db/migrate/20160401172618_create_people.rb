class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.uuid :gr_id
      t.references :ministry, index: true, foreign_key: {on_delete: :restrict, on_update: :cascade}
      t.string :first_name
      t.string :last_name
      t.string :preferred_name
      t.integer :gender, default: 0, null: false
      t.date :birth_date
      t.integer :marital_status, default: 0, null: false
      t.string :language, array: true, default: []
      t.date :date_joined_staff
      t.date :date_left_staff
      t.uuid :key_guid
      t.boolean :approved
      t.integer :organizational_status, default: 0, null: false
      t.integer :funding_source, default: 0, null: false
      t.boolean :is_secure
      t.string :country_of_residence, limit: 3
      t.integer :ministry_of_employment_id, index: true

      t.timestamps null: false
    end
    add_index :people, :gr_id, unique: true
    add_foreign_key :people, :ministries, column: :ministry_of_employment_id, on_delete: :nullify, on_update: :cascade
  end
end
