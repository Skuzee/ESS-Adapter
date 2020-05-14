////input-display.cpp

#include "input-display.hpp"

void writeToUSB_BYTE(Gamecube_Data_t& data) {

	Serial.write(data.report.raw8, sizeof(data.report.raw8));
  Serial.write(NEWLINE);
}


void writeToUSB_BIT(Gamecube_Report_t &GC_report) {

  for (uint8_t byteCounter = 0; byteCounter < 8; byteCounter++) {

    for (uint8_t bitCounter = 0; bitCounter < 8; bitCounter++) {
      //Masks off one bit at a time and sends an ascii 1 or 0 to serial console.
      Serial.write(GC_report.raw8[byteCounter]&(0x80>>bitCounter) ? ASCII_1 : ASCII_0);
    }
  }
  Serial.write(NEWLINE);
}
