#ifndef HAL_HALUART_H_
#define HAL_HALUART_H_

#include <stdint.h>

void Hal_uart_init();
void Hal_uart_put_char(uint8_t ch);

#endif // HAL_HALUART_H_
