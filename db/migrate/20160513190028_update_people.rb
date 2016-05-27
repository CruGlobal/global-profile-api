class UpdatePeople < ActiveRecord::Migration
  def change
    remove_column :people, :country_of_residence

    add_reference :people, :spouse
    add_column :people, :marriage_date, :date

    add_column :people, :skype_id, :string
    add_column :people, :phone_number, :string
  end
end
