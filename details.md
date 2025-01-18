# Design Details

An ergonomic handle distributes the hand contact pressure as evenly as possible.

## Basis

The dimensions in this model are based on several research papers using anthropometric data from various populations
around the world. The handle profile is based on a 2020 study in which gripping hands were measured with a contour gauge
to derive the correct curves for an ergonomic handle.

All of these studies are cited and linked in the blog article "[Whose hands are biggest? You may be
surprised.](https://www.nablu.com/2022/03/whose-hands-are-biggest-you-may-be.html)"

The handle contour study was extrapolated by generalizing it to be scalable to any size of hand. Knowing that the handle
height is based on metacarpal breadth (hand width) and the handle cross section sizes are based on hand length, one can
generate vertical and horizontal scale factors for the curve control points given in the study, and thereby obtain a
handle scaled correctly to any size hand.

## Usage

Place this in a searchable location, like the same directory as your script, and near the top, put this line:

use <ergonomic_handle.scad>

## Modules

### Main

`ergonomic_handle(hand_length=185, hand_width=86, flair=true, bottomcapext=0, topext=0, groovespc=0, tiltangle=110, fn=64, halfrotate=false);`

Renders the body of an ergonomic handle. The handle is oriented so that the top surface is centered at the origin.

**Parameters:**

- `hand_length`: Length of hand from tip of middle finger to first crease on wrist. Defaults to `default_hand_length()`.
- `hand_width`: Metacarpal breadth; width of the four fingers where they meet the palm. Defaults to `default_hand_width()`.
- `flair`: Set to `true` to flare out the top and bottom of the front edge for better pull force. When `flair=false`, the handle is generated as described in the referenced study. Defaults to `true`.
- `bottomcapext`: Bottom cap extension. `0` = flat bottom (default). Suggested values range from 3 to 8.
- `topext`: Top extension, curves extrapolated upward by this amount. `0` = no extension (default). The extension extends above the origin.
- `groovespc`: Groove spacing for improved grip. `0` = none (default, or if `fingergroove=true`). Suggested spacing is 6-10 mm. Grooves are 1.2 mm wide and 0.6 mm deep.
- `fingergroove`: Set to `false` for no finger grooves (default), or `true` to include them (this disables `groovespc`). WARNING: Enabling this setting causes the handle to fit ONLY the hand for which it is sized! The grooves are un-ergonomic and uncomfortable if the handle size doesn't match the hand.
- `tiltangle`: Handle tilt angle. `110°` (default) recommended. Should be no less than 90°.
- `fn`: Number of facets (default 64) in elliptical cross-section as well as vertical slices. Vertical slices are always 128 if `fingergroove=true`.
- `halfrotate`: Whether to rotate polygon vertices half of a segment around the ellipse (default `false`). Useful only for overlapping two low-poly handles for interesting textures (see demo).

### Helpers

`ergonomic_handle_top_ellipse(hand_length, hand_width, topext, tiltangle, fn);`

Returns a polygon corresponding to the top surface of the handle (including extension). Parameters are the same as described above. All have defaults if omitted.

`ergonomic_handle_bottom_ellipse(hand_length, hand_width, tiltangle, fn);`

Returns a polygon corresponding to the bottom surface of the handle (excluding bottom cap extension). Useful when not using a bottom cap and you want to match something with the bottom of the handle. Parameters are the same as described above. All have defaults if omitted.

Additionally, `ergonomic_handle_height(hand_width, metacarpal_expansion)` may be used to get the height of the basic handle body without extensions. This is the same as `hand_width * metacarpal_expansion`.

The handle is rendered with the top center at origin. The bottom of the handle (excluding extension cap) is `ergonomic_handle_height()` below the origin.

### Default Parameters

All default parameters are overridden in module arguments.

These hand dimensions (186 mm length, 85 mm breadth) were calculated from data found in various journal articles, broken down by nationality: Bangladeshi, Czech, Filipino, German, central Indian, East Indian, Iranian, Korean, Jordanian, Mexican, Taiwanese, Turkish, and Vietnamese. The average male hand length is 186 mm (range 173-198) and breadth is 85 mm (range 78-98). The average female hand length is 170 mm (range 161-180) and breadth is 76 mm (range 68-92). Using the average male size should also cover nearly all adult females and all children.

When plotted by hand area (length x width), the populations sort themselves into three obvious groups with similar hand sizes. Vietnamese and Indian females have the smallest hands, followed closely by Turkish and Bangladeshi females. Filipino males seem to be an outlier with the largest hands. Other than Filipino males, the group with the largest hands includes Czech, Iranian, Jordanian, Turkish, and German males, as well as Filipino females.
