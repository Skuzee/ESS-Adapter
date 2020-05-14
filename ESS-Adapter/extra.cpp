//extra.cpp

#include "extra.hpp"


/* void startButtonResets(Gamecube_Data_t& data) { // Resets the program if the Start button is pressed for ~6 seconds.
  static unsigned long timeStamp = millis();

  if (data.report.start) {
    if (millis() - timeStamp > 600) { // If the time since the last press has been 6 seconds, reset.
      blinkLED(3,100);
      // asm volatile ("  jmp 0"); // Soft-reset, Assembly command that jumps to the start of the reset vector.
      digitalWrite(RST_PIN, LOW); // Hard-reset, Pin 4 to RST.
    }
  }
  else {
    timeStamp = millis();
  }
}*/

void analogTriggerToDigitalPress(Gamecube_Data_t& data, int Threshold) { // The following 2 if statments map analog L and R presses to digital presses. The range is 0-255.

  if (data.report.left > Threshold)
    data.report.l = 1;
  if (data.report.right > Threshold)
    data.report.r = 1;

}

/*void blinkLED(int blinks, int blinkTime) { //blink time in Milliseconds, be warned millis() is not accurate becuase of all the interupts so 100mS is ~ 1 second.
#ifdef LED_PIN

  for (blinks; blinks>0; blinks--) {
    digitalWrite(LED_PIN, HIGH);
    delay(blinkTime);
    digitalWrite(LED_PIN, LOW);
    delay(blinkTime);
  }

#endif
}*/
