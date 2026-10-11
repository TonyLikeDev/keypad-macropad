#include <Arduino.h>
#line 1 "G:\\Github\\keypad-macropad\\keypad\\keypad.ino"
#include <Keypad.h>

// Sends one letter (a..p) over USB serial per key press. bridge.py on the PC turns it into Ctrl+Alt+Shift+letter.
// A key held past 400 ms repeats as the UPPERCASE letter every 200 ms; bridge.py decides which keys honour repeats.
const byte ROWS = 4, COLS = 4;
char keys[ROWS][COLS] = {
  {'a','b','c','d'},
  {'e','f','g','h'},
  {'i','j','k','l'},
  {'m','n','o','p'}
};
byte rowPins[ROWS] = {9, 8, 7, 6};
byte colPins[COLS] = {5, 4, 3, 2};
Keypad pad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

char held = 0;
unsigned long lastSent = 0;

#line 19 "G:\\Github\\keypad-macropad\\keypad\\keypad.ino"
void setup();
#line 24 "G:\\Github\\keypad-macropad\\keypad\\keypad.ino"
void loop();
#line 19 "G:\\Github\\keypad-macropad\\keypad\\keypad.ino"
void setup() {
  Serial.begin(9600);
  pad.setHoldTime(400);  // ms before a pressed key counts as HOLD
}

void loop() {
  char k = pad.getKey();
  if (k) {
    Serial.write(k);
    held = k;
    lastSent = millis();
  } else if (held) {
    KeyState s = pad.getState();
    if (s == HOLD && millis() - lastSent >= 200) {
      Serial.write(held - 32);  // 'a'..'p' -> 'A'..'P'
      lastSent = millis();
    } else if (s == IDLE) {
      held = 0;  // released
    }
  }
}

