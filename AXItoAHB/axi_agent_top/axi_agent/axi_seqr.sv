class axi_seqr extends uvm_sequencer#(axi_xtn);
     `uvm_component_utils(axi_seqr)
     `NEW_COMP

     function void build_phase(uvm_phase phase);
        super.build_phase(phase);

    endfunction
endclass
