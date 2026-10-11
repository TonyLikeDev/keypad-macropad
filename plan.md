# Arduino 4x4 Keypad to Custom Macro Keyboard: Plan

## Hardware

- Board: Arduino Uno, original (confirmed, has the ATmega16U2 USB chip, not a CH340 clone)
- Keypad: 4x4 matrix keypad
- Wiring:
  - Row pins to D9, D8, D7, D6
  - Column pins to D5, D4, D3, D2

## Goal

Turn the 4x4 keypad into a custom USB macro keyboard where each key can run a different task (shortcut, app launch, text snippet). Reassigning a key's task later must not require re-flashing the Arduino.

## Approach

Reflash the Uno's ATmega16U2 (the USB chip) with keyboard HID firmware so the board shows up as a real USB keyboard. Each key sends a fixed, rarely used shortcut (Ctrl+Alt+Shift plus a letter). All real task assignment happens on the computer in a hotkey config file, so changing what a key does is just editing text.

## Step 1: Upload the keypad sketch FIRST

Do this while the board still has the stock USB firmware.

```cpp
#include <Keypad.h>

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

uint8_t report[8] = {0};

void sendKey(uint8_t modifier, uint8_t code) {
  report[0] = modifier;
  report[2] = code;
  Serial.write(report, 8);   // key down
  report[0] = 0;
  report[2] = 0;
  Serial.write(report, 8);   // key up
}

void setup() {
  Serial.begin(9600);
}

void loop() {
  char k = pad.getKey();
  if (k) sendKey(0x07, 0x04 + (k - 'a'));  // Ctrl+Alt+Shift + A..P
}
```

Key layout, top-left to bottom-right: A B C D / E F G H / I J K L / M N O P. Each key sends Ctrl+Alt+Shift plus its letter.

Modifier values: 0x01 Left Ctrl, 0x02 Left Shift, 0x04 Left Alt, 0x08 Windows/Cmd key. Add them together for combos (0x07 is Ctrl+Alt+Shift).

Before flashing the keyboard firmware, test the wiring and key order with the Serial Monitor or a small pyserial script. Once the keyboard firmware is installed, Serial Monitor no longer works.

## Step 2: Get the keyboard firmware

- File: `Arduino-keyboard-0.3.hex` by Darran Hunt
- Make sure it targets the ATmega16U2 (used on Uno R3 boards)

## Step 3: Put the ATmega16U2 into DFU mode

- Short RESET and GND on the small 6-pin header next to the USB port with a jumper wire, then release.
- Check the official Arduino DFU guide for the exact pins before shorting anything.

## Step 4: Flash the firmware

Windows: open Atmel FLIP, select ATmega16U2, load the hex, then Erase, Program, Verify.

Linux or Mac:

```
sudo dfu-programmer atmega16u2 erase
sudo dfu-programmer atmega16u2 flash Arduino-keyboard-0.3.hex
sudo dfu-programmer atmega16u2 reset
```

Unplug and replug the board. It should now appear as a USB keyboard.

## Step 5: Revert path (to upload sketches again)

Reflash the stock firmware the same way (DFU mode, then flash) using this file from the Arduino IDE install:

`hardware/arduino/avr/firmwares/atmegaxxu2/arduino-usbserial/Arduino-usbserial-atmega16u2-Uno-Rev3.hex`

## Step 6: Assign tasks to keys on the computer

Each key already sends Ctrl+Alt+Shift plus a letter. Map those combos to actions with an OS-level hotkey tool. Editing this config is how you change what a key does.

### Windows: AutoHotkey v2

Create `keypad.ahk`:

```
^!+a::Run "calc.exe"
^!+b::Send "^c"
^!+c::Send "^v"
^!+d::Send "myemail@example.com"
^!+e::Run "https://www.youtube.com"
```

`^` is Ctrl, `!` is Alt, `+` is Shift. Double-click the file to reload after edits. Put it in the Startup folder to run at login. AutoHotkey can also give different actions per active window.

### Mac

Karabiner-Elements, BetterTouchTool, or the built-in Shortcuts app.

### Linux

`sxhkd` or `xbindkeys`, binding each combo to a shell command in a plain config file.

## Alternative paths (not chosen)

