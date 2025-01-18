use <../ergonomic_handle.scad>

// Low-facet handle with grooves overlayed on low-facet handle without grooves, with finger-grooves and end cap
union()
{
    ergonomic_handle(hand_length = 178, hand_width = 79.4, bottomcapext = 6, groovespc = 0, fingergroove = true,
                     fn = 14, halfrotate = false);
    ergonomic_handle(hand_length = 178, hand_width = 79.4, bottomcapext = 6, groovespc = 7, fingergroove = false,
                     fn = 14, halfrotate = true);
}
