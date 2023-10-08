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
    output [15:0] select,
    output zero
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
  assign zero = ((~y2) & sign3) | (y2 & sign1);
endmodule



module multiplier (
    input [15:0] a,
    input [15:0] b,
    input begin_signal,
    output [15:0] amass,
    output reg end_signal
);
  wire [15:0] neg_a;  //-a
  wire [15:0] left_shift_a;  //a<<1
  wire [15:0] left_shift_neg_a;  //(-a)<<1
  wire [15:0] select;  //基-4 booth 选出的加数
  wire [15:0] left_shift_two_add_tmp_amass;  // add_tmp_amass<<2
  wire [15:0] left_shift_two_tmp_b;  //tmp_b<<2
  wire [15:0] add_tmp_amass;  //tmp_amass + select
  wire [15:0] left_shift_two_tmp_amass;  //tmp_amass<<2
  wire nop;
  wire zero;  //表示直接位移

  reg [15:0] tmp_amass;  //暂存积
  reg [15:0] tmp_b;  //暂存b
  reg control;  //控制每一轮进行，上升沿触发新一轮
  reg valid;  //表示是否可以进行运算
  reg [3:0] count;  //计数器，控制总轮数


  complement complement_0 (
      .a(a),
      .b(neg_a)
  );

  booth_selector booth_selector_0 (
      .y0(tmp_b[13]),
      .y1(tmp_b[14]),
      .y2(tmp_b[15]),
      .a(a),
      .neg_a(neg_a),
      .left_shift_a(left_shift_a),
      .left_shift_neg_a(left_shift_neg_a),
      .select(select),
      .zero(zero)
  );

  adder adder_0 (
      .a(tmp_amass),
      .b(select),
      .sum(add_tmp_amass),
      .overflow(nop)
  );

  assign left_shift_a[15:1] = a[14:0];
  assign left_shift_a[0] = 1'b0;
  assign left_shift_neg_a[15:1] = neg_a[14:0];
  assign left_shift_neg_a[0] = 1'b0;
  assign left_shift_two_tmp_b[15:2] = tmp_b[13:0];
  assign left_shift_two_tmp_b[1] = 1'b0;
  assign left_shift_two_tmp_b[0] = 1'b0;
  assign left_shift_two_add_tmp_amass[0] = 1'b0;
  assign left_shift_two_add_tmp_amass[1] = 1'b0;
  assign left_shift_two_add_tmp_amass[15:2] = add_tmp_amass[13:0];
  assign left_shift_two_tmp_amass[0] = 1'b0;
  assign left_shift_two_tmp_amass[1] = 1'b0;
  assign left_shift_two_tmp_amass[15:2] = tmp_amass[13:0];
  assign amass = tmp_amass;

  always @(posedge begin_signal) begin
    //初始化
    control <= 1'b0;
    valid <= 1'b1;
    count <= 3'b000;
    end_signal <= 1'b0;
    tmp_b[15:0] <= b[15:0];
    tmp_amass[15:0] <= 16'b0000000000000000;
    #0.5;
    //开始工作
    control <= 1'b1;
  end

  always @(posedge control) begin
    if (valid) begin
      control <= 1'b0;
      if (count == 7) begin
        tmp_amass <= add_tmp_amass;
        //终止
        valid <= 1'b0;
        end_signal <= 1'b1;
      end else if (zero) begin
        tmp_amass <= left_shift_two_tmp_amass;
        tmp_b <= left_shift_two_tmp_b;
        count <= count + 1;
        #0.5;
        control <= 1'b1;
      end else begin
        tmp_amass <= left_shift_two_add_tmp_amass;
        tmp_b <= left_shift_two_tmp_b;
        count <= count + 1;
        #0.5;
        control <= 1'b1;
      end
    end
  end

endmodule


module test_adder;
  wire [15:0] answer;
  reg [15:0] a, b;
  reg [15:0] res;

  multiplier multiplier (
      a,
      b,
      in,
      answer,
      out
  );
  reg in;
  wire out;
  integer i;
  initial begin
    for (i = 0; i < 100; i = i + 1) begin
      $display("TESTCASE %d:", i);
      in = 1'b0;
      a[15:0] = $random;
      b[15:0] = $random;
      res = a * b;
      in = 1'b1;
      #10;
    end
    $finish;
  end

  always @(posedge out) begin
    $display("calculating: %d * %d = %d", a, b, res);
    if (answer !== res[15:0]) begin
      $display("Wrong Answer!: %d", answer);
    end
  end
endmodule
