interface APB_I2C_master_interface(input logic PCLK);

    logic                            TM;
    logic                            SE;
//  inputs
    logic                            PRESETN;                 
    logic [32-1:0]                   PADDR;                  
    logic [32-1:0]                   PWDATA;                
    logic                            PWRITE;                   
    logic                            PSEL;                     
    logic                            PENABLE;                   
    logic                            scl_pad_i;          // SCL input signal from pad
    logic                            sda_pad_i;          // SDA input signal from pad

//  outputs
    logic                            PREADY;             //  output
    logic [32-1:0]                   PRDATA;             //  output     
    logic                            scl_pad_o;          // SCL output signal to pad
    logic                            scl_pad_oe;         // SCL output enable signal for the pad
    logic                            sda_pad_o;          // SDA output signal to pad
    logic                            sda_pad_oe;         // SDA output enable signal for the pad
    logic                            interrupt_pad_o;     // Interrupt signal for notifying the software

// slave I/O pins
    logic                            slv_scl_pad_o  = 0;          // SCL output signal to pad
    logic                            slv_scl_pad_oe = 0;         // SCL output enable signal for the pad
    logic                            slv_sda_pad_o  = 0;          // SDA output signal to pad
    logic                            slv_sda_pad_oe = 0;         // SDA output enable signal for the pad

    logic                            interrupt_pad_o_a;

// TWI
    wand                             SCL;
    wand                             SDA;

    assign SCL = scl_pad_oe === 1'b1 ? scl_pad_o : 1;
    assign SCL = slv_scl_pad_oe === 1'b1 ? slv_scl_pad_o : 1;

    assign SDA = sda_pad_oe === 1'b1 ? sda_pad_o : 1;
    assign SDA = slv_sda_pad_oe === 1'b1 ? slv_sda_pad_o:1;

    
endinterface
