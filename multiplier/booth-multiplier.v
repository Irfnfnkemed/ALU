`include "../adder/adder-carry.v"

module complement (
    input  [15:0] a,
    output [15:0] b
);  //取反加一
  wire [15:0] c = ~a;
  wire nop;
  adder adder_0 (
      .a(c),
      .b(16'b0000000000000001),
      .sum(b),
      .overflow(nop)
  );
endmodule


module booth_selector (
    input y0,
    input y1,
    input y2,
    input [15:0] a,
    input [15:0] neg_a,
    input [15:0] left_shift_a,
    input [15:0] left_shift_neg_a,
    output [15:0] select
);
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



module multiplier (
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] amass
);
  wire [15:0] neg_a;
  wire [15:0] left_shift_a;
  wire [15:0] left_shift_neg_a;

  complement complement_0 (
      .a(a),
      .b(neg_a)
  );

  assign left_shift_a[15:1] = a[14:0];
  assign left_shift_a[0] = 1'b0;
  assign left_shift_neg_a[15:1] = neg_a[14:0];
  assign left_shift_neg_a[0] = 1'b0;


  wire [15:0] select;
  wire [15:0] left_shift_two_tmp_amass;
  wire [15:0] left_shift_two_tmp_b;
  wire [15:0] tmp_amass_2;
  wire nop;
  reg [15:0] tmp_amass;
  reg [15:0] tmp_b;


  assign left_shift_two_tmp_b[15:2] = tmp_b[13:0];
  assign left_shift_two_tmp_b[1]   = 1'b0;
  assign left_shift_two_tmp_b[0]   = 1'b0;

  adder adder_0 (
      .a(tmp_amass),
      .b(select),
      .sum(tmp_amass_2),
      .overflow(nop)
  );


  assign left_shift_two_tmp_amass[0] = 1'b0;
  assign left_shift_two_tmp_amass[1] = 1'b0;
  assign left_shift_two_tmp_amass[15:2] = tmp_amass_2[13:0];


  booth_selector booth_selector_0 (
      .y0(tmp_b[13]),
      .y1(tmp_b[14]),
      .y2(tmp_b[15]),
      .a(a),
      .neg_a(neg_a),
      .left_shift_a(left_shift_a),
      .left_shift_neg_a(left_shift_neg_a),
      .select(select)
  );

  assign amass = tmp_amass;

  integer i;
  always @(*) begin
    //$display("aaa");
    tmp_b[15:0] <= b[15:0];
    tmp_amass[15:0] <= 16'b0000000000000000;
    #10;
    for (i = 0; i < 7; i = i + 1) begin
      tmp_amass <= left_shift_two_tmp_amass;
      tmp_b <= left_shift_two_tmp_b;
      #1;
    end
    tmp_amass <= tmp_amass_2;
    #1;
  end

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
    $display("TESTCASE %d:", i);
    a[15:0] = $random;
    b[15:0] = $random;
    res = a * b;

    #30;
    $display("%d * %d = %d", a, b, res);

    if (answer !== res[15:0]) begin
      $display("Wrong Answer!: %d", answer);
    end

    $display("Congratulations! You have passed all of the tests.");
    $finish;
  end
endmodule
