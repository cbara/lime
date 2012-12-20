# Instantiating the VideoJS player, this method has to be called. It creates an object with
# the DOM elements as properties, Events as jQuery events and javascript methods.
# Th form of call is
#
#      window.LIMEPlayer.VideoJSInit(domElement, optionsHash, function(err, playerObj){
#        if(err){
#          console.error('Error initializing player', err);
#        } else {
#          USE PLAYER OBJECT HERE.
#        }
#      })
#
window.LIMEPlayer.VideoJSInit = (el, options, cb) ->
  unless _V_
    console.error "VideoJS not loaded!"
    cb "VideoJS not loaded"
    return
  _.defer =>
    player =
      # The player instance is the (could be even) hidden player instance that we wrap.
      instance: _V_(el, {
        flash: iFrameMode: true
        swf: "lib/videojs/video-js.swf"	# SORIN - added to fix flash fallback bug
      })

      # # Methods:

      # play()
      play: ->
        @instance.play()

      # pause()
      pause: ->
        @instance.pause()

      # getLength()
      getLength: ->
        @instance.duration()

      # seek(pos)
      seek: (pos) ->
        if pos isnt undefined
          @instance.currentTime pos

      # currentTime()
      currentTime: ->
        @instance.currentTime()

      currentSource: ->
        @instance.tag.src or jQuery('source',this.instance.tag).attr('src')

      # @player.addComponent 'Annotations', player: @player

    # Setting up the player instance
    player.instance.addEvent "loadedmetadata", =>
    #player.instance.ready =>
      player.instance.isFullScreen = options.fullscreen

      # player.videoOverlay is the DOM element over the entire video element
      videoOverlay = player.instance.addComponent("VideoOverlay")  # add component to display 4 regions of annotations
      player.videoOverlay = jQuery videoOverlay.el
      player.videoOverlay.css
        height: '100%'

      # player.timelineOverlay is the DOM element over the timeline
      timelineOverlay = player.instance.controlBar.progressControl.addComponent "VideoOverlay"
      player.timelineOverlay = jQuery timelineOverlay.el
      player.timelineOverlay.css
        position: 'absolute'
        top: 0
        right: 0
        left: 0
        height: '100%'
        padding: 0
        margin: 0
        background: 'transparent'
        'pointer-events': 'none'

      # player.buttonContainer is the DOM element in the button bar that can accomodate switch elements (eg show/hide annotations)
      player.buttonContainer = player.instance.controlBar.addComponent("AnnotationToggle").el

      # # Events
      # timeupdate event
      player.instance.addEvent "timeupdate", (e) ->
        limeevent = jQuery.Event "timeupdate", currentTime: player.instance.currentTime()
        jQuery(player).trigger limeevent

      # fullscreenchange event
      player.instance.addEvent 'fullscreenchange', (e) =>
        fsce = jQuery.Event 'fullscreenchange', isFullScreen: player.instance.isFullScreen
        jQuery(player).trigger fsce

      # play event
      player.instance.addEvent 'play', (e) =>
        playevent = jQuery.Event 'play'
        jQuery(player).trigger playevent

      player.instance.play()
      cb null, player

  # Prepare Components for video overlay, button
  _V_.VideoOverlay = _V_.Component.extend #for  annotations on the sidebars
    options:
      loadEvent: "play"

    init: (player, options) ->
      @_super player, options

    createElement: ->
      el = _V_.createElement "div",
      # className: "spacial-annotation-overlays-wrapper"
        className: "lime-overlay"
        style: 'border: 2px red solid'
      el.innerHTML = "&nbsp;"
      el

  # ConnectME annotation toggler button that shows/hides the annotations on Fullscreen
  _V_.AnnotationToggle = _V_.Button.extend
    buttonText: "Annotations On/Off"
    buildCSSClass: ->
      "vjs-annotationstoggler " + @_super()

    onClick: ->
      if LimePlayer.options.annotationsVisible is false
        $(".vjs-annotationstoggler").removeClass "annotationstoggler-off"
        LimePlayer.options.annotationsVisible = true
        LimePlayer.player.AnnotationOverlaysComponent.show()  if LimePlayer.player.AnnotationOverlaysComponent
        if @player.isFullScreen #show Annotations sidebars
          LimePlayer.player.AnnotationsSidebars.show()
        else #only show in fullscreen
          LimePlayer.player.AnnotationsSidebars.hide()
      else #toggle off Annotation overlays
        $(".vjs-annotationstoggler").addClass "annotationstoggler-off"
        LimePlayer.player.AnnotationsSidebars.hide()
        LimePlayer.player.AnnotationOverlaysComponent.hide()  if LimePlayer.player.AnnotationOverlaysComponent
        LimePlayer.options.annotationsVisible = false
      console.log "fullscreen " + @player.isFullScreen, "visible " + LimePlayer.options.annotationsVisible

###
  # ConnectME Annotation Sidebars for fullscreen mode - displays 4 fixed regions (NWSE) as containers for widgets
  _V_.AnnotationsSidebars = _V_.Component.extend #for  annotations on the sidebars
    options:
      loadEvent: "play"

    init: (player, options) ->
      @_super player, options
      player.addEvent "fullscreenchange", @proxy(-> #for hiding overlay annotations when not in fullscreen
        @hide()  if @player.isFullScreen is false
      )
      player.addEvent "play", @proxy(->
        @fadeIn()
        @player.addEvent "mouseover", @proxy(@fadeIn)
      )

      # this.player.addEvent("mouseout", this.proxy(this.fadeOut));	//maybe we want to
      @player.AnnotationsSidebars = this #attach Component for sidebar annotations to player

    createElement: -> #we just attach and show the "annotation-wrapper" div created in the _initVideoPlayer method
      $(".annotation-wrapper", @el).show()[0]

    fadeIn: ->
      @_super()

    fadeOut: ->
      @_super()

    lockShowing: ->
      @el.style.opacity = "1"

###