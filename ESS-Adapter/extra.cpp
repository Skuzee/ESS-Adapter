//extra.cpp

#include "extra.hpp"
#include "input-display.hpp"
#include <EEPROM.h>

EEPROM_settings settings;

void softReset() {
  asm volatile ("  jmp 0"); // Soft-reset, Assembly command that jumps to the start of the reset vector.
}

void analogTriggerToDigitalPress(Gamecube_Report_t& GCreport, uint8_t Threshold) { // Maps analog L and R presses to digital presses. Range of sensitivity from 0 to 255. 0 being most sensitive. My controller has a range of ~30 to 240.
  if (GCreport.left > Threshold)
    GCreport.l = 1;
  if (GCreport.right > Threshold)
    GCreport.r = 1;
}

uint8_t enterSettingsMenuN64Controller(const N64_Report_t& N64report) {
  if (N64report.l && N64report.r && N64report.cup && N64report.cdown && N64report.cright && N64report.cleft)
    return 1;
  else
    return 0;
}

uint8_t changeSettings(Gamecube_Report_t& GCreport) { // read the initial buttons of the controller and set EEPROM accordingly.
  IndicatorLights(1, settings.game_selection);
  IndicatorLights(2, settings.ess_map);

  if (GCreport.l && GCreport.r) {
    if (GCreport.z) { // Press Z to reset settings to default.
      EEPROM.update(0, !EEPROM.read(0));
      tryPrintln(".");
      tryPrintln(EEPROM.read(0) ? "Restore Factory Settings. Z to undo." : "Reset Cancelled.");
      delay(500);
    }

    if (GCreport.dright || GCreport.dleft) { // Cycle n64 game button maps
      settings.game_selection += GCreport.dright - GCreport.dleft + 3;
      settings.game_selection %= 3;
      tryPrintln("");

      switch (settings.game_selection) {
        case GAME_OOT:
          tryPrintln("OOT.");
          settings.ess_map = ESS_ON;
          break;

        case GAME_YOSHI:
          tryPrintln("Yoshi Story.");
          settings.ess_map = ESS_ON;
          break;

        case GAME_GENERIC:
          tryPrintln("Generic");
          settings.ess_map = ESS_OFF;
          break;
      }
      delay(500);
    }

    if (GCreport.dup) { // ESS on
      settings.ess_map = ESS_ON;
      tryPrintln("");

      switch (settings.ess_map) {
        case ESS_OFF:
          tryPrintln("ESS: OFF.");
          break;

        case ESS_ON:
          tryPrintln("ESS: ON.");
          break;
      }
      delay(500);
    }

    if (GCreport.ddown) { // ESS off
      settings.ess_map = ESS_OFF;
      tryPrintln("");

      switch (settings.ess_map) {
        case ESS_OFF:
          tryPrintln("ESS: OFF.");
          break;
          
        case ESS_ON:
          tryPrintln("ESS: ON.");
          break;
      }
      delay(500);
    }

    if (GCreport.a) { // Input Display Toggle.
      settings.input_display_enabled = !settings.input_display_enabled;
      tryPrintln("");
      tryPrint("Input Display: ");
      tryPrintln(settings.input_display_enabled ? "ON" : "OFF");
      delay(500);
    }
    tryPrint(".");
    delay(50);

    return 1; //if settings are being changed, continue to loop.
  }
  else {
    EEPROM.put(1, settings); // store any changed settings.
    tryPrintln("");
    tryPrintln("Changes Saved.");
    loadSettings(); // check to see if eeprom was factory reset.

    return 0; // return 0, read controller normally now.
  }
}

void loadSettings() {
  if (EEPROM.read(0)) { // if EEPROM (position 0) == 1, write default settings to EEPROM and 'lock' EEPROM by setting position 0 to 0.
    settings = {INPUT_DISPLAY_ON, GAME_OOT, ESS_ON, 1};
    EEPROM.put(1, settings);
    EEPROM.update(0, 0);
    delay(2000);
    tryPrintln("");
    tryPrintln("Saved to EEPROM");
  }
  else {
    EEPROM.get(1, settings);
  }
  printSetting();
}

void printSetting() {
  tryPrint("Input Display: ");
  tryPrintln(settings.input_display_enabled ? "ON" : "OFF");
  tryPrint("ESS: ");
  
  switch (settings.ess_map) {
    case ESS_OFF:
      tryPrintln("OFF");
      break;

    case ESS_ON:
      tryPrintln("ON");
      break;
  }
  tryPrint("Game : ");
  
  switch (settings.game_selection) {
    case GAME_OOT:
      tryPrintln("OOT");
      break;

    case GAME_YOSHI:
      tryPrintln("Yoshi Story");
      break;

    case GAME_GENERIC:
      tryPrintln("Generic");
      break;
  }
}

void initializeDebug() {
  pinMode(DEBUG_READ, OUTPUT);
  pinMode(DEBUG_ESS, OUTPUT);
  pinMode(DEBUG_INPUT, OUTPUT);
  pinMode(DEBUG_WRITE, OUTPUT);
}

void initilizeStatusLights() {
  pinMode(LED1_PIN_R, OUTPUT);
  pinMode(LED1_PIN_G, OUTPUT);
  pinMode(LED1_PIN_B, OUTPUT);
  pinMode(LED2_PIN_R, OUTPUT);
  pinMode(LED2_PIN_G, OUTPUT);
  pinMode(LED2_PIN_B, OUTPUT);

  IndicatorLights(1, settings.game_selection);
  IndicatorLights(2, settings.ess_map);

}

// Red = 0, Green = 1, Blue = 2
void IndicatorLights(uint8_t LEDNumber, uint8_t LEDcolor) {
  if (LEDNumber == 1) { // Set LED for Game.
    digitalWrite(LED1_PIN_R, LED_OFF);
    digitalWrite(LED1_PIN_G, LED_OFF);
    digitalWrite(LED1_PIN_B, LED_OFF);

    switch (LEDcolor) {
      case GAME_OOT:
        digitalWrite(LED1_PIN_R, LED_ON);
        break;

      case GAME_YOSHI:
        digitalWrite(LED1_PIN_G, LED_ON);
        break;

      case GAME_GENERIC:
        digitalWrite(LED1_PIN_B, LED_ON);
        break;
    }
  } else if (LEDNumber == 2) { // Set LED for ESS setting.
    digitalWrite(LED2_PIN_R, LED_OFF);
    digitalWrite(LED2_PIN_G, LED_OFF);
    digitalWrite(LED2_PIN_B, LED_OFF);

    switch (LEDcolor) {
      case GAME_OOT:
        digitalWrite(LED2_PIN_R, LED_ON);
        break;

      case GAME_YOSHI:
        digitalWrite(LED2_PIN_G, LED_ON);
        break;

      case GAME_GENERIC:
        digitalWrite(LED2_PIN_B, LED_ON);
        break;
    }
  } else {
    digitalWrite(LED1_PIN_R, LED_OFF);
    digitalWrite(LED1_PIN_G, LED_OFF);
    digitalWrite(LED1_PIN_B, LED_OFF);
    digitalWrite(LED2_PIN_R, LED_OFF);
    digitalWrite(LED2_PIN_G, LED_OFF);
    digitalWrite(LED2_PIN_B, LED_OFF);
  }
}
