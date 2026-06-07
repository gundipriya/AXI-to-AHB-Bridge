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
