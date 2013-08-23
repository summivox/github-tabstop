repeat = (c, n) ->
  s = ''
  s += c for i in [0...n] by 1
  s

transform = do ->
  TAB = PACKED_HTML['tab.html'].trim()
  (el) ->
    for line in $(el).addClass('ghts-file').find('pre .line')
      line.innerHTML = line.innerHTML.replace(/\t/g, TAB)

modify = (el, ts) ->
  if isNaN ts then return false
  et = repeat '&nbsp;', ts
  for tab in el.getElementsByClassName('ghts-tab')
    tab.innerHTML = et
  return true

bind = (file, input) ->
  input?.addEventListener 'change', -> modify file, Number(input.value)

make =
  'github.com': ->
    for file in $('.file:not(.ghts-file)')
      transform file
      $(file).find('.actions').prepend(PACKED_HTML['ui-github.html'])
      input = $(file).find('.ghts-input')[0]
      bind file, input
    return
  'gist.github.com': ->
    for file in $('.file-box:not(.ghts-file)')
      transform file
      $(file).find('.button-group').prepend(PACKED_HTML['ui-gist.html'])
      input = $(file).find('.ghts-input')[0]
      bind file, input
    return

$ ->
  if f = make[document.location.host]
    f()
    setInterval f, 500
