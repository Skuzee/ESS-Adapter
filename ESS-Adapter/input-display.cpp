//input-display.cpp

#include "input-display.hpp"
#include "extra.hpp"

void writeToUSB_BYTE(Gamecube_Data_t& data) {
  if (Serial.availableForWrite() >= 10 && settings.input_display_enabled) { // Only write to serial data buffer if it's not full. Disconnecting Arduino Serial Monitor makes serial data buffer fill and halt program; this prevents that.
    noInterrupts(); // Important! Due to how time sensitive our code is, and how the arduino parallel processes serial data (with interrupts), we must allow the data to be written to the serial buffer or it will back up and hault the program. This was causing a hiccup in the timing roughly once every second, resulting in missing controller reads/updates.
    Serial.write(data.report.raw8, sizeof(data.report.raw8));
    Serial.write(NEWLINE);
    interrupts();
  }
}

void writeToUSB_BIT(Gamecube_Report_t &GCreport) { // Sending the data as ASCII would allow for compatibility with old versions of nintendospy. This isn't tested and honestly this is probably too slow to work. 8 times slower than writeToUSB_BYTE. The data sent is 65 bytes long per poll, and the serial buffer is only 64 bytes. If the buffer fills up the program will block until there is room to finish sending the data. ¯\_(ツ)_/¯
  if (Serial.availableForWrite() >= 10 && settings.input_display_enabled) {
    noInterrupts();
    for (uint8_t byteCounter = 0; byteCounter < 8; byteCounter++) {
      for (uint8_t bitCounter = 0; bitCounter < 8; bitCounter++) {
        //Masks off one bit at a time and sends an ascii 1 or 0 to serial console.
        Serial.write(GCreport.raw8[byteCounter] & (0x80 >> bitCounter) ? ASCII_1 : ASCII_0);
      }
    }
    Serial.write(NEWLINE);
    interrupts();
  }
}

void tryPrint(String input) {
  if ( Serial.availableForWrite() > input.length())
    Serial.print(input);
}

void tryPrintln(String input) {
  if ( Serial.availableForWrite() > input.length())
    Serial.println(input);
}

void tryPrint(uint8_t input) {
  if ( Serial.availableForWrite() > 1)
    Serial.print(input);
}

void tryPrintln(uint8_t input) {
  if ( Serial.availableForWrite() > 1)
    Serial.println(input);
}

void checkSerialBufferFull() {
  static uint8_t lastBuffer;

  if (Serial.availableForWrite() == lastBuffer)
    Serial.flush();
  else
    lastBuffer = Serial.availableForWrite();
}

// 0 = 'S' start bit
// 11 = 'E' end bit
// fills bytes 1 to 10, then sends it all.
void serialDebug(uint8_t input) { 
	
	static uint8_t position = 0;
	serialDebugData[position] = input;
	position++;
	
	if (position == 10) {
		position = 0;
		Serial.print('S');
		Serial.print(' ');
		
		for (uint8_t i = 0; i < 10; i++) {
			Serial.print(serialDebugData[i]);
			Serial.print(' ');
		}
		
		Serial.println('E');
	}
}
