//`ifndef _params
//`define _params 1

package def_pack;
typedef struct {

  reg [31:0] pc;
  reg [4:0] rd;
  reg [31:0] immediate;
  reg [4:0] rs1;
  reg [4:0] rs2;

  ////
  // rv-32-i instruction
  ////
  reg lui;
  reg auipc;
  reg jal;
  reg jalr;
  reg beq;
  reg bne;
  reg blt;
  reg bge;
  reg bltu;
  reg bgeu;
  reg lb;
  reg lh;
  reg lw;
  reg lbu;
  reg lhu;
  reg sb;
  reg sh;
  reg sw;
  reg addi;
  reg slti;
  reg sltiu;
  reg xori;
  reg ori;
  reg andi;
  reg slli;
  reg srli;
  reg srai;
  reg add;
  reg sub;
  reg sll;
  reg slt;
  reg sltu;
  reg xor_;
  reg srl;
  reg sra;
  reg or_;
  reg and_;
  // reg fence;
  // reg fence_i;
  // reg ecall;
  // reg ebreak;
  // reg csrrw;
  // reg csrrs;
  // reg csrrc;
  // reg cssrwi;
  // reg cssrsi;
  // reg cssrci;



  ////
  // rv-32-m instructions
  ////
  reg mul;
  reg mulh;
  reg mulhsu;
  reg mulhu;
  reg div;
  reg divu;
  reg rem;
  reg remu;

  // privileged
  reg mret;


  // represents it is conditional jump instructions
  reg forwarding_rs1;
  reg forwarding_rs2;



} control_info;

endpackage 
//`endif