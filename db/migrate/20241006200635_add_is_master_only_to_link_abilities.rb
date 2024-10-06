class AddIsMasterOnlyToLinkAbilities < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      ALTER TYPE ability ADD VALUE 'is_master_only';
    SQL
  end
end
