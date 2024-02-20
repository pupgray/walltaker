class AddForcePreviewAbility  < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      ALTER TYPE ability ADD VALUE 'force_preview';
    SQL
  end
end
