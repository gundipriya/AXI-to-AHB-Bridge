class axi_rst_seq_base extends uvm_sequence#(axi_rst_xtn);
    `uvm_object_utils(axi_rst_seq_base)
    `NEW_OBJ
endclass

class axi_rst_seq extends axi_rst_seq_base;
    `uvm_object_utils(axi_rst_seq)
    `NEW_OBJ

    task body();
        req = axi_rst_xtn::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {aresetn == 1'b0;});
        finish_item(req);
    endtask
endclass
