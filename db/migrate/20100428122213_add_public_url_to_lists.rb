class AddPublicUrlToLists < ActiveRecord::Migration
  def self.up
    add_column :lists, :has_public_url, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :lists, :has_public_url
  end
end
