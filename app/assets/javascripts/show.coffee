values = []
bfbvm_gallery_init = ->
  $("#gallery div").each (index) ->
    right = top =  (-index * 15)
    zindex = 1000 + right
    values.unshift(right)

bfbvm_gallery = ->
  elements = $("#gallery div")
  $("#gallery div").each (index) ->
    value = values[index]
    zindex = 1000 + value;
    $(this).animate( {top: value + 'px', right: value + 'px', 'z-index': zindex }, 500 )
    #$(this).css('top', )
    #$(this).css('right', value + "px")
    #$(this).css('z-index', zindex)
  values.push( values.shift() )

$ ->
  setInterval(bfbvm_gallery, 3000)
  bfbvm_gallery_init()
  bfbvm_gallery()