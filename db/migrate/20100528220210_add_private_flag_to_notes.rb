class AddPrivateFlagToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes, :is_private, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :notes, :is_private
  end
end
