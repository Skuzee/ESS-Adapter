//input-display.hpp

#pragma once
#include <arduino.h>
#include "src/Nintendo/src/Nintendo.h"

#define ASCII_0 '\0'
#define ASCII_1 '1'
#define NEWLINE '\n'

void writeToUSB_BYTE(Gamecube_Data_t& data);

void writeToUSB_BYTE(N64_Report_t& report);

void writeToUSB_BIT(Gamecube_Report_t& GC_report);

void tryPrint(String input);

void tryPrintln(String input);

void tryPrint(uint8_t input);

void tryPrintln(uint8_t input);

void checkSerialBufferFull();
