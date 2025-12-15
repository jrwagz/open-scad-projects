include<BOSL2/std.scad>
include <BOSL2/joiners.scad>
include <led_channel_bosl2.scad>

/* [Frame_Parameters] */
// Frame Width (mm)
// If pointing LEDs inside, then this should be the inner dimensions of the frame
// If pointing LEDs outside, then this should be the outer dimensions of the frame
frame_width = 635.0;

// Frame Height (mm)
// If pointing LEDs inside, then this should be the inner dimensions of the frame
// If pointing LEDs outside, then this should be the outer dimensions of the frame
frame_height = 937.0;

// If LEDs are pointing outwards, true, else false
led_face_outwards = true;

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

// BEGIN included file
// TODO: re-insert included file for upload to MakerWorld
// END included file



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
// echo("total_width_pieces",total_width_pieces);
// echo("total_height_pieces",total_height_pieces);
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

// These variables help us ensure that all parts have the same z-axis bottom and are aligned
connector_up_shift = (led_strip_width + 0.1*2 + 1.4*2)/2;
channel_up_shift = connector_up_shift/2;

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
            up(channel_up_shift) right(5) back(30+ch_offset*40) {
                xrot(-90) led_channel_half(gender="male",
                    cutout=cutout,
                    channel_length=height_ch_length,
                    led_strip_width=led_strip_width,
                    channel_wall_height=channel_wall_height);
            }
            up(channel_up_shift) left(5) back(15+ch_offset*40) {
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
                up(channel_up_shift) right(5) back(30+ch_offset*40) {
                    xrot(-90) led_channel_half(gender="male",
                        cutout=cutout,
                        channel_length=width_ch_length,
                        led_strip_width=led_strip_width,
                        channel_wall_height=channel_wall_height);
                }
                up(channel_up_shift) left(5) back(15+ch_offset*40) {
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
                up(connector_up_shift) right(conn_number*35) back(18+ch_offset*40) {
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

// TODO: remove these lines before uploading to MakerWorld
mw_plate_1();
up(30) mw_plate_2();
up(60) mw_plate_3();
up(90) mw_plate_4();
up(120) mw_plate_5();

