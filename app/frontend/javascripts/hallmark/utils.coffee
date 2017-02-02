module.exports = class Utils
  constructor: ->

  # Opens links marked as external in a new browser window
  @links: ->
    $('body').on 'click', 'a[rel*="external"]', (e) ->
      e.preventDefault()
      window.open $(e.target).closest('a').attr('href')

  # Simple spam prevention by changing example/at/example.com to proper email string
  @mails: ->
    $('a[href^="mailto:"]').each (index, el) ->
      mail = el.href.replace('mailto:','')
      replaced = mail.replace('/at/','@')
      el.href = 'mailto:' + replaced
      el.innerHTML = replaced if el.innerHTML == mail

  # Extra classes on <html> element helping with styling
  @mobile: ->
    ua = navigator.userAgent.toLowerCase()
    classes = []

    classes.push 'android' if ua.indexOf('android') > -1
    classes.push 'native' if ua.indexOf('android') > -1 and !(ua.indexOf('chrome') > -1) and !(ua.indexOf('firefox') > -1)
    classes.push 'native' if ua.indexOf('android') > -1 and ua.indexOf('samsungbrowser') > -1
    classes.push 'mie9' if ua.indexOf('iemobile/9.') > -1
    classes.push 'mie10' if ua.indexOf('iemobile/10.') > -1

    $('html').removeClass('no-touch').addClass 'mie touch' if ua.indexOf('iemobile') > -1

    document.documentElement.className += ' ' + classes.join(' ')


  @initialize: ->
    @links()
    @mails()
    @mobile()
