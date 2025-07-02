package data_types_pkg;

    // Example typedefs
    typedef logic [7:0]  byte_t;
    typedef logic [15:0] word_t;
    typedef logic [31:0] dword_t;

    typedef enum { IDLE, START, DATA, STOP } state_t;

    typedef struct packed {
        logic        txf;         // Bit 12: Transmit buffer full (read-only)
        logic        rxe;         // Bit 11: Receive buffer empty (read-only)
        logic [7:0]  br_div;      // Bits 10:3: Baud rate divisor (read/write)
        logic        word;        // Bit 2: Word length (read/write)
        logic        stop;        // Bit 1: Stop bits (read/write)
        logic        en;          // Bit 0: Enable (read/write)
    } ctrl_reg_t;

    typedef struct packed {
        logic [7:0]  br_div;      // Bits 10:3: Baud rate divisor (read/write)
        logic        word;        // Bit 2: Word length (read/write)
        logic        stop;        // Bit 1: Stop bits (read/write)
        logic        en;          // Bit 0: Enable (read/write)
    } config_t;

endpackage : data_types_pkg