# Used to control background of the home page. 
# Necessary to make background-size: cover work in IE8
class Home.BackgroundController

  constructor: (@background_container) ->
    # jquery.backgroundSize.min.js is used - if current browser (namely: IE lt 9) does
    # not support background-size: cover, an <img> element will be inserted
    # and automagically Will Just Work™. See https://github.com/louisremi/jquery.backgroundSize.js
    @background_container.css("background-size", "cover" )

