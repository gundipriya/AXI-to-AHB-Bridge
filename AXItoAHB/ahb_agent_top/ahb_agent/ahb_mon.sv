
class ahb_mon extends uvm_monitor;
     `uvm_component_utils(ahb_mon)
    uvm_analysis_port #(ahb_xtn) ahb_mon_port;

    function new(string name = "ahb_monitor",uvm_component parent);
      super.new(name,parent);
      ahb_mon_port = new("ahb_mon_port",this);
   endfunction


    ahb_cfg ahb_cfg_h;
    virtual ahb_if vif;
    ahb_xtn xtn;



     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(ahb_cfg)::get(this,"*","ahb_cfg",ahb_cfg_h))
            `uvm_fatal("FATAL","cfg failed | ahb_mon")
        vif = ahb_cfg_h.vif;
    endfunction


   task run_phase(uvm_phase phase);
      forever
         collect();
   endtask

   task collect();

        xtn = ahb_xtn::type_id::create("xtn",this);

        begin

            wait((vif.ahb_mon_cb.hready == 1'b1) && (vif.ahb_mon_cb.htrans == 2'b10)); // when htrans is non sequential (bridge initiates the transfer as non seq(single transfer))
                                                                                        // htrans = non seq is valid transfer
            xtn.haddr  = vif.ahb_mon_cb.haddr;
            xtn.htrans = vif.ahb_mon_cb.htrans;
            xtn.hburst = vif.ahb_mon_cb.hburst;
            xtn.hsize  = vif.ahb_mon_cb.hsize;
            xtn.hwrite = vif.ahb_mon_cb.hwrite;
            xtn.hready = vif.ahb_mon_cb.hready;
            xtn.hresp  = vif.ahb_mon_cb.hresp;   // 1st cc addr and control signals

            // 2nd cc data sampling

            if(vif.ahb_mon_cb.hwrite == 1'b1)     //write trans
                begin
                    @(vif.ahb_mon_cb);
                    wait(vif.ahb_mon_cb.hready == 1'b1)
                    xtn.hwdata = vif.ahb_mon_cb.hwdata;
                    ahb_mon_port.write(xtn);
                end

            else
                begin
                    @(vif.ahb_mon_cb);
                    xtn.hrdata = vif.ahb_mon_cb.hrdata; //wait for hready to be high?b
                    ahb_mon_port.write(xtn);
                end

        end

        `uvm_info(get_type_name(),
                    $sformatf("ahb_trans: \n %p",xtn.sprint()),
                    UVM_LOW)

    endtask
endclass
//----------------------------------------------------------------------------