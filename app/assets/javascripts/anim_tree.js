const MAX_HEIGHT = 600
const MAX_WIDTH = 1000
$(document).ready(function() {
  if ($('.tree-chart').length > 0) {
    var width = $(window).width();
    var height = $(window).height();
    var horz_offset = width > MAX_WIDTH ? (width - MAX_WIDTH)/2 : 0
    var vert_offset = height > MAX_HEIGHT ? (height - MAX_HEIGHT)/2 : 0
    var center_x = MAX_WIDTH/2
    var center_y = MAX_HEIGHT/2

    var paper = Raphael(horz_offset, vert_offset, MAX_WIDTH, MAX_HEIGHT);
    var background = paper.rect(0, 0, MAX_WIDTH, MAX_HEIGHT);
    background.attr("fill", "#aaa")

    // var line = paper.path( ["M", 80, 60, "L", 10, 200 ] );
    // line.attr("stroke-width", 10);
    // line.attr("stroke", "#00f")
    // var circle = paper.circle(center_x, center_y, 10);
    // circle.attr("fill", "#00f");
    // circle.attr("class", "helloworld");

    guidelines = function() {
      var circle = paper.circle(center_x, center_y, 280);
      circle.attr("stroke", "#fff");
      var circle = paper.circle(center_x, center_y, 210);
      circle.attr("stroke", "#fff");
      var circle = paper.circle(center_x, center_y, 140);
      circle.attr("stroke", "#fff");
      var circle = paper.circle(center_x, center_y, 70);
      circle.attr("stroke", "#fff");
    }()


    var line = paper.path( ["M", center_x, center_y - 35, "l", 0, 35 ] );
    line.attr("stroke-width", 1);
    var circle = paper.circle(center_x, center_y - 35, 10);
    circle.attr("fill", "#f00");
    var main_user_circle = paper.circle(center_x, center_y, 10);
    main_user_circle.attr("fill", "#00f");


    drawCircle = function(distance_from_center, degree, from_circle) {
      // get angle between this circle and main circle. That's starting angle, then subtract 2 iterations
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

    const CHILDREN = 3

    drawChildren = function(circle, start_angle, layer) {
      var circles = []
      var angle_between_circles = 360 / (Math.pow(CHILDREN, layer))
      var first_angle = start_angle - (angle_between_circles * 1) // start_angle - (angle_between_circles * 1)
      for (var i=0; i<CHILDREN; i++) {
        var new_circle = drawCircle(70 * layer, first_angle + (angle_between_circles * (i+1.5)), circle) // (angle_between_circles * (i+1.5))
        circles.push(new_circle)
      }
      return circles
    }

    circles_to_have_children = [main_user_circle]
    for (var layer=0; layer<4; layer++) {
      children_circles = []
      $(circles_to_have_children).each(function(e) {
        var angle = ((360 / circles_to_have_children.length) * e) + 180
        children_circles.push(drawChildren(this, angle, layer+1))
      })
      circles_to_have_children = flatten(children_circles)
    }

    background.toBack();
  }
})

degToRad = function(degrees) {
  return degrees * Math.PI / 180;
};

radToDeg = function(radians) {
  return radians * 180 / Math.PI;
};

flatten = function(arrays) {
  return [].concat.apply([], arrays)
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
