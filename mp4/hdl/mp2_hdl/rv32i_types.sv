package rv32i_types;
// Mux types are in their own packages to prevent identiier collisions
// e.g. pcmux::pc_plus4 and regfilemux::pc_plus4 are seperate identifiers
// for seperate enumerated types
import pcmux::*;
import marmux::*;
import cmpmux::*;
import alumux::*;
import regfilemux::*;

typedef logic [31:0] rv32i_word;
typedef logic [4:0] rv32i_reg;
typedef logic [3:0] rv32i_mem_wmask;

typedef enum bit [6:0] {
    nop      = 7'b0,
    op_lui   = 7'b0110111, //load upper immediate (U type)
    op_auipc = 7'b0010111, //add upper immediate PC (U type)
    op_jal   = 7'b1101111, //jump and link (J type)
    op_jalr  = 7'b1100111, //jump and link register (I type)
    op_br    = 7'b1100011, //branch (B type)
    op_load  = 7'b0000011, //load (I type)
    op_store = 7'b0100011, //store (S type)
    op_imm   = 7'b0010011, //arith ops with register/immediate operands (I type)
    op_reg   = 7'b0110011, //arith ops with register operands (R type)
    op_csr   = 7'b1110011  //control and status register (I type)
} rv32i_opcode;

typedef enum bit [2:0] {
    beq  = 3'b000,
    bne  = 3'b001,
    blt  = 3'b100,
    bge  = 3'b101,
    bltu = 3'b110,
    bgeu = 3'b111
} branch_funct3_t;

typedef enum bit [2:0] {
    lb  = 3'b000,
    lh  = 3'b001,
    lw  = 3'b010,
    lbu = 3'b100,
    lhu = 3'b101
} load_funct3_t;

typedef enum bit [2:0] {
    sb = 3'b000,
    sh = 3'b001,
    sw = 3'b010
} store_funct3_t;

typedef enum bit [2:0] {
    add  = 3'b000, //check bit30 for sub if op_reg opcode
    sll  = 3'b001,
    slt  = 3'b010,
    sltu = 3'b011,
    axor = 3'b100,
    sr   = 3'b101, //check bit30 for logical/arithmetic
    aor  = 3'b110,
    aand = 3'b111
} arith_funct3_t;

typedef enum bit [2:0] {
    alu_add = 3'b000,
    alu_sll = 3'b001,
    alu_sra = 3'b010,
    alu_sub = 3'b011,
    alu_xor = 3'b100,
    alu_srl = 3'b101,
    alu_or  = 3'b110,
    alu_and = 3'b111
} alu_ops;

typedef enum bit [1:0] {
    start = 2'b00,
    mem_resp = 2'b01,
    wait_ = 2'b10,
    process_dirty_eviction = 2'b11
} ewb_states;

// 2 bit up down branch predictor state
//
typedef enum bit [1:0] {
    strongly_not_taken = 2'b00,
    not_taken = 2'b01,
    taken = 2'b10,
    strongly_taken = 2'b11
} predictor_state;

// for tournament predictor
//
typedef enum bit [1:0] {
    strongly_first_predictor = 2'b00,
    first_predictor = 2'b01,
    second_predictor = 2'b10,
    strongly_second_predictor = 2'b11
} tournament_choice;

typedef enum bit {  
    no_take = 1'b0,
    take = 1'b1
} prediction_choice;

typedef struct packed {
    rv32i_opcode opcode;
    alu_ops aluop;
    branch_funct3_t cmpop;
    logic load_regfile;
    logic load_data_address; // MAR for data
    logic load_data_value; // MDR for data
    logic data_read; // mem_read for data
    logic data_write; // mem_write for data
    logic load_data_out;
    alumux::alumux1_sel_t alumux1_sel;
    alumux::alumux2_sel_t alumux2_sel;
    regfilemux::regfilemux_sel_t regfilemux_sel;
    cmpmux::cmpmux_sel_t cmpmux_sel;
} rv32i_control_word;

typedef struct packed {
    // Instruction and trap
    rv32i_word inst_rdata;
    logic trap;
    // Regfile
    rv32i_reg rs1_addr;
    rv32i_reg rs2_addr;
    rv32i_word rs1_rdata;
    rv32i_word rs2_rdata;
    logic load_regfile;
    rv32i_reg rd_addr;
    rv32i_word rd_wdata;
    // PC
    rv32i_word pc_wdata;
    rv32i_word pc_rdata;
    // Memory
    rv32i_word mem_addr;
    logic [3:0] rmask;
    rv32i_mem_wmask wmask;
    logic [31:0] mem_rdata;
    logic [31:0] mem_wdata;
} rvfi_signals;


endpackage : rv32i_types