- Serial plus PC script: the Arduino sends plain characters over serial, and a Python script (pyserial and pyautogui) reads them and runs actions from a config file. Simpler and fully reversible, but the script must be running in the background.
- Native-USB board (Pro Micro, Leonardo, or Pico): use `Keyboard.h`, or QMK/VIA/KMK on a Pico. True plug and play, GUI remapping, no PC script, no reflash cycle.

## Open items

- ~~Which OS the task-assignment config should target~~ Windows (AutoHotkey v2).
- ~~Final list of what each of the 16 keys should do~~ First layout set in `keypad.ahk` (row 1 windows, row 2 apps, row 3 editing, row 4 media; see the file for each key). Change any line any time.

## Status and pre-flash findings (2026-10-11)

Steps 2-5 were fact-checked against primary sources. Nothing has been flashed yet; no board was connected.

### Done on the PC
- Step 1: DONE and verified on hardware (Uno on COM3, keypad wired D9-D6 rows / D5-D2 columns). `keypad/keypad.ino` is uploaded and `python check_keys.py COM3` returned all 16 letters a-p in the right order. `diag/` holds a wiring diagnostic (prints which two pins a key connects) for any future wiring doubts. If an upload ever fails with "not in sync", check for wires in D0/D1. Tools now live on G: (`tools\arduino-cli`, `tools\autohotkey`), AutoHotkey v2.0.30 portable.
- Step 2: the original hex hosts (hunt.net.nz, Dropbox) are dead, copies online differ in size, and the 0.3 release was written for the ATmega8U2, so "make sure it targets the 16U2" cannot be checked from a filename. Built from source instead: `harlequin-tech/arduino-usb` commit `0a0cfc77` (Darran Hunt's code, rev 0.3), in `firmwares/arduino-keyboard`: `make MCU=atmega16u2 MCU_AVRDUDE=atmega16u2 MCU_DFU=atmega16u2` with avr-gcc 7.3.0.
  - `firmware/Arduino-keyboard-atmega16u2.hex`: 3826 bytes, ends at 0x0EF1 (DFU bootloader starts at 0x3000). SHA-256 `5694DFD5CA9F42A5343E2B1B21E80552D17FFD2C7290F362A3225D87CF4CC386`.
  - Source confirms 9600 baud 8N1 and that each 8 serial bytes become one HID report unchanged, which matches the sketch.
- Step 5: `firmware/Arduino-usbserial-atmega16u2-Uno-Rev3.hex` is a copy of the stock file (on this PC it lives under `%LOCALAPPDATA%\Arduino15\packages\arduino\hardware\avr\1.8.8\firmwares\atmegaxxu2\arduino-usbserial\`, not the IDE 1.x path above). SHA-256 `A1EF236C428CD57D56E53B401579C64B2E904FB9EFEF5AD665348FE523A4C158`.
- Step 6: `keypad.ahk` (AutoHotkey v2, not installed yet) waits for the pad to release Ctrl+Alt+Shift before sending, because key-up arrives a few ms after key-down.

### Before flashing
1. Upload the sketch, run `check_keys.py`, confirm a b c d / e f g h / i j k l / m n o p.
2. Rehearse on the stock firmware first: enter DFU, confirm the tool sees an ATmega16U2 (USB 03EB:2FEF), flash the stock hex back, confirm the board is still an Uno. Only then flash the keyboard hex.
3. Windows 11 is not on FLIP's supported list. FLIP needs Java and its libusb-win32 driver (from the Flip folder). Fallback: dfu-programmer 1.1.0 plus a WinUSB driver from Zadig, installed only on the DFU device.
4. Re-read Arduino's DFU page in a browser. Short RESET and GND on the 16U2 header by the USB connector, not the 328P ICSP header; identify pins by number.
5. DFU-flash application-only hexes only. The `*COMBINED*` hexes are for ISP recovery and must never go through DFU.
6. If DFU entry is ever lost, recovery needs an ISP programmer (or a second Uno running ArduinoISP) on the 16U2 header.

### Things to know afterwards
- With the keyboard firmware installed, sketches cannot be uploaded over USB; each sketch change is two DFU cycles.
- Pressing two keys at once drops the chord (the Keypad library reports one key).
- AutoHotkey only catches the combos while it is running and not over elevated windows. Without it, the keypad types Ctrl+Alt+Shift+letter into apps.

## Change of plan (2026-10-11): serial bridge instead of reflashing the 16U2

Steps 2-5 (reflash) are shelved. Two attempts to put the 16U2 into DFU mode (RESET+GND on the header by the USB connector, 1 s and 3 s holds) reset the chip (COM3 vanished and returned, Windows played disconnect/reconnect) but it came back as a normal Uno both times; Windows never saw a `03EB:2FEF` device and `dfu-programmer` found nothing. So this board's DFU entry doesn't work (missing or disabled loader). Nothing was written to the board. Reviving the reflash path would need an ISP programmer or a second Arduino (ArduinoISP) on that header, and the original HID sketch, firmware hex and `tools\dfu-programmer` are kept for that (`firmware/`, the sketch is in Step 1 above).

How it works now (the "serial plus PC script" path from the alternatives, but reusing the AutoHotkey file):
- `keypad/keypad.ino` sends one letter a-p over USB serial per key press (replaces the HID-report sketch).
- `bridge.py` reads the letter and presses Ctrl+Alt+Shift+letter (finds the Uno by USB ID, reconnects after unplug).
- `keypad.ahk` maps each combo to an action. **To change what a key does: edit its line in `keypad.ahk`, then run `start_keypad.cmd` again (reloads it). No reflashing.**
- `start_keypad.cmd` starts both; `stop_keypad.cmd` stops both. Stop before uploading a sketch (the bridge holds COM3).
- Verified on hardware: all 16 keys reach the hotkey layer in order. Not yet tested: unplug/replug recovery, running at login.
- Tools are on G: (`tools\arduino-cli`, `tools\autohotkey`, `tools\dfu-programmer`). `.test\` and `diag\` are test helpers.

### Key naming (the user's convention)
The keypad's printed labels are S1-S16 and map to letters in order: S1=a, S2=b ... S16=p, i.e. `^!+a` is S1 and `^!+p` is S16. Rows run across, columns run down, as the user holds it:

| | Col 1 | Col 2 | Col 3 | Col 4 |
|---|---|---|---|---|
| Row 1 | S13 (m) | S9 (i) | S5 (e) | S1 (a) |
| Row 2 | S14 (n) | S10 (j) | S6 (f) | S2 (b) |
| Row 3 | S15 (o) | S11 (k) | S7 (g) | S3 (c) |
| Row 4 | S16 (p) | S12 (l) | S8 (h) | S4 (d) |

Hardware-verified: S1=a (single press), and the four corners S1, S4, S13, S16 gave a, d, m, p. The other 12 positions are inferred from the pattern. (The wiring's own "rows" D9-D6 and "columns" D5-D2 are electrical and don't match this naming.)

### Later changes and findings (2026-10-11, after the pivot)
- `check_keys.py` and the HID-report sketch are gone (bridge path only). `AutoHotkey` is installed portably in `tools\autohotkey` (it was "not installed yet" earlier in this file).
- Upload failure: with the keypad wires attached, uploads failed ("not in sync" / "programmer is not responding"). With the Uno-side wires removed the upload worked, and the wires went back on D9 to D2 without trouble. Cause not proven; a wire on D0 or D1 is the likely one.
- `keypad.ahk` bug caught by validation: `A_LocalAppData` does not exist in AutoHotkey 2.0.30 (it would pop a warning on load). Replaced with `EnvGet("LOCALAPPDATA")`.
- S3 is now `screenshot.ps1`: saves a PNG of the monitor under the mouse and copies it to the clipboard. Tested on a 1920x1080 landscape monitor and a 768x1366 portrait one (image sizes matched), including the full chain bridge -> AutoHotkey -> script, and the clipboard contents.
- Volume keys (S8, S12) repeat while held: the Uno sends an uppercase letter every 200 ms after 400 ms; `REPEAT` in `bridge.py` decides which keys honour it.
- `start_keypad.cmd` now stops old copies first and finds AutoHotkey and Python on other PCs. Not tested: unplug/replug recovery, running at login.
- Project website in `docs/`, GitHub README at the repo root.
