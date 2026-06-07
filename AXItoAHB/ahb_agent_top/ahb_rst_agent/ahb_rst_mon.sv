class ahb_rst_mon extends uvm_monitor;
     `uvm_component_utils(ahb_rst_mon)
    ahb_rst_cfg ahb_rst_cfg_h;
    ahb_cfg ahb_cfg_h;
    ahb_rst_xtn req;

    virtual ahb_rst_if.AHB_RST_MON_MP vif;
    virtual ahb_if.AHB_MON_MP hvif;

    uvm_analysis_port#(ahb_rst_xtn) rst_mon_port;

    function new(string name = "",uvm_component parent);
      super.new(name,parent);
      rst_mon_port = new("rst_mon_port",this);
    endfunction

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
