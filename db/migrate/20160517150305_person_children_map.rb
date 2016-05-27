class PersonChildrenMap < ActiveRecord::Migration
  def change
    create_table :people_children, id: false do |t|
      t.integer :person_id
      t.integer :child_id
    end

    add_index :people_children, :person_id
    add_index :people_children, :child_id
    remove_reference :children, :person, index: true, foreign_key: true
  end
end
