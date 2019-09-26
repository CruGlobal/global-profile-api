class CreateEmailAddresses < ActiveRecord::Migration
  def change
    create_table :email_addresses do |t|
      t.uuid :gr_id
      t.references :person, index: true, foreign_key: {on_delete: :cascade, on_update: :cascade}
      t.string :email
      t.boolean :primary
      t.string :location

      t.timestamps null: false
    end
    add_index :email_addresses, :gr_id, unique: true
  end
end
