#ifndef HAL_RVPB_UART_H_
#define HAL_RVPB_UART_H_

#include <stdint.h>

typedef union UARTDR_t
{
    uint32_t all; // UARTDR 통합제어
    struct
    {
        uint32_t DATA : 8;      // 7:0
        uint32_t FE : 1;        // 8
        uint32_t PE : 1;        // 9
        uint32_t BE : 1;        // 10
        uint32_t OE : 1;        // 11
        uint32_t reserved : 20; // 31:12
    } bits;

} UARTDR_t;

#endif // HAL_RVPB_UART_H_