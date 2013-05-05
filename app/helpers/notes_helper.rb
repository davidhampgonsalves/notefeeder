module NotesHelper
  require 'rdiscount'

  #format the url to be used in a href
  def add_protocol_to_url(url)
    #add the http protocol if one isn't set
    if not url.match /[^\/]+?:\/\//
      url = 'http://' + url
    end

    return url
  end

  #apply markdown
  def markdown(markdown_text)
    return RDiscount.new(markdown_text).to_html
  end
end
