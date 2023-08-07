///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////     CRC_Module     /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
module CRC #(parameter 	LFSR_WD = 8,			//linear feedback shift register width (8,16,32...) 
						DATA_WD = 8, 			//input data width (8,16,32...)
						Seed = 'b1101_1000,		//the value that counter return to after reset 
						Taps = 'b0100_0100		//the implementation of LFSR (place of xor gates)
						)
(
input   wire            CLK,					// module operating clock
input   wire            RST,					// module reset to intialize the LFSR
input   wire            ACTIVE,					// high signal during  data transaction, low otherwise
input   wire            DATA,					// input serial data
output  reg             CRC,					// serial output CRC bits
output  reg             Valid					// high during output transmission, low otherwise
);


// Internal signals and registers
reg [LFSR_WD-1:0] LFSR;			//LFSR register declaration
reg [DATA_WD-1:0] Counter;		//to count the input data bits
reg  counter_done;				//flag activited when the counter counts all the input data bits
wire Feedback;					//feedback declared as a wire in the LFSR implementation 

//  Integers
integer i;

// Assign statments
assign Feedback = LFSR[0] ^ DATA;

// Sequential always block
always@(posedge CLK or negedge RST)
begin
	if (!RST) 
		begin
			LFSR <= Seed;	//1101_1000
			CRC <= 1'b0;
			Valid <= 1'b0;
			Counter <= 'b0;
			counter_done <= 1'b0;
		end
	else if(ACTIVE && !counter_done)
		begin
			Counter <= Counter + 1'b1;    	
			for (i = 0; i < LFSR_WD-1; i=i+1) 			
			begin
				if (Taps[i])   	//Taps 0100_0100	
					LFSR[i] <= LFSR[i+1] ^ Feedback;
				else 
					LFSR[i] <= LFSR[i+1];
			end 
			LFSR[7] <= Feedback ;   	 			 	 
		end
	else if(!ACTIVE && counter_done)
	    begin
			CRC <=	LFSR[0];
			LFSR <= LFSR >> 1; 
		end
end

// Combinational always block
always@(*)
begin
	if(Counter == DATA_WD)
	begin
		Counter = 'b0;
		counter_done = 1'b1;
		Valid = 1'b1;
	end   
end



endmodule 