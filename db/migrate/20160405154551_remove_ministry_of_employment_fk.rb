class RemoveMinistryOfEmploymentFk < ActiveRecord::Migration
  def change
    remove_column :people, :ministry_of_employment_id
  end
end
