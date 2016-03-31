class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.uuid :gr_id
      t.string :name
      t.string :code

      t.timestamps null: false
    end
  end
end
