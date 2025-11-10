class APB_I2C_master_reg_adapter extends uvm_reg_adapter;
   `uvm_object_utils(APB_I2C_master_reg_adapter)
 
   function new(string name = "APB_I2C_master_reg_adapter");
      super.new(name);
      supports_byte_enable = 0;
      provides_responses   = 0;
   endfunction

   virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      apb_sequence_item apb_item = apb_sequence_item::type_id::create("apb_item");
      apb_item.wr = (rw.kind == UVM_READ) ? 1'b0 : 1'b1;
      apb_item.PADDR = rw.addr;
      if(rw.kind == UVM_READ) apb_item.PRDATA = rw.data;
      else apb_item.PWDATA = rw.data;
      return apb_item;      
   endfunction

   virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      apb_sequence_item apb_item ;
      if(!$cast(apb_item, bus_item)) `uvm_fatal("NOT_BUS_TYPE","Provided bus_item is not of the correct type")
      rw.kind = (apb_item.wr  == 1'b0) ? UVM_READ : UVM_WRITE;
      rw.addr = apb_item.PADDR;
      rw.data = (apb_item.wr  == 1'b0) ? apb_item.PRDATA : apb_item.PWDATA;
      rw.status = UVM_IS_OK;
   endfunction

endclass
