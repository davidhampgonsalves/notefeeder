class Note < ActiveRecord::Base
    belongs_to :list
    validates_length_of :title, :maximum => 100, :too_long => 'your title can only be 100 characters long'
    validates_length_of :description, :maximum => 800, :too_long => 'your description can only be 800 characters long'
    validates_length_of :url, :maximum => 800, :too_long => 'your url can only be 800 characters long'

  def validate

    if title.blank? && description.blank? && url.blank?
      errors.add(:title, "you must fill in at least one field")
      errors.add(:description, "you must fill in at least one field")
      errors.add(:url, "you must fill in at least one field")
    end
  end
end
