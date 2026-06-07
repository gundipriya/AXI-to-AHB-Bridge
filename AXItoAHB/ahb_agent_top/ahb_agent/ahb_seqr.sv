class ahb_seqr extends uvm_sequencer#(ahb_xtn);
     `uvm_component_utils(ahb_seqr)
     `NEW_COMP


     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
endclass
