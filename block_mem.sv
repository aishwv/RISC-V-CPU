`default_nettype none

import def_pack::control_info;


module block_memory(
  input wire CLK,
  input wire RSTN,
  input wire MEM_ENABLED,
  input wire [9:0] ADDRESS,
  input wire WRITE_ENABLE,
  input wire [31:0] WRITE_DATA,
  output reg [31:0] READ_DATA,
  output reg [31:0] BLOCK_LED_DIRECT_1,
  output reg [31:0] BLOCK_LED_DIRECT_2,
  output reg [31:0] BLOCK_LED_DIRECT_3,
  output reg [31:0] BLOCK_LED_DIRECT_4
);

  localparam memory_size = 1024;
  reg[31:0] memory [0:memory_size - 1];


always @(posedge CLK) begin

   BLOCK_LED_DIRECT_1 <= memory[10'b0000000000];
   BLOCK_LED_DIRECT_2 <= memory[10'b0000000001];
   BLOCK_LED_DIRECT_3 <= memory[10'b0000000010];
   BLOCK_LED_DIRECT_4 <= memory[10'b0000000011];
   
  if (MEM_ENABLED) begin
    if (WRITE_ENABLE) begin
      memory[ADDRESS] <= WRITE_DATA;
    end
    READ_DATA <= memory[ADDRESS];
  end
end

endmodule
`default_nettype wire