class axi_rst_xtn extends uvm_sequence_item;
     `uvm_object_utils(axi_rst_xtn)

    rand bit aresetn;
    logic bvalid;
    logic rvalid;

     `NEW_OBJ

     function void do_print(uvm_printer printer);
        printer.print_field("aresetn", this.aresetn, 1, UVM_DEC);
     endfunction
 endclass
