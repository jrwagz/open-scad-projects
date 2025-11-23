include<BOSL2/std.scad>
include <BOSL2/joiners.scad>

// Led Channel Primitives - Implemented with BOSL2 primitives and concepts

// led_channel
// Generates a connectorized modular LED channel
//
// Parameters:
//   channel_length          - length of the led channel
//   led_strip_width         - width of LED strip to place in channel
//
//   cutout                  - if true, cut out portion of channel floor for connector/wire, default: false
//   cutout_length           - cutout length, defaults to 15.0mm
//   led_strip_tolerance     - tolerance on the sides of the LED strip to the walls, defaults to 0.1mm
//   channel_wall_width      - width of the walls on the channel, defaults to 1.4mm
//   channel_wall_height     - Height of walls around LED strip, defaults to 8.0mm
//   channel_floor_thickness - thickness of floor under LED strip, defaults to 5.0mm
//   stub_height             - Height of stub for dovetail connector, defaults to 11.0mm
//   stub_length             - Length of stub for dovetail connector, defaults to 7.0mm
//   dovetail_length         - Length of dovetail connector (width of base of dovetail), defaults to 4.0mm
//   dovetail_depth          - Depth of dovetail connector (how much it goes into the connector), defaults to 3.0mm
//   dovetail_angle          - Angle in degrees for dovetail connector, defaults to 60 degrees
//   dovetail_tolerance      - Tolerance around dovetail connector, defaults to 0.1mm
module led_channel (
    channel_length, led_strip_width,
    cutout=false,cutout_length=15.0,
    anchor=CENTER,spin=0,orient=UP,
    led_strip_tolerance=0.1,
    channel_wall_width=1.4, channel_wall_height=8.0,
    channel_floor_thickness=6.0,
    stub_height=10.0,stub_length=7.0,
    dovetail_length=4.0,dovetail_depth=3.0,dovetail_angle=60.0,dovetail_tolerance=0.1)
{

total_x_len = channel_length;
total_y_len = led_strip_width+2*(led_strip_tolerance)+2*(channel_wall_width);
total_z_len = channel_wall_height + channel_floor_thickness + stub_height;

default_z_mid = stub_height + (channel_floor_thickness/2);
z_shift = default_z_mid - (total_z_len/2);

dovetail_offset = dovetail_depth/tan(dovetail_angle);

// The Dovetail needs to be centered between the channel floor and the
// stub height
dove_center = (channel_floor_thickness + stub_height)/2;
dove_offset = dove_center - (stub_height/2);

// echo("total_x_len",total_x_len);
// echo("total_y_len",total_y_len);
// echo("total_z_len",total_z_len);
// echo("default_z_mid",default_z_mid);
// echo("z_shift",z_shift);
// echo("slop",get_slop());
// echo("dove_center",dove_center);
// echo("dove_offset",dove_offset);

attachable(anchor,spin,orient, size=[total_x_len,total_y_len,total_z_len]) {
    diff() union() {
        // Main Channel Floor
        up(z_shift) cuboid([channel_length,
            led_strip_width+2*(led_strip_tolerance),
            channel_floor_thickness],
            anchor=anchor, spin=spin, orient=orient) {
                // Optional cutout for wires/connector
                if (cutout) {
                    tag("remove") left(stub_length) align(CENTER,RIGHT) cuboid([
                        cutout_length,
                        led_strip_width+2*(led_strip_tolerance),
                        channel_floor_thickness+0.02
                    ]);
                }
                // Channel Walls
                align([FRONT,BACK],[BOTTOM,BOTTOM]){
                    cuboid([channel_length,
                    channel_wall_width,
                    channel_wall_height + channel_floor_thickness]);
                }
                // Dovetail Stub - Female
                align(BOTTOM,LEFT){
                    cuboid([stub_length,
                        total_y_len,
                        stub_height])
                            tag("remove") up(dove_offset) xrot(90) attach(LEFT)
                                dovetail("female",
                                    thickness=total_y_len,
                                    width=dovetail_length+2*dovetail_offset,
                                    height=dovetail_depth,
                                    angle=90-dovetail_angle);
                }
                // Dovetail Stub - Male
                align(BOTTOM,RIGHT){
                    cuboid([stub_length-dovetail_depth,
                    total_y_len,
                    stub_height])
                         up(dove_offset) xrot(90) attach(RIGHT)
                            dovetail("male",
                                    width=dovetail_length+2*dovetail_offset,
                                    thickness=total_y_len,
                                    height=dovetail_depth,
                                    angle=90-dovetail_angle);
                }
        }
    }
    children();
}
}


