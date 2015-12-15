$(document).ready(function() {
  if ($('.tree-chart').length > 0) {
    // Creates canvas 320 × 200 at 10, 50
    var paper = Raphael(50, 50, 320, 1000);
    var line = paper.path( ["M", 80, 60, "L", 10, 200 ] );
    line.attr("stroke-width", 10);
    line.attr("stroke", "#00f")

    // Creates circle at x = 50, y = 40, with radius 10
    var circle = paper.circle(50, 50, 50);
    // Sets the fill attribute of the circle to red (#f00)
    circle.attr("fill", "#f00");

    // Sets the stroke attribute of the circle to white
    circle.attr("stroke", "#fff");
  }
})
