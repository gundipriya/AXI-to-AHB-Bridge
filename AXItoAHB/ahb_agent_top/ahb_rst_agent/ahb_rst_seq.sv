class ahb_rst_seq_base extends uvm_sequence#(ahb_rst_xtn);
    `uvm_object_utils(ahb_rst_seq_base)
    `NEW_OBJ
endclass

class ahb_rst_seq extends ahb_rst_seq_base;
    `uvm_object_utils(ahb_rst_seq)
    `NEW_OBJ

    task body();
        req = ahb_rst_xtn::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {hresetn == 1'b0;});
        finish_item(req);
    endtask
endclass
