class ahb_rst_xtn extends uvm_sequence_item;
     `uvm_object_utils(ahb_rst_xtn)

     rand bit hresetn;
     bit hready;
     logic [1:0] htrans;

     `NEW_OBJ

     function void do_print(uvm_printer printer);
        printer.print_field("hresetn", this.hresetn, 1, UVM_DEC);
     endfunction
 endclass
