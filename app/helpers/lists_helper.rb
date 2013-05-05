module ListsHelper

  #creates the json that contains the list name and id
  def get_lists_names_and_ids_json ( lists )
    names_and_ids = {}

    @lists.sort.each do | list_name, list |
      names_and_ids[list_name] = list[:id] 
    end

    return names_and_ids.to_json
  end
end
