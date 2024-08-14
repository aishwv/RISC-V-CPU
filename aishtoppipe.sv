module aishtoppipe(
    input wire        CLOCK_50,
    input       [3:0] KEY,
    input       [9:0] SW,
    output reg  [0:9] LEDR,
    output reg  [0:6] HEX0
   );

    parameter select_clock = 25;
    
    wire [31:0] LED_DIRECT_MEM1;
    wire [31:0] LED_DIRECT_MEM2;
    wire [31:0] LED_DIRECT_MEM3;
    wire [31:0] LED_DIRECT_MEM4;
    wire [31:0] LED_REG[0:31];
    reg [31:0] MYCLOCK;
    reg reset = 1'b0; 
    reg [0:0] clk;
    logic completed_led=1'b0;

    
    clock_divider myclock(
           .clock(CLOCK_50),
           .divided_clocks(MYCLOCK)
       );
    
    
    cpu my_cpu (
       .CLK(clk),
       .RSTN(reset),
       .register_file(LED_REG),
       .completed(completed_led),
       .led_direct_1(LED_DIRECT_MEM1),
       .led_direct_2(LED_DIRECT_MEM2),
       .led_direct_3(LED_DIRECT_MEM3),
       .led_direct_4(LED_DIRECT_MEM4)
        );
  

always @ (*)
begin

    if (completed_led == 1'b1)
        begin
          HEX0 <= 7'b0000000; 
          LEDR <= { clk,8'b00000000,reset} ;
        end
    else
        begin
            HEX0 <= 7'b1111111;
        if (clk)
            LEDR <= 10'b1010101010;
        else
            LEDR <= 10'b0101010101;
        end
       
    if (SW[0]==1) 
        begin
            clk <= MYCLOCK[select_clock];   
        end
    else if (completed_led)
           LEDR <= 10'b0000000000;
        else
        begin
           clk <= 0; 
           LEDR <= 10'b1111111111;
        end

    if (SW[1]==1 ) 
    begin
       case( KEY )
           4'B0111: LEDR <= LED_DIRECT_MEM1[9:0];
           4'B1011: LEDR <= LED_DIRECT_MEM2[9:0];
           4'B1101: LEDR <= LED_DIRECT_MEM3[9:0];
           4'B1110: LEDR <= LED_DIRECT_MEM4[9:0];
       endcase 
    end
    else 
    begin
        case( KEY )
           4'B0111: LEDR <= LED_REG[4][21:12];
           4'B1011: LEDR <= LED_REG[3][9:0];
           4'B1101: LEDR <= LED_REG[2][9:0];
           4'B1110: LEDR <= LED_REG[30][9:0];
       endcase 
    end
end
endmodule

