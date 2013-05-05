class AddIndexToIdsNotes < ActiveRecord::Migration
  def self.up
    add_index :notes, [:list_id, :id]
  end

  def self.down
    remove_index :notes, :list_id
  end
end
