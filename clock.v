LA_RUE_GREEN_st: begin
			
				la_rue_green = 1'b1;
				la_rue_yellow = 1'b0;
				la_rue_red = 1'b0;
				orchard_green = 1'b0;
				orchard_yellow = 1'b0;
				orchard_red = 1'b1;
				pedestrian_walk = 1'b0;
				pedestrian_stop = 1'b1;
			
				if (orchard_sensor == 1'b1 | pedestrian_queue == 1'b1) begin
					if ((count >= 3'b011) & (count <= 3'b110) & la_rue_sensor == 1'b0) begin
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
				
				if (count > 3'b011) begin
					if (pedestrian_queue == 1'b1) begin //Change to allow for memory
						state_c = PED_WALK_st;
						count_c = 28'b0;
						x_c = 28'b0;
					end
					else if (pedestrian_queue == 1'b0 & orchard_sensor == 1'b1) begin
						state_c = ORCHARD_GREEN_st;
						count_c = 28'b0;
						x_c = 28'b0;
					end
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
			
				if (count >= 3'b110) begin
					state_c = PED_DONT_WALK_st;
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
				
				flash_count = flash_count + 1'b1;
				
				if (count > 3'b001) begin
					state_c = PED_OFF_st;
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
				
				flash_count = flash_count + 1'b1;
				
				//Still Flashing
				if (count > 3'b001 & flash_count != 3'b110) begin
					state_c = PED_DONT_WALK_st;
					count_c = 28'b0;
					x_c = 28'b0;
					
				end
				
				//Done flashing
				else if (count >= 3'b001 & flash_count == 3'b110) begin
					
					if (orchard_sensor == 1'b0) begin //No orchard request, could be La Rue or ped request
						state_c = LA_RUE_GREEN_st;
						count_c = 28'b0;
						x_c = 28'b0;
						flash_count = 1'b0;
						pedestrian_queue = 1'b0; //Clear queue
					end
					else begin
						state_c = ORCHARD_GREEN_st;
						count_c = 28'b0;
						x_c = 28'b0;
						flash_count = 1'b0;
						pedestrian_queue = 1'b0; //Clear queue
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
				
				if (la_rue_sensor == 1'b0 & pedestrian_queue == 1'b0) begin //no other sensor active
					if (count >= 3'b011 & orchard_sensor == 1'b0) begin
						state_c = ORCHARD_YELLOW_st;
						count_c = 28'b0;
						x_c = 28'b0;
					end
				end
				
				else if (la_rue_sensor == 1'b1 | pedestrian_queue == 1'b1) begin
					if (count >= 3'b001 & count <= 3'b110 & orchard_sensor == 1'b0) begin //3<=t<=6 and orchard off
						state_c = ORCHARD_YELLOW_st;
						count_c = 28'b0;
						x_c = 28'b0;
					end
					
					else if (count > 6) begin
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
				
				if (count > 3'b011) begin
					
					state_c = LA_RUE_GREEN_st; //Default next state
					
					if (la_rue_sensor == 1'b0 & pedestrian_queue == 1'b1) begin
						state_c = PED_WALK_st;
					end
					
					count_c = 28'b0;
					x_c = 28'b0;
					
				end
			
			end