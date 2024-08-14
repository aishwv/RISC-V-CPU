`default_nettype none

import def_pack::control_info;


module executer(
  input wire CLK,
  input wire RSTN,
  input wire EXECUTER_ENABLED,
  input wire [31:0] REGISTER_FILE [0:31],
  input control_info CTR_INFO,
  input wire [31:0] FORWARDED_VAL,
  output wire [31:0] JUMP_DEST,
  output reg [31:0] EXEC_RD,
  output reg [31:0] MEMORY_OUT,
  output control_info CTR_INFO_OUT,
  output wire [31:0] EXE_LED_DIRECT_1,
  output wire [31:0] EXE_LED_DIRECT_2,
  output wire [31:0] EXE_LED_DIRECT_3,
  output wire [31:0] EXE_LED_DIRECT_4
);



wire [31:0] RS1_VAL = (CTR_INFO.forwarding_rs1) ? FORWARDED_VAL : REGISTER_FILE[CTR_INFO.rs1];
wire [31:0] RS2_VAL = (CTR_INFO.forwarding_rs2) ? FORWARDED_VAL : REGISTER_FILE[CTR_INFO.rs2];

aluer alu(
  .CLK(CLK),
  .RSTN(RSTN),
  .ALU_ENABLED(EXECUTER_ENABLED),
  .CTR_INFO(CTR_INFO),
  .RS1_VAL(RS1_VAL),
  .RS2_VAL(RS2_VAL),
  .ALU_RESULT(EXEC_RD)
);


assign JUMP_DEST = CTR_INFO.jal                                            ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  CTR_INFO.jalr                                            ? $signed(RS1_VAL) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.beq && (RS1_VAL == RS2_VAL))                   ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.bne && (RS1_VAL != RS2_VAL))                   ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.blt && ($signed(RS1_VAL) < $signed(RS2_VAL)))  ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.bge && ($signed(RS1_VAL) >= $signed(RS2_VAL))) ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.bltu && (RS1_VAL < RS2_VAL))                   ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.bgeu && (RS1_VAL >= RS2_VAL))                  ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  CTR_INFO.pc + 1;

wire [31:0] note = $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2) ;

wire [9:0] address = $signed({1'b0, RS1_VAL}) + $signed(CTR_INFO.immediate);
wire write_enable = (CTR_INFO.sb || CTR_INFO.sh || CTR_INFO.sw) ? 1'b1 : 1'b0;

block_memory memory (
  .CLK(CLK),
  .RSTN(RSTN),
  .MEM_ENABLED(EXECUTER_ENABLED),
  .ADDRESS(address),
  .WRITE_ENABLE(write_enable),
  .WRITE_DATA(RS2_VAL),
  .READ_DATA(MEMORY_OUT),
  .BLOCK_LED_DIRECT_1(EXE_LED_DIRECT_1),
  .BLOCK_LED_DIRECT_2(EXE_LED_DIRECT_2),
  .BLOCK_LED_DIRECT_3(EXE_LED_DIRECT_3),
  .BLOCK_LED_DIRECT_4(EXE_LED_DIRECT_4)
);



always @(posedge CLK) begin
  if (EXECUTER_ENABLED) begin
    CTR_INFO_OUT <= CTR_INFO;
  end
end

endmodule
`default_nettype wire