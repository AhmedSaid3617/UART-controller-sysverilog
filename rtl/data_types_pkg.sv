package data_types_pkg;

    // Example typedefs
    typedef logic [7:0]  byte_t;
    typedef logic [15:0] word_t;
    typedef logic [31:0] dword_t;

    typedef enum { IDLE, START, DATA, STOP } state_t;

    typedef struct packed {
        logic        txe;         // Bit 13: Transmit enable (read-only)
        logic        rxe;         // Bit 12: Receive enable (read-only)
        logic [7:0]  br_div;      // Bits 11:3: Baud rate divisor (read/write)
        logic        word;        // Bit 2: Word length (read/write)
        logic        stop;        // Bit 1: Stop bits (read/write)
        logic        en;          // Bit 0: Enable (read/write)
    } ctrl_reg_t;

endpackage : data_types_pkg