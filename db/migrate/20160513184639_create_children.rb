class CreateChildren < ActiveRecord::Migration
  def change
    create_table :children do |t|
      t.references :person, index: true, foreign_key: {on_delete: :cascade, on_update: :cascade}
      t.string :first_name
      t.date :birth_date

      t.timestamps null: false
    end
  end
end
