class RemoveCompletedAtNotes < ActiveRecord::Migration
  def self.up
    remove_column :notes, :created_at 
  end

  def self.down
  end
end
