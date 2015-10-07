class AddIndexToTsearchNotes < ActiveRecord::Migration
  def self.up
    execute "create index notes_tsearch_index on notes using gist(to_tsvector('english', title || ' ' || url  || ' ' || description))"
  end

  def self.down
    execute "drop index notes_tsearch_index"
  end
end
