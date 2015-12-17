function getParams(param) {
	var vars = {};
	window.location.href.replace(
		/[?&]+([^=&]+)=?([^&]*)?/gi, // regexp
		function( m, key, value ) { // callback
			vars[key] = value !== undefined ? value : '';
		}
	);

	if ( param ) {
		return vars[param] ? vars[param] : null;
	}
	return vars;
}

const PAPER_HEIGHT = 700
const PAPER_WIDTH = 700
const DISTANCE_BETWEEN_LAYERS=80

$(document).ready(function() {
  degToRad = function(degrees) {
    return degrees * Math.PI / 180;
  };

  radToDeg = function(radians) {
    return radians * 180 / Math.PI;
  };

  flatten = function(arrays) {
    return [].concat.apply([], arrays)
  }

  getJson = function(layer_count) {
    var url = $('.tree-chart').attr('data-userTreeUrl')
    var new_params = $.extend({}, params, {layer_count: 4});
    $.get(url, new_params).success(function(data) {
      refreshAnimTree(data)
    })
  }

  if ($('.tree-chart').length > 0) {
    params = getParams()
    getJson(4)
  }
})


refreshAnimTree = function(users_json) {

  drawCircle = function(distance_from_center, degree, from_circle) {
    var x = distance_from_center * Math.sin(degToRad(degree))
    var y = distance_from_center * Math.sin(degToRad(90 - degree))
    var circle = paper.circle(center_x + x, center_y + y, 10);
    circle.attr("fill", "#0f0");
    if (from_circle) {
      var line = paper.path( ["M", from_circle.attr('cx'), from_circle.attr('cy'), "L", circle.attr('cx'), circle.attr('cy') ] );
      line.attr("stroke-width", 2);
      line.toBack()
    }
    return circle
  }

  drawChildren = function(circle, start_angle, layer) {
    var circles = []
    var angle_between_circles = 360 / (Math.pow(CHILDREN, layer))
    var first_angle = start_angle - (angle_between_circles * 1)
    for (var i=0; i<CHILDREN; i++) {
      var new_circle = drawCircle(DISTANCE_BETWEEN_LAYERS * layer, first_angle + (angle_between_circles * (i+1.5)), circle)
      circles.push(new_circle)
    }
    return circles
  }

  var width = $(window).width();
  var height = $(window).height();
  var horz_offset = width > PAPER_WIDTH ? (width - PAPER_WIDTH)/2 : 0
  var vert_offset = height > PAPER_HEIGHT ? (height - PAPER_HEIGHT)/2 : 0
  var center_x = PAPER_WIDTH/2
  var center_y = PAPER_HEIGHT/2

  var paper = Raphael(horz_offset, vert_offset, PAPER_WIDTH, PAPER_HEIGHT);
  var background = paper.rect(0, 0, PAPER_WIDTH, PAPER_HEIGHT);
  background.attr("fill", "#aaa")

  guidelines = function() {
    var circle = paper.circle(center_x, center_y, DISTANCE_BETWEEN_LAYERS);
    circle.attr("stroke", "#fff");
    var circle = paper.circle(center_x, center_y, DISTANCE_BETWEEN_LAYERS*2);
    circle.attr("stroke", "#fff");
    var circle = paper.circle(center_x, center_y, DISTANCE_BETWEEN_LAYERS*3);
    circle.attr("stroke", "#fff");
    var circle = paper.circle(center_x, center_y, DISTANCE_BETWEEN_LAYERS*4);
    circle.attr("stroke", "#fff");
  }()

  var upline = users_json['upline'];
  if (!$.isEmptyObject(upline)) {
    var line = paper.path( ["M", center_x, center_y - 35, "l", 0, 35 ] );
    line.attr("stroke-width", 1);
    var circle = paper.circle(center_x, center_y - 35, 10);
    circle.attr("fill", "#f00");
    circle.node.setAttribute("data-name", upline['name']);
    circle.node.setAttribute("data-username", upline['username']);
    circle.node.setAttribute("data-personal", upline['personal']);
    circle.node.setAttribute("data-userid", upline['user_id']);
    circle.node.setAttribute("data-directscount", upline['directs_count']);
  }

  var user = users_json['user']
  var main_user_circle = paper.circle(center_x, center_y, 10);
  main_user_circle.attr("fill", "#00f");
  main_user_circle.node.setAttribute("data-name", user['name']);
  main_user_circle.node.setAttribute("data-username", user['username']);
  main_user_circle.node.setAttribute("data-personal", user['personal']);
  main_user_circle.node.setAttribute("data-userid", user['user_id']);
  main_user_circle.node.setAttribute("data-directscount", user['directs_count']);

  drawDownlineCircles = function(parent_user, parent_circle, layer, angle) {
    if (layer == 5) { return [] }
    if (layer == 1) { angle = 0 }

    var downlines = parent_user['downlines']

    if (downlines.length > 0) {
      var angle_width = 360 / Math.pow(3, layer-1)
      var angle_spacing = angle_width / downlines.length
      var relative_angles = []
      if (downlines.length == 1) {
        relative_angles = [angle]
      } else if (downlines.length == 2) {
        relative_angles = [angle+angle_spacing*0.5, angle-angle_spacing*0.5]
      } else if (downlines.length == 3) {
        relative_angles = [angle+angle_spacing, angle, angle-angle_spacing]
      }

      $(downlines).each(function(i) {
        var down_circle = drawCircle(DISTANCE_BETWEEN_LAYERS * layer, relative_angles[i], parent_circle)
        down_circle.node.setAttribute("data-name", this['name']);
        down_circle.node.setAttribute("data-username", this['username']);
        down_circle.node.setAttribute("data-personal", this['personal']);
        down_circle.node.setAttribute("data-userid", this['user_id']);
        down_circle.node.setAttribute("data-directscount", this['directs_count']);
        drawDownlineCircles(this, down_circle, layer + 1, relative_angles[i])
      })
    }
  }

  drawDownlineCircles(user, main_user_circle, 1)

  $('circle').click(function() {
    if ($(this).attr('data-userid')) {
      params["user_id"] = $(this).attr('data-userid')
      paper.clear()
      getJson(4)
    }
  }).mousemove(function(evt) {
    if ($(this).attr('data-userid')) {
      $('#name-row > .placeholder').html($(this).attr('data-name'))
      $('#username-row > .placeholder').html($(this).attr('data-username'))
      $('#personal-row > .placeholder').html($(this).attr('data-personal'))
      $('#directs_count-row > .placeholder').html($(this).attr('data-directscount'))

      var mouseX = evt.clientX, mouseY = evt.clientY;
      var width = $('#info-box').width(), height = $('#info-box').height();
      var mouse_left = mouseX < (window.innerWidth / 2), mouse_top = mouseY < (window.innerHeight / 2);
      var new_x = mouseX + 10
      var new_y = mouse_top ? mouseY + 15 : (mouseY - height - 30)
      $("#info-box").css({'top': new_y, 'left': new_x})
      $("#info-box").removeClass('hidden')
    }
  }).mouseleave(function() {
    $("#info-box").addClass('hidden')
  })

  background.toBack();
  main_user_circle.toFront();
}

// Lowercase letter means relative
// M	moveto	(x y)+
// Z	closepath	(none)
// L	lineto	(x y)+
// H	horizontal lineto	x+
// V	vertical lineto	y+
// C	curveto	(x1 y1 x2 y2 x y)+
// S	smooth curveto	(x2 y2 x y)+
// Q	quadratic Bézier curveto	(x1 y1 x y)+
// T	smooth quadratic Bézier curveto	(x y)+
// A	elliptical arc	(rx ry x-axis-rotation large-arc-flag sweep-flag x y)+
// R	Catmull-Rom curveto*	x1 y1 (x y)+
