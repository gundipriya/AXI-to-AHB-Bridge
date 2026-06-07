class ahb_xtn extends uvm_sequence_item;
    `uvm_object_utils(ahb_xtn)

    bit hwrite;
    bit [2:0] hsize;
    bit [1:0] htrans;
    bit [31:0] haddr;
    bit [2:0] hburst;
    bit [63:0] hwdata;
    bit hbusreq;                 ////////
    bit hlock;
    rand bit [63:0] hrdata;
    bit hready;
    bit [1:0]hresp;
    bit [3:0]hmaster;
    rand bit[2:0] delay_cycles;
    rand enum { okay,okay_with_wait_state,error} resp;

    constraint delay_c {delay_cycles inside {[2:5]};}
    constraint h_resp_c {hresp inside {[0:1]};}

    function new(string name = "ahb_trans");
        super.new(name);
    endfunction

    function void do_print(uvm_printer printer);
        super.do_print(printer);

        printer.print_field("hwrite", this.hwrite, 1, UVM_DEC);
        printer.print_field("haddr", this.haddr, 32, UVM_DEC);
        printer.print_field("htrans", this.htrans, 2, UVM_DEC);
        printer.print_field("hsize", this.hsize, 3, UVM_DEC);
        printer.print_field("hburst", this.hburst, 3, UVM_DEC);
        printer.print_field("hrdata", this.hrdata, 64, UVM_DEC);
        printer.print_field("hwdata", this.hwdata, 64, UVM_DEC);
        printer.print_field("hready", this.hready, 1, UVM_DEC);
        printer.print_field("hresp", this.hresp, 1, UVM_DEC);
    endfunction
endclass
