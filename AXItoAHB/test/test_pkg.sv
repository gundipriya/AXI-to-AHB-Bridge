package test_pkg;
        import uvm_pkg::*;
        `include "uvm_macros.svh"


        `define NEW_OBJ \
        function new(string name="");   \
                super.new(name);        \
        endfunction

        `define NEW_COMP        \
        function new(string name="",uvm_component parent);      \
                super.new(name,parent); \
        endfunction

        `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_cfg.sv"
        `include "../axi_agent_top/axi_rst_agent/axi_rst_cfg.sv"
        `include "../ahb_agent_top/ahb_agent/ahb_cfg.sv"
        `include "../axi_agent_top/axi_agent/axi_cfg.sv"
        `include "../tb/env_cfg.sv"

        `include "../axi_agent_top/axi_rst_agent/axi_rst_xtn.sv"
        `include "../axi_agent_top/axi_rst_agent/axi_rst_seq.sv"
        `include "../axi_agent_top/axi_rst_agent/axi_rst_seqr.sv"
        `include "../axi_agent_top/axi_rst_agent/axi_rst_drv.sv"
        `include "../axi_agent_top/axi_rst_agent/axi_rst_mon.sv"
        `include "../axi_agent_top/axi_rst_agent/axi_rst_agent.sv"

        `include "../axi_agent_top/axi_agent/axi_xtn.sv"
        `include "../axi_agent_top/axi_agent/axi_seq.sv"
        `include "../axi_agent_top/axi_agent/axi_seqr.sv"
        `include "../axi_agent_top/axi_agent/axi_drv.sv"
        `include "../axi_agent_top/axi_agent/axi_mon.sv"
        `include "../axi_agent_top/axi_agent/axi_agent.sv"

        `include "../axi_agent_top/axi_agent_top.sv"


        `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_xtn.sv"
        `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_seq.sv"
        `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_seqr.sv"
        `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_drv.sv"
        `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_mon.sv"
        `include "../ahb_agent_top/ahb_rst_agent/ahb_rst_agent.sv"

        `include "../ahb_agent_top/ahb_agent/ahb_xtn.sv"
        `include "../ahb_agent_top/ahb_agent/ahb_seq.sv"
        `include "../ahb_agent_top/ahb_agent/ahb_seqr.sv"
        `include "../ahb_agent_top/ahb_agent/ahb_drv.sv"
        `include "../ahb_agent_top/ahb_agent/ahb_mon.sv"
        `include "../ahb_agent_top/ahb_agent/ahb_agent.sv"

        `include "../ahb_agent_top/ahb_agent_top.sv"

        `include "../tb/sb.sv"
        `include "../tb/env.sv"

        `include "../test/test.sv"
endpackage
