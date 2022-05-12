//input-display.hpp

#pragma once
#include <arduino.h>
#include "src/Nintendo/src/Nintendo.h"

#define ASCII_0 '\0'
#define ASCII_1 '1'
#define NEWLINE '\n'

extern char serialDebugData[10];

void writeToUSB_BYTE(Gamecube_Data_t& data);

void writeToUSB_BIT(Gamecube_Report_t& GC_report);

void tryPrint(String input);

void tryPrintln(String input);

void tryPrint(uint8_t input);

void tryPrintln(uint8_t input);

void checkSerialBufferFull();

void serialDebug(char input);
