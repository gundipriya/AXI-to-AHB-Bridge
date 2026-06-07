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
                foreach(axi_agent_top_h[i])  begin
                    uvm_config_db#(axi_cfg)::set(this,"*","axi_cfg",env_cfg_h.axi_cfg_h[i]);
                    uvm_config_db#(axi_rst_cfg)::set(this,"*","axi_rst_cfg",env_cfg_h.axi_rst_cfg_h[i]);
                    axi_agent_top_h[i] = axi_agent_top::type_id::create($sformatf("axi_agent_top_h[%0d]",i),this);
                end
                end

                if(env_cfg_h.has_ahb_agent) begin
                foreach(ahb_agent_top_h[i]) begin
                    uvm_config_db#(ahb_cfg)::set(this,"*","ahb_cfg",env_cfg_h.ahb_cfg_h[i]);
                    uvm_config_db#(ahb_rst_cfg)::set(this,"*","ahb_rst_cfg",env_cfg_h.ahb_rst_cfg_h[i]);
                    ahb_agent_top_h[i] = ahb_agent_top::type_id::create($sformatf("ahb_agent_top_h[%0d]",i),this);
                end

                end

                if(env_cfg_h.has_scoreboard) begin
                foreach(sbh[i])
                    sbh[i] = sb::type_id::create($sformatf("sbh[%0d]",i), this);
                end
            end
    endfunction

    function void connect_phase(uvm_phase phase);
            foreach(axi_agent_top_h[i]) begin
            axi_agent_top_h[i].axi_agent_h. axi_mon_h.axi_mon_port.connect(sbh[i].fifo_axi_h.analysis_export);
            axi_agent_top_h[i].axi_agent_h. axi_mon_h.axi_wr_mon_port.connect(sbh[i].fifo_axi_wdata_h.analysis_export);
            axi_agent_top_h[i].axi_agent_h. axi_mon_h.axi_rd_mon_port.connect(sbh[i].fifo_axi_rdata_h.analysis_export);
            axi_agent_top_h[i].axi_rst_agent_h.axi_rst_mon_h.rst_mon_port.connect(sbh[i].fifo_axi_rst_h.analysis_export);
            end

            foreach(ahb_agent_top_h[i]) begin
                ahb_agent_top_h[i].ahb_agent_h.ahb_mon_h.ahb_mon_port.connect(sbh[i].fifo_ahb_h.analysis_export);
                ahb_agent_top_h[i].ahb_rst_agent_h.ahb_rst_mon_h.rst_mon_port.connect(sbh[i].fifo_ahb_rst_h.analysis_export);
            end
    endfunction
endclass
