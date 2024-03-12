class AddLoggedInToSurrenders < ActiveRecord::Migration[7.1]
  def change
    add_column :surrenders, :logged_in, :boolean, default: false
    add_column :surrenders, :current_page, :string
  end
end
