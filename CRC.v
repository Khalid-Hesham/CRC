///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////     CRC_Module     /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
module CRC #(parameter 	LFSR_WD = 8,			//linear feedback shift register width (8,16,32...) 
						DATA_WD = 8, 			//input data width (8,16,32...)
						Seed = 'b1101_1000,		//the value that LFSR return to after reset 
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
wire  counter_done;			//flag activited when the counter counts all the input data bits
wire Feedback;				//feedback declared as a wire in the LFSR implementation 

//  Integers
integer i;

// Assign statments
assign Feedback = LFSR[0] ^ DATA;
assign counter_done = (Counter == DATA_WD);


// Always Block For CRC Operation
always@(posedge CLK or negedge RST)
begin
	if (!RST) 
		begin
			LFSR <= Seed;	//1101_1000
			CRC <= 1'b0;
			Valid <= 1'b0;
			Counter <= 'b0;
		end
	else if(ACTIVE && !counter_done) // Entering data serially to the LFSR
		begin  	
			Counter <= Counter + 1'b1;
			// Doing CRC operation 
			for (i = 0; i < LFSR_WD-1; i=i+1) 			
				begin
					if (Taps[i])   	//Taps 0100_0100
						LFSR[i] <= LFSR[i+1] ^ Feedback;
					else 
						LFSR[i] <= LFSR[i+1];
				end 
			LFSR[7] <= Feedback ;   
			if(Counter == DATA_WD - 1)
				Valid <= 1'b1;	 			 	 
		end
	else if(!ACTIVE && counter_done) // Extracting data serially from the LFSR
	    begin
			CRC <=	LFSR[0];
			LFSR <= LFSR >> 1;
		end
end


////////////////////////////////////////////////////
///////////  Tracing the LFSR operation  ///////////
////////////////////////////////////////////////////
//LFSR -> 1 1 0 1 _ 1 0 0 0
//DATA -> 93 -> 1001_0011
//Feedback -> 0^1=1
//LFSR[7]=1, LFSR[6]=0, LFSR[5]=1, LFSR[4]=0,
//LFSR[3]=1, LFSR[2]=0, LFSR[1]=0, LFSR[0]=0 
////////////////////////////////////////////////////
//LFSR -> 1 1 0 1 _ 1 0 0 0
//DATA -> 72 -> 0111_0010 
//Feedback -> 0^0=0
//LFSR[7]=0, LFSR[6]=1, LFSR[5]=1, LFSR[4]=0,
//LFSR[3]=1, LFSR[2]=1, LFSR[1]=0, LFSR[0]=0
////////////////////////////////////////////////////

endmodule 
