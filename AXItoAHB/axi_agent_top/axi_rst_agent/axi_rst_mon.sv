class axi_rst_mon extends uvm_monitor;
     `uvm_component_utils(axi_rst_mon)
    axi_rst_cfg axi_rst_cfg_h;
    virtual axi_rst_if.AXI_RST_MON_MP vif;
    virtual axi_if.AXI_MON_MP avif;
    axi_cfg axi_cfg_h;
    axi_rst_xtn req;

     uvm_analysis_port#(axi_rst_xtn) rst_mon_port;
    function new(string name = "",uvm_component parent);
      super.new(name,parent);
      rst_mon_port = new("rst_mon_port",this);
    endfunction
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
