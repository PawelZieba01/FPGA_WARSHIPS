//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   template_ram
 Author:        Robert Szczygiel
 Version:       1.0
 Last modified: 2023-05-19
 Coding style: Xilinx recommended + ANSI ports
 Description:  Template for RAM module as recommended by Xilinx. The module
 				has second output port 'dpo', which can be removed when not needed
 				(together with 'dpra' and 'read_dpra');

 ** This example shows the use of the Vivado rom_style attribute
 **
 ** Acceptable values are:
 ** block : Instructs the tool to infer RAMB type components.
 ** distributed : Instructs the tool to infer LUT ROMs.
 **
 */
//////////////////////////////////////////////////////////////////////////////
 module board_mem 
    #( parameter
		X_SIZE = 16,
		Y_SIZE = 16,
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


endmodule

