do ($=jQuery, uiModel = @edsc.models.page.current.ui, urlUtil = edsc.util.url) ->

  updateLandingPageState = ->
    uiModel.isLandingPage(History.getState().hash == '/')

  updateLandingPage = (isLandingPage) ->
    $content = $('.landing-toolbar-content')
    $('.landing-hidden').toggle(!isLandingPage)
    $('.landing-visible').toggle(isLandingPage)
    if (isLandingPage)
      $('.landing-dialog-toolbar').append($content)
      $('#keywords').focus()
    else
      $('.landing-toolbar-container').append($content)
    $content.css(top: 0, left: 0, position: 'relative')


  updateLandingPageAnimated = (isLandingPage) ->
    $content = $('.landing-toolbar-content')
    startOffset = $content.offset()
    $content.css(position: 'absolute', zIndex: 101, left: startOffset.left, top: startOffset.top)
    $('.landing-toolbar-container').append($content)

    if isLandingPage
      $('.landing-hidden').fadeOut()
      $('.landing-visible').fadeIn
        complete: ->
          endOffset = $('.landing-dialog-toolbar').offset()
          $content.animate(endOffset, duration: 200, complete: -> updateLandingPage(isLandingPage))
    else
      endOffset = $('.landing-toolbar-container').offset()
      $content.animate(endOffset,
        complete: ->
          $('.landing-visible').fadeOut()
          $('.landing-hidden').fadeIn(complete: -> updateLandingPage(isLandingPage))
        duration: 200)

  $(document).ready ->
    isFirstUpdate = true

    uiModel.isLandingPage.subscribe (isLandingPage) ->
      # Avoid doing animations when the screen first shows
      if isFirstUpdate
        isFirstUpdate = false
        updateLandingPage(isLandingPage)
      else
        updateLandingPageAnimated(isLandingPage)

    $(window).on 'resize', ->
      if $('body').hasClass('is-landing')
        $('.landing-toolbar-content').offset($('.landing-dialog-toolbar').offset())

    updateLandingPageState()

    $(window).on 'statechange anchorchange', updateLandingPageState

    $('.landing-area').on 'keypress', '#keywords', (e) ->
      urlUtil.pushState('/search') if e.which == 13

    $('.landing-area').on 'submit', 'form', -> urlUtil.pushState('/search')

    $('.landing-area').on 'click', '.submit, .master-overlay-show', -> urlUtil.pushState('/search')

    $('.landing-area').on 'click', '.spatial-selection a',
      -> urlUtil.pushState('/search')
