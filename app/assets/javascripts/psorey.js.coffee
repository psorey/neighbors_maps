jQuery ->
  $('form').on 'click', '.remove_fields', (event) ->
    console.log("remove_fields click")
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('fieldset').hide()
    event.preventDefault()


jQuery ->
  $('form').on 'click', '.add_fields', (event) ->
    console.log("add fields click")
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()



