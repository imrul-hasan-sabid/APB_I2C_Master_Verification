//------------------------------------APB Specification Parameters---------------------------------------

parameter   ADDR_WIDTH              =   32,
parameter   DATA_WIDTH              =   32,

//-------------------------------------------------------------------------------------------------------

//------------------------------Register Specification Parameters---------------------------------

parameter   REG_DATA_WIDTH          =   8,
parameter   MODE_WIDTH              =   2,
parameter   PRESCALER_WIDTH         =   2,
parameter   BIT_RATE_CONST_WIDTH    =   8,
parameter   SLAVE_ADDR_WIDTH        =   8,

//-------------------------------------------------------------------------------------------------------

//---------------------------------Submodules Specification Parameters-----------------------------------

parameter   SCL_GEN_COUNTER_WIDTH   =   16,     // Bit-length of clock generation counter  
parameter   BIT_COUNTER_WIDTH       =   3,      // Bit-length of bit counter
parameter   STATE_WIDTH_MFSM        =   5,      // Bit-length of master mode control fsm state storing variables
parameter   STATE_WIDTH_AFSM        =   2,      // Bit-length of APB transfer control fsm state storing variables

//-------------------------------------------------------------------------------------------------------

parameter   DRIVER_SEL_WIDTH        =   2,
parameter   STATUS_SEL_WIDTH        =   4,
parameter   STATUS_REG_WIDTH        =   8
