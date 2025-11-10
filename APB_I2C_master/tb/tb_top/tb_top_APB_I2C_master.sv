`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::*;

module tb_top_APB_I2C_master;

bit clk;

always begin
    clk = 0;
    #79;
    clk = 1;
    #79;
end

APB_I2C_master_interface intf(clk);
APB_I2C_master_interface intf_a(clk);

/*
twi DUT(
    .pclk               (intf.PCLK),
    .presetn            (intf.PRESETN),
    .psel               (intf.PSEL),
    .pwrite             (intf.PWRITE),
    .penable            (intf.PENABLE),
    .paddr              (intf.PADDR),
    .pwdata             (intf.PWDATA),
    .scl_in             (intf.SCL),
    .sda_in             (intf.SDA),	
    //-------------------------output ports-----------------------------
    .pready             (intf.PREADY),
    .prdata             (intf.PRDATA),
    .scl_out            (intf.scl_pad_o),
    .scl_out_en         (intf.scl_pad_oe),
    .sda_out            (intf.sda_pad_o),
    .sda_out_en         (intf.sda_pad_oe),
    .interrupt          (intf.interrupt_pad_o),
    .TM                 (intf.TM), 
    .SE                 (intf.SE)
);
*/

top DUT(
    .pclk               (intf.PCLK),
    .presetn            (intf.PRESETN),
    .psel               (intf.PSEL),
    .pwrite             (intf.PWRITE),
    .penable            (intf.PENABLE),
    .paddr              (intf.PADDR),
    .pwdata             (intf.PWDATA),
    .scl_pad_i          (intf.SCL),
    .sda_pad_i          (intf.SDA),	
    //-------------------------output ports-----------------------------
    .pready             (intf.PREADY),
    .prdata             (intf.PRDATA),
    .scl_pad_o          (intf.scl_pad_o),
    .scl_pad_oe         (intf.scl_pad_oe),
    .sda_pad_o          (intf.sda_pad_o),
    .sda_pad_oe         (intf.sda_pad_oe),
    .interrupt_pad_o    (intf.interrupt_pad_o)
);

top DUT_a(
    .pclk               (intf_a.PCLK),
    .presetn            (intf_a.PRESETN),
    .psel               (intf_a.PSEL),
    .pwrite             (intf_a.PWRITE),
    .penable            (intf_a.PENABLE),
    .paddr              (intf_a.PADDR),
    .pwdata             (intf_a.PWDATA),
    .scl_pad_i          (intf.SCL),
    .sda_pad_i          (intf.SDA),	
    //-----------------------_a--output ports-----------------------------
    .pready             (intf_a.PREADY),
    .prdata             (intf_a.PRDATA),
    .scl_pad_o          (intf_a.scl_pad_o),
    .scl_pad_oe         (intf_a.scl_pad_oe),
    .sda_pad_o          (intf_a.sda_pad_o),
    .sda_pad_oe         (intf_a.sda_pad_oe),
    .interrupt_pad_o    (intf.interrupt_pad_o_a)
);

assign intf.SCL = intf_a.scl_pad_oe === 1'b1 ? intf_a.scl_pad_o : 1;
assign intf.SDA = intf_a.sda_pad_oe === 1'b1 ? intf_a.sda_pad_o : 1;

initial begin
    uvm_config_db#(virtual APB_I2C_master_interface)::set(null,"uvm_test_top.env.I2C_agnt","vif",intf);
    uvm_config_db#(virtual APB_I2C_master_interface)::set(null,"uvm_test_top.env.APB_agnt","vif",intf);
    uvm_config_db#(virtual APB_I2C_master_interface)::set(null,"uvm_test_top.env.APB_agnt_a","vif",intf_a);
    run_test("");
end

//=====================================
//==============Assertion==============
//=====================================
wire sda, scl;
logic notifier=0; 
assign sda = intf.SDA;
assign scl = intf.SCL;

specify
  specparam tSU_STA = 0.6e-6;
  specparam tHD_STA = 0.6e-6;
  specparam tSU_DAT = 100e-9;
  specparam tHD_DAT = 0.0;
  $setuphold(negedge sda &&& (scl==1), scl, tSU_STA, tHD_STA, notifier); // $setuphold(reference_event, data_event, setup_limit, hold_limit);
  $setuphold(posedge sda &&& (scl==1), scl, tSU_STA, tHD_STA, notifier); // $setuphold(reference_event, data_event, setup_limit, hold_limit);
  $setup(sda , posedge scl, tSU_DAT, notifier);                          // $setu(data_event, reference_event, setup_limit);
  $hold(sda , negedge scl, tHD_DAT, notifier);                           // $hold(data_event, reference_event, hold_limit);
endspecify

bit prv_sda;
bit prv_scl;
bit busy;
logic [7:0] sda_data;
int count_cycle=0;
bit first_byte;
bit wr;

always@(negedge intf.PCLK) begin
    if(intf.PRESETN) begin
        if(intf.SCL && (prv_sda !== intf.SDA) && prv_scl) begin
           if(prv_sda && !intf.SDA) begin
               busy = 1;
               first_byte = 1;
               wr = 0;
           end
           else if(!prv_sda && intf.SDA) begin
               busy = 0;
           end
           count_cycle = 0;
           sda_data    = 0;
        end
        if(intf.interrupt_pad_o) begin
           count_cycle = 0;
           sda_data    = 0;                
        end
        prv_sda = intf.SDA;
        prv_scl = intf.SCL;
    end    
    else begin
        prv_sda     = 0;
        prv_scl     = 0;
        busy        = 0;
        first_byte  = 0;
        count_cycle = 0;
        sda_data    = 0;
        wr          = 0;
    end
end


always@(posedge intf.SCL) begin
    @(posedge intf.PCLK);
    if(intf.SCL) count_cycle ++;
    
    if(count_cycle != 9) begin
        sda_data = sda_data << 1;
        sda_data[0] = intf.SDA;
    end
    if(count_cycle == 8) begin
        if(first_byte) wr = sda_data[0];
    end
    if(count_cycle == 9) begin
        first_byte  = 0;
    end
end

wire assert_disable;

`ifdef assert_on
assign assert_disable = !intf.PRESETN;
`else
assign assert_disable = 1 ;
`endif

