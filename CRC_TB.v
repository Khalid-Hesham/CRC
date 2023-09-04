//  Define Time Scale
`timescale 1ns/1ps

///////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////     CRC Test_Bench     //////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
module CRC_TB;

// Parameters
parameter  CLK_PERIOD = 100;
parameter  Test_Cases = 10;         

parameter  LFSR_WD_tb = 8;
parameter  DATA_WD_tb = 8;
parameter  Seed_tb = 8'b1101_1000;
parameter  Taps_tb = 8'b0100_0100;

//  DUT Signals
reg                         DATA_tb;
reg                         CLK_tb;
reg                         RST_tb;
reg                         ACTIVE_tb;
wire                        CRC_tb;
wire                        Valid_tb;

// Loop Variables
integer j;

///////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////      Memories      //////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

// Initiate 2D arrays for reading text files
reg    [LFSR_WD_tb-1:0]   Test_inputs   [Test_Cases-1:0] ; // to save the inputs from txt in -> 2D array
reg    [LFSR_WD_tb-1:0]   Expected_outputs   [Test_Cases-1:0] ; // to save the outputs from txt in -> 2D array

///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////     Initial     ////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

// Intial Block
initial 
 begin
    
    // System Functions
        $dumpfile("CRC_DUMP.vcd") ;       
        $dumpvars; 
    
    // Read Input Files
        $readmemh("DATA_h.txt", Test_inputs);
        $readmemh("Expec_Out_h.txt", Expected_outputs);

    // initialization
        initialize();

    // Test Cases
        for (j=0;j<Test_Cases;j=j+1)
        begin
            reset ();
            crc_operation(Test_inputs[j]) ;               // do_lfsr_operation
            check_out(Expected_outputs[j],j) ;           // check output response
        end

    #100
      $stop ;

 end
///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////     Tasks     ////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

// Initialization
task initialize ;
 begin
    CLK_tb  = 'b0;
    RST_tb  = 'b1;
    ACTIVE_tb = 'b0;
 end
endtask

// Reset technique
task reset;
begin
    RST_tb =  'b1;
  #(CLK_PERIOD)
    RST_tb  = 'b0;
  #(CLK_PERIOD)
    RST_tb  = 'b1;
end
endtask

// CRC Operation
task crc_operation;
 input  [DATA_WD_tb-1:0]     input_data_tb;
 integer i;
 begin
    ACTIVE_tb = 1'b1;
    for (i = 0; i<DATA_WD_tb ;i=i+1 ) 
        begin
            DATA_tb <= input_data_tb[i]; // Update the serial data signal
                #(CLK_PERIOD);  
        end      // Wait for CLK Period between each bit

    ACTIVE_tb = 1'b0;  
 end
endtask

// Check the output
task check_out ;
 input  reg     [DATA_WD_tb-1:0]       expected_output;
 input  integer                        operation_number; 
 
 reg    [LFSR_WD_tb-1:0]               generated_output;
 
 integer k;
 
 begin
    if (Valid_tb) 
    begin
            for(k=0; k<LFSR_WD_tb; k=k+1)
                begin
                #(CLK_PERIOD) generated_output[k] = CRC_tb ;
                end
            if(generated_output == expected_output) 
                $display("Test Case %d is succeeded",operation_number);
            else
                $display("Test Case %d is failed", operation_number);  
                
    end       
 end
endtask

///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////     Clock     /////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
// CLock generation
always #(CLK_PERIOD/2)  CLK_tb = ~CLK_tb ;


///////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////     DUT     /////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
// DUT instantiation
CRC #(  .LFSR_WD(LFSR_WD_tb),
        .DATA_WD(DATA_WD_tb),
        .Seed(Seed_tb),
        .Taps(Taps_tb)
) DUT (
.DATA(DATA_tb),
.CLK(CLK_tb),
.RST(RST_tb),
.ACTIVE(ACTIVE_tb),
.CRC(CRC_tb),
.Valid(Valid_tb)
);



endmodule
