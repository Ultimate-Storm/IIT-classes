module stimulus;
    reg [3:0] A,B;
    wire [3:0] S;
    wire CO;

    adder_4bit a(A,B,S,CO);
    
    initial
    begin
        #10 A=4'b0000; B=4'b0000;
        #5 $display("%d+%d=%d %b", A,B,S,CO);

        #10 A=4'b1011; B=4'b0101;
        #5 $display("%d+%d=%d %b", A,B,S,CO);

        #10 A=4'b0100; B=4'b1010;
        #5 $display("%d+%d=%d %b", A,B,S,CO);

        #10 A=4'b0001; B=4'b0001;
        #5 $display("%d+%d=%d %b", A,B,S,CO);

        #10 A=4'b0001; B=4'b0111;
        #5 $display("%d+%d=%d %b", A,B,S,CO);

        #10 A=4'b1000; B=4'b0111;
        #5 $display("%d+%d=%d %b", A,B,S,CO);
    end
endmodule
