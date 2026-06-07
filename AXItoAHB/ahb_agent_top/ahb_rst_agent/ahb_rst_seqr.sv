class ahb_rst_seqr extends uvm_sequencer#(ahb_rst_xtn);
     `uvm_component_utils(ahb_rst_seqr)
     `NEW_COMP

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
endclass
