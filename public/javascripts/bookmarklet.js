/* minify with java -jar compiler.jar --compilation_level ADVANCED_OPTIMIZATIONS --js bookmarklet.js --js_output_file comp.js */

init();

function init() {
	if(document.getElementById("notefeeder-jquery-script") == null) {
		var jqueryLib = document.createElement("script");
		jqueryLib.id = "notefeeder-jquery-script";
		jqueryLib.onload = main;
		jqueryLib.src = "http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js";
		jqueryLib.type = "text/javascript";
    //for ie
    jqueryLib.onreadystatechange = function() {
      if (this.readyState == 'complete') {
        main();
      }
    }
		document.getElementsByTagName("head")[0].appendChild(jqueryLib);
	}else
		main();
}

function main() {
	noteInput = $("#nf_9823");
	if(noteInput.length == 0)
	{
		/* add the div with the div to the page */
    var container = $("<div id=nf_9823></div>");
		var inputContainer = "<a class=h2 href=http://notefeeder.heroku.com/lists>note feeder</a>" +
			"<a class=h1 href=http://notefeeder.heroku.com/notes/new>create note</a>" +
			"<a href=# class=close> close </a><div style=clear:both;><label for=list_id>list</label> <select id=list_id>";
		/* add the users lists */
		for(var listName in userLists)
			inputContainer += "<option value=" + userLists[listName] + ">" + listName + "</option>";
		inputContainer += "</select> <label for=title>title</label><input id=title type=text />" +
			"<label for=url>url</label><textarea id=url style=height:40px></textarea>" +
			"<label for=desc>desc</label><textarea id=desc style=height:50px></textarea></div>" +
			"<div id=status></div>" +
			"<a class=submit href=#> create note </a><img class=loading style=display:none src=http://notefeeder.heroku.com/images/loading.gif />";
    container.html(inputContainer);
    container.children("a.close").click(function() {container.remove();return false;});

		$("body").append(container);
    initWindow(container);
 
	}else if(noteInput.hasClass("visiable"))
  	hideWindow(noteInput);
  else
    showWindow(noteInput);
}
 
function initWindow(container) {
	/* populate the title and the url of the drop down */
	container.find("#url").val(window.location);
  var title = $("title").html();
  if(title != undefined)
  	container.find("#title").val(title.substring(0, 100));
	
	/* drop newly created div down */
	container.animate({ right:"0" }, 500);
	container.addClass("visiable");
 
	/* bind the create note function to the create button */
	container.find("a.submit").bind("click", function(){
		var note = getNoteFromInput();
		createNote(note);});
}

function showWindow(noteInput)
{
		noteInput.animate({ right:"0" }, 500);
		noteInput.addClass("visiable");
}

function hideWindow(noteInput)
{
		noteInput.removeClass("visiable");
		noteInput.animate({ right:"-425px"}, 500);
}
 
function getNoteFromInput()
{
	var note = Array();
	var inputs = $("#nf_9823 div").children();
	for(var i=0 ; i < inputs.length ; i++)
	{
            var tag = inputs[i].nodeName.toLowerCase();
            var id = inputs[i].id;
            if(tag === "input" || tag === "textarea" || tag === "select")
                note[id] = inputs[i].value;
	}
	return note;
}

function encodeNoteFields(note)
{
  for(field in note)
    note[field] = encodeURIComponent(note[field]);
}
 
function createNote(note)
{	
	var errors = getInputErrors(note["title"], note["url"], note["desc"]);
	if(errors.length != 0)
	{
		displayStatus({"error" : errors});
		return;
	}

  encodeNoteFields(note);
	
  $("#nf_9823 .loading").show();
	/* create ajax request to create note */
  var url = appendParams("http://notefeeder.heroku.com/notes/create_from_bookmark/0.json", note);
 
  $.ajax({ url: url, dataType: "jsonp", success: function(data){
	  displayStatus(data, note);
  }, error: function(textStatus){
	  displayStatus({"error": textStatus}, note);
  }});
}
 
function appendParams(url, note)
{
  url += "?list_id=" + note["list_id"];
  url += "&title=" + note["title"];
  url += "&url=" + note["url"];
  url += "&description=" + note["desc"];
  return url;
}
 
function getInputErrors(title, url, desc)
{
	var errors = Array();
	if(empty(title) && empty(url) && empty(desc))
	  errors.push("fill in at least one field");
	if(!empty(title) && title.length > 100)
	  errors.push("title must be less then 100 characters");
	if(!empty(url) && url.length > 800)
	  errors.push("url must be less then 800 characters");
	if(!empty(desc) && desc.length > 800)
	  errors.push("description must be less then 800 characters");
	return errors;
}
 
function empty(field) 
{
	return field === "";
}
 
function displayStatus(status, note)
{
  $("#nf_9823 .loading").hide();
	var statusHtml = "";
	for(var statusType in status)
    if(typeof(status[statusType]) == "object")
        /* if there is an array of this type of errors */
        for(var errorType in status[statusType])
          if(errorType == "auth")
          {
              var url = appendParams("http://notefeeder.heroku.com/create/notes", note);
              statusHtml += createStatusItemHtml(statusType, "<a href=" + url + " target=blank> login </a> to complete the note creation");
          }else
            statusHtml += createStatusItemHtml(statusType, status[statusType][errorType]);
    else
    {
        /*the request was a success so hide the window after a bit */
        if(statusType === "success")
          window.setTimeout(function() {
            hideWindow($("#nf_9823"));
            $("#nf_9823 #status").html("");
          }, 1100);
        /* if there is only one message of this type */
        statusHtml += createStatusItemHtml(statusType, status[statusType]);
    }       
	$("#nf_9823 #status").html(statusHtml);
}
 
function createStatusItemHtml(type, message)
{
	return "<div class=" + type + "> " + message + "</div>";
}
