$(document).ready(function() {
  $('#filter-users-form').change(function() {
    var time_a = performance.now()
    $('#loading-container').removeClass('hidden');
    $('#filtered-user-table').html('');
    var url = $('#filtered-user-table').attr('data-userUrl');
    var params = $(this).serialize();
    $.get(url, params)
      .success(function(user_table_template) {
        $('#filtered-user-table').html(user_table_template);
        $('#loading-container').addClass('hidden');
        console.log((performance.now() - time_a) + "ms");
      })
  });
  $('#filter-users-form').change()

  $('.js-refresh-btn').click(function(e) {
    e.preventDefault();
    $('#filter-users-form').change()
    return false
  })

  $('tbody')
    .on('mouseover', '.highlight-zygy-id', function() {
      if ($(this).html().trim().length > 0) {
        $('.highlight-zygy-id:contains("' + $(this).children().html() + '")').css('background', 'orange');
        $(this).css('background', 'red');
      }
    })
    .on('mouseleave', '.highlight-zygy-id', function() {
      if ($(this).html().trim().length > 0) {
        $('.highlight-zygy-id:contains("' + $(this).children().html() + '")').css('background', 'inherit');
        $(this).css('background', 'inherit');
      }
    })

})
