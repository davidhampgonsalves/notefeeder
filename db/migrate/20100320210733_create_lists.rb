class CreateLists < ActiveRecord::Migration
  def self.up
    create_table :lists do |t|
      t.string :name
      t.string :user
      t.timestamp :created_at
    end
    add_index :lists, :user
    add_index :lists, [:user, :name], :unique => true
  end

  def self.down
    drop_table :lists
  end
end
