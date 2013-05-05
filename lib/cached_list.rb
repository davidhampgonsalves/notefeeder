module CachedList
    #returns the list info based on id
  def get_cached_list_info(list_id)
      user_lists.each_value do | list |
        if list[:id] == list_id
          return list
        end
      end

      return nil
  end

  #initilizes(if required) the hash containing the list name/id pairs
  def init_session_user_lists
    #create the user lists hash if it doesn't already exist
    if logged_in? and not user_lists_cached?
      #get the lists for this user
      lists = List.all(:conditions => {:user => user})

      lists_hash = {}
      deleted_lists_hash = {} 
      # the hash uses the list name as the key and the id as the value     
      lists.each do | list |
        if list.deleted
          deleted_lists_hash[list.name] = create_list_hash(list)
        else
          lists_hash[list.name] = create_list_hash(list)
        end
      end
      #save it to the session
      session[:user_lists] = lists_hash
      session[:deleted_user_lists] = deleted_lists_hash
    end
  end


  #creates a hash representing a list
  def create_list_hash(list)
    return {:name => list.name, :has_public_url => list.has_public_url, :id => list.id}
  end
end
