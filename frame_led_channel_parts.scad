include<BOSL2/std.scad>
include <BOSL2/joiners.scad>

/* [Frame_Parameters] */
// Frame Width (mm)
// If pointing LEDs inside, then this should be the inner dimensions of the frame
// If pointing LEDs outside, then this should be the outer dimensions of the frame
frame_width = 255.0;

// Frame Height (mm)
// If pointing LEDs inside, then this should be the inner dimensions of the frame
// If pointing LEDs outside, then this should be the outer dimensions of the frame
frame_height = 555.0;

// If LEDs are pointing outwards, true, else false
led_face_outwards = false;

// Width of LED Strip to be used in channel (mm)
led_strip_width = 10.0;

// Height of Walls on LED channel (mm)
channel_wall_height=8.0;

// Height of Plate (mm) For example: X1C - 235mm x 235mm
plate_height = 235;

// Maximum length channel to make (mm), this should not be longer than the maximum width of your print plate
max_channel_length=200.0;
///////////////////////////////////////////////////////////////////////////////

//// End of Parameters

$slop = 0.1;

$fn = $preview ? 10 : 200;

//// BEGIN included file
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
//// END included file



// Step 1 - Figure out how much of the height and width will be lost to the corner connectors
// - If led_face_outwards=false, then we lose 2 x channel_wall_height (one on each side)
// - If led_face_outwards=true, then we lose 2 x (channel_wall_height+channel_floor_thickness=5.0+stub_height=11.0) (one on each side)

margin_loss = led_face_outwards ?
                (channel_wall_height+5.0+11.0) :
                (channel_wall_height);

width_after_margin = frame_width - 2*margin_loss;
height_after_margin = frame_height - 2*margin_loss;

// Now figure out how many pieces of width and height we need to make
total_width_pieces = (floor(width_after_margin/max_channel_length) + 1)*2;
total_height_pieces = (floor(height_after_margin/max_channel_length) + 1)*2;
total_channels = total_width_pieces + total_height_pieces;

width_ch_length = width_after_margin / (total_width_pieces/2);
height_ch_length = height_after_margin / (total_height_pieces/2);

// echo("width_after_margin",width_after_margin);
// echo("height_after_margin",height_after_margin);
// echo("width_ch_length",width_ch_length);
// echo("height_ch_length",height_ch_length);
// echo("total_channels",total_channels);

// Step 2 - Calculate number of plates

// Since we already won't be generating pieces longer than the printing table, we just need to figure
// out how many can fit onto a plate, based on the given parameters, looking only at the Y dimension



// Y-dimension needed for each channel
// = channel_wall_height*2 + channel_floor_thickness(6)*2 + stub_height(10) + 0.5(buffer)*3
// = 16 + 12 + 10 + 1.5 = 39.5
ch_per_plate = floor(plate_height/(channel_wall_height*2 + (6*2) + 10 + (0.5*3)));
// echo("ch_per_plate",ch_per_plate);
number_of_plates = floor((total_channels+1)/ch_per_plate) + 1;
// echo("number_of_plates",number_of_plates);

// We create a generic module that will generate the desired plate number
// inside that module we iterate over the possible number/type of channel slots
// for that plate, and then generate the necessary channels given the exact plate number
// First it starts with putting down the height pieces, then the width pieces, and then
// Finally a row for the connectors
module generate_plate(
    plate_number=1
) {
    start_channel = ((plate_number-1)*ch_per_plate)+1;
    end_channel = start_channel + ch_per_plate - 1;
    num_channels = ch_per_plate;
    for (ch_offset = [0:ch_per_plate-1]) {
        ch_num = start_channel + ch_offset;
        // First, see if any height pieces are needed
        if (ch_num <= total_height_pieces) {
            cutout = (ch_num == 1) ? true : false;
            right(5) back(30+ch_offset*40) {
                xrot(-90) led_channel_half(gender="male",
                    cutout=cutout,
                    channel_length=height_ch_length,
                    led_strip_width=led_strip_width,
                    channel_wall_height=channel_wall_height);
            }
            left(5) back(15+ch_offset*40) {
                xrot(90) led_channel_half(gender="female",
                    cutout=cutout,
                    channel_length=height_ch_length,
                    led_strip_width=led_strip_width,
                    channel_wall_height=channel_wall_height);
            }

        }
        // Second, see if any width pieces are needed
        if (ch_num > total_height_pieces) {
            if (ch_num <= total_height_pieces + total_width_pieces) {
                cutout = (ch_num == total_height_pieces + 1) ? true : false;
                right(5) back(15+ch_offset*40) {
                    xrot(-90) led_channel_half(gender="male",
                        cutout=cutout,
                        channel_length=width_ch_length,
                        led_strip_width=led_strip_width,
                        channel_wall_height=channel_wall_height);
                }
                left(5) back(30+ch_offset*40) {
                    xrot(90) led_channel_half(gender="female",
                        cutout=cutout,
                        channel_length=width_ch_length,
                        led_strip_width=led_strip_width,
                        channel_wall_height=channel_wall_height);
                }
            }
        }
        // Last, see if the connectors are needed
        if (ch_num == total_height_pieces + total_width_pieces + 1) {
            for (conn_number = [-2:1]) {
                right(conn_number*35) back(18+ch_offset*40) {
                    if (led_face_outwards) {
                        led_channel_connector_90(led_strip_width=led_strip_width);
                    } else {
                        led_channel_connector_270(led_strip_width=led_strip_width);
                    }
                }
            }
        }
    }
}


// Module for Plate 1
module mw_plate_1() {
    fwd(plate_height/2) generate_plate(plate_number=1);
}

// Module for Plate 2
module mw_plate_2() {
    fwd(plate_height/2) generate_plate(plate_number=2);
}

// Module for Plate 3
module mw_plate_3() {
    fwd(plate_height/2) generate_plate(plate_number=3);
}

// Module for Plate 4
module mw_plate_4() {
    fwd(plate_height/2) generate_plate(plate_number=4);
}

// Module for Plate 5
module mw_plate_5() {
    fwd(plate_height/2) generate_plate(plate_number=5);
}

// Module for Plate 6
module mw_plate_6() {
    fwd(plate_height/2) generate_plate(plate_number=6);
}

//mw_plate_1();
// right(175) mw_plate_2();

