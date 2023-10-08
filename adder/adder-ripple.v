/* ACM Class System (I) Fall Assignment 1 
 *
 *
 * Implement your naive adder here
 * 
 * GUIDE:
 *   1. Create a RTL project in Vivado
 *   2. Put this file into `Sources'
 *   3. Put `test_adder.v' into `Simulation Sources'
 *   4. Run Behavioral Simulation
 *   5. Make sure to run at least 100 steps during the simulation (usually 100ns)
 *   6. You can see the results in `Tcl console'
 *
 */

module full_adder (
    input  a,
    input  b,
    input  c_in,
    output c_out,
    output s
);
  assign internal_wire1 = a ^ b;
  assign internal_wire2 = a & b;
  assign internal_wire3 = c_in & internal_wire1;
  assign c_out = internal_wire2 | internal_wire3;
  assign s = c_in ^ internal_wire1;

endmodule

module adder (
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] sum,
    output        overflow
);
  wire carry_0,
		 carry_1,
		 carry_2,
		 carry_3,
		 carry_4,
		 carry_5,
		 carry_6,
		 carry_7,
		 carry_8,
		 carry_9,
		 carry_10,
		 carry_11,
		 carry_12,
		 carry_13,
		 carry_14;
  full_adder full_adder0 (
      .a    (a[0]),
      .b    (b[0]),
      .c_in (1'b0),
      .c_out(carry_0),
      .s    (sum[0])
  );
  full_adder full_adder1 (
      .a    (a[1]),
      .b    (b[1]),
      .c_in (carry_0),
      .c_out(carry_1),
      .s    (sum[1])
  );
  full_adder full_adder2 (
      .a    (a[2]),
      .b    (b[2]),
      .c_in (carry_1),
      .c_out(carry_2),
      .s    (sum[2])
  );
  full_adder full_adder3 (
      .a    (a[3]),
      .b    (b[3]),
      .c_in (carry_2),
      .c_out(carry_3),
      .s    (sum[3])
  );
  full_adder full_adder4 (
      .a    (a[4]),
      .b    (b[4]),
      .c_in (carry_3),
      .c_out(carry_4),
      .s    (sum[4])
  );
  full_adder full_adder5 (
      .a    (a[5]),
      .b    (b[5]),
      .c_in (carry_4),
      .c_out(carry_5),
      .s    (sum[5])
  );
  full_adder full_adder6 (
      .a    (a[6]),
      .b    (b[6]),
      .c_in (carry_5),
      .c_out(carry_6),
      .s    (sum[6])
  );
  full_adder full_adder7 (
      .a    (a[7]),
      .b    (b[7]),
      .c_in (carry_6),
      .c_out(carry_7),
      .s    (sum[7])
  );
  full_adder full_adder8 (
      .a    (a[8]),
      .b    (b[8]),
      .c_in (carry_7),
      .c_out(carry_8),
      .s    (sum[8])
  );
  full_adder full_adder9 (
      .a    (a[9]),
      .b    (b[9]),
      .c_in (carry_8),
      .c_out(carry_9),
      .s    (sum[9])
  );
  full_adder full_adder10 (
      .a    (a[10]),
      .b    (b[10]),
      .c_in (carry_9),
      .c_out(carry_10),
      .s    (sum[10])
  );
  full_adder full_adder11 (
      .a    (a[11]),
      .b    (b[11]),
      .c_in (carry_10),
      .c_out(carry_11),
      .s    (sum[11])
  );
  full_adder full_adder12 (
      .a    (a[12]),
      .b    (b[12]),
      .c_in (carry_11),
      .c_out(carry_12),
      .s    (sum[12])
  );
  full_adder full_adder13 (
      .a    (a[13]),
      .b    (b[13]),
      .c_in (carry_12),
      .c_out(carry_13),
      .s    (sum[13])
  );
  full_adder full_adder14 (
      .a    (a[14]),
      .b    (b[14]),
      .c_in (carry_13),
      .c_out(carry_14),
      .s    (sum[14])
  );
  full_adder full_adder15 (
      .a    (a[15]),
      .b    (b[15]),
      .c_in (carry_14),
      .c_out(overflow),
      .s    (sum[15])
  );
endmodule
