//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   board_mem
 Author:        Pawel Zieba
 Version:       1.0
 Last modified: 2023-07-29
 Coding style: Xilinx recommended + ANSI ports
 Description:  Memory module with 16x16 array, 2-bit data inside.
			   8-bit read address and 8-bit write address.
			   Working witch two different clocks (for writting and reading).
			   Addresing: {[7:4] x_addr, [3:0] y_addr}
 */
//////////////////////////////////////////////////////////////////////////////
 module board_mem 
    #( parameter
		X_SIZE = 12,		//memory array x size
		Y_SIZE = 12,		//memory array y size
		X_ADDR_WIDTH = 4,
        Y_ADDR_WIDTH = 4,
        DATA_WIDTH = 2
	)
	(
        input logic write_clk,
        input logic read_clk,
        input logic [Y_ADDR_WIDTH+X_ADDR_WIDTH-1 : 0] write_addr, //[7:4] x_addr, [3:0] y_addr
        input logic [Y_ADDR_WIDTH+X_ADDR_WIDTH-1 : 0] read_addr,  //[7:4] x_addr, [3:0] y_addr
        input logic [DATA_WIDTH-1 : 0] write_data,
        input logic  write_enable,

        output logic [DATA_WIDTH-1 : 0] read_data
	);

	(* ram_style = "block" *)
	logic [DATA_WIDTH-1 : 0] ram [X_SIZE][Y_SIZE];



	always_ff @(posedge write_clk) begin : ram_write_blk
		if (write_enable) begin
			ram [write_addr[7:4]][write_addr[3:0]] <= write_data;
		end
	end

    always_ff @(posedge read_clk) begin : ram_read_blk
		read_data <= ram[read_addr[7:4]][read_addr[3:0]];
	end


	//for simulation
	initial begin
		for(int x=0; x<X_SIZE; x++) begin
			for(int y=0; y<Y_SIZE; y++) begin
				ram[x][y] <= 2'(x);
			end
		end
	end
endmodule

