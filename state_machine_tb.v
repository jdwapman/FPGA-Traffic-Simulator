module state_machine_tb();

	wire la_rue_green, la_rue_yellow, la_rue_red;
	wire orchard_green, orchard_yellow, orchard_red;
	wire pedestrian_walk, pedestrian_stop;
	wire [27:0] count, count_c, x, x_c;
	wire [3:0] state, state_c;
	
	reg clk;
	reg reset_n;
	reg la_rue_sensor, orchard_sensor, pedestrian_sensor;
	
	
	integer i, last_count;
	
	state_machine UUT(.clk(clk), .reset_n(reset_n), .la_rue_sensor(la_rue_sensor),
						.orchard_sensor(orchard_sensor), .pedestrian_sensor(pedestrian_sensor), 
						.la_rue_green(la_rue_green), .la_rue_yellow(la_rue_yellow), .la_rue_red(la_rue_red),
						.orchard_green(orchard_green), .orchard_yellow(orchard_yellow), .orchard_red(orchard_red),
						.pedestrian_walk(pedestrian_walk), .pedestrian_stop(pedestrian_stop),
						.count(count), .count_c(count_c),
						.state(state), .state_c(state_c), .x(x), .x_c(x_c));
	initial begin
	
		//Initialize clock
		clk = 0;
		
		//Reset Module
		reset_n = 0;
		#10;
		reset_n = 1;
		#10;
		
		//Initialize sensor inputs
		la_rue_sensor = 1;
		orchard_sensor = 0;
		pedestrian_sensor = 1; //off

		$display("Test 1");
		for (i = 0; i < 50; i = i + 1) begin //Turn on and off pedestrian sensor from La Rue. La rue sensor is on
		
			#3;
			
			clk = ~clk;
			
			#3;
			
			if (i == 1) begin
				//orchard_sensor = 1;
				pedestrian_sensor = 0; //Pedestrian present
			end
			
			#3;
			
			if (i == 3) begin
				pedestrian_sensor = 1; //Turn off pedestrian sensor
				orchard_sensor = 1; //Turn on orchard sensor
			end
			
			#3;
			
			$display("Count: %d, Current State: %d", count, state);		
			
		end
		
		$display("Test 2");
		//La Rue -> Orchard -> Pedestrian -> Orchard/La Rue
		for (i = 0; i < 50; i = i + 1) begin
		
			#3;
			
			clk = ~clk;
			
			#3;
			
			if (i == 1) begin
				la_rue_sensor = 0;
				orchard_sensor = 1;
			end
			
			#3;
			
			if (i == 20) begin
				pedestrian_sensor = 0; //Turn on pedestrian sensor
			end
			
			//Optional
			if (i == 25) begin
				la_rue_sensor = 1;
				orchard_sensor = 0;
			end
			
			#3;
			
			$display("Count: %d, Current State: %d", count, state);		
			
		end
		
		$display("End Tests");


	end
	
endmodule