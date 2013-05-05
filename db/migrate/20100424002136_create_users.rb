class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :user_openid
      t.string :user
    end
    add_index :users, :user_openid
  end

  def self.down
    drop_table :users
  end
end