default disable iff(assert_disable);

property unknown_check(valid, signal);
    @(posedge intf.PCLK) valid |-> !$isunknown(signal);
endproperty

property APB_I2C_next_cycle_signal_check(valid, signal);
    @(posedge intf.PCLK) valid |=> signal;
endproperty

property stability_check(valid, signal, ready);
    @(posedge intf.PCLK) valid |=> $stable(signal) until_with ready;
endproperty

property APB_I2C_M_TWSTA_TWSTO(pwdata, sda);
    @(posedge intf.PCLK) intf.PSEL && intf.PENABLE && intf.PREADY && intf.PWRITE && intf.PADDR==0 && intf.PWDATA[2] && pwdata |=> ##[0:$] intf.SCL ##0 intf.SCL until_with sda ##1 intf.SCL[*6];
endproperty

property APB_I2C_M_TWSTA_with_TWSTO(pwdata);
    @(posedge intf.PCLK) intf.PSEL && intf.PENABLE && intf.PREADY && intf.PWRITE && intf.PADDR==0 && intf.PWDATA[2] && pwdata |=> ##[0:$] intf.SCL ##1 $stable(intf.SCL) until_with ($rose(intf.SDA) ##[0:$] $fell(intf.SDA)) ##1 intf.SCL[*6];
endproperty

property APB_I2C_M_interrupt_pad_o_deassert(pwdata, intp);
    @(posedge intf.PCLK) intf.PSEL && intf.PENABLE && intf.PREADY && intf.PWRITE && intf.PADDR==0 && intf.PWDATA[2] && pwdata |=> $fell(intp);
endproperty

property APB_I2C_M_interrupt_pad_o_assert_after_S(pwdata);
    @(posedge intf.PCLK) intf.PSEL && intf.PENABLE && intf.PREADY && intf.PWRITE && intf.PADDR==0 && intf.PWDATA[2] && pwdata |=> ##[0:$] $fell(intf.SCL) ##2 $rose(intf.interrupt_pad_o);
endproperty

property APB_I2C_M_interrupt_pad_o_assert_EOT;
    @(posedge intf.PCLK) !intf.interrupt_pad_o && count_cycle==9 |=> ##[0:$] $fell(intf.SCL) ##2 $rose(intf.interrupt_pad_o);
endproperty

property APB_I2C_M_TWEA(pwdata, ack);
    @(posedge intf.PCLK) intf.PSEL && intf.PENABLE && intf.PREADY && intf.PWRITE && intf.PADDR==0 && intf.PWDATA[2] && wr==1 && first_byte==0 && pwdata|=> ##[0:$] count_cycle==9 ##0 (intf.SDA == !ack);
endproperty

property APB_I2C_M_interrupt_pad_o_low_stable_TWSTA_TWSTO(pwdata, signal);
    @(posedge intf.PCLK) intf.PSEL && intf.PENABLE && intf.PREADY && intf.PWRITE && intf.PADDR==0 && intf.PWDATA[2] && pwdata |=> !intf.interrupt_pad_o ##1 $stable(intf.interrupt_pad_o) until signal;
endproperty

