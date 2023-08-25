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
        input logic clk1,		//slow_clk
        input logic clk2,		//fast_clk
        input logic [Y_ADDR_WIDTH+X_ADDR_WIDTH-1 : 0] addr1,  //[7:4] x_addr, [3:0] y_addr	(addr for slow clk)
        input logic [Y_ADDR_WIDTH+X_ADDR_WIDTH-1 : 0] addr2,  //[7:4] x_addr, [3:0] y_addr	(addr for fast clk)
        input logic [DATA_WIDTH-1 : 0] write_data1,
        input logic  w_nr,										  //write, !read 

		output logic [DATA_WIDTH-1 : 0] read_data1,		//read data for slow clk
        output logic [DATA_WIDTH-1 : 0] read_data2		//read data for fast clk
	);

	(* ram_style = "block" *)
	logic [DATA_WIDTH-1 : 0] ram [0:(1<<(Y_ADDR_WIDTH+X_ADDR_WIDTH))-1];

	logic [Y_ADDR_WIDTH+X_ADDR_WIDTH-1 : 0] 	ram_addr1;
	logic [Y_ADDR_WIDTH+X_ADDR_WIDTH-1 : 0] 	ram_addr2;

	assign ram_addr1 	= 	addr1[7:4] + (addr1[3:0])*12;
	assign ram_addr2	= 	addr2[7:4] + (addr2[3:0])*12;

	always_ff @(posedge clk1) begin : ram_write_nread_blk
		if (w_nr) begin
			ram[ram_addr1] <= write_data1;
		end
		else begin
			read_data1 <= ram[ram_addr1];
		end
	end

    always_ff @(posedge clk2) begin : ram_read_blk
		read_data2 <= ram[ram_addr2];
	end


	//for simulation
	initial begin
		for(int x=0; x<X_SIZE; x++) begin
			for(int y=0; y<Y_SIZE; y++) begin
				ram[x+y*X_SIZE] <= 2'b00;
			end
		end
	end
endmodule

