


`timescale 1ns/1ns
import uvm_pkg::*;
`include "uvm_macros.svh"

`define NEW_OBJ	\
function new(string name="");	\
	super.new(name);	\
endfunction 

`define NEW_COMP	\
function new(string name="",uvm_component parent);	\
	super.new(name,parent);	\
endfunction 

interface axi_if(input bit clk);

endinterface

interface ahb_if(input bit clk);

endinterface

interface axi_rst_if(input bit clk);

endinterface

interface ahb_rst_if(input bit clk);

endinterface
//================================================================================================================
//------------------ CONFIGARATION CLASSES -------------------------------------------------------------------------------
//===================================================================================================================
class ahb_rst_cfg extends uvm_object;
    `uvm_object_utils(ahb_rst_cfg)
     `NEW_OBJ

    virtual ahb_rst_if vif; 
    uvm_active_passive_enum is_active = UVM_ACTIVE;

endclass

class axi_rst_cfg extends uvm_object;
    `uvm_object_utils(axi_rst_cfg)
     `NEW_OBJ
    virtual axi_rst_if vif;
    //if
    uvm_active_passive_enum is_active = UVM_ACTIVE;

endclass

class ahb_cfg extends uvm_object;
    `uvm_object_utils(ahb_cfg)
     `NEW_OBJ

    virtual ahb_if vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;

endclass

class axi_cfg extends uvm_object;
    `uvm_object_utils(axi_cfg)
     `NEW_OBJ
    virtual axi_if vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;


endclass

class env_cfg extends uvm_object;
    `uvm_object_utils(env_cfg)
     `NEW_OBJ

    ahb_rst_cfg ahb_rst_cfg_h[];
    axi_rst_cfg axi_rst_cfg_h[];
    ahb_cfg  ahb_cfg_h[];
    axi_cfg axi_cfg_h[];

    bit has_axi_agent = 1;
    bit has_ahb_agent=1;
    bit has_axi_rst_agent = 1;
    bit has_ahb_rst_agent=1;

    int no_of_duts=1;

    int has_scoreboard=1;

    int ahb_length[$];
    int axi_length[$];

endclass
//================================================================================================================
//------------------ TRANSACTION CLASSES--------------------------------------------------------------------------
//=================================================================================================================

 class ahb_rst_xtn extends uvm_sequence_item;
     `uvm_object_utils(ahb_rst_xtn)

     rand bit hresetn;
     bit hready;
     logic [1:0] htrans;

     `NEW_OBJ

     function void do_print(uvm_printer printer);
        printer.print_field("hresetn", this.hresetn, 1, UVM_DEC);
     endfunction
 endclass

  class axi_rst_xtn extends uvm_sequence_item;
     `uvm_object_utils(axi_rst_xtn)

    rand bit aresetn;
    logic bvalid;
    logic rvalid;

     `NEW_OBJ

     function void do_print(uvm_printer printer);
        printer.print_field("aresetn", this.aresetn, 1, UVM_DEC);
     endfunction
 endclass

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

 class axi_xtn extends uvm_sequence_item;
     `uvm_object_utils(axi_xtn)
      rand bit aresetn;

     // write address channel
     rand bit[7:0] awid;
     rand bit [31:0] awaddr;
     rand bit [1:0] awburst;
     rand bit [7:0] awlen;
     rand bit [2:0] awsize;
     rand bit  awvalid;
     bit  awready; 

    // write data channel
     rand bit [7:0] wid;
     rand bit[63:0] wdata[];
     bit [7:0] wstrb[];       // logic written in post randomization since we need length
     rand bit wvalid;
     bit wready;  //response from slave
     bit wlast;  // logic in driver so not randomized

     // write response channel
    bit[1:0] bresp;
    bit bvalid;
    bit bready;
    bit[7:0] bid;

     // read address channel
     rand bit[7:0] arid;
     rand bit [31:0] araddr;
     rand bit [1:0] arburst;
     rand bit [7:0] arlen;
     rand bit [2:0] arsize;
     rand bit  arvalid;
     bit  arready;
   
    // read data channel
    bit [7:0] rid;
    bit[63:0] rdata[];
    bit rvalid;
    bit [1:0] rresp[];
    bit rready;     
    bit rlast;

    bit[63:0] temp_wdata;   // what are these for?
    bit[63:0] temp_rdata;

    int delay_cycles;


     `NEW_OBJ

    constraint write_id{awid==wid; bid==wid;}
    constraint read_id{arid==rid;}

    constraint arburst_c{arburst inside{0,1,2};}
    constraint awburst_c{awburst inside{0,1,2};}

    constraint arsize_c{arsize inside{0,1,2,3};}
    constraint awsize_c{awsize inside{0,1,2,3};}   //channel width is 64 bit only 8 bytes supported

    // wrap and fixed burst will not support aligned address hence we need to make sure only aligned values are being assigned
    // aligned address is multiples of size
    constraint write_align{((awburst==2'b10 || awburst==2'b00) && awsize ==1) -> awaddr%2 ==0;}
    constraint write_align1{((awburst==2'b10 || awburst==2'b00) && awsize ==2) -> awaddr%4 ==0;}
    constraint write_align2{((awburst==2'b10 || awburst==2'b00) && awsize ==3) -> awaddr%8 ==0;}

    constraint read_align {((arburst==2'b10 || arburst==2'b00) && arsize ==1) -> araddr%2 ==0;}
    constraint read_align1{((arburst==2'b10 || arburst==2'b00) && arsize ==2) -> araddr%4 ==0;}
    constraint read_align2{((arburst==2'b10 || arburst==2'b00) && arsize ==3) -> araddr%8 ==0;}

    constraint  wdata_size{wdata.size==awlen+1;}

   function void do_print(uvm_printer printer);
   super.do_print(printer);

   // reset
   printer.print_field("aresetn", aresetn, 1, UVM_BIN);

   // write address channel
   printer.print_field("awid", awid, 8, UVM_DEC);
   printer.print_field("awaddr", awaddr, 32, UVM_HEX);
   printer.print_field("awburst", awburst, 2, UVM_BIN);
   printer.print_field("awlen", awlen, 8, UVM_DEC);
   printer.print_field("awsize", awsize, 3, UVM_DEC);
   printer.print_field("awvalid", awvalid, 1, UVM_BIN);
   printer.print_field("awready", awready, 1, UVM_BIN);

   // write data channel
   printer.print_field("wid", wid, 8, UVM_DEC);

   printer.print_array_header("wdata", wdata.size());
   foreach(wdata[i])
      printer.print_field($sformatf("wdata[%0d]", i),
                           wdata[i],
                           64,
                           UVM_HEX);
   printer.print_array_footer();

   printer.print_array_header("wstrb", wstrb.size());
   foreach(wstrb[i])
      printer.print_field($sformatf("wstrb[%0d]", i),
                           wstrb[i],
                           8,
                           UVM_HEX);
   printer.print_array_footer();

   printer.print_field("wvalid", wvalid, 1, UVM_BIN);
   printer.print_field("wready", wready, 1, UVM_BIN);
   printer.print_field("wlast", wlast, 1, UVM_BIN);

   // write response channel
   printer.print_field("bresp", bresp, 2, UVM_BIN);
   printer.print_field("bvalid", bvalid, 1, UVM_BIN);
   printer.print_field("bready", bready, 1, UVM_BIN);
   printer.print_field("bid", bid, 8, UVM_DEC);

   // read address channel
   printer.print_field("arid", arid, 8, UVM_DEC);
   printer.print_field("araddr", araddr, 32, UVM_HEX);
   printer.print_field("arburst", arburst, 2, UVM_BIN);
   printer.print_field("arlen", arlen, 8, UVM_DEC);
   printer.print_field("arsize", arsize, 3, UVM_DEC);
   printer.print_field("arvalid", arvalid, 1, UVM_BIN);
   printer.print_field("arready", arready, 1, UVM_BIN);

   // read data channel
   printer.print_field("rid", rid, 8, UVM_DEC);

   printer.print_array_header("rdata", rdata.size());
   foreach(rdata[i])
      printer.print_field($sformatf("rdata[%0d]", i),
                           rdata[i],
                           64,
                           UVM_HEX);
   printer.print_array_footer();

   printer.print_array_header("rresp", rresp.size());
   foreach(rresp[i])
      printer.print_field($sformatf("rresp[%0d]", i),
                           rresp[i],
                           2,
                           UVM_BIN);
   printer.print_array_footer();

   printer.print_field("rvalid", rvalid, 1, UVM_BIN);
   printer.print_field("rready", rready, 1, UVM_BIN);
   printer.print_field("rlast", rlast, 1, UVM_BIN);

   // temporary variables
   printer.print_field("temp_wdata", temp_wdata, 64, UVM_HEX);
   printer.print_field("temp_rdata", temp_rdata, 64, UVM_HEX);

   // misc
   printer.print_int("delay_cycles", delay_cycles, 32, UVM_DEC);

endfunction

    function void post_randomize();
        int j=0;
        bit[31:0] start_addr = awaddr;
        int no_of_bytes = 2**awsize;
        int burst_length= awlen+1;
        bit[31:0] aligned_address = (start_addr/no_of_bytes)*no_of_bytes;
        wstrb = new[awlen+1];
        for(int i=(start_addr%8); i<((aligned_address % 8)+no_of_bytes);i++) // i value should be in between 0 to 7 because i represents the index of wstrb thats why we use %8 
            wstrb[j][i]=1'b1;

        for(int l=1; l<burst_length;l++)
        begin
            aligned_address = aligned_address + no_of_bytes;
            j++;
            for(int k=(aligned_address%8); k<((aligned_address%8)+no_of_bytes);k++)
            wstrb[j][k]=1'b1;
        end
    endfunction
 endclass

//================================================================================================================
//------------------ AHB RESET SEQUENCE -------------------------------------------------------------------------------
//===================================================================================================================
class ahb_rst_seq_base extends uvm_sequence#(ahb_rst_xtn);
    `uvm_object_utils(ahb_rst_seq_base)
    `NEW_OBJ
endclass

class ahb_rst_seq extends ahb_rst_seq_base;
    `uvm_object_utils(ahb_rst_seq)
    `NEW_OBJ

    task body();
        req = ahb_rst_xtn::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {hresetn == 1'b0;});
        finish_item(req);
    endtask
endclass


//================================================================================================================
//------------------ AXI RESET SEQUENCE -------------------------------------------------------------------------------
//===================================================================================================================
class axi_rst_seq_base extends uvm_sequence#(axi_rst_xtn);
    `uvm_object_utils(axi_rst_seq_base)
    `NEW_OBJ
endclass

class axi_rst_seq extends axi_rst_seq_base;
    `uvm_object_utils(axi_rst_seq)
    `NEW_OBJ

    task body();
        req = axi_rst_xtn::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {aresetn == 1'b0;});
        finish_item(req);
    endtask
endclass

//================================================================================================================
//------------------ AXI SEQUENCE -------------------------------------------------------------------------------
//===================================================================================================================
class axi_seq_base extends uvm_sequence#(axi_xtn);
    `uvm_object_utils(axi_seq_base)
    `NEW_OBJ
    env_cfg env_cfg_h;
    int temp;      // variable for length which we are setting from test
endclass

class axi_seq extends axi_seq_base; //both read and write simulataneously
    `uvm_object_utils(axi_seq)
    `NEW_OBJ

    task body();
        req = axi_xtn::type_id::create("req");
        if(!uvm_config_db#(env_cfg)::get(null,get_full_name(),"env_cfg", env_cfg_h))
            `uvm_fatal("FATAL", "getting cfg failed in axi sequence")

        temp = env_cfg_h.axi_length.pop_front();

        start_item(req);
        assert(req.randomize() with {awlen==temp; arlen==temp; arvalid==1; awvalid==1; wvalid==1; awburst inside{[0:1]};});  //single or wrap
        finish_item(req);
    endtask
endclass

class axi_burst_seq extends axi_seq_base;// only write operation and incr burst
    `uvm_object_utils(axi_burst_seq)
    `NEW_OBJ

    task body();
        req = axi_xtn::type_id::create("req");
        if(!uvm_config_db#(env_cfg)::get(null,get_full_name(),"env_cfg", env_cfg_h))
            `uvm_fatal("FATAL", "getting cfg failed in axi burst sequence")

        temp = env_cfg_h.axi_length.pop_front();

        start_item(req);
        assert(req.randomize() with {awlen==temp; arlen==temp; arvalid==0; awvalid==1; wvalid==1; awburst ==2;});
        finish_item(req);
    endtask
endclass

class axi_read_seq extends axi_seq_base; //only read operation
    `uvm_object_utils(axi_read_seq)
    `NEW_OBJ

    task body();
        req = axi_xtn::type_id::create("req");
        if(!uvm_config_db#(env_cfg)::get(null,get_full_name(),"env_cfg", env_cfg_h))
            `uvm_fatal("FATAL", "getting cfg failed in axi burst sequence")

        temp = env_cfg_h.axi_length.pop_front();

        start_item(req);
        assert(req.randomize() with {awlen==temp; arlen==temp; arvalid==1; awvalid==0; wvalid==0; arsize inside {0,1,2,3};
                arburst inside {0,1,2};});
        finish_item(req);
    endtask
endclass

//================================================================================================================
//------------------ AHB SEQUENCES -------------------------------------------------------------------------------
//===================================================================================================================

class ahb_sequence_base extends uvm_sequence#(ahb_xtn);
    `uvm_object_utils(ahb_sequence_base)

    env_cfg env_cfg_h;

    function new(string name="ahb_sequence_base");
        super.new(name);
    endfunction

endclass


class ahb_seq extends ahb_sequence_base;
    `uvm_object_utils(ahb_seq);

    function new(string name="ahb_seq");
        super.new(name);
    endfunction

    task body();

        req=ahb_xtn::type_id::create("req");

        if(!uvm_config_db#(env_cfg)::get(null,get_full_name(),"env_cfg",env_cfg_h))
            `uvm_fatal(get_type_name(),"configuration fail in ahb_sequence")

        repeat((2*(env_cfg_h.ahb_length.pop_front())))
        begin
            start_item(req);
            assert(req.randomize() with {delay_cycles==2;});
            finish_item(req);
        end

    endtask
endclass

//================================================================================================================
//------------------ AHB SLAVE rst -------------------------------------------------------------------------------
//===================================================================================================================

class ahb_rst_drv extends uvm_driver#(ahb_rst_xtn);
     `uvm_component_utils(ahb_rst_drv)
     `NEW_COMP
    ahb_rst_cfg ahb_rst_cfg_h;
    ahb_cfg ahb_cfg_h;        // we need to get hready signal since the reset should be active till hready is asserted and that hready
                            // signal is there inside the ahb interface and to get ahb interface we need ahb config

    virtual ahb_rst_if.AHB_RST_DRV_MP vif;
    virtual ahb_if.AHB_DRV_MP hvif;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(ahb_cfg)::get(this,"*","ahb_cfg",ahb_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb_rst_drv")

        if(!uvm_config_db#(ahb_rst_cfg)::get(this,"*","ahb_rst_cfg",ahb_rst_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb_rst_drv")
        vif = ahb_rst_cfg_h.vif;
        hvif = ahb_cfg_h.vif;
    endfunction

    task run_phase(uvm_phase phase);
      forever begin
            seq_item_port.get_next_item(req);
            send_to_dut(req);
            seq_item_port.item_done();
      end
    endtask

    task send_to_dut(ahb_rst_xtn req);
        @(vif.ahb_rst_drv_cb);
        vif.ahb_rst_drv_cb.hresetn <= req.hresetn;
        hvif.ahb_drv_cb.hready <= 1'b1;
        @(vif.ahb_rst_drv_cb);
        @(vif.ahb_rst_drv_cb);
        vif.ahb_rst_drv_cb.hresetn <= 1'b1;
        hvif.ahb_drv_cb.hready <= 1'b0;
        @(vif.ahb_rst_drv_cb);
        @(vif.ahb_rst_drv_cb);
    endtask
endclass
//------------------------------------------------------------------------------------------------------------

class ahb_rst_mon extends uvm_monitor;
     `uvm_component_utils(ahb_rst_mon)
    ahb_rst_cfg ahb_rst_cfg_h;
    ahb_cfg ahb_cfg_h;
    ahb_rst_xtn req;

    virtual ahb_rst_if.AHB_RST_MON_MP vif;
    virtual ahb_if.AHB_MON_MP hvif;
     `NEW_COMP

    uvm_analysis_port#(ahb_rst_xtn) rst_mon_port;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(ahb_cfg)::get(this,"*","ahb_cfg",ahb_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb rst mon")

        if(!uvm_config_db#(ahb_rst_cfg)::get(this,"*","ahb_rst_cfg",ahb_rst_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb_rst_mon")

        vif = ahb_rst_cfg_h.vif;
        hvif = ahb_cfg_h.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            collect();
        end
    endtask

    task collect();
            req = ahb_rst_xtn::type_id::create("req");
            wait(!vif.ahb_rst_mon_cb.hresetn);
            @(vif.ahb_rst_mon_cb);
            req.hresetn = vif.ahb_rst_mon_cb.hresetn;
            req.htrans = hvif.ahb_mon_cb.htrans;

            rst_mon_port.write(req);
    endtask
endclass
//------------------------------------------------------------------------------------------------------------

class ahb_rst_seqr extends uvm_sequencer#(ahb_rst_xtn);
     `uvm_component_utils(ahb_rst_seqr)
     `NEW_COMP

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
endclass


//================================================================================================================
//------------------ AXI MASTER rst -------------------------------------------------------------------------------
//===================================================================================================================

class axi_rst_drv extends uvm_driver#(axi_rst_xtn);
     `uvm_component_utils(axi_rst_drv)
     `NEW_COMP
    axi_rst_cfg axi_rst_cfg_h;
    virtual axi_rst_if.AXI_RST_DRV_MP vif;

    axi_cfg axi_cfg_h;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
         if(!uvm_config_db#(axi_cfg)::get(this,"*","axi_cfg",axi_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi_rst_drv")

       if(!uvm_config_db#(axi_rst_cfg)::get(this,"*","axi_rst_cfg",axi_rst_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi_rst_drv")
        vif = axi_rst_cfg_h.vif;
    endfunction

     task run_phase(uvm_phase phase);
      forever begin
            seq_item_port.get_next_item(req);
            send_to_dut(req);
            seq_item_port.item_done();
      end
    endtask

    task send_to_dut(axi_rst_xtn req);
        @(vif.axi_rst_drv_cb);
        vif.axi_rst_drv_cb.aresetn <= req.aresetn;
        @(vif.axi_rst_drv_cb);
        @(vif.axi_rst_drv_cb);
        vif.axi_rst_drv_cb.aresetn <= 1'b1;
       // @(vif.axi_rst_drv_cb);
       // @(vif.axi_rst_drv_cb);
    endtask

endclass
//------------------------------------------------------------------------------------------------------------

class axi_rst_mon extends uvm_monitor;
     `uvm_component_utils(axi_rst_mon)
     `NEW_COMP
    axi_rst_cfg axi_rst_cfg_h;
    virtual axi_rst_if.AXI_RST_MON_MP vif;
    virtual axi_if.AXI_MON_MP avif;
    axi_cfg axi_cfg_h;
    axi_rst_xtn req;

     uvm_analysis_port#(axi_rst_xtn) rst_mon_port;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
         if(!uvm_config_db#(axi_cfg)::get(this,"*","axi_cfg",axi_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi_rst_mon")

         if(!uvm_config_db#(axi_rst_cfg)::get(this,"*","axi_rst_cfg",axi_rst_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi_rst_mon")
          vif = axi_rst_cfg_h.vif;
          avif= axi_cfg_h.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            collect();
        end
    endtask

    task collect();
            req = axi_rst_xtn ::type_id::create("req");
            wait(!vif.axi_rst_mon_cb.aresetn);
            @(vif.axi_rst_mon_cb);
            req.aresetn = vif.axi_rst_mon_cb.aresetn;
            req.rvalid = avif.axi_mon_cb.rvalid;
            req.bvalid = avif.axi_mon_cb.bvalid;
            rst_mon_port.write(req);
    endtask
endclass

//------------------------------------------------------------------------------------------------------------

class axi_rst_seqr extends uvm_sequencer#(axi_rst_xtn);
     `uvm_component_utils(axi_rst_seqr)
     `NEW_COMP

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
endclass

//================================================================================================================
//------------------ AHB SLAVE-------------------------------------------------------------------------------
//===================================================================================================================
class ahb_drv extends uvm_driver;
     `uvm_component_utils(ahb_drv)
     `NEW_COMP
    ahb_cfg ahb_cfg_h;
    virtual ahb_if vif;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(ahb_cfg)::get(this,"*","ahb_cfg",ahb_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb_drv")
        vif = ahb_cfg_h.vif;
    endfunction
endclass
//------------------------------------------------------------------------------------------------------------

class ahb_mon extends uvm_monitor;
     `uvm_component_utils(ahb_mon)
     `NEW_COMP
    ahb_cfg ahb_cfg_h;
    virtual ahb_if vif;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(ahb_cfg)::get(this,"*","ahb_cfg",ahb_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb_mon")
        vif = ahb_cfg_h.vif;
    endfunction
endclass
//------------------------------------------------------------------------------------------------------------

class ahb_seqr extends uvm_sequencer;
     `uvm_component_utils(ahb_seqr)
     `NEW_COMP


     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
endclass

//================================================================================================================
//------------------ AXI MASTER -------------------------------------------------------------------------------
//===================================================================================================================
class axi_drv extends uvm_driver;
     `uvm_component_utils(axi_drv)
     `NEW_COMP

    axi_xtn axi_xtn_h;
    axi_xtn q_aw[$], q_w[$], q_b[$], q_rw[$], q_r[$];

    semaphore sem_aw=new(1);
    semaphore sem_w=new();
    semaphore sem_b = new();
    semaphore sem_ar=new(1);
    semaphore sem_r=new();

    semaphore sem_aw_w = new(1);
    semaphore sem_ar_r = new();
    semaphore sem_w_b= new();

    axi_cfg axi_cfg_h;
    virtual axi_if.AXI_DRV_MP vif;
    ///virtual axi_rst_if.AXI_DRV_MP vif;
    task write_address_channel(axi_xtn xtn);
        @(vif.axi_drv_cb);
        begin
           vif.axi_drv_cb.awvalid <= xtn.awvalid;
           vif.axi_drv_cb.awid    <= xtn.awid;
           vif.axi_drv_cb.awaddr  <= xtn.awaddr;
           vif.axi_drv_cb.awlen   <= xtn.awlen;
           vif.axi_drv_cb.awsize  <= xtn.awsize;
           vif.axi_drv_cb.awburst <= xtn.awburst;

           wait(vif.axi_drv_cb.awready)
           @(vif.axi_drv_cb);
           vif.axi_drv_cb.awvalid <= 1'b0;
           repeat(xtn.delay_cycles)
           @(vif.axi_drv_cb);
        end
    endtask

    task read_address_channel(axi_xtn xtn);
        @(vif.axi_drv_cb);
        begin
           vif.axi_drv_cb.arvalid <= xtn.arvalid;
           vif.axi_drv_cb.arid    <= xtn.arid;
           vif.axi_drv_cb.araddr  <= xtn.araddr;
           vif.axi_drv_cb.arlen   <= xtn.arlen;
           vif.axi_drv_cb.arsize  <= xtn.arsize;
           vif.axi_drv_cb.arburst <= xtn.arburst;
           vif.axi_drv_cb.aresetn <= xtn.aresetn;

           wait(vif.axi_drv_cb.arready)
           @(vif.axi_drv_cb);
           vif.axi_drv_cb.arvalid <= 1'b0;
           repeat(xtn.delay_cycles)
           @(vif.axi_drv_cb);
        end
    endtask

    task write_response_channel(axi_xtn xtn);
        begin
          
           vif.axi_drv_cb.bready <= 1'b1;

           wait(vif.axi_drv_cb.bvalid)
           @(vif.axi_drv_cb);
           vif.axi_drv_cb.bready <= 1'b0;
          
           repeat(xtn.delay_cycles)
           @(vif.axi_drv_cb);
            end
       
    endtask

    task write_data_channel(axi_xtn xtn);
        begin
            foreach(xtn.wdata[i]) begin
           vif.axi_drv_cb.wvalid <= xtn.wvalid;
           vif.axi_drv_cb.wid    <= xtn.wid;
           vif.axi_drv_cb.wdata  <= xtn.wdata[i];
           vif.axi_drv_cb.wstrb   <= xtn.wstrb[i];
           
           if(i==xtn.awlen) vif.axi_drv_cb.wlast<=1'b1;
           else vif.axi_drv_cb.wlast<=1'b0;

           wait(vif.axi_drv_cb.wready)
           @(vif.axi_drv_cb);
           vif.axi_drv_cb.wvalid <= 1'b0;
           vif.axi_drv_cb.wlast <= 1'b0;
           @(vif.axi_drv_cb);
           repeat(xtn.delay_cycles)
           @(vif.axi_drv_cb);
            end
        end
    endtask



    task read_data_channel(axi_xtn xtn);
        begin
           repeat(vif.axi_drv_cb.arlen + 1'b1) begin
            @(vif.axi_drv_cb);
           vif.axi_drv_cb.rready <= 1'b1;

           wait(vif.axi_drv_cb.rvalid)
           @(vif.axi_drv_cb);
           vif.axi_drv_cb.rready <= 1'b0;
          
           repeat(xtn.delay_cycles)
           @(vif.axi_drv_cb);
            end
        end
    endtask


    task send_to_dut(axi_xtn xtn);
        q_aw.push_back(xtn); 
        q_w.push_back(xtn);
        q_b.push_back(xtn);
        q_rw.push_back(xtn);
        q_r.push_back(xtn);
        fork
            begin
               
               sem_aw.get(1);                           // get the key
               write_address_channel(q_aw.pop_front()); 
               sem_w.put(1);
               sem_aw.put(1);    // putting it back as it supports outstanding transactions
               
            end 

            begin
               sem_aw_w.get(1);
               sem_w.get(1);
               write_data_channel(q_w.pop_front()); //running 
               sem_b.put(1); 
               sem_aw_w.put(1);
            end

            begin
                sem_b.get(1);
               write_response_channel(q_b.pop_front());
              
            end

             begin
                sem_ar.get(1);
                read_address_channel(q_rw.pop_front());
               sem_r.put(1); 
               sem_ar.put(1);
            end

             begin
               sem_ar_r.get(1);
               sem_r.get(1);
               read_data_channel(q_r.pop_front());
               sem_ar_r.put(1);
            end
        join_any
    endtask

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(axi_cfg)::get(this,"*","axi_cfg",axi_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi_drv")
        vif = axi_cfg_h.vif;
        
    endfunction


    task run_phase(uvm_phase phase)
        forever begin
            seq_item_port.get_next_item(req);
            send_to_dut(req);
            seq_item_port.item_done();
        end
    endtask


endclass
//------------------------------------------------------------------------------------------------------------

class axi_mon extends uvm_monitor;
     `uvm_component_utils(axi_mon)
     `NEW_COMP
    axi_cfg axi_cfg_h;
    virtual axi_if.AXI_MON_MP vif;

    uvm_analysis_port#(axi_xtn) axi_mon_port;
    uvm_analysis_port#(axi_xtn) axi_wr_mon_port;
    uvm_analysis_port#(axi_xtn) axi_rd_mon_port;

    axi_xtn xtn_aw,xtn_ar, xtn_r, xtn_w, xtn_b;
    axi_xtn q_w[$], q_r[$];                  //how does this queues work? why do we need this? bz we are pushing xtn in address as well as in data...// when we say pop
    axi_xtn axi_write_data, axi_read_data;
    semaphore sem_aw=new(1);
    semaphore sem_w=new();
    semaphore sem_b = new();
    semaphore sem_ar=new(1);
    semaphore sem_r=new();

    semaphore sem_aw_w = new(1);
    semaphore sem_ar_r = new(1);
    semaphore sem_w_b= new();

    task write_address_channel();
        xtn_aw = axi_xtn::type_id::create("xtn_aw");
        wait((vif.axi_mon_cb.awvalid) && (vif.axi_mon_cb.awready))
           xtn_aw.awvalid  = vif.axi_mon_cb.awvalid;
           xtn_aw.awid     = vif.axi_mon_cb.awid;
           xtn_aw.awaddr   = vif.axi_mon_cb.awaddr;
           xtn_aw.awlen    = vif.axi_mon_cb.awlen;
           xtn_aw.awsize   = vif.axi_mon_cb.awsize;
           xtn_aw.awburst  = vif.axi_mon_cb.awburst;
           xtn_aw.awready  = vif.axi_mon_cb.awready;

          q_w.push_back(xtn_aw);   //we need queue for oustanding requests 
          @(vif.axi_mon_cb);
    endtask

    
    task read_address_channel();
        xtn_ar = axi_xtn::type_id::create("xtn_ar");

        wait((vif.axi_mon_cb.arvalid) && (vif.axi_mon_cb.arready))

           xtn_ar.arvalid  = vif.axi_mon_cb.arvalid;
           xtn_ar.arid     = vif.axi_mon_cb.arid;
           xtn_ar.araddr   = vif.axi_mon_cb.araddr;
           xtn_ar.arlen    = vif.axi_mon_cb.arlen;
           xtn_ar.arsize   = vif.axi_mon_cb.arsize;
           xtn_ar.arburst  = vif.axi_mon_cb.arburst;
           xtn_ar.arready  = vif.axi_mon_cb.arready;

          q_r.push_back(xtn_ar);
          @(vif.axi_mon_cb);
    endtask


    task write_data_channel(axi_xtn xtn);
        xtn_w = axi_xtn::type_id::create("xtn_w");

        xtn_w = xtn;  //  xtn has all write addr and control signals

        xtn_w.wdata=new[xtn_w.awlen+1];
        xtn_w.wstrb=new[xtn_w.awlen+1];

        foreach(xtn_w.wdata[i])
        begin
            wait((vif.axi_mon_cb.wvalid==1'b1)&&((vif.axi_mon_cb.wready==1'b1)))

            axi_write_data = axi_xtn::type_id::create("axi_write_data");

            xtn_w.wready   = vif.axi_mon_cb.wready;
            xtn_w.wvalid   = vif.axi_mon_cb.wvalid;
            xtn_w.wid      = vif.axi_mon_cb.wid;
            xtn_w.wdata[i] = vif.axi_mon_cb.wdata;

            axi_write_data.temp_wdata[7:0]=vif.axi_mon_cb.wstrb[0]?vif.axi_mon_cb.wdata[7:0]:8'b00000000;  // here wstrb in vif is not dynamic so wstrb[0] indicates the first bit in wstrb variable and according to the bit we decide it is valid byte or not
            axi_write_data.temp_wdata[15:8]=vif.axi_mon_cb.wstrb[1]?vif.axi_mon_cb.wdata[15:8]:8'b00000000;
            axi_write_data.temp_wdata[23:16]=vif.axi_mon_cb.wstrb[2]?vif.axi_mon_cb.wdata[23:16]:8'b00000000;
            axi_write_data.temp_wdata[31:24]=vif.axi_mon_cb.wstrb[3]?vif.axi_mon_cb.wdata[31:24]:8'b00000000;
            axi_write_data.temp_wdata[39:32]=vif.axi_mon_cb.wstrb[4]?vif.axi_mon_cb.wdata[39:32]:8'b00000000;
            axi_write_data.temp_wdata[47:40]=vif.axi_mon_cb.wstrb[5]?vif.axi_mon_cb.wdata[47:40]:8'b00000000;
            axi_write_data.temp_wdata[55:48]=vif.axi_mon_cb.wstrb[6]?vif.axi_mon_cb.wdata[55:48]:8'b00000000;
            axi_write_data.temp_wdata[63:56]=vif.axi_mon_cb.wstrb[7]?vif.axi_mon_cb.wdata[63:56]:8'b00000000;

            xtn_w.wstrb[i] = vif.axi_mon_cb.wstrb;  //in trans strb is dynamic. so if we have 4 transfers the size will be 4. each element in wstrb that is wstrb[0] is 8 bit data corresponding to one transfer

            if(i==(xtn_w.wdata.size-1))           // 4 bytes ---> 0123 till 3  or we can even using awlen isnt it?
                xtn_w.wlast = vif.axi_mon_cb.wlast;

            axi_wr_mon_port.write(axi_write_data); // we will send wdata to sb for every transfer
            
            @(vif.axi_mon_cb);
            
        end

        `uvm_info(get_type_name(),$sformatf("axi_xtn :\n %p",xtn_w.sprint()),UVM_LOW)
         q_w.push_back(xtn_w);      // pushing the transaction 
    endtask


    task read_data_channel(axi_xtn xtn);
    bit a;

    xtn_r = axi_xtn::type_id::create("xtn_r");
    xtn_r= xtn;
    xtn_r.rdata=new[xtn_r.arlen+1];

    foreach(xtn_r.rdata[i])
    begin
        wait((vif.axi_mon_cb.rvalid)&&((vif.axi_mon_cb.rready)))

        axi_read_data=axi_xtn::type_id::create("axi_read_data");

        xtn_r.rid = vif.axi_mon_cb.rid;
        xtn_r.rvalid = vif.axi_mon_cb.rvalid;
        xtn_r.rready = vif.axi_mon_cb.rready;
        xtn_r.rdata[i] = vif.axi_mon_cb.rdata;
        xtn_r.rresp[i] = vif.axi_mon_cb.rresp;

        axi_read_data.temp_rdata=vif.axi_mon_cb.rdata;   // because for every transfer we will send the data to sb so we cant send the dynamic array of data


        if(i==(xtn_r.rdata.size-1))
        begin
            xtn_r.rlast = vif.axi_mon_cb.rlast;
            a= vif.axi_mon_cb.rlast;
        end

        @(vif.axi_mon_cb);

        axi_rd_mon_port.write(axi_read_data);  // sending every transfer in transaction to sb
    end

    axi_mon_port.write(xtn_r);

    `uvm_info(get_type_name(),$sformatf("axi_xtn :\n %p",xtn_r.sprint()),UVM_LOW)

    endtask
   
    task write_response_channel(axi_xtn xtn);
        xtn_b = axi_xtn::type_id::create("xtn_b");
        xtn_b = xtn;

        wait((vif.axi_mon_cb.bvalid)&&((vif.axi_mon_cb.bready)))

        xtn.bvalid  = vif.axi_mon_cb.bvalid;
        xtn.bready  = vif.axi_mon_cb.bready;
        xtn_b.bid    = vif.axi_mon_cb.bid;
        xtn_b.bresp  = vif.axi_mon_cb.bresp;
        xtn_b.bvalid = vif.axi_mon_cb.bvalid;

        axi_mon_port.write(xtn_b);

        `uvm_info(get_type_name(),$sformatf("axi_xtn:\n %p",xtn.sprint()),UVM_LOW)

        axi_mon_port.write(xtn_b);
        @(vif.axi_mon_cb);
    endtask

    // we are sending write xtn and read xtn in data channels insider foreach loop(for every transfer)
    // we are sending xtn to mon port at the end of transaction i.e, in write response (last stage of write transaction - contains all write related info)
    // and in read data channel( last of read trans - contains all read related signals)


    task collect();

        fork
            begin
               
               sem_aw.get(1);                           // get the key
               write_address_channel(); 
               sem_aw.put(1);    // putting it back as it supports outstanding transactions
               sem_w.put(1);
            end 

            begin
               sem_aw_w.get(1);  //blocking overriding till the previous transa data is transfered completely
               sem_w.get(1);
               write_data_channel(q_w.pop_front()); //running 
               sem_b.put(1); 
               sem_aw_w.put(1);
            end

            begin
                sem_b.get(1);
               write_response_channel(q_w.pop_front());
              
            end

             begin
                sem_ar.get(1);
                read_address_channel();
               sem_r.put(1); 
               sem_ar.put(1);
            end

             begin
               sem_ar_r.get(1);
               sem_r.get(1);
               read_data_channel(q_r.pop_front());
               sem_ar_r.put(1);
            end
        join_any
    endtask

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(axi_cfg)::get(this,"*","axi_cfg",axi_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi_mon")
         vif = axi_cfg_h.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
           collect();
        end
    endtask
endclass
//------------------------------------------------------------------------------------------------------------

class axi_seqr extends uvm_sequencer;
     `uvm_component_utils(axi_seqr)
     `NEW_COMP

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
    endfunction
endclass

//================================================================================================================
//------------------ AGENTS -------------------------------------------------------------------------------
//===================================================================================================================
class ahb_rst_agent extends uvm_agent;
     `uvm_component_utils(ahb_rst_agent)
    ahb_rst_drv ahb_rst_drv_h;
    ahb_rst_mon ahb_rst_mon_h;
    ahb_rst_seqr ahb_rst_seqr_h;
    ahb_rst_cfg ahb_rst_cfg_h;

     `NEW_COMP

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
         if(!uvm_config_db#(ahb_rst_cfg)::get(this,"*","ahb_rst_cfg",ahb_rst_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb_rst_agent")
        
        ahb_rst_mon_h = ahb_rst_mon ::type_id::create("ahb_rst_mon_h",this);

        if(ahb_rst_cfg_h.is_active==UVM_ACTIVE) begin
        ahb_rst_drv_h = ahb_rst_drv ::type_id::create("ahb_rst_drv_h",this);
        ahb_rst_seqr_h = ahb_rst_seqr ::type_id::create("ahb_rst_seqr_h",this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(ahb_rst_cfg_h.is_active == UVM_ACTIVE)
        ahb_rst_drv_h.seq_item_port.connect(ahb_rst_seqr_h.seq_item_export);
    endfunction
endclass

//------------------------------------------------------------------------------------------------------------

class axi_rst_agent extends uvm_agent;
     `uvm_component_utils(axi_rst_agent)
     `NEW_COMP
     axi_rst_drv axi_rst_drv_h;
     axi_rst_mon axi_rst_mon_h;
     axi_rst_seqr axi_rst_seqr_h;
    axi_rst_cfg axi_rst_cfg_h;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);

         if(!uvm_config_db#(axi_rst_cfg)::get(this,"*","axi_rst_cfg",axi_rst_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi reset agent")
        axi_rst_mon_h = axi_rst_mon ::type_id::create("axi_rst_mon_h",this);

         if(axi_rst_cfg_h.is_active==UVM_ACTIVE) begin
        axi_rst_drv_h = axi_rst_drv ::type_id::create("axi_rst_drv_h",this);
        axi_rst_seqr_h = axi_rst_seqr ::type_id::create("axi_rst_seqr_h",this);
         end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(axi_rst_cfg_h.is_active == UVM_ACTIVE)
        axi_rst_drv_h.seq_item_port.connect(axi_rst_seqr_h.seq_item_export);
    endfunction
endclass

//------------------------------------------------------------------------------------------------------------


class ahb_agent extends uvm_agent;
     `uvm_component_utils(ahb_agent)
     `NEW_COMP

    ahb_drv ahb_drv_h;
    ahb_mon ahb_mon_h;
    ahb_seqr ahb_seqr_h;
    ahb_cfg ahb_cfg_h;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(ahb_cfg)::get(this,"*","ahb_cfg",ahb_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb_agent")

        ahb_mon_h = ahb_mon ::type_id::create("ahb_mon_h",this);

        if(ahb_cfg_h.is_active==UVM_ACTIVE) begin
        ahb_drv_h = ahb_drv ::type_id::create("ahb_drv_h",this);
        ahb_seqr_h = ahb_seqr ::type_id::create("ahb_seqr_h",this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(ahb_cfg_h.is_active == UVM_ACTIVE)
        ahb_drv_h.seq_item_port.connect(ahb_seqr_h.seq_item_export);
    endfunction
endclass

//------------------------------------------------------------------------------------------------------------

class axi_agent extends uvm_agent;
     `uvm_component_utils(axi_agent)
     `NEW_COMP

    axi_drv axi_drv_h;
    axi_mon axi_mon_h;
    axi_seqr axi_seqr_h;
    axi_cfg axi_cfg_h;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);

         if(!uvm_config_db#(axi_cfg)::get(this,"*","axi_cfg",axi_cfg_h))
            `uvm_fatal("FATAL","cfg failed | axi  agent")
        
         axi_mon_h = axi_mon ::type_id::create("axi_mon_h",this);

         if(axi_cfg_h.is_active==UVM_ACTIVE) begin
            axi_drv_h = axi_drv ::type_id::create("axi_drv_h",this);
            axi_seqr_h = axi_seqr ::type_id::create("axi_seqr_h",this);
         end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(axi_cfg_h.is_active == UVM_ACTIVE)
        axi_drv_h.seq_item_port.connect(axi_seqr_h.seq_item_export);
    endfunction
endclass

//================================================================================================================
//------------------ AGENT TOPS -------------------------------------------------------------------------------
//===================================================================================================================
class ahb_agent_top extends uvm_env;
     `uvm_component_utils(ahb_agent_top)
     `NEW_COMP

    ahb_rst_agent ahb_rst_agent_h[];
    ahb_agent ahb_agent_h[];
    env_cfg env_cfg_h;

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(env_cfg)::get(this,"","env_cfg",env_cfg_h))
            `uvm_fatal("FATAL","getting config failed | ahb_agent_top")
        config_create();
    endfunction

    function void config_create();
            begin
                ahb_agent_h = new[env_cfg_h.no_of_duts];
                ahb_rst_agent_h = new[env_cfg_h.no_of_duts];
                
                if(env_cfg_h.has_ahb_agent) begin
                foreach(ahb_agent_h[i]) begin
    
                    uvm_config_db#(ahb_cfg)::set(this,"*","ahb_cfg",env_cfg_h.ahb_cfg_h[i]);
                    ahb_agent_h[i] = ahb_agent::type_id::create($sformatf("ahb_agent_h[%0d]",i),this);
                end
                end
           
                if(env_cfg_h.has_ahb_rst_agent) begin
                foreach(ahb_rst_agent_h[i]) begin
                    uvm_config_db#(ahb_rst_cfg)::set(this,"*","ahb_rst_cfg",env_cfg_h.ahb_rst_cfg_h[i]);
                    ahb_rst_agent_h[i] = ahb_rst_agent::type_id::create($sformatf("ahb_rst_agent_h[%0d]",i),this);
                end
                end
            
            end
    endfunction
endclass


class axi_agent_top extends uvm_env;
     `uvm_component_utils(axi_agent_top)
     `NEW_COMP

    axi_agent axi_agent_h[];
    axi_rst_agent axi_rst_agent_h[];
    env_cfg env_cfg_h;
    
     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(env_cfg)::get(this,"","env_cfg",env_cfg_h))
            `uvm_fatal("FATAL","gettong config failed | axi_agent_top")

        config_create();
    endfunction

     function void config_create();
            begin
                axi_agent_h = new[env_cfg_h.no_of_duts];
                axi_rst_agent_h = new[env_cfg_h.no_of_duts];
                

                if(env_cfg_h.has_axi_agent) begin
                foreach(axi_agent_h[i]) begin
                    uvm_config_db#(axi_cfg)::set(this,"*","axi_cfg",env_cfg_h.axi_cfg_h[i]);
                    axi_agent_h[i] = axi_agent::type_id::create($sformatf("axi_agent_h[%0d]",i),this);
                end
                end
           
                if(env_cfg_h.has_axi_rst_agent) begin
                foreach(axi_rst_agent_h[i]) begin
                    uvm_config_db#(axi_rst_cfg)::set(this,"*","axi_rst_cfg",env_cfg_h.axi_rst_cfg_h[i]);
                    axi_rst_agent_h[i] = axi_rst_agent::type_id::create($sformatf("axi_rst_agent_h[%0d]",i),this);
                end
                end
            
            end
    endfunction
endclass

//================================================================================================================
//------------------ COMMON CLASSES -------------------------------------------------------------------------------
//===================================================================================================================
class sb extends uvm_scoreboard;
     `uvm_component_utils(sb)
     `NEW_COMP

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
endclass

class env extends uvm_env;
     `uvm_component_utils(env)
     `NEW_COMP

    sb sbh[];
    axi_agent_top axi_agent_top_h[];
    ahb_agent_top ahb_agent_top_h[];
    env_cfg env_cfg_h;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(env_cfg)::get(this,"","env_cfg",env_cfg_h))
            `uvm_fatal("FATAL","gettong config failed | env")
        config_create();
    endfunction

    function void config_create();
            begin
                axi_agent_top_h = new[env_cfg_h.no_of_duts];
                ahb_agent_top_h = new[env_cfg_h.no_of_duts];
                sbh = new[env_cfg_h.no_of_duts];

                if(env_cfg_h.has_axi_agent) begin
                foreach(axi_agent_top_h[i]) 
                    axi_agent_top_h[i] = axi_agent_top::type_id::create($sformatf("axi_agent_top_h[%0d]",i),this);
                end
           
                if(env_cfg_h.has_ahb_agent) begin
                foreach(ahb_agent_top_h[i]) 
                    ahb_agent_top_h[i] = ahb_agent_top::type_id::create($sformatf("ahb_agent_top_h[%0d]",i),this);
                end
                
                if(env_cfg_h.has_scoreboard) begin
                foreach(sbh[i])
                    sbh[i] = sb::type_id::create($sformatf("sbh[%0d]",i), this);
                end
            end
    endfunction

endclass


class test extends uvm_test;
        `uvm_component_utils(test)
         
        
         env envh;
        axi_rst_cfg  axi_rst_cfg_h[];
        axi_cfg axi_cfg_h[];
        ahb_rst_cfg ahb_rst_cfg_h[];
        ahb_cfg ahb_cfg_h[];
        env_cfg  env_cfg_h;

        bit has_axi_agent = 1;
        bit has_ahb_agent=1;
        bit has_ahb_rst_agent=1;
        bit has_axi_rst_agent = 1;
        
        int no_of_duts=1;
        
        bit has_scoreboard=1;

        rand int length[];
        int no_of_trans;

        constraint length_c {foreach(length[i])
                                 length[i] inside {[1:15]}; }
        

        `NEW_COMP

        function void config_create();
            if(has_axi_agent)
            begin
                axi_cfg_h = new[no_of_duts];
                env_cfg_h.axi_cfg_h = new[no_of_duts];
                foreach(axi_cfg_h[i])
                    axi_cfg_h[i] = axi_cfg::type_id::create($sformatf("axi_cfg_h[%0d]",i));
            end

            if(has_axi_rst_agent)
            begin
                axi_rst_cfg_h = new[no_of_duts];
                env_cfg_h.axi_rst_cfg_h = new[no_of_duts];
                foreach(axi_rst_cfg_h[i])
                    axi_rst_cfg_h[i] = axi_rst_cfg::type_id::create($sformatf("axi_rst_cfg_h[%0d]",i));
            end

            if(has_ahb_agent)
            begin
                ahb_cfg_h = new[no_of_duts];
                env_cfg_h.ahb_cfg_h = new[no_of_duts];
                foreach(ahb_cfg_h[i])
                    ahb_cfg_h[i] = ahb_cfg::type_id::create($sformatf("ahb_cfg_h[%0d]",i));
            end

            if(has_ahb_rst_agent)
            begin
                ahb_rst_cfg_h = new[no_of_duts];
                env_cfg_h.ahb_rst_cfg_h = new[no_of_duts];
                foreach(ahb_rst_cfg_h[i])
                    ahb_rst_cfg_h[i] = ahb_rst_cfg::type_id::create($sformatf("ahb_rst_cfg_h[%0d]",i));
            end
        endfunction


        function void config_set();
            if(has_axi_agent)
            begin
                foreach(axi_cfg_h[i])  begin
                    if(!uvm_config_db#(virtual axi_if)::get(this,"","vif", axi_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | axi cfg")
                env_cfg_h.axi_cfg_h[i] = axi_cfg_h[i];
                end
            end

            if(has_axi_rst_agent)
            begin
                
                foreach(axi_rst_cfg_h[i]) begin
                    if(!uvm_config_db#(virtual axi_rst_if)::get(this,"", "vif",axi_rst_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | axi reset cfg")
                    env_cfg_h.axi_rst_cfg_h[i] = axi_rst_cfg_h[i];
                    
                end
            end

            if(has_ahb_agent)
            begin
                foreach(ahb_cfg_h[i]) begin
                    if(!uvm_config_db#(virtual ahb_if)::get(this,"", "vif",ahb_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | ahb cfg")
                    env_cfg_h.ahb_cfg_h[i] = ahb_cfg_h[i];
                    
                end
            end

            if(has_ahb_rst_agent)
            begin
                foreach(ahb_rst_cfg_h[i]) begin
                     if(!uvm_config_db#(virtual ahb_rst_if)::get(this,"", "vif",ahb_rst_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | ahb reset cfg")
                    env_cfg_h.ahb_rst_cfg_h[i]= ahb_rst_cfg_h[i];
                   
                end
            end

            this.randomize() with {length.size == no_of_trans;}; // randomizing length for all transactions

            foreach(length[i]) begin
                env_cfg_h.axi_length.push_back(length[i]);  //pushing the randomized length values to env cfg variable length
                env_cfg_h.ahb_length.push_back(length[i]);  // both axi and ahb should have same length for given transaction
            end

            env_cfg_h.has_axi_agent = has_axi_agent;
            env_cfg_h.has_ahb_agent=has_ahb_agent;
            env_cfg_h.has_axi_rst_agent = has_axi_rst_agent;
            env_cfg_h.has_ahb_rst_agent=has_ahb_rst_agent;

            env_cfg_h.no_of_duts=no_of_duts;

            env_cfg_h.has_scoreboard=has_scoreboard;

            uvm_config_db#(env_cfg)::set(this,"*", "env_cfg", env_cfg_h);

        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                env_cfg_h = env_cfg::type_id::create("env_cfg_h");
                config_create();
                config_set();
                envh = env::type_id::create("envh",this);
        endfunction

        function void end_of_elaboration_phase(uvm_phase phase);
                uvm_top.print_topology();
        endfunction

endclass




module top;
  bit clk;

  always #5 clk=~clk;

    axi_if axi_if_inst(clk);
    ahb_if ahb_if_inst(clk);
    axi_rst_if axi_rst_if_inst(clk);
    ahb_rst_if ahb_rst_if_inst(clk);

        initial begin
                uvm_config_db#(virtual axi_if)::set(null, "*", "vif", axi_if_inst);
                uvm_config_db#(virtual ahb_if)::set(null, "*", "vif", ahb_if_inst);
                uvm_config_db#(virtual axi_rst_if)::set(null, "*", "vif", axi_rst_if_inst);
                uvm_config_db#(virtual ahb_rst_if)::set(null, "*", "vif", ahb_rst_if_inst);
                run_test("test");
        end
endmodule

// if more than 1 dut then setting and getting will not be proper
// parameterise drv seqr seq
// include modport for the drv mon virtual interface
//axi_master_agent_top
//ahb_slave_agent_top




class test extends uvm_test;
        `uvm_component_utils(test)


         env envh;
        axi_rst_cfg  axi_rst_cfg_h[];
        axi_cfg axi_cfg_h[];
        ahb_rst_cfg ahb_rst_cfg_h[];
        ahb_cfg ahb_cfg_h[];
        env_cfg  env_cfg_h;

        bit has_axi_agent = 1;
        bit has_ahb_agent=1;
        bit has_ahb_rst_agent=1;
        bit has_axi_rst_agent = 1;

        int no_of_duts=1;
        axi_seq axi_seq_h;
        ahb_seq ahb_seq_h;
         axi_rst_seq axi_rst_seq_h;
         ahb_rst_seq ahb_rst_seq_h;
        bit  has_scoreboard=1;
        rand int length[];
        int no_of_trans=1;

        constraint length_c {foreach(length[i])
                                 length[i] inside {[1:15]}; }

        `NEW_COMP

        function void config_create();
            if(has_axi_agent)
            begin
                axi_cfg_h = new[no_of_duts];
                env_cfg_h.axi_cfg_h = new[no_of_duts];
                foreach(axi_cfg_h[i])
                    axi_cfg_h[i] = axi_cfg::type_id::create($sformatf("axi_cfg_h[%0d]",i));
            end

            if(has_axi_rst_agent)
            begin
                axi_rst_cfg_h = new[no_of_duts];
                env_cfg_h.axi_rst_cfg_h = new[no_of_duts];
                foreach(axi_rst_cfg_h[i])
                    axi_rst_cfg_h[i] = axi_rst_cfg::type_id::create($sformatf("axi_rst_cfg_h[%0d]",i));
            end

            if(has_ahb_agent)
            begin
                ahb_cfg_h = new[no_of_duts];
                env_cfg_h.ahb_cfg_h = new[no_of_duts];
                foreach(ahb_cfg_h[i])
                    ahb_cfg_h[i] = ahb_cfg::type_id::create($sformatf("ahb_cfg_h[%0d]",i));
            end

            if(has_ahb_rst_agent)
            begin
                ahb_rst_cfg_h = new[no_of_duts];
                env_cfg_h.ahb_rst_cfg_h = new[no_of_duts];
                foreach(ahb_rst_cfg_h[i])
                    ahb_rst_cfg_h[i] = ahb_rst_cfg::type_id::create($sformatf("ahb_rst_cfg_h[%0d]",i));
            end
        endfunction


        function void config_set();
            if(has_axi_agent)
            begin
                foreach(axi_cfg_h[i])  begin
                    if(!uvm_config_db#(virtual axi_if)::get(this,"","vif", axi_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | axi cfg")
                env_cfg_h.axi_cfg_h[i] = axi_cfg_h[i];
                end
            end

            if(has_axi_rst_agent)
            begin

                foreach(axi_rst_cfg_h[i]) begin
                    if(!uvm_config_db#(virtual axi_rst_if)::get(this,"", "vif",axi_rst_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | axi reset cfg")
                    env_cfg_h.axi_rst_cfg_h[i] = axi_rst_cfg_h[i];

                end
            end

            if(has_ahb_agent)
            begin
                foreach(ahb_cfg_h[i]) begin
                    if(!uvm_config_db#(virtual ahb_if)::get(this,"", "vif",ahb_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | ahb cfg")
                    env_cfg_h.ahb_cfg_h[i] = ahb_cfg_h[i];

                end
            end

            if(has_ahb_rst_agent)
            begin
                foreach(ahb_rst_cfg_h[i]) begin
                     if(!uvm_config_db#(virtual ahb_rst_if)::get(this,"", "vif",ahb_rst_cfg_h[i].vif))
                        `uvm_fatal("FATAL", "getting vif failed | ahb reset cfg")
                    env_cfg_h.ahb_rst_cfg_h[i]= ahb_rst_cfg_h[i];

                end
            end
            this.randomize() with {length.size == no_of_trans;}; // randomizing length for all transactions

            foreach(length[i]) begin
                env_cfg_h.axi_length.push_back(length[i]);  //pushing the randomized length values to env cfg variable length
                env_cfg_h.ahb_length.push_back(length[i]);  // both axi and ahb should have same length for given transaction
            end

            env_cfg_h.has_axi_agent = has_axi_agent;
            env_cfg_h.has_ahb_agent=has_ahb_agent;
            env_cfg_h.has_axi_rst_agent = has_axi_rst_agent;
            env_cfg_h.has_ahb_rst_agent=has_ahb_rst_agent;

            env_cfg_h.no_of_duts=no_of_duts;

            env_cfg_h.has_scoreboard=has_scoreboard;

            uvm_config_db#(env_cfg)::set(this,"*", "env_cfg", env_cfg_h);

        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                env_cfg_h = env_cfg::type_id::create("env_cfg_h");
                axi_seq_h = axi_seq :: type_id::create("axi_seq_h");
                ahb_seq_h = ahb_seq :: type_id::create("ahb_seq_h");
                axi_rst_seq_h = axi_rst_seq :: type_id::create("axi_rst_seq_h");
                ahb_rst_seq_h = ahb_rst_seq :: type_id::create("ahb_rst_seq_h");

                config_create();
                config_set();
                envh = env::type_id::create("envh",this);
        endfunction

        function void end_of_elaboration_phase(uvm_phase phase);
                uvm_top.print_topology();
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
                foreach(envh.axi_agent_top_h[i]) begin
                axi_rst_seq_h.start(envh.axi_agent_top_h[i].axi_rst_agent_h.axi_rst_seqr_h);
                ahb_rst_seq_h.start(envh.ahb_agent_top_h[i].ahb_rst_agent_h.ahb_rst_seqr_h);
                axi_seq_h.start(envh.axi_agent_top_h[i].axi_agent_h.axi_seqr_h);
                ahb_seq_h.start(envh.ahb_agent_top_h[i].ahb_agent_h.ahb_seqr_h);
                end
                phase.phase_done.set_drain_time(this,200000);

            phase.drop_objection(this);
        endtask
endclass