// led_channel_half
// Generates a connectorized modular LED channel
// Pre-split into a half for optimal printing without supports
// Specify gender="male" to get a part that mates with one for gender="female"
//
// Parameters:
//   channel_length          - length of the led channel
//   led_strip_width         - width of LED strip to place in channel
//   gender                  - male/female for the two separate parts that connect to each other
//
//   cutout                  - if true, cut out portion of channel floor for connector/wire, default: false
//   cutout_length           - cutout length, defaults to 15.0mm
//   led_strip_tolerance     - tolerance on the sides of the LED strip to the walls, defaults to 0.1mm
//   channel_wall_width      - width of the walls on the channel, defaults to 1.4mm
//   channel_wall_height     - Height of walls around LED strip, defaults to 8.0mm
//   channel_floor_thickness - thickness of floor under LED strip, defaults to 5.0mm
//   stub_height             - Height of stub for dovetail connector, defaults to 11.0mm
//   stub_length             - Length of stub for dovetail connector, defaults to 7.0mm
//   dovetail_length         - Length of dovetail connector (width of base of dovetail), defaults to 4.0mm
//   dovetail_depth          - Depth of dovetail connector (how much it goes into the connector), defaults to 3.0mm
//   dovetail_angle          - Angle in degrees for dovetail connector, defaults to 60 degrees
//   dovetail_tolerance      - Tolerance around dovetail connector, defaults to 0.1mm
module led_channel_half (
    channel_length, led_strip_width,
    gender="male",
    cutout=false,cutout_length=15.0,
    anchor=CENTER,spin=0,orient=UP,
    led_strip_tolerance=0.1,
    channel_wall_width=1.4, channel_wall_height=8.0,
    channel_floor_thickness=6.0,
    stub_height=10.0,stub_length=7.0,
    dovetail_length=4.0,dovetail_depth=3.0,dovetail_angle=60.0,dovetail_tolerance=0.1)
{

total_x_len = channel_length;
total_y_len = (led_strip_width/2)+led_strip_tolerance+channel_wall_width;
total_z_len = channel_wall_height + channel_floor_thickness + stub_height;

default_z_mid = stub_height + (channel_floor_thickness/2);
z_shift = default_z_mid - (total_z_len/2);

dovetail_offset = dovetail_depth/tan(dovetail_angle);

max_connector_spacing = 50;

connector_length = 10;
connector_width = channel_floor_thickness;

connector_pieces = floor(channel_length/max_connector_spacing) + 1;
connector_spacing = channel_length/connector_pieces;
odd_connector_count = connector_pieces % 2 == 1 ? true : false;

wall_alignment = gender=="male"? BACK :
                 gender=="female"? FRONT :
                 assert(false, str("Unsupported gender: ", gender));

connector_movement = gender=="male" ? 1 : -1;
cutout_shift = odd_connector_count ? connector_spacing/2 : 0;
cutout_align = gender=="male" ? FRONT : BACK;

// The Dovetail needs to be centered between the channel floor and the
// stub height
dove_center = (channel_floor_thickness + stub_height)/2;
dove_offset = dove_center - (stub_height/2);

// echo("total_x_len",total_x_len);
// echo("total_y_len",total_y_len);
// echo("total_z_len",total_z_len);
// echo("default_z_mid",default_z_mid);
// echo("z_shift",z_shift);
// echo("slop",get_slop());
// echo("connector_pieces",connector_pieces);
// echo("dove_center",dove_center);
// echo("dove_offset",dove_offset);

attachable(anchor,spin,orient, size=[total_x_len,total_y_len,total_z_len]) {
    union() {
        diff() {
        // Main Channel Floor
        up(z_shift) cuboid([channel_length,
            total_y_len,
            channel_floor_thickness],
            anchor=anchor, spin=spin, orient=orient) {
            // Optional cutout for wires/connector
            if (cutout) {
                tag("remove") right(cutout_shift) back(-connector_movement*0.01) align(CENTER,cutout_align) cuboid([
                    cutout_length,
                    total_y_len-channel_wall_width,
                    channel_floor_thickness+0.02
                ]);
            }
            // Channel Wall
            align(TOP,wall_alignment){
                cuboid([channel_length,
                channel_wall_width,
                channel_wall_height]);
            }
            // Dovetail Stub - Female
            align(BOTTOM,LEFT){
                    cuboid([stub_length,
                        total_y_len,
                        stub_height])
                            tag("remove") up(dove_offset) xrot(90) attach(LEFT)
                                dovetail("female",
                                    thickness=total_y_len,
                                    width=dovetail_length+2*dovetail_offset,
                                    height=dovetail_depth,
                                    angle=90-dovetail_angle);
                }
            // Dovetail Stub - Male
            align(BOTTOM,RIGHT){
                cuboid([stub_length-dovetail_depth,
                total_y_len,
                stub_height])
                    up(dove_offset) xrot(90) attach(RIGHT)
                        dovetail("male",
                                width=dovetail_length+2*dovetail_offset,
                                thickness=total_y_len,
                                height=dovetail_depth,
                                angle=90-dovetail_angle);
            }
            fwd(connector_movement*(total_y_len/2)) xcopies(l=(channel_length-connector_spacing), n=connector_pieces) {
                tag("remove") half_joiner_clear(l=connector_length, w=connector_width, orient=FWD, spin=90, clearance=0.01);
                if (gender=="male") {
                    half_joiner(l=connector_length, w=connector_width, orient=FWD, spin=90, base=2);
                } else {
                    half_joiner2(l=connector_length, w=connector_width, orient=BACK, spin=90, base=2);
                }
            }
        }
    }
    }
    children();

}
}

