module lab6(

	//////////// CLOCK //////////
	input               ADC_CLK_10,
	input               MAX10_CLK1_50,
	input               MAX10_CLK2_50,

	//////////// KEY //////////
	input         [1:0] KEY,

	//////////// LED //////////
	output        [9:0] LEDR,

	//////////// SW //////////
	input         [9:0] SW,

	//////////// VGA //////////
	output reg    [3:0] VGA_B,
	output reg    [3:0] VGA_G,
	output reg          VGA_HS,
	output reg    [3:0] VGA_R,
	output reg          VGA_VS
);



//=======================================================
//  REG/WIRE declarations
//=======================================================
localparam X_BITS = 10;
localparam Y_BITS = 9;

wire clk;
wire reset_n;

// VGA Timing SIgnals
wire h_sync, v_sync;
wire disp_ena;
wire [11:0] rgb;

// VGA Pixel Counters
wire [X_BITS-1:0] x;
wire [Y_BITS-1:0] y;

wire la_rue_green, la_rue_yellow, la_rue_red;
wire orchard_green, orchard_yellow, orchard_red;
wire pedestrian_walk, pedestrian_stop;
wire state;
wire [2:0] test;
wire [27:0] count;

//=======================================================
/*
Put your code here.

Note that you will have to change the signal assignments in the instantiation
of the "draw" module in order to interact your state machine with the VGA
display.
*/
//=======================================================

state_machine lab6(
	.reset_n(reset_n),
	.clk(clk),
	.la_rue_green(la_rue_green),
	.la_rue_yellow(la_rue_yellow),
	.la_rue_red(la_rue_red),
	.orchard_green(orchard_green),
	.orchard_yellow(orchard_yellow),
	.orchard_red(orchard_red),
	.pedestrian_walk(pedestrian_walk),
	.pedestrian_stop(pedestrian_stop),
	.la_rue_sensor(SW[0]),
	.orchard_sensor(SW[1]),
	.pedestrian_sensor(KEY[1]),
	.count(count)

);

//=======================================================
// Other stuff - change out signals here as appropriate
//=======================================================
assign reset_n = KEY[0];
assign LEDR[9:0]    = count[9:0];


// Instantiate Drawing moduole
draw drawer(
   .clk                 (clk),
   .reset_n             (reset_n),
   .x                   (x),
   .y                   (y),
   .la_rue_green        (la_rue_green),
   .la_rue_yellow       (la_rue_yellow),
   .la_rue_red          (la_rue_red),
   .orchard_green       (orchard_green),
   .orchard_yellow      (orchard_yellow),
   .orchard_red         (orchard_red),
   .pedestrian_walk     (pedestrian_walk),
   .pedestrian_stop     (pedestrian_stop),
   .rgb_out             (rgb)
   

   );

// Instantiate PLL
vga_pll	pll_inst (
	.inclk0    ( MAX10_CLK1_50 ),
	.c0        ( clk )
	);

// Instantite VGA controller
vga_timing timing(
   .pixel_clk     (clk),
   .reset_n       (reset_n),
   .h_sync        (h_sync),
   .v_sync        (v_sync),
   .disp_ena      (disp_ena),
   .column        (x),
   .row           (y)
   );

// Register VGA output signals for timing purposes
always @(posedge clk) begin
   if (disp_ena == 1'b1) begin
      VGA_R <= rgb[11:8];
      VGA_G <= rgb[7:4];
      VGA_B <= rgb[3:0];
   end else begin
      VGA_R <= 4'd0;
      VGA_B <= 4'd0;
      VGA_G <= 4'd0;
   end
   VGA_HS <= h_sync;
   VGA_VS <= v_sync;
end

endmodule
