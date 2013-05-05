class List < ActiveRecord::Base
    has_many :notes

    validates_length_of :name, :maximum => 100, :too_long => 'your lists name can only be 100 characters long'
    validates_presence_of :name, :message => 'you need to give your list a name'
    validates_uniqueness_of :name, :scope => :user, :message => 'you already have a list with that name'

    def validate
      #don't allow the / char in the name (will break show_by_name
      if name.match '[<>\/]'
        errors.add_to_base 'your list name can\'t contain the characters "/","<" or ">"'
      end
    end
end
