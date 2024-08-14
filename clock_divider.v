module clock_divider (clock, divided_clocks);
	 input  wire 			clock; //reset?
	 output reg [31:0] divided_clocks = 0; 

	 always @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	 end

endmodule 