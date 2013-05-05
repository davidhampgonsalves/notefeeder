class AddDeletedToLists < ActiveRecord::Migration
  def self.up
    add_column :lists, :deleted, :boolean, :default => false
    add_column :lists, :deleted_since, :datetime, :default => nil
  end

  def self.down
    remove_column :lists, :deleted
    remove_column :lists, :deleted_since
  end
end
