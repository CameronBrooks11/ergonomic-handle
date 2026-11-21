// Grooved handle with a top extension
// A bottom cap, grip grooves, and a matching block on the top surface.

use <../ergonomic_handle.scad>

ergonomic_handle(hand_length=178, hand_width=79.4, bottomcapext=6, topext=10, groovespc=6);
translate([0, 0, 10]) linear_extrude(20, scale=0.8)
        ergonomic_handle_top_ellipse(hand_length=178, hand_width=79.4, topext=10);
