class User < ActiveRecord::Base
  validates_presence_of :user_openid, :message => 'there was an error.  Your open id wasn\'t set'
  validates_uniqueness_of :user_openid, :message => 'you have already created a user name linked to this open id'

  validates_presence_of :user, :message => 'you need a user name to use this app'
  validates_uniqueness_of :user, :message => 'that user name is already taken'
end
