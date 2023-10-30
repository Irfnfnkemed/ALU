`include "../adder/adder-carry.v"

module complement (
    input  [15:0] a,
    output [15:0] b
);  //取反加一

  wire [15:0] c = ~a;

  adder adder_0 (
      .a  (c),
      .b  (16'b0000000000000001),
      .sum(b)
  );

endmodule

module full_adder (
    input  a0,
    input  a1,
    input  a2,
    output s,
    output c
);  //全加器

  assign internal_wire1 = a0 ^ a1;
  assign internal_wire2 = a0 & a1;
  assign internal_wire3 = a2 & internal_wire1;
  assign s = a2 ^ internal_wire1;
  assign c = internal_wire2 | internal_wire3;

endmodule

module booth_selector (
    input         y0,
    input         y1,
    input         y2,
    input  [15:0] a,
    input  [15:0] neg_a,
    input  [15:0] left_shift_a,
    input  [15:0] left_shift_neg_a,
    output [15:0] select
);  //基-4booth编码取部分和

  wire [15:0] out1;
  wire [15:0] out2;
  wire [15:0] out3;
  wire [15:0] out4;

  assign sign1 = y0 & y1;
  assign sign2 = y0 ^ y1;
  assign sign3 = ~(y0 | y1);
  assign select1 = (~y2) & sign1;
  assign select2 = (~y2) & sign2;
  assign select3 = y2 & sign2;
  assign select4 = y2 & sign3;
  assign out1 = left_shift_a & {16{select1}};
  assign out2 = a & {16{select2}};
  assign out3 = neg_a & {16{select3}};
  assign out4 = left_shift_neg_a & {16{select4}};
  assign select = out1 | out2 | out3 | out4;

endmodule


module wallace_adder (
    input  [15:0] a0,
    input  [15:0] a1,
    input  [15:0] a2,
    output [15:0] s,
    output [15:0] c
);  //Wallace树中，将三数加法转化为两数加法

  genvar i;
  generate
    assign c[0] = 1'b0;

    full_adder full_adder (
        .a0(a0[15]),
        .a1(a1[15]),
        .a2(a2[15]),
        .s (s[15])
    );

    for (i = 0; i < 15; i = i + 1) begin
      full_adder full_adder (
          .a0(a0[i]),
          .a1(a1[i]),
          .a2(a2[i]),
          .s (s[i]),
          .c (c[i+1])
      );
    end
  endgenerate

endmodule

module multiplier (
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] amass
);  //乘法器（16X16）

  wire [15:0] neg_a;  //-a
  wire [15:0] left_shift_a;  //a<<1
  wire [15:0] left_shift_neg_a;  //(-a)<<1
  wire [15:0] select[0:7];  //基-4booth编码选出的部分和
  wire [15:0] part_sum_first_level[0:7];  //第一层Wallace部分和
  wire [15:0] part_sum_second_level[0:5];  //第二层Wallace部分和
  wire [15:0] part_sum_third_level[0:3];  //第三层Wallace部分和
  wire [15:0] part_sum_forth_level[0:2];  //第四层Wallace部分和
  wire [15:0] part_sum_fifth_level[0:1];  //第五层Wallace部分和

  complement complement_0 (
      .a(a),
      .b(neg_a)
  );

  assign left_shift_a[15:1] = a[14:0];
  assign left_shift_a[0] = 1'b0;
  assign left_shift_neg_a[15:1] = neg_a[14:0];
  assign left_shift_neg_a[0] = 1'b0;

  genvar i, j;
  generate
    booth_selector booth_selector (
        .y0              (1'b0),
        .y1              (b[0]),
        .y2              (b[1]),
        .a               (a),
        .neg_a           (neg_a),
        .left_shift_a    (left_shift_a),
        .left_shift_neg_a(left_shift_neg_a),
        .select          (select[0])
    );

    for (i = 1; i < 8; i = i + 1) begin
      booth_selector booth_selector (
          .y0              (b[2*i-1]),
          .y1              (b[2*i]),
          .y2              (b[2*i+1]),
          .a               (a),
          .neg_a           (neg_a),
          .left_shift_a    (left_shift_a),
          .left_shift_neg_a(left_shift_neg_a),
          .select          (select[i])
      );
    end

    for (i = 0; i < 8; i = i + 1) begin
      assign part_sum_first_level[i][15:2*i] = select[i][15-2*i:0];
      for (j = 0; j < 2 * i; j = j + 1) begin
        assign part_sum_first_level[i][j] = 1'b0;
      end
    end

  endgenerate

  wallace_adder wallace_adder_first_level_1 (
      .a0(part_sum_first_level[0]),
      .a1(part_sum_first_level[1]),
      .a2(part_sum_first_level[2]),
      .s (part_sum_second_level[0]),
      .c (part_sum_second_level[1])
  );
  wallace_adder wallace_adder_first_level_2 (
      .a0(part_sum_first_level[3]),
      .a1(part_sum_first_level[4]),
      .a2(part_sum_first_level[5]),
      .s (part_sum_second_level[2]),
      .c (part_sum_second_level[3])
  );
  assign part_sum_second_level[4][15:0] = part_sum_first_level[6][15:0];
  assign part_sum_second_level[5][15:0] = part_sum_first_level[7][15:0];

  wallace_adder wallace_adder_second_level_1 (
      .a0(part_sum_second_level[0]),
      .a1(part_sum_second_level[1]),
      .a2(part_sum_second_level[2]),
      .s (part_sum_third_level[0]),
      .c (part_sum_third_level[1])
  );
  wallace_adder wallace_adder_second_level_2 (
      .a0(part_sum_second_level[3]),
      .a1(part_sum_second_level[4]),
      .a2(part_sum_second_level[5]),
      .s (part_sum_third_level[2]),
      .c (part_sum_third_level[3])
  );

  wallace_adder wallace_adder_third_level_1 (
      .a0(part_sum_third_level[0]),
      .a1(part_sum_third_level[1]),
      .a2(part_sum_third_level[2]),
      .s (part_sum_forth_level[0]),
      .c (part_sum_forth_level[1])
  );
  assign part_sum_forth_level[2][15:0] = part_sum_third_level[3][15:0];

  wallace_adder wallace_adder_forth_level_1 (
      .a0(part_sum_forth_level[0]),
      .a1(part_sum_forth_level[1]),
      .a2(part_sum_forth_level[2]),
      .s (part_sum_fifth_level[0]),
      .c (part_sum_fifth_level[1])
  );

  adder adder_final (
      .a  (part_sum_fifth_level[0]),
      .b  (part_sum_fifth_level[1]),
      .sum(amass)
  );
endmodule


module test_adder;
  wire [15:0] answer;
  reg [15:0] a, b;
  reg [15:0] res;

  multiplier multiplier (
      a,
      b,
      answer
  );
  integer i;
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, multiplier);
    for (i = 0; i < 100; i = i + 1) begin
      $display("TESTCASE %d:", i);
      a[15:0] = $random;
      b[15:0] = $random;
      res = a * b;
      #100 $display("calculating: %d * %d = %d", a, b, res);
      if (answer !== res[15:0]) begin
        $display("Wrong Answer!: %d", answer);
      end
    end
    $finish;
  end
endmodule
