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

module half_adder (
    input  a,
    input  b,
    output g,
    output p
);
  assign g = a & b;
  assign p = a ^ b;
endmodule

module four_bit_adder (
    input  [3:0] p,
    input  [3:0] g,
    input        carry_in,
    output [3:0] sum
);
  assign carry0 = g[0] | p[0] & carry_in;
  assign carry1 = p[1] & g[0] | g[1] | p[1] & p[0] & carry_in;
  assign carry2 = p[2] & p[1] & g[0] | p[2] & g[1] | g[2] | p[2] & p[1] & p[0] & carry_in;
  assign sum[0] = p[0] ^ carry_in;
  assign sum[1] = p[1] ^ carry0;
  assign sum[2] = p[2] ^ carry1;
  assign sum[3] = p[3] ^ carry2;
endmodule

module PGM (
    input  [3:0] p,
    input  [3:0] g,
    output       p_out,
    output       g_out
);
  assign p_out = p[3] & p[2] & p[1] & p[0];
  assign g_out = p[3] & p[2] & p[1] & g[0] | p[3] & p[2] & g[1] | p[3] & g[2] | g[3];
endmodule

module adder (
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] sum,
    output        overflow
);
  wire [15:0] p, g;
  wire [3:0] four_p, four_g;
  half_adder half_adder0 (
      .a(a[0]),
      .b(b[0]),
      .p(p[0]),
      .g(g[0])
  );
  half_adder half_adder1 (
      .a(a[1]),
      .b(b[1]),
      .p(p[1]),
      .g(g[1])
  );
  half_adder half_adder2 (
      .a(a[2]),
      .b(b[2]),
      .p(p[2]),
      .g(g[2])
  );
  half_adder half_adder3 (
      .a(a[3]),
      .b(b[3]),
      .p(p[3]),
      .g(g[3])
  );
  half_adder half_adder4 (
      .a(a[4]),
      .b(b[4]),
      .p(p[4]),
      .g(g[4])
  );
  half_adder half_adder5 (
      .a(a[5]),
      .b(b[5]),
      .p(p[5]),
      .g(g[5])
  );
  half_adder half_adder6 (
      .a(a[6]),
      .b(b[6]),
      .p(p[6]),
      .g(g[6])
  );
  half_adder half_adder7 (
      .a(a[7]),
      .b(b[7]),
      .p(p[7]),
      .g(g[7])
  );
  half_adder half_adder8 (
      .a(a[8]),
      .b(b[8]),
      .p(p[8]),
      .g(g[8])
  );
  half_adder half_adder9 (
      .a(a[9]),
      .b(b[9]),
      .p(p[9]),
      .g(g[9])
  );
  half_adder half_adder10 (
      .a(a[10]),
      .b(b[10]),
      .p(p[10]),
      .g(g[10])
  );
  half_adder half_adder11 (
      .a(a[11]),
      .b(b[11]),
      .p(p[11]),
      .g(g[11])
  );
  half_adder half_adder12 (
      .a(a[12]),
      .b(b[12]),
      .p(p[12]),
      .g(g[12])
  );
  half_adder half_adder13 (
      .a(a[13]),
      .b(b[13]),
      .p(p[13]),
      .g(g[13])
  );
  half_adder half_adder14 (
      .a(a[14]),
      .b(b[14]),
      .p(p[14]),
      .g(g[14])
  );
  half_adder half_adder15 (
      .a(a[15]),
      .b(b[15]),
      .p(p[15]),
      .g(g[15])
  );
  PGM PFM0 (
      .p    (p[3:0]),
      .g    (g[3:0]),
      .p_out(four_p[0]),
      .g_out(four_g[0])
  );
  PGM PFM1 (
      .p    (p[7:4]),
      .g    (g[7:4]),
      .p_out(four_p[1]),
      .g_out(four_g[1])
  );
  PGM PFM2 (
      .p    (p[11:8]),
      .g    (g[11:8]),
      .p_out(four_p[2]),
      .g_out(four_g[2])
  );
  PGM PFM3 (
      .p    (p[15:12]),
      .g    (g[15:12]),
      .p_out(four_p[3]),
      .g_out(four_g[3])
  );
  assign carry0 = four_g[0];
  assign carry1 = four_p[1] & four_g[0] | four_g[1];
  assign carry2 = four_p[2] & four_p[1] & four_g[0] | four_p[2] & four_g[1] | four_g[2];
  assign overflow = four_p[3] & four_p[2] & four_p[1] & four_g[0] | four_p[3] & four_p[2] & four_g[1] | four_p[3] & four_g[2] | four_g[3];
  four_bit_adder four_bit_adder0 (
      .p       (p[3:0]),
      .g       (g[3:0]),
      .carry_in(1'b0),
      .sum     (sum[3:0])
  );
  four_bit_adder four_bit_adder1 (
      .p       (p[7:4]),
      .g       (g[7:4]),
      .carry_in(carry0),
      .sum     (sum[7:4])
  );
  four_bit_adder four_bit_adder2 (
      .p       (p[11:8]),
      .g       (g[11:8]),
      .carry_in(carry1),
      .sum     (sum[11:8])
  );
  four_bit_adder four_bit_adder3 (
      .p       (p[15:12]),
      .g       (g[15:12]),
      .carry_in(carry2),
      .sum     (sum[15:12])
  );
endmodule
