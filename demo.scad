use <ergonomic_handle.scad>

// ---------- demo ----------

// default handle with no finger grooves
translate([ 0, -90, 0 ]) ergonomic_handle(hand_length = 178, hand_width = 79.4, fingergroove = false);

// low-facet handle with grooves overlayed on low-facet handle without grooves, with finger-grooves and end cap
translate([ 0, 0, 0 ]) union()
{
    ergonomic_handle(hand_length = 178, hand_width = 79.4, bottomcapext = 6, groovespc = 0, fingergroove = true,
                     fn = 14, halfrotate = false);
    ergonomic_handle(hand_length = 178, hand_width = 79.4, bottomcapext = 6, groovespc = 7, fingergroove = false,
                     fn = 14, halfrotate = true);
}
// grooved handle with top extension, bottom cap, and matching structure on top surface
translate([ 0, 90, 0 ])
{
    ergonomic_handle(hand_length = 178, hand_width = 79.4, bottomcapext = 6, topext = 10, groovespc = 6);
    translate([ 0, 0, 10 ]) linear_extrude(20, scale = 0.8)
        ergonomic_handle_top_ellipse(hand_length = 177.9, hand_width = 79.4, topext = 10);
}