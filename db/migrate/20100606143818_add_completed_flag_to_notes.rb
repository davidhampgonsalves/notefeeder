class AddCompletedFlagToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes, :completed, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :notes, :completed
  end
end
