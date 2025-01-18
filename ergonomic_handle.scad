/*
 * Ergonomic handle
 * by Alex Matulich
 * Verson 5.1, May 2022
 *
 * Revised and uploaded to GitHub for continued development as well as reference and visibility on December 5th, 2024.
 *
 */

hand_length = 186;           // Default hand length for scaling (mm)
hand_width = 85;             // Default metacarpal breadth (mm)
metacarpal_expansion = 1.12; // Typical metacarpal breadth expansion in grip position (10%-15%)
flair = true;                // Enable top/bottom flaring for enhanced pull force
fingergroove = true;         // Add grooves for finger-specific ergonomic fit
groovespc = 8;               // Spacing between grooves (mm)
groovedepth = 0.6;           // Depth of grooves for grip (mm)
tiltangle = 110;             // Tilt angle of the handle (degrees)
topext = 0;                  // No top extension added
bottomcapext = 6;            // Bottom cap extended by 6 mm
bottomcapscale = 0.3;        // Bottom cap scaled to 30% of the handle cross-section
fn = 64;                     // Number of facets for ellipses
halfrotate = false;          // No half-rotation of polygon vertices

// Generate the ergonomic handle with the defined parameters
ergonomic_handle(hand_length = hand_length, hand_width = hand_width, metacarpal_expansion = metacarpal_expansion,
                 flair = flair, fingergroove = fingergroove, groovespc = groovespc, groovedepth = groovedepth,
                 tiltangle = tiltangle, topext = topext, bottomcapext = bottomcapext, bottomcapscale = bottomcapscale,
                 fn = fn, halfrotate = halfrotate);

// Dummy module to stop customizer from picking up internal variables
module dummy()
{
}

// -------------------------------
// ---------- constants ----------
// -------------------------------

// Handle curve coefficients
ehandle_coeff_default = [   // coefficents for default handle based on all test subjects

    // curve E (forward profile)
    [ 0.10820685778527288,
     7.8071566553000377e-002,
    -0.11713845806508627 ],
    // curve F (side profile)
    [ 8.9094997189434533e-002,
    -0.23994552971632244,
     1.0934064033888202,
    -1.5902142712055265,
     0.70892877695967604 ],
    // curve G (rear profile)
    [ 0.10820685778528655,
    -0.46856937731734472,
     1.9272376487779372,
    -2.9629722410641546,
     1.4995260044545953 ]
];

ehandle_coeff_fwdflair = [  // coefficients for handle with forward profile flared at the ends

    // curve E - assumes 12% metacarpal expansion
    [0.11246945332942532,
    -1.8795070341676573e-002,
     0.36187545606899507,
    -0.83803954628607691,
     0.46058029602811634],
     // curve F
     ehandle_coeff_default[1],
     // curve G
     ehandle_coeff_default[2]
];

// trochoid finger groove parameters
// finger width porportions from anthropometric data
thumbfrac = 0.231959853553746;      // thumb fraction of hand width
forefingerfrac = 0.200542328752527; // forefinger fraction of hand width

/* 0.261856394119384, 0.262553059392204, 0.251706774167261, 0.22388377232115,0.22388377232115
four fingers only - doesn't work well */
fingwidfrac = [
    // thumb plus four fingers
    0.5 * (thumbfrac + forefingerfrac),
    0.5 * (thumbfrac + forefingerfrac), // split total width of thumb+forefinger
    0.201238475943949,                  // middle finger
    0.193454805146993,                  // ring finger
    0.172804536602786,                  // pinky
    0.172804536602786                   // copy pinky to avoid array index overrun in trochoid()
];

trochoid_amp = 0.65; // trochoid amplitude, must be between 0.5 and 0.9

// -----------------------------
// ---------- modules ----------
// -----------------------------

