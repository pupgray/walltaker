class AddAcceptedConsequencesToSurrenders < ActiveRecord::Migration[7.1]
  def change
    add_column :surrenders, :accepted_consequences, :boolean, default: false
  end
end