// led_channel_connector_90
// Generates 90 degree connector for a modular LED channel
//
// 90 degree connector is generally useful for when you want to have the LEDs facing outward and
// the whole channel forms a rectangle.
//
// Parameters:
//   led_strip_width         - width of LED strip to place in channel
//
//   led_strip_tolerance     - tolerance on the sides of the LED strip to the walls, defaults to 0.1mm
//   channel_wall_width      - width of the walls on the channel, defaults to 1.4mm
//   channel_floor_thickness - thickness of floor under LED strip, defaults to 5.0mm
//   stub_height             - Height of stub for dovetail connector, defaults to 11.0mm
//   stub_length             - Length of stub for dovetail connector, defaults to 7.0mm
//   dovetail_length         - Length of dovetail connector (width of base of dovetail), defaults to 4.0mm
//   dovetail_depth          - Depth of dovetail connector (how much it goes into the connector), defaults to 3.0mm
//   dovetail_angle          - Angle in degrees for dovetail connector, defaults to 60 degrees
//   dovetail_tolerance      - Tolerance around dovetail connector, defaults to 0.1mm

module led_channel_connector_90 (
    led_strip_width,
    led_strip_tolerance=0.1,
    channel_wall_width=1.4,
    channel_floor_thickness=6.0,
    stub_height=10.0,stub_length=7.0,
    dovetail_length=4.0,dovetail_depth=3.0,dovetail_angle=60.0,dovetail_tolerance=0.1)
{
    dovetail_offset = dovetail_depth/tan(dovetail_angle);
    total_y_len = led_strip_width+2*(led_strip_tolerance)+2*(channel_wall_width);

    // The Dovetail needs to be centered between the channel floor and the
    // stub height
    dove_center = (channel_floor_thickness + stub_height)/2;

    // Main body
    diff() {
        down(total_y_len/2) rotate_extrude(angle=90) {
            square([channel_floor_thickness+stub_height,
            led_strip_width+(2*led_strip_tolerance)+2*channel_wall_width]);
        }
        // Dovetail female connector
        tag("remove")
            back(dove_center) xrot(90) dovetail("female",
                thickness=total_y_len,
                width=dovetail_length+2*dovetail_offset,
                height=dovetail_depth,
                angle=90-dovetail_angle, orient=RIGHT);
    }
    // Dovetail male connector
    right(dove_center) xrot(90) dovetail("male",
        thickness=total_y_len,
        width=dovetail_length+2*dovetail_offset,
        height=dovetail_depth,
        angle=90-dovetail_angle);
}