// render the handle
module ergonomic_handle(hand_length = default_hand_length(), hand_width = default_hand_width(), flair = true,
                        bottomcapext = 0, topext = 0, groovespc = 0, fingergroove = false, tiltangle = 110, fn = 64,
                        halfrotate = false, metacarpal_expansion = 1.12, groovedepth = 0.6, bottomcapscale = 0.3)
{
    if (metacarpal_expansion < 1.10 || metacarpal_expansion > 1.15)
    {
        echo("WARNING: metacarpal_expansion must be between 1.10 and 1.15. Adjusting to fit the valid range.");
        metacarpal_expansion = max(1.10, min(metacarpal_expansion, 1.15));
    }
    ehdcoeff = flair ? ehandle_coeff_fwdflair : ehandle_coeff_default;
    ecof = hand_length * ehdcoeff[0];                                  // scaled front profile coefficients
    fcof = hand_length * ehdcoeff[1];                                  // scaled side profile coefficients
    gcof = hand_length * ehdcoeff[2];                                  // scaled rear profile coefficients
    ehlen = ergonomic_handle_height(hand_width, metacarpal_expansion); // length of handle
    bcapext = bottomcapext / ehlen;                                    // unit-scaled end cap extension
    t_ext = topext / ehlen;                                            // unit-scaled top extension
    tfwx = fingergroove ? trochoid(0, ehlen) : 0;
    bfwx = fingergroove ? trochoid(ehlen, ehlen) : 0;
    vfn = fingergroove ? 128 : fn;

    estack = [ // stack of ellipse cross sections
       // top extension, if any
        if (topext > 0)
            for(z=[-t_ext:1/fn:-0.01/ehlen])
                let(xmin = polynomial(gcof, z),
                    xmax = polynomial(ecof, z),
                    ymax = polynomial(fcof, z))
                    elev_ellipse(xmin, xmax, ymax, z*ehlen, tiltangle, fn, tfwx, halfrotate),

        // main body of handle
        for(i=[0:vfn])
            let(z=i/vfn,
                fwx = fingergroove ? trochoid(z*ehlen, ehlen) : 0,
                xmin = polynomial(gcof, z),
                xmax = polynomial(ecof, z),
                ymax = polynomial(fcof, z))
                    elev_ellipse(xmin, xmax, ymax, z*ehlen, tiltangle, fn, fwx, halfrotate),

        // bottom cap, if any
        if (bottomcapext > 0)
            for(z=[1+0.5/ehlen:1/ehlen:1+bcapext-0.01/ehlen])
                let(scl = bottomcapscale+(1-bottomcapscale)*cos(90*(z-1)/bcapext), xmin = scl*polynomial(gcof, z), xmax = scl*polynomial(ecof, z), ymax = scl*polynomial(fcof, z))
                    elev_ellipse(xmin, xmax, ymax, z*ehlen, tiltangle, fn, bfwx, halfrotate),
        // last ellipse of bottom cap
        if (bottomcapext > 0)
            let(z=1+bcapext, scl=bottomcapscale, xmin = scl*polynomial(gcof, z), xmax = scl*polynomial(ecof, z), ymax = scl*polynomial(fcof, z))
                elev_ellipse(xmin, xmax, ymax, z*ehlen, tiltangle, fn, bfwx, halfrotate)
    ];
    // render the object right-side-up
    rotate([ 0, 180, 0 ]) difference()
    {
        polyhedron_stack(estack);
        if (groovespc > 0 && !fingergroove)
            for (h = [1.5 * groovespc:groovespc:ehlen - groovespc])
                groove_ellipse(h);
    }

    module groovecutter(groovedepth)
    {
        polygon(points = [ [ -groovedepth, 0 ], [ 4 - groovedepth, 4 ], [ 4 - groovedepth, -4 ] ]);
    }

    module groove_ellipse(ht)
    {
        let(z = ht / ehlen, xmin = polynomial(gcof, z), xmax = polynomial(ecof, z), ymax = polynomial(fcof, z),
            semimajoraxis = 0.5 * (xmax + xmin))
            multmatrix(m =
                           [
                               [ 1, 0, cos(tiltangle), semimajoraxis - xmin + ht * cos(tiltangle) ],
                               [ 0, ymax / semimajoraxis, 0, 0 ], [ 0, 0, 1, ht ], [ 0, 0, 0, 1 ]
                           ]) rotate([ 0, 0, 180 ]) rotate_extrude(angle = 360, $fn = fn, convexity = 4)
                translate([ semimajoraxis, 0, 0 ]) groovecutter(groovedepth);
    }
}

// Build a polyhedron object from a stack of polygons. It is assumed that each polygon has [x,y,z] coordinates as its
// vertices, and the ordering of vertices follows the right-hand-rule with respect to the direction of propagation of
// each successive polygon.
module polyhedron_stack(stack)
{
    nz = len(stack);    // number of z layers
    np = len(stack[0]); // number of polygon vertices
    facets = [
        [for (j = [0:np - 1]) j], // close first opening
        for (i = [0:nz - 2]) for (j = [0:np - 1])
            let(k1 = i * np + j, k4 = i * np + ((j + 1) % np), k2 = k1 + np, k3 = k4 + np)[k1, k2, k3, k4],
        [for (j = [np * nz - 1:-1:np * nz - np]) j], // close last opening
    ];
    polyhedron(flatten(stack), facets, convexity = 6);
}

// return polygon of top ellipse (including extension)
module ergonomic_handle_top_ellipse(hand_length = default_hand_length(), hand_width = default_hand_width(),
                                    metacarpal_expansion = 1.12, flair = true, fingergroove = true, topext = 0,
                                    tiltangle = 110, fn = 64, halfrotate = false)
{
    coeff = hand_length * (flair ? ehandle_coeff_fwdflair : ehandle_coeff_default);
    top = -topext / ergonomic_handle_height(hand_width, metacarpal_expansion);
    tfwx = fingergroove ? trochoid(0, ergonomic_handle_height(hand_width, metacarpal_expansion)) : 0;
    p3d = elev_ellipse(polynomial(coeff[2], top), polynomial(coeff[0], top), polynomial(coeff[1], top), -topext,
                       tiltangle, fn, tfwx, halfrotate);
    p2d = [for (a = p3d)[-a[0], a[1]]];
    polygon(points = p2d);
}

