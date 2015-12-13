$(document).ready(function() {
  $('#filter-users-form').change(function() {
    $('#loading-container').removeClass('hidden');
    $('#filtered-user-table').html('');
    var url = $('#filtered-user-table').attr('data-userUrl');
    var params = $(this).serialize();
    $.get(url, params)
      .success(function(user_table_template) {
        $('#filtered-user-table').html(user_table_template);
        $('#loading-container').addClass('hidden');
      })
  });
  $('#filter-users-form').change()

  $('tbody')
    .on('mouseover', '.highlight-solution', function() {
      if ($(this).html().length > 0) {
        $('.highlight-solution:contains("' + $(this).html() + '")').css('background', 'orange');
        $(this).css('background', 'red');
      }
    })
    .on('mouseleave', '.highlight-solution', function() {
      if ($(this).html().length > 0) {
        $('.highlight-solution:contains("' + $(this).html() + '")').css('background', 'inherit');
        $(this).css('background', 'inherit');
      }
    })

})