// led_channel_connector_270
// Generates 270 degree connector for a modular LED channel
//
// 270 degree connector is generally useful for when you want to have the LEDs facing inward and
// the whole channel forms a rectangle.
//
// Parameters:
//   led_strip_width         - width of LED strip to place in channel
//
//   led_strip_tolerance     - tolerance on the sides of the LED strip to the walls, defaults to 0.1mm
//   channel_wall_width      - width of the walls on the channel, defaults to 1.4mm
//   channel_floor_thickness - thickness of floor under LED strip, defaults to 5.0mm
//   stub_height             - Height of stub for dovetail connector, defaults to 11.0mm
//   dovetail_length         - Length of dovetail connector (width of base of dovetail), defaults to 4.0mm
//   dovetail_depth          - Depth of dovetail connector (how much it goes into the connector), defaults to 3.0mm
//   dovetail_angle          - Angle in degrees for dovetail connector, defaults to 60 degrees
//   dovetail_tolerance      - Tolerance around dovetail connector, defaults to 0.1mm
module led_channel_connector_270 (
    led_strip_width,
    led_strip_tolerance=0.1,
    channel_wall_width=1.4,
    channel_floor_thickness=6.0,
    stub_height=10.0,
    dovetail_length=4.0,dovetail_depth=3.0,dovetail_angle=60.0,dovetail_tolerance=0.1)
{
    dovetail_offset = dovetail_depth/tan(dovetail_angle);
    total_y_len = led_strip_width+2*(led_strip_tolerance)+2*(channel_wall_width);
    // This offset keeps the bend radius the same as the 90 connector
    offset_length = channel_floor_thickness+stub_height;

    // The Dovetail needs to be centered between the channel floor and the
    // stub height
    dove_center = (channel_floor_thickness + stub_height)/2;

    // Main body
    diff() {
        down(total_y_len/2) rotate_extrude(angle=90) {
            translate([offset_length,0,0]) {
                square([channel_floor_thickness+stub_height,
                    led_strip_width+(2*led_strip_tolerance)+2*channel_wall_width]);
            }
        }
        // Dovetail female connector
        tag("remove")
            back(offset_length+dove_center) xrot(90) dovetail("female",
                thickness=total_y_len,
                width=dovetail_length+2*dovetail_offset,
                height=dovetail_depth,
                angle=90-dovetail_angle, orient=RIGHT);
    }
    // Dovetail male connector
    right(offset_length+dove_center) xrot(90) dovetail("male",
        thickness=total_y_len,
        width=dovetail_length+2*dovetail_offset,
        height=dovetail_depth,
        angle=90-dovetail_angle);
}


$slop = 0.1;
length=50;
led_width=10;

// led_channel_connector_270(led_strip_width=led_width);


// led_channel_half(channel_length = length, led_strip_width = led_width, gender="female", cutout=true);

// back(20) xrot(-90) led_channel(channel_length = length, led_strip_width = led_width);
// back(50) xrot(-90) led_channel_half(channel_length = length, led_strip_width = led_width, gender="male");
// back(80)  xrot(90) led_channel_half(channel_length = length, led_strip_width = led_width, gender="female");


// // fwd(20) xrot(90) led_channel(channel_length = length, led_strip_width = led_width, cutout=true);
// fwd(50) xrot(90) led_channel_half(channel_length = length, led_strip_width = led_width, gender="female", cutout=true);
// fwd(80) xrot(-90) led_channel_half(channel_length = length, led_strip_width = led_width, gender="male", cutout=true);

// color("red") right(50) led_channel_connector_90(led_strip_width=led_width, $fn=200);
// left(80) led_channel_connector_270(led_strip_width=led_width, $fn=200);