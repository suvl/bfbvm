load_agenda = ->
  $.getJSON 'http://bfbvm-sib.herokuapp.com/services.json', (data) ->
    items = []
    $.each data, (key, val) ->
      item = '<tr><td>' + val.data + '</td>'
      item += '<td id=\'' + val.id + '\'>' + val.nome
      if val.local != ''
        item += ' (' + val.local + ')'
      item += '</td></tr>'
      items.push item
      return
    $('<table/>',
      'class': 'table booking'
      html: items.join('')).appendTo '#bfbvm-agenda'
    $('#bfbvm-agenda .loading-gif').hide 0
    return
  return

$ ->
  if $('#bfbvm-agenda').length > 0
    load_agenda()

  $("section > ul.nav > li, .navbar-nav .dropdown-menu > li").delay(400).animate({'margin-right': 0}, 900, 'easeOutExpo')