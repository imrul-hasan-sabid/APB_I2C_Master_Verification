/* ----------------------------------- APB ---------------------------------- */
parameter       APB_ADDR_WIDTH      = 32, 
                APB_DATA_WIDTH      = 32, 

/* ---------------------------- Register Address ---------------------------- */
                TWBR_ADDR           = 32'h00,
                TWSR_ADDR           = 32'h04,
                TWAR_ADDR           = 32'h08, 
                TWDR_ADDR           = 32'h0c, 
                TWCR_ADDR           = 32'h10, 

/* ----------------------------- Register Width ----------------------------- */
                TWBR_WIDTH          = 8, 
                TWSR_WIDTH          = 8, 
                TWAR_WIDTH          = 8, 
                TWDR_WIDTH          = 8,
                TWCR_WIDTH          = 8, 

/* -------------------------- Register Reset Value -------------------------- */
                TWBR_RESET_VALUE    = 8'b0, 
                TWAR_RESET_VALUE    = 8'b0, 
                TWDR_RESET_VALUE    = 'b0, 
                TWSR_RESET_VALUE    = 8'hF8, 
                TWCR_RESET_VALUE    = 8'b0, 

/* ---------------------- TWCR Register Bit Description --------------------- */
                TWINT               = 7, 
                TWEA                = 6, 
                TWSTA               = 5, 
                TWSTO               = 4, 
                TWWC                = 3, 
                TWEN                = 2, 
                TWIE                = 0, 

/* ---------------------- TWSR Register Bit Description --------------------- */
                TWS_WIDTH           = 5,
                TWPS_WIDTH          = 2, 
                TWPS_START          = 1, 
                TWPS_END            = 0,
                TWS_START           = 7,
                TWS_END             = 3,

/* ---------------------- TWAR Register Bit Description --------------------- */
                TWGCE               = 0, 

/* --------------------  for Bus Interface Unit -------------------- */
                TWDR_MODE_WIDTH     = 2, 
                BIT_COUNTER_WIDTH   = 4




