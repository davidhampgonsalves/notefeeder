class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.integer :list_id, :null => false
      t.string :title
      t.text :description
      t.text :url
      t.timestamp :created_at    
    end
    add_index :notes, :list_id
  end

  def self.down
    drop_table :notes
  end
end
