# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_field_errors( object, field_name )
    errors = ''
    if !object.errors.empty? && object.errors[field_name] != nil
      errors = object.errors[field_name]
    end

   return "<div class='input_error_msg'>" + errors + "</div>"
  end
end
