xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://notefeeder.com" do
 xml.channel do

   xml.title       'note feeder/' + @list[:name]
   xml.link        url_for(:only_path => false, :controller => 'lists', :action => :show, :id => @list[:id])
   xml.description @list[:name]

   @notes.each do | note |
     xml.item do
       xml.title       note.title

       if !note.is_private and note.url and
          not note.url.strip.empty? and 
          (not note.description or note.description.empty?)
         xml.link add_protocol_to_url(note.url)
       else
         xml.link url_for(:only_path => false, :controller => 'notes', :action => 'show', :id => note.id)
       end
       if note.is_private
        xml.description "" 
       else
        xml.description note.description
       end       
       xml.guid        url_for(:only_path => false, :controller => 'notes', :action => 'show', :id => note.id)
     end
   end

 end
end