assert_APB_I2C_M_TWSTA: assert property(APB_I2C_M_TWSTA_TWSTO(intf.PWDATA[7] && !intf.PWDATA[4] && intf.PWDATA[5], $fell(intf.SDA)));
assert_APB_I2C_M_TWSTO: assert property(APB_I2C_M_TWSTA_TWSTO(intf.PWDATA[7] && intf.PWDATA[4] && !intf.PWDATA[5], $rose(intf.SDA)));
assert_APB_I2C_M_TWSTA_with_TWSTO: assert property(APB_I2C_M_TWSTA_with_TWSTO(intf.PWDATA[7] && intf.PWDATA[5] && intf.PWDATA[4]));
assert_APB_I2C_M_interrupt_pad_o_deassert: assert property(APB_I2C_M_interrupt_pad_o_deassert(intf.PWDATA[7] && intf.interrupt_pad_o, intf.interrupt_pad_o));
assert_APB_I2C_M_interrupt_pad_o_assert_after_S: assert property(APB_I2C_M_interrupt_pad_o_assert_after_S(intf.PWDATA[7] && intf.PWDATA[5] && !intf.PWDATA[4]));
assert_APB_I2C_M_interrupt_pad_o_assert_EOT: assert property(APB_I2C_M_interrupt_pad_o_assert_EOT);
assert_APB_I2C_M_TWEA: assert property(APB_I2C_M_TWEA(intf.PWDATA[7] && intf.PWDATA[6] && !intf.PWDATA[5] && !intf.PWDATA[4], intf.PWDATA[6]));
assert_APB_I2C_M_interrupt_pad_o_low_stable_TWSTA: assert property(APB_I2C_M_interrupt_pad_o_low_stable_TWSTA_TWSTO(intf.PWDATA[7] && !intf.PWDATA[4] && intf.PWDATA[5], $fell(intf.SCL)));
assert_APB_I2C_M_interrupt_pad_o_low_stable_TWSTO: assert property(APB_I2C_M_interrupt_pad_o_low_stable_TWSTA_TWSTO(intf.PWDATA[7] && intf.PWDATA[4] && !intf.PWDATA[5], $fell(intf.SCL)));
assert_APB_I2C_M_interrupt_pad_o_low_stable_TWSTA_with_TWSTO: assert property(APB_I2C_M_interrupt_pad_o_low_stable_TWSTA_TWSTO(intf.PWDATA[7] && intf.PWDATA[4] && intf.PWDATA[5], $fell(intf.SCL)));
assert_APB_I2C_M_interrupt_pad_o_low_stable_till_EOT: assert property(APB_I2C_M_interrupt_pad_o_low_stable_TWSTA_TWSTO(intf.PWDATA[7] && intf.PWDATA[5:4]==0, count_cycle==9 && $fell(intf.SCL)));
assert_APB_I2C_M_interrupt_pad_o_unknown: assert property(unknown_check(intf.PRESETN, intf.interrupt_pad_o));
assert_APB_I2C_M_scl_pad_o_unknown: assert property(unknown_check(intf.PRESETN, intf.scl_pad_o));
assert_APB_I2C_M_scl_pad_oe_unknown: assert property(unknown_check(intf.PRESETN, intf.scl_pad_oe));
assert_APB_I2C_M_sda_pad_o_unknown: assert property(unknown_check(intf.PRESETN, intf.sda_pad_o));
assert_APB_I2C_M_sda_pad_oe_unknown: assert property(unknown_check(intf.PRESETN, intf.sda_pad_oe));
assert_APB_I2C_M_sda_unknown: assert property(unknown_check(1, intf.SDA));
assert_APB_I2C_M_scl_unknown: assert property(unknown_check(1, intf.SCL));

// Assertions related to APB 
assert_APB_I2C_M_presetn_unknown: assert property(unknown_check(1, intf.PRESETN));
assert_APB_I2C_M_psel_unknown: assert property(unknown_check(intf.PRESETN, intf.PSEL));
assert_APB_I2C_M_penable_unknown: assert property(unknown_check(intf.PSEL, intf.PENABLE));
assert_APB_I2C_M_paddr_unknown: assert property(unknown_check(intf.PSEL, intf.PADDR));
assert_APB_I2C_M_pwrite_unknown: assert property(unknown_check(intf.PSEL, intf.PWRITE));
assert_APB_I2C_M_pwdata_unknown: assert property(unknown_check(intf.PSEL && intf.PWRITE, intf.PWDATA));
assert_APB_I2C_M_pready_unknown: assert property(unknown_check(intf.PSEL && intf.PENABLE, intf.PREADY));
assert_APB_I2C_M_prdata_unknown: assert property(unknown_check(intf.PREADY && !intf.PWRITE, intf.PRDATA));
assert_APB_I2C_M_penable_high: assert property(APB_I2C_next_cycle_signal_check(intf.PSEL && !intf.PENABLE, intf.PENABLE));
assert_APB_I2C_M_penable_low: assert property(APB_I2C_next_cycle_signal_check(intf.PREADY && intf.PENABLE, !intf.PENABLE));
assert_APB_I2C_M_paddr_stable: assert property(stability_check(intf.PSEL && !intf.PENABLE, intf.PADDR, intf.PREADY));
assert_APB_I2C_M_pwrite_stable: assert property(stability_check(intf.PSEL && !intf.PENABLE, intf.PWRITE, intf.PREADY));
assert_APB_I2C_M_pwdata_stable: assert property(stability_check(intf.PSEL && !intf.PENABLE, intf.PWDATA, intf.PREADY));
assert_APB_I2C_M_psel_stable: assert property(stability_check(intf.PSEL && !intf.PENABLE, intf.PSEL, intf.PREADY));

endmodule
