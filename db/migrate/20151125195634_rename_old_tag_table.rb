class RenameOldTagTable < ActiveRecord::Migration
  def up
    rename_table :tags, :cakephp_tags_old
  end

  def down
  end
end
