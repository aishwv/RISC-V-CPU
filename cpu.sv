`default_nettype none

import def_pack::control_info;

module cpu (
  input wire CLK,
  input wire RSTN,
  output reg [31:0] register_file [0:31],
  output reg completed,
  output wire [31:0] led_direct_1,
  output wire [31:0] led_direct_2,
  output wire [31:0] led_direct_3,
  output wire [31:0] led_direct_4
);

  // Note that we have to change this val when you want to change the number of instructions.
  wire [31:0] final_pc = 32'd18;
  localparam inst_mem_size = 32'd18;



  // define important components
  reg [31:0] pc;
  reg [31:0] executing_inst;

  // define control flags
  reg decoder_enabled;
  reg executer_enabled;
  reg writer_enabled;


  ////////////////////
  // code for test
  ////////////////////
  //constants inst_mem
  // assign RESULT = register_file[14];
  reg [31:0] inst_mem [0:inst_mem_size] = '{


         32'h00001237,  //0 lui, x4,1
         32'h00500193,  //1 addi x3,x0,5      
         32'h01b00113,  //2 addi x2, x0, 27
         32'h0080006f,  //3 jal x0,8
         32'h00a00193,  //4 addi x3,x0,10     // x3 should not be added with 10 becuase of jal
         32'h00310f33,  //5 add x30, x2, x3   // 27+5 to make 32
         32'h01e40023,  //6 sb x30 0 x8
         32'h03700e93,  //7 addi x29, x0, 55
  //       32'h00200e93,  //7 addi x29,x0,2
         32'h02100f13,  //8 addi x30 x0   33 
         32'h01df5463,  //9 bge x30,x29,8
         32'h000e8f13,  //10 addi x30, x29,0
         32'h00140413,  //11 addi x8 x8 1  
         32'h01e40023,  //12 sb x30 0 x8
         32'h02200f13,  //13 addi x30 x0 34
         32'h00140413,  //14 addi x8 x8 1
         32'h01e40023,  //15 sb x30 0 x8
         32'h02300f13,  //16 addi x30 x0 35 
         32'h00140413,  //17 addi x8 x8 1  
         32'h01e40023   //18 sb x30 0 x8



/*
         32'h00001137,  //0 lui x2, 1
         32'h00500193,  //1 addi x3,x0,5 x30,x0,32
         32'h02000f13,  //2 addi x30 x0 32  
         32'h01e40023,  //3 sb x30 0 x8
         32'h03700e93,  //4 addi x29, x0, 55
//         32'h00200e93,  //4 addi x29,x0,2
         32'h02100f13,  //5 addi x30 x0   33 
         32'h01df5463,  //6 bge x30,x29 , 8
         32'h000e8f13,  //7 addi x30, x29,0
         32'h00140413,  //8 addi x8 x8 1  
         32'h01e40023,  //9 sb x30 0 x8
         32'h02200f13,  //10 addi x30 x0 34
         32'h00140413,  //11 addi x8 x8 1
         32'h01e40023,  //12 sb x30 0 x8
         32'h02300f13,  //13 addi x30 x0 35 
         32'h00140413,  //14 addi x8 x8 1  
         32'h01e40023  //15 sb x30 0 x8



         32'h00200e03,  //0 lb x28,2
         32'h02000f13,  //1 addi x30 x0 32 
         32'h01e40023,  //2 sb x30 0 x8
         32'h037e8e93,  //3 addi x29,x29,55
         32'h002e8e93,  //3 addi x29,x29,2
         32'h02100f13,  //4 addi x30 x0   33 
         32'h01df5463,  //5 bge x30,x29 , 8
         32'h000e8f13,  //6 addi x30, x29,0
         32'b00000000,  //7 00000000
         32'h00140413,  //8 addi x8 x8 1  
         32'h01e40023,  //9 sb x30 0 x8
         32'h02200f13,  //10 addi x30 x0 34
         32'h00140413,  //11 addi x8 x8 1
         32'h01e40023,  //12 sb x30 0 x8
         32'h02300f13,  //13 addi x30 x0 35 
         32'h00140413,  //14 addi x8 x8 1  
         32'h01e40023,  //15 sb x30 0 x8
         32'h00000000   //16 end
*/
  };
  int reg_index; // index used for register initialization
  initial begin
    pc <= 0;
    // initialize register_file
    for(reg_index = 0; reg_index < 32; reg_index = reg_index + 1) begin // i++, ++i
        register_file[reg_index] <= 32'b0;
    end

    decoder_enabled <= 1;
    executer_enabled <= 1;
    writer_enabled <= 1;


  end


  ////////////////////
  // define variables
  ////////////////////
  // need for overall
  control_info ctr_info_d;
  control_info ctr_info_e;
  // need for fetch stage
  reg [31:0] instruction;
  // need for decode stage

  // define conditional jump
  wire conditional_jump;

  decoder decode (
    .CLK(CLK),
    .RSTN(RSTN),
    .DECODER_ENABLED(decoder_enabled),
    .INSTRUCTION(instruction),
    .PC(pc),
    .CONDITIONAL_JUMP(conditional_jump),
    .CTR_INFO(ctr_info_d)
  );
  // need for execute stage
  wire [31:0] jump_dest;
  reg [31:0] exec_rd;
  reg [31:0] memory_out;

  wire [31:0] write_data;

  executer execute (
    .CLK(CLK),
    .RSTN(RSTN),
    .EXECUTER_ENABLED(executer_enabled),
    .REGISTER_FILE(register_file),
    .CTR_INFO(ctr_info_d),
    .FORWARDED_VAL(write_data),
    .JUMP_DEST(jump_dest),
    .EXEC_RD(exec_rd),
    .MEMORY_OUT(memory_out),
    .CTR_INFO_OUT(ctr_info_e),
    .EXE_LED_DIRECT_1(led_direct_1),
    .EXE_LED_DIRECT_2(led_direct_2),
    .EXE_LED_DIRECT_3(led_direct_3),
    .EXE_LED_DIRECT_4(led_direct_4)
  );
  // need for write stage

  wire write_enable;
  reg [3:0] conditional_jump_count;



  writer write(
    .CLK(CLK),
    .RSTN(RSTN),
    .WRITER_ENABLED(writer_enabled),
    .REGISTER_FILE(register_file),
    .CTR_INFO(ctr_info_e),
    .EXEC_RD(exec_rd),
    .MEMORY_OUT(memory_out),
    .WRITE_ENABLE(write_enable),
    .WRITE_DATA(write_data)
  );



  initial begin
    conditional_jump_count <= 3'b0;
  end


  ////////////////////
  // define each stage
  ////////////////////
  always @(posedge CLK) begin

//    completed <= (ctr_info_e.pc == final_pc+1 & interrupt_count == 0);

    completed <= (ctr_info_e.pc >= final_pc+1);

    // ---------------- stall controller -----------------
    // stall when conditional jump write and execute not disabled
    if(conditional_jump == 1 & conditional_jump_count == 0) begin
      // conditional instruction is in decode stage
      conditional_jump_count <= 1;
      decoder_enabled <= 0;
    end
    else if(conditional_jump_count == 1) begin
      // conditional instruction is in execute stage
      conditional_jump_count <= 2;
      pc <= jump_dest-1; // -1 because we want the pc in fetch stage not decode stage
    end
    else if(conditional_jump_count == 2) begin
      // conditional instruction is in write stage
      conditional_jump_count <= 0;
      decoder_enabled <= 1;
      pc <= pc + 1;
    end

    else begin
      pc <= pc + 1;
    end



    // fetch instruction
    if (pc <= inst_mem_size) begin
      instruction <= inst_mem[pc];
    end
    else begin
      instruction <= 32'b00000000000000000000000000010011;
    end

    // decode instruction

    // write back
    if(write_enable & writer_enabled) begin
      register_file[ctr_info_e.rd] <= write_data;
    end


  end


endmodule
