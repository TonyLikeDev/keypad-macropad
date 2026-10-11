"""Reads key letters (a..p) from the Uno and presses Ctrl+Alt+Shift+<letter>; keypad.ahk turns that into actions.
Run: python bridge.py (shows keys) or pythonw bridge.py (silent). Stop it before uploading a sketch: it holds the COM port."""
import ctypes, time, serial
from serial.tools import list_ports

REPEAT = "hl"  # keys that keep firing while held: S8 volume up (h), S12 volume down (l). Others fire once per press.

user32 = ctypes.windll.user32
CTRL, SHIFT, ALT, KEYUP = 0x11, 0x10, 0x12, 2

def combo(letter):
    vk = ord(letter.upper())  # the VK code of A-Z is its ASCII code
    mods = (CTRL, ALT, SHIFT)
    for k in mods + (vk,): user32.keybd_event(k, 0, 0, 0)
    for k in (vk,) + mods[::-1]: user32.keybd_event(k, 0, KEYUP, 0)

def find_port():
    return next((p.device for p in list_ports.comports() if p.vid == 0x2341), None)  # 0x2341 = Arduino

def main():
    while True:
        port = find_port()
        if not port:
            time.sleep(2)
            continue
        try:
            with serial.Serial(port, 9600) as s:
                while True:
                    c = s.read(1).decode(errors="ignore")
                    if "a" <= c <= "p":  # a fresh press
                        print(c, flush=True)
                        combo(c)
                    elif "A" <= c <= "P" and c.lower() in REPEAT:  # the Uno says the key is still held
                        combo(c)
        except (serial.SerialException, OSError):
            time.sleep(2)  # unplugged or port busy: look again

if __name__ == "__main__":
    main()
