// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

// https://github.com/vakata/jstree#the-required-json-format

$(document).ready(function() {
  $('#user-tree').jstree();

  $('#user-tree').on("changed.jstree", function (e, data) {
    console.log(data.node.text.trim());
  });

  $('button').on('click', function () {
    $('#user-tree').jstree(true).select_node('child_node_1');
    $('#user-tree').jstree('select_node', 'child_node_1');
    $.jstree.reference('#user-tree').select_node('child_node_1');
  });
})
