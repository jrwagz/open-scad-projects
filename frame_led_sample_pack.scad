include<BOSL2/std.scad>
include<led_channel_bosl2.scad>

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

connector_up_shift = (led_strip_width + 0.1*2 + 1.4*2)/2;
channel_up_shift = connector_up_shift/2;

up(channel_up_shift) right(5) back(30) {
    xrot(-90) led_channel_half(gender="male",
        cutout=true,
        channel_length=75,
        led_strip_width=led_strip_width,
        channel_wall_height=channel_wall_height);
}
up(channel_up_shift) left(5) back(15) {
    xrot(90) led_channel_half(gender="female",
        cutout=true,
        channel_length=75,
        led_strip_width=led_strip_width,
        channel_wall_height=channel_wall_height);
}

up(connector_up_shift) left(70) led_channel_connector_90(led_strip_width=led_strip_width);
up(connector_up_shift) right(50) led_channel_connector_270(led_strip_width=led_strip_width);

up(channel_up_shift) right(5) fwd(15) {
    xrot(-90) led_channel_half(gender="male",
        cutout=false,
        channel_length=75,
        led_strip_width=led_strip_width,
        channel_wall_height=channel_wall_height);
}
up(channel_up_shift) left(5) fwd(30) {
    xrot(90) led_channel_half(gender="female",
        cutout=false,
        channel_length=75,
        led_strip_width=led_strip_width,
        channel_wall_height=channel_wall_height);
}