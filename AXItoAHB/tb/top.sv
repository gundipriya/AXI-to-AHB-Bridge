 module top();
   import uvm_pkg::*;
   import test_pkg::*;
   bit hclock;
   bit aclock;
   logic hgrant=1'b1;
   initial
     begin
       hclock=0;
       forever #8 hclock=~hclock;
     end
   initial
     begin
       aclock=0;
       forever #5 aclock=~aclock;
     end
   axi_if in0(aclock);
   ahb_if in1(hclock);
   axi_rst_if in2(aclock);
   ahb_rst_if in3(hclock);

   axi2ahb_bridge_top DUT(
                                .aclk(aclock),
                                .aresetn(in2.aresetn),
                                .hclk(hclock),
                                .hresetn(in3.hresetn),

        //axi side
        //aw channel
                                .awid(in0.awid),
                                .awaddr(in0.awaddr),
                                .awlen(in0.awlen),
                                .awsize(in0.awsize),
                                .awburst(in0.awburst),
                                .awvalid(in0.awvalid),
                                .awready(in0.awready),
        //w channel
                                .wid(in0.wid),
                                .wdata(in0.wdata),
                                .wstrb(in0.wstrb),
                                .wlast(in0.wlast),
                                .wvalid(in0.wvalid),
                                .wready(in0.wready),
        //ar channel
                                .arid(in0.arid),
                                .araddr(in0.araddr),
                                .arlen(in0.arlen),
                                .arsize(in0.arsize),
                                .arburst(in0.arburst),
                                .arvalid(in0.arvalid),
                                .arready(in0.arready),
        //b response
                                .bid(in0.bid),
                                .bresp(in0.bresp),
                                .bvalid(in0.bvalid),
                                .bready(in0.bready),
        //r response
                                .rid(in0.rid),
                                .rdata(in0.rdata),
                                .rresp(in0.rresp),
                                .rlast(in0.rlast),
                                .rvalid(in0.rvalid),
                                .rready(in0.rready),

        //ahb_side
        //ahb output
                                .haddr(in1.haddr),
                                .htrans(in1.htrans),
                                .hwrite(in1.hwrite),
                                .hsize(in1.hsize),
                                .hburst(in1.hburst),
                                .hwdata(in1.hwdata),
                                .hbusreq(in1.hbusreq),
                                .hlock(in1.hlock),
        //ahb input
                                .hrdata(in1.hrdata),
                                .hready(in1.hready),
                                .hresp(in1.hresp),
                                .hgrant(hgrant),
                                .hmaster(in1.hmaster)
                        );

   initial
     begin
       `ifdef VCS
          $fsdbDumpvars(0,axi2ahb_bridge_tb_top);
       `endif
       uvm_config_db#(virtual axi_if)::set(null,"*","vif",in0);
       uvm_config_db#(virtual ahb_if)::set(null,"*","vif",in1);
       uvm_config_db#(virtual axi_rst_if)::set(null,"*","vif",in2);
       uvm_config_db#(virtual ahb_rst_if)::set(null,"*","vif",in3);
       run_test();
     end
 endmodule
