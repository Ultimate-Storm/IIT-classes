module stimulus;

parameter T = 20;

reg [31:0] dataIn;
reg [1:0] opsel, outsel;
reg [4:0] addressA, addressB;
reg asel, bsel, oen, clk;

wire [31:0] outPut;
wire over;


integer handle3,desc3;

// Instantiate the design block counter
cpu proj(addressA, addressB, dataIn, asel,bsel, clk, opsel, outsel, oen, outPut, over);
initial
begin
clk = 1'b1;
forever #T  clk = ~clk;
end

initial
 begin
handle3 = $fopen ("stim_proj.out");
  $shm_open("shm.db",1);
  $shm_probe(stimulus,"AS");
  #1100  $shm_close();
  #1 $finish;
  end


always
begin
desc3=handle3;
#1 $fdisplay(desc3, $time,"clk=%b, addressA=%d, addressB=%d, dataIn=%d, opsel=%d, outsel=%d, asel=%d, bsel=%d, oen=%d, OUT=%d", clk, addressA, addressB, dataIn, opsel, outsel,asel, bsel, oen, outPut);

end

 // Stimulate the Input Signals
initial
 begin

// 1. store (0000_0005) in [0]

#T

addressA = 5'b00000;

addressB = 5'b00000;

dataIn = 32'h0000_0005;

opsel = 2'b01;

outsel =2'b00;

asel = 0;

bsel = 0;

oen = 1;


#(T*2)


// 2. store AAAA_AAAA  in [1]

addressA=5'b00000;

addressB= 5'b00001;

dataIn = 32'hAAAA_AAAA;

opsel = 2'b01;

outsel = 2'b00;

asel = 0;

bsel = 0;

oen = 1;

#(T*2)

// 3. store 5555_5555 in [2]

addressA = 5'b00000;

addressB = 5'b00010;

dataIn = 32'h5555_5555;


opsel = 2'b01;

outsel =2'b00;

asel = 0;

bsel = 0;

oen = 1;



#(T*2)

// 4. store 0000_000A in [3]

addressA = 5'b00000;

addressB = 5'b00011;

dataIn = 32'h0000_000A;

opsel = 2'b01;

outsel =2'b00;

asel = 0;

bsel = 0;

oen = 1;

#(T*2)

// 5. store 0000_0001 in [4]

addressA = 5'b00000;

addressB = 5'b00100;

dataIn = 32'h0000_0001;

opsel = 2'b01;

outsel =2'b00;

asel = 0;

bsel = 0;

oen = 1;

#(T*2)

// 6. store FFFF_FFFF in [5]

addressA = 5'b00000;

addressB = 5'b00101;

dataIn = 32'hFFFF_FFFF;

opsel = 2'b01;

outsel =2'b00;

asel = 0;

bsel = 0;

oen = 1;

#(T*2)

// 7. store 0000_00C8 in [6]

addressA = 5'b00000;

addressB = 5'b00110;

dataIn = 32'h0000_00C8;

opsel = 2'b01;

outsel =2'b00;

asel = 0;

bsel = 0;

oen = 1;

#(T*2)

// 8. store 0000_012C in [7]

addressA = 5'b00000;

addressB = 5'b00111;

dataIn = 32'h0000_012C;

opsel = 2'b01;

outsel =2'b00;

asel = 0;

bsel = 0;

oen = 1;

#(T*2)

// 9. store 0000_0001 in [8]

addressA = 5'b00000;

addressB = 5'b01000;

dataIn = 32'h0000_0001;

opsel = 2'b01;

outsel =2'b00;

asel = 0;

bsel = 0;

oen = 1;

#(T*2)

// 10. store AAAA_AAAB in [9]

addressA = 5'b00000;

addressB = 5'b01001;

dataIn = 32'hAAAA_AAAB;

opsel = 2'b01;

outsel =2'b00;

asel = 0;

bsel = 0;

oen = 1;

#(T*2)

// 11. store 5555_5555 in [10]

addressA = 5'b00000;

addressB = 5'b01010;

dataIn = 32'h5555_5555;

opsel = 2'b01;

outsel =2'b00;

asel = 0;

bsel = 0;

oen = 1;

#(T*2)
//12. ADD     [2][0] 

addressA = 5'd2;

addressB = 5'd0;

dataIn = 32'd0;

opsel = 2'b00;

outsel =2'b01;

asel = 1;

bsel = 1;

oen = 1;


#(T*2)

#(T*2)

//13. ADD      [1][2] = 0 + 1E = 1E	
addressA = 5'd1;

addressB = 5'd2;

dataIn = 32'd0;

opsel = 2'b00;

outsel =2'b01;

asel = 1;

bsel = 1;

oen = 1;

#(T*2)

//14. ADD      [6][7] = 0 + 1E = 1E	
addressA = 5'd6;

addressB = 5'd7;

dataIn = 32'd0;

opsel = 2'b00;

outsel =2'b01;

asel = 1;

bsel = 1;

oen = 1;

#(T*2)

//14. ADD      [0][3] = 0 + 1E = 1E	
addressA = 5'd0;

addressB = 5'd3;

dataIn = 32'd0;

opsel = 2'b00;

outsel =2'b01;

asel = 1;

bsel = 1;

oen = 1;

#(T*2)

//15. SUB      [2][4] = 0 + 1E = 1E	
addressA = 5'd2;

addressB = 5'd4;

dataIn = 32'd0;

opsel = 2'b01;

outsel =2'b01;

asel = 1;

bsel = 1;

oen = 1;

#(T*2)

//16. ADD      [2][8] = 0 + 1E = 1E	
addressA = 5'd2;

addressB = 5'd8;

dataIn = 32'd0;

opsel = 2'b00;

outsel =2'b01;

asel = 1;

bsel = 1;

oen = 1;

#(T*2)

//17. SUB      [2][0] = FFFF_FFF6 - 0000_0032 = FFFF_FFC4
addressA = 5'd2;

addressB = 5'd0;

dataIn = 32'd0;

opsel = 2'b01;

outsel =2'b01;

asel = 1;

bsel = 1;

oen = 1;

#(T*2)

//18. ADD      [9][10] = 0 + 1E = 1E	
addressA = 5'd9;

addressB = 5'd10;

dataIn = 32'd0;

opsel = 2'b00;

outsel =2'b01;

asel = 1;

bsel = 1;

oen = 1;

#(T*2)

//19. READ     [7] = 0
addressA = 5'd7;

addressB = 5'd7;

dataIn = 32'd0;

opsel = 2'b01;

outsel =2'b00;

asel = 1;

bsel = 0;

oen = 1;

#(T*2)

//20. READ     [3] = 1E
addressA = 5'd3;

addressB = 5'd3;

dataIn = 32'd0;

opsel = 2'b01;

outsel =2'b00;

asel = 1;

bsel = 0;

oen = 1;

#(T*2)

//21. READ     [1] = FFFF_FFC4
addressA = 5'd1;

addressB = 5'd1;

dataIn = 32'd0;

opsel = 2'b01;

outsel =2'b00;

asel = 1;

bsel = 0;

oen = 1;

end
endmodule
