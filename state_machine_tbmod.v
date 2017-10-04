module state_machine(

	clk, reset_n, la_rue_sensor, orchard_sensor, pedestrian_sensor, 
	la_rue_green, la_rue_yellow, la_rue_red, 
	orchard_green, orchard_yellow, orchard_red,
	pedestrian_walk, pedestrian_stop, count, count_c, state, state_c, x, x_c
	
);
	//Inputs
	input reset_n;
	input clk;
	input la_rue_sensor, orchard_sensor, pedestrian_sensor;
	
	//Outputs
	output reg la_rue_green, la_rue_yellow, la_rue_red;
	output reg orchard_green, orchard_yellow, orchard_red;
	output reg pedestrian_walk, pedestrian_stop;
	
	//FLIP FLOPS
	
	//Sensor flip flops
	reg [2:0] flash_count, flash_count_c; //Used to count number of flashes
	reg pedestrian_queue, pedestrian_queue_c; //Used to store pedestrian requests
	
	reg la_rue_sensor_ff, orchard_sensor_ff, pedestrian_sensor_ff;
	reg la_rue_sensor_ff_c, orchard_sensor_ff_c, pedestrian_sensor_ff_c;
	
	//State Flip Flops
	output reg [2:0] state;
	output reg [2:0] state_c;
	
	//Counter flip flops
	output reg [27:0] count;
	output reg [27:0] count_c;
	
	output reg [27:0] x; //Counter
	output reg [27:0] x_c;
	
	//State definitions
	parameter LA_RUE_GREEN_st = 3'b000;
	parameter LA_RUE_YELLOW_st = 3'b001;
	parameter PED_WALK_st = 3'b010;
	parameter PED_DONT_WALK_st = 3'b011;
	parameter PED_OFF_st = 3'b100;
	parameter ORCHARD_GREEN_st = 3'b101;
	parameter ORCHARD_YELLOW_st = 3'b110;
	
	always @(*) begin
		
		//Flip Flop Defaults
		state_c = state;
		flash_count_c = flash_count;
		
		la_rue_sensor_ff_c = la_rue_sensor; //Save sensor states to FF
		orchard_sensor_ff_c = orchard_sensor;
		pedestrian_sensor_ff_c = pedestrian_sensor_ff; 
		
		//Counter
		count_c = count + 1; //Testbench
		x_c = x + 1'b1; //Clock counter
		/*
		if (x == 28'd24999999) begin //1 sec
			x_c = 28'd0;
			count_c = count + 1'b1; //Increase counter once per second
		end
		*/
		if (pedestrian_sensor == 0) begin
			pedestrian_sensor_ff_c = 1'b1; //To remember whether the pedestrian has pressed the signal
		end

		
		//State Machine Logic
		case (state) 
			
			LA_RUE_GREEN_st: begin
			
				la_rue_green = 1'b1;
				la_rue_yellow = 1'b0;
				la_rue_red = 1'b0;
				
				orchard_green = 1'b0;
				orchard_yellow = 1'b0;
				orchard_red = 1'b1;
				
				pedestrian_walk = 1'b0;
				pedestrian_stop = 1'b1;
			
				if (orchard_sensor_ff == 1'b1 | pedestrian_sensor_ff == 1'b1) begin
					if ((count >= 3'b011) & (count <= 3'b110) & la_rue_sensor_ff == 1'b0) begin
						state_c = LA_RUE_YELLOW_st;
						count_c = 28'b0;
						x_c = 28'b0;
					end
					else if (count > 3'b110) begin
						state_c = LA_RUE_YELLOW_st;
						count_c = 28'b0;
						x_c = 28'b0;
					end
				end
				
			end
			
			LA_RUE_YELLOW_st: begin
			
				la_rue_green = 1'b0;
				la_rue_yellow = 1'b1;
				la_rue_red = 1'b0;
				
				orchard_green = 1'b0;
				orchard_yellow = 1'b0;
				orchard_red = 1'b1;
				
				pedestrian_walk = 1'b0;
				pedestrian_stop = 1'b1;
				
				if (count == 3'b011) begin
					if (pedestrian_sensor_ff == 1'b1) begin //Change to allow for memory
						state_c = PED_WALK_st;
						count_c = 28'b0;
						x_c = 28'b0;
					end
					else if (pedestrian_sensor_ff == 1'b0 & orchard_sensor_ff == 1'b1) begin
						state_c = ORCHARD_GREEN_st;
						count_c = 28'b0;
						x_c = 28'b0;
					end
				end
				
			end
			
			ORCHARD_GREEN_st: begin
			
				la_rue_green = 1'b0;
				la_rue_yellow = 1'b0;
				la_rue_red = 1'b1;
				
				orchard_green = 1'b1;
				orchard_yellow = 1'b0;
				orchard_red = 1'b0;
				
				pedestrian_walk = 1'b0;
				pedestrian_stop = 1'b1;
				
				if (la_rue_sensor_ff == 1'b0 & pedestrian_sensor_ff == 1'b0) begin //no other sensor active
					if (count >= 3'b011 & orchard_sensor_ff == 1'b0) begin
						state_c = ORCHARD_YELLOW_st;
						count_c = 28'b0;
						x_c = 28'b0;
					end
				end
				
				else if (la_rue_sensor_ff == 1'b1 | pedestrian_sensor_ff == 1'b1) begin
					if (count >= 3'b001 & count <= 3'b110 & orchard_sensor_ff == 1'b0) begin //3<=t<=6 and orchard off
						state_c = ORCHARD_YELLOW_st;
						count_c = 28'b0;
						x_c = 28'b0;
					end
					
					else if (count > 3'b110) begin
						state_c = ORCHARD_YELLOW_st;
						count_c = 28'b0;
						x_c = 28'b0;
					end
					
				end
				
			end
			
			ORCHARD_YELLOW_st: begin
			
				la_rue_green = 1'b0;
				la_rue_yellow = 1'b0;
				la_rue_red = 1'b1;
				orchard_green = 1'b0;
				orchard_yellow = 1'b1;
				orchard_red = 1'b0;
				pedestrian_walk = 1'b0;
				pedestrian_stop = 1'b1;
				
				if (count == 3'b011) begin
					
					state_c = LA_RUE_GREEN_st; //Default next state
					
					if (la_rue_sensor_ff == 1'b0 & pedestrian_sensor_ff == 1'b1) begin
						state_c = PED_WALK_st;
					end
					
					count_c = 28'b0;
					x_c = 28'b0;
					
				end
			
			end
			
			PED_WALK_st: begin
			
				la_rue_green = 1'b0;
				la_rue_yellow = 1'b0;
				la_rue_red = 1'b1;
				
				orchard_green = 1'b0;
				orchard_yellow = 1'b0;
				orchard_red = 1'b1;
				
				pedestrian_walk = 1'b1;
				pedestrian_stop = 1'b0;
			
				if (count > 3'b110) begin
					state_c = PED_DONT_WALK_st;
					flash_count_c = flash_count + 3'b001;
					count_c = 28'b0;
					x_c = 28'b0;
				end
			
			
			end
			
			PED_DONT_WALK_st: begin
			
				la_rue_green = 1'b0;
				la_rue_yellow = 1'b0;
				la_rue_red = 1'b1;
				
				orchard_green = 1'b0;
				orchard_yellow = 1'b0;
				orchard_red = 1'b1;
				
				pedestrian_walk = 1'b0;
				pedestrian_stop = 1'b1;
				
				
				
				if (count >= 3'b001) begin
					state_c = PED_OFF_st;
					flash_count_c = flash_count + 3'b001;
					count_c = 28'b0;
					x_c = 28'b0;
					
				end
				
			end
			
			PED_OFF_st: begin
			
				la_rue_green = 1'b0;
				la_rue_yellow = 1'b0;
				la_rue_red = 1'b1;
				
				orchard_green = 1'b0;
				orchard_yellow = 1'b0;
				orchard_red = 1'b1;
				
				pedestrian_walk = 1'b0;
				pedestrian_stop = 1'b0;
				
				
				//Still Flashing
				//if (count > 3'b001 & flash_count != 3'b110) begin
				if (count >= 3'b001 & flash_count < 3'b101) begin
					flash_count_c = flash_count + 3'b001;
					state_c = PED_DONT_WALK_st;
					count_c = 28'b0;
					x_c = 28'b0;
					
				end
				
				
				//else if (flash_count >= 3'b110) begin
				else if (count >= 3'b001 & flash_count >= 3'b101) begin
				
					if (orchard_sensor_ff == 1'b0) begin //No orchard request, could be La Rue or ped request
						state_c = LA_RUE_GREEN_st;
						count_c = 28'b0;
						x_c = 28'b0;
						flash_count_c = 3'b000;
						pedestrian_sensor_ff_c = 1'b0; //Clear queue
					end
					else begin
						state_c = ORCHARD_GREEN_st;
						count_c = 28'b0;
						x_c = 28'b0;
						flash_count_c = 3'b000;
						pedestrian_sensor_ff_c = 1'b0; //Clear queue
					end
					
				end
				
			end
			
		endcase
		
		
		

		
		//If reset
		if (reset_n == 0) begin


			state_c = 3'b000;
			
			x_c = 28'd0;
			
			count_c = 28'd0;
			
			flash_count_c = 3'b000;
			
			orchard_sensor_ff_c = 1'b0;
			la_rue_sensor_ff_c = 1'b0;
			
			pedestrian_sensor_ff_c = 1'b0;
			
		end
		
	end
	
	//Flip Flops
	always @( clk) begin //Change to "clk" for testbench
	//always @(posedge clk) begin //Change to "clk" for testbench	
		state <= #1 state_c;
		count <= #1 count_c;
		x <= #1 x_c;
		flash_count <= #1 flash_count_c;
		
		orchard_sensor_ff <= #1 orchard_sensor_ff_c;
		la_rue_sensor_ff <= #1 la_rue_sensor_ff_c;
		pedestrian_sensor_ff <= #1 pedestrian_sensor_ff_c;
		
	end
	
	
endmodule