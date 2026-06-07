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
            $display("got the trans from seq in runphase : AXI RESET DRIVER");
            send_to_dut(req);
            seq_item_port.item_done();
            $display("sent the trans to dut(finished) : AXI RESET DRIVER");
      end
    endtask

    task send_to_dut(axi_rst_xtn req);

        $display("entered send to dut task: AXI RESET DRIVER");
        @(vif.axi_rst_drv_cb);
        vif.axi_rst_drv_cb.aresetn <= req.aresetn;
        @(vif.axi_rst_drv_cb);
        @(vif.axi_rst_drv_cb);
        vif.axi_rst_drv_cb.aresetn <= 1'b1;
        $display("completed send to dut task: AXI RESET DRIVER");
       // @(vif.axi_rst_drv_cb);
       // @(vif.axi_rst_drv_cb);
    endtask

endclass