// return polygon of bottom ellipse (EXCLUDING bottom cap extension)
module ergonomic_handle_bottom_ellipse(hand_length = default_hand_length(), hand_width = default_hand_width(),
                                       metacarpal_expansion = 1.12, flair = true, fingergroove = true, tiltangle = 110,
                                       fn = 64, halfrotate = false)
{
    coeff = hand_length * (flair ? ehandle_coeff_fwdflair : ehandle_coeff_default);
    ehlen = ergonomic_handle_height(hand_width, metacarpal_expansion);
    bfwx = fingergroove ? trochoid(ehlen, ehlen) : 0;
    p3d = elev_ellipse(polynomial(coeff[2], 1), polynomial(coeff[0], 1), polynomial(coeff[1], 1),
                       ergonomic_handle_height(hand_width, metacarpal_expansion), tiltangle, fn, bfwx, halfrotate);
    p2d = [for (a = p3d)[-a[0], a[1]]];
    polygon(points = p2d);
}

// -------------------------------
// ---------- functions ----------
// -------------------------------

// default gender-based hand dimensions
function default_hand_length(female = false) = female ? 171 : 186;
function default_hand_width(female = false) = female ? 76 : 85;

// height of handle without extensions
function ergonomic_handle_height(hand_width = default_hand_width(),
                                 metacarpal_expansion) = hand_width * metacarpal_expansion;

// polynomial evaluation at x, given any number of coefficents c[0]...c[degree]
// usage: y = polynomial(coefficients, x);
function polynomial(cof, x, sum = 0, indx = undef) = let(i = indx == undef ? len(cof) - 1 : indx) i == 0
                                                         ? cof[0] + sum
                                                         : polynomial(cof, x, x *(sum + cof[i]), i - 1);

// elliptical cross section of handle at elevation z
function elev_ellipse(xmin, xmax, ymax, z, tiltangle, fn = 64, fwd_ext = 0, halfrotate = false) =
    let(semimajor = 0.5 * (xmax + xmin), fwd_semimajor = semimajor + fwd_ext, yscl = ymax / semimajor,
        hr = halfrotate ? 0 : 180 / fn,
        xoff = z * cos(tiltangle) + xmax -
               semimajor)[for (a = [-90 + hr:360 / fn:89.9])[fwd_semimajor * cos(a) + xoff, yscl *semimajor *sin(a), z],
                          for (a = [90 + hr:360 / fn:269.9])[semimajor * cos(a) + xoff, yscl *semimajor *sin(a), z]];

// flatten an array of arrays
function flatten(l) = [for (a = l) for (b = a) b];

// ----------------------------------
// trochoid finger groove functions
// ----------------------------------

// finger grooves are four trochoids of different sizes blended together end-to-end
function trochoid(z_elev,
                  handwid) = let(fdata = getfingindex(max(0, z_elev), handwid), fi = fdata[0],
                                 width = fingwidfrac[fi] * handwid, nextwid = fingwidfrac[fi + 1] * handwid,
                                 r = width / (2 * PI), b = trochoid_amp * r, nextb = trochoid_amp * nextwid / (2 * PI),
                                 accumwid = fdata[1] * handwid, z = z_elev - accumwid, zfrac = z / width,
                                 theta = findtrochtheta(z, r, b, 2 * PI * zfrac),
                                 thetadeg = fi == 0 && theta < PI ? 180 : theta * 180 / PI, // 5.1: remove top knuckle
                                 interpb = zfrac * (nextb - b) + b, y = interpb + interpb * cos(thetadeg))
                                 /*(fi==0 && thetadeg<180) ? 0.01  // special case for thumb
                                     : */
                                 1.1 *
                                 y
                             + 0.2;

// for a give z elevation, return the corresponding finger index 0-4
function getfingindex(z, handwid, i = 0,
                      accumwid = 0) = let(widfrac = accumwid + fingwidfrac[i], wid = widfrac * handwid) z <= wid
                                              || i == 3
                                          ? [ i, accumwid ]
                                          : getfingindex(z, handwid, i + 1, widfrac);

// for a given z elevation, find the corresponding trochoid rotation angle - no closed-form solution for this, so using
// Newton-Raphson iterative method
function findtrochtheta(z, r, b, theta = PI,
                        n = 0) = let(tdeg = theta * 180 / PI,
                                     newtheta = theta - (r * theta - b * sin(tdeg) - z) / (r - b * cos(tdeg)))
                                                 abs(newtheta - theta) < 0.001 ||
                                         n >= 8
                                     ? newtheta
                                     : findtrochtheta(z, r, b, newtheta, n + 1);