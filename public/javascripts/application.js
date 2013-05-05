//validates fields based on their class
function validate_on_class(input_fields, errors)
{
	var all_valid = true;
	
	for(var i=0 ; i < input_fields.length ; i++)
	{
		input_valid = true
		input_field = $(input_fields[i]);
		
		classes = input_field.attr('class');
		if((start = classes.indexOf(' length')) >= 0)
		{
			//account for the lengh of the search phrase
			start += 7
			end = classes.indexOf(' ', start + 8);
			if(end == -1)
				end = classes.length;
			
			var max_length = classes.substring(start, end);
			
			if (input_field.val().length > max_length)
			{
				errors[i] = 'you are  ' + (input_field.val().length - max_length) + ' chars over the max of ' + max_length;
				all_valid = false;
			}
		}
	}
	
	return all_valid;
}

//validates that all fields are not empty or blank
function validate_all_not_empty(input_fields, errors)
{
	var all_empty = true;
	for(var i=0 ; i < input_fields.length && all_empty ; i++)
	{	
		if($(input_fields[i]).val() != '')
			all_empty = false;
	}
	
	if(all_empty)
	{
		var input_error;
		for(var i=0 ; i < input_fields.length && all_empty ; i++)
		{
			errors[i] = 'at least one of these must be filled';
		}
	}
	return !all_empty;
}

// adds errors to input and removes outdated ones
function update_error_areas(input_areas, errors)
{
	input_errors = input_areas.children('.input_error_msg');
	for(var i=0 ; i < input_areas.length ; i++)
	{
		input_error = $(input_errors[i]);
		
		//show or hide the input error elements depending on the validity of the input
		if(errors[i] == '' && input_error.is(':visible'))
		{	
			input_error.hide(400);
			input_error.html('');
		}else if(errors[i] != '')
		{
			input_error.html(errors[i]);
			if (input_error.is(':hidden'))
				input_error.show(400);
		}
	}	
}

//highlights the bookmarklet to grab user attention
function highlightBookmarklet()
{
  $('#bookmarklet_blurb').parent().css('background-color', '#FFFFCC');
}
