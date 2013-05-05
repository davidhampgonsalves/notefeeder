class AddIndexForOrderToNotes < ActiveRecord::Migration
  def self.up
    add_index :notes, [:list_id, :created_at]
  end

  def self.down
  end
end
