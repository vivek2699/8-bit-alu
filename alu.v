`define ADD 0
`define CADD 1
`define SUB 2
`define BSUB 3
`define NEG 4
`define INC 5
`define DEC 6
`define PASS 7
`define AND 8
`define OR 9
`define XOR 10
`define COMP 11
`define L_ARITH_SHIFT 12
`define R_ARITH_SHIFT 13
`define L_LOG_SHIFT 14
`define R_LOG_SHIFT 15
`define L_ROT 16
`define R_ROT 17
`define L_CROT 18
`define R_CROT 19

module alu
(
  input clk,
  input opcode,
  input operand_A,
  input operand_B,
  input enable,
  input input_ready,
  input carry_in,
  input borrow_in,
  input rst,
  output result_out,
  output borrow_out,
  output result_ready,
  output carry_out,
  output zero,
  output negative,
  output overflow,
  output parity
);

  reg [4:0] opcode;
  reg [7:0] signed operand_A;
  reg [7:0] signed operand_B;
  reg [7:0] signed result_out;

  reg finished;
  reg running;
  
  reg add_instr, addc_instr, sub_instr, subb_instr, neg_instr, inc_instr, dec_instr, pass_instr, and_instr, or_instr, xor_instr;
  reg comp_instr, l_arith_shft_instr, r_arith_shft_instr, l_log_shft_instr, r_log_shft_instr, l_rot_instr, r_rot_instr, l_crot_instr, r_crot_instr;

  always@( posedge clk)
    begin
      if(rst)
        begin
          carry_out <= 0;
          zero <= 0;
          result_ready <= 0;
          y_out <= 0;
          negative <= 0;
          overflow <= 0;
          parity <= 0;
          finished <= 1;
          running <= 0;
        end
      else
        begin
          if(finished && enable && input_ready)
            begin
              
              if(opcode == ADD)
                begin
                  if(operand_A + operand_B < -128)
                    begin
                      borrow_out <= 1;
                      result_out <= 8'b256 - operand_A - operand_B;
                    end
                  
                  else if(operand_A + operand_B > 127)
                    begin
                      carry_out <= 1;
                      result_out <= (operand_A + operand_B)[7:0];
                    end
                  else
                    result_out <= operand_A + operand_B;                  
                  finished <= 1;
                  result_ready <= 1;
                end
              
              if(opcode == CADD)
                begin
                  if(operand_A + operand_B + carry_in < -128)
                    begin
                      borrow_out <= 1;
                      result_out <= 8'b256 - operand_A + operand_B+carry_in;
                    end
                  
                  else if(operand_A + operand_B + carry_in > 127)
                    begin
                      carry_out <= 1;
                      result_out <= (operand_A + operand_B + carry_in)[7:0];
                    end
                  else
                    result_out <= operand_A + operand_B + carry_in;
                  finished <= 1;
                  result_ready <= 1;
                end
              
              if(opcode == SUB)
                begin

                  if(operand_A - operand_B < -128)
                    begin
                      borrow_out <= 1;
                      result_out <= 8'b256 - operand_A + operand_B;
                    end
                  
                  else if(operand_A - operand_B > 127)
                    begin
                      carry_out <= 1;
                      result_out <= (operand_A - operand_B)[7:0];
                    end
                  else
                    result_out <= operand_A - operand_B;
                end
              
              if(opcode == BSUB)
                begin
                  if(operand_A - operand_B - borrow_in < -128)
                    begin
                      borrow_out <= 1;
                      result_out <= 256 - operand_A + operand_B + borrow_in;
                    end
                  
                  else if(operand_A - operand_B - borrow_in > 127)
                    begin
                      carry_out <= 1;
                      result_out <= (operand_A - operand_B - borrow_in)[7:0];
                    end
                  else
                    result_out <= operand_A - operand_B - borrow_in;
                end
              
              if(opcode == NEG)
                begin
                  result_out <= -operand_A;
                end
              
              if(opcode == INC)
                begin
                  if(operand_A + 1 > 127)
                    begin
                      carry_out = 1;
                      result_out <= -128;
                    end
                  else
                    result_out <= operand_A + 1;
                end
              
              if(opcode == DEC)
                begin
                  if(operand_A - 1 < -128)
                    begin
                      borrow_out <= 1;
                      result_out <= 127
                    end
                  else
                    result_out <= operand_A - 1;
                end
              
              if(opcode == PASS)
                begin
                  result_out <= operand_A;
                end
              
              if(opcode == AND)
                result_out <= operand_A & operand_B;
              
              if(opcode == OR)
                result_out <= operand_A | operand_B;
              
              if(opcode == XOR)
                result_out <= operand_A ^ operand_B;
              
              if(opcode == COMP)
                result_out <= ~operand_A;
              
              if(opcode == L_ARITH_SHIFT)
                begin
                  result_out[0] <= 0;
                  result_out[7:1] <= operand_A[6:0];
                end
              
              if(opcode == R_ARITH_SHIFT)
                begin
                  result_out[7] <= operand_A[7];
                  result_out[6:0] <= operand_A[7:1];
                end
              
              
              if(opcode == L_LOG_SHIFT)
                begin
                  result_out[0] <= 0;
                  result_out[7:1] <= operand_A[6:0];
                end
              
              if(opcode == R_LOG_SHIFT)
                begin
                  result_out[7] <= 0;
                  result_out[6:0] <= operand_A[7:1];
                end
              
              if(opcode == L_ROT)
                begin
                  result_out[0] <= operand_A[7];
                  result_out[7:1] <= operand_A[6:0];
                end
              
              if(opcode == R_ROT)
                begin
                  result_out[7] <= operand_A[0];
                  result_out[6:0] <= operand_A[7:1];
                end
              
              if(opcode == L_CROT)
                begin
                  carry_out <= operand_A[7];
                  result_out[7:1] <= operand_A[6:0];
                  result_out[0] <= carry_in;
                end
              
              if(opcode == R_CROT)
                begin
                  carry_out <= operand_A[0];
                  result_out[7] <= carry_in;
                  result_out[6:0] <= operand_A[7:1];
                end
              
            end
        end
    end

endmodule
