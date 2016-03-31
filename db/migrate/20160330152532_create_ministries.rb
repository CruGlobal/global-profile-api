class CreateMinistries < ActiveRecord::Migration
  def change
    create_table :ministries do |t|
      t.uuid :ministry_id
      t.string :name
      t.string :min_code
      t.string :gp_key

      t.timestamps null: false
    end
  end
end
