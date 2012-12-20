class window.DBPediaInfoPlugin extends window.LimePlugin
  init: ->
    @name = 'DBPediaInfoPlugin'
    console.info "Initialize #{@name}"
    for annotation in @lime.annotations
      jQuery(annotation).bind "becomeActive", (e) =>
        annotation = e.target
        if annotation.resource.value.indexOf("geonames") < 0
          annotation.entityPromise.done (entity) =>
            widget = @lime.allocateWidgetSpace @,
              thumbnail: "img/info.png" # should go into CSS
              title: "#{annotation.getLabel()} Info"
            if widget
              widget.annotation = annotation
                # widget.html @renderAnnotation(annotation)
              # widget.html @renderAnnotation(annotation)
              widget.show()
              # insert widget click function
              jQuery(widget).bind 'activate', (e) => #click behaviour - highlight the related widgets by adding a class to them
                annotation = e.target.annotation
                @displayModal annotation

            annotation.widgets[@name] = widget

      jQuery(annotation).bind "becomeInactive", (e) =>
        annotation = e.target
        #console.info(annotation, 'became inactive');
        widget = annotation.widgets[@name]
        if widget
          widget.deactivate()
          return

  showAbstractInModalWindow: (annotation, modalContainer) ->
    label = annotation.getLabel()
    page = annotation.getPage()
    lime = this.lime
    comment = annotation.getDescription()
    depiction = annotation.getDepiction()

    result = "<div id=\"listContainer\" style=\"position:relative; float: left; z-index: 10; width:35%; height: 95%; background: white; box-shadow: rgba(85,85,85,0.5) 0px 0px 24px;\" >" + "<img src=\"" + depiction + "\" style=\"display: block; width: auto; max-height: 300px; max-width:90%; margin-top: 30px; margin-left: auto;  margin-right: auto; border: 5px solid black; \" >" + "</div>" + "<div id=\"displayArea\" style=\"position:relative; float: left; z-index: 1; width: 65%; height:95%; background: #DBDBDB; overflow: auto;\">" + "<p style=\"margin-left: 10px; font-size: 22px; text-align: left; color:black; font-family: 'Share Tech', sans-serif; font-weight: 400;\">" + comment + "</p>" + "</div>"
    modalContent = $("#modalContent")

    #$(modalContent).append("<div style=\"margin: 10px; font-family:verdana; font-size:20px; color: white\">" + comment + "</div>");
    $(modalContent).append result

  displayModal: (annotation) -> # Modal window script usin jquery

    # Get Modal Window
    #var modalcontainer;
    if @lime.player.isFullScreen
      modalcontainer = $(".modalwindow")
    else
      modalcontainer = $("#modalWindow")

    # Get mask element
    mask = undefined
    if @lime.player.isFullScreen
      mask = $(".mask")
    else
      mask = $("#mask")

    #Resize the modal container
    $(modalcontainer).css "height", "70%"
    $(modalcontainer).css "max-height", "500px"

    # Empty the modal container
    $(modalcontainer).empty()

    # Create contetn holders within the modal container
    $(modalcontainer).append "<a href=\"#\" class=\"close\" role=\"button\"><img src=\"img/close-icon.png\" style=\"width: 22px; height: 22px;\"/></a>"
    $(modalcontainer).append "<div id=\"modalContent\" style=\"height: 95%; width: 100%; position: relative; margin: 0 auto;\">"
    $(modalcontainer).append "</div>"

    #Get the screen height and width
    maskHeight = $(window).height()
    maskWidth = $(window).width()

    #Set heigth and width to mask to fill up the whole screen
    $(mask).css
      width: maskWidth
      height: maskHeight


    #transition effect
    $(mask).fadeIn 100
    $(mask).fadeTo "fast", 0.8

    #Get the window height and width
    winH = $(window).height()
    winW = $(window).width()

    #Set the popup window to center
    $(modalcontainer).css "top", winH / 2 - $(modalcontainer).height() / 2
    $(modalcontainer).css "left", winW / 2 - $(modalcontainer).width() / 2

    #transition effect
    $(modalcontainer).fadeIn 100

    #if close button is clicked
    $(".close").click (e) =>

      #Cancel the link behavior
      e.preventDefault()
      $(mask).hide()
      $(modalcontainer).hide()
      $(modalcontainer).empty()


    #if mask is clicked
    $(mask).click (e) =>
      $(this).hide()
      $(modalcontainer).hide()
      $(modalcontainer).empty()

    $(window).resize (e) =>

      #Get the screen height and width
      maskHeight = $(document).height()
      maskWidth = $(document).width()

      #Set height and width to mask to fill up the whole screen
      $(mask).css
        width: maskWidth
        height: maskHeight


      #Get the window height and width
      winH = $(window).height()
      winW = $(window).width()

      #Set the popup window to center
      $(modalcontainer).css "top", winH / 2 - $(modalcontainer).height() / 2
      $(modalcontainer).css "left", winW / 2 - $(modalcontainer).width() / 2

    #box.blur(function() { setTimeout(<bluraction>, 100); });
    @showAbstractInModalWindow annotation, modalcontainer