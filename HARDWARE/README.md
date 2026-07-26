# ESP-32 Hardware Node — Smart Life (PPP System Protocol)

This directory contains the firmware code and hardware documentation for the **ESP-32 Smart Home Controller Node** connecting to the **Smart Life** mobile app and **PPP Gateway System**.

---

## 📌 Hardware Pin Mapping (ESP-32)

| ESP-32 Pin | Component / Function | State / Logic | Smart Life App Target |
| :--- | :--- | :--- | :--- |
| **GPIO 0** | BOOT / Reset Button | Press & Hold 5s to Factory Reset | Re-enters Wi-Fi AP Provisioning Mode |
| **GPIO 2** | Status LED | Fast Blink = AP Setup Mode<br>Slow Blink = Wi-Fi Connecting<br>Solid ON = Connected | Connection Status Indicator |
| **GPIO 16** | Relay Channel 1 | Active LOW (LOW = ON) | Main Ceiling Chandelier |
| **GPIO 17** | Relay Channel 2 | Active LOW (LOW = ON) | Ambient LED Strip |
| **GPIO 18** | Relay Channel 3 | Active LOW (LOW = ON) | HVAC AC Compressor |
| **GPIO 19** | Relay Channel 4 | Active LOW (LOW = ON) | Main Entrance Smart Lock / Plug |
| **5V / VIN** | 5V Power Supply | Power Input (5V DC, 2A) | Main Power Rail |
| **GND** | Common Ground | Ground | Shared Ground Rail |

---

## 📶 First-Time Wi-Fi Provisioning Flow

### Method A: Direct Connection via Smart Life Mobile App
1. Power ON the ESP-32 for the first time.
2. The ESP-32 starts an Access Point:
   - **SSID**: `PPP-SmartHome-Setup`
   - **Password**: `12345678`
   - **AP IP**: `192.168.4.1`
3. Open the **Smart Life** mobile application -> Click **"Provision New ESP32 Device"**.
4. Enter your home Wi-Fi SSID and Password.
5. The mobile app sends a POST request to `http://192.168.4.1/api/wifi-setup`.
6. The ESP-32 saves the credentials to non-volatile storage (NVS), reboots into Station Mode, and connects to your home router!

### Method B: Browser Captive Portal
1. Connect your phone or laptop to Wi-Fi network `PPP-SmartHome-Setup` (password: `12345678`).
2. Open your browser and visit: `http://192.168.4.1`
3. Fill in your Home Wi-Fi SSID, Password, and click **"Save & Connect"**.

---

## ⚡ Factory Reset
To erase saved Wi-Fi credentials and return the ESP-32 to Provisioning Mode:
- **Press and hold the BOOT button (GPIO 0) for 5 seconds.**
- The onboard LED will flash rapidly 10 times, clear the NVS storage, and restart in `PPP-SmartHome-Setup` AP mode.

---

## 🛠️ Flashing the Code to ESP-32

1. Open Arduino IDE or VS Code with PlatformIO.
2. Install the **ArduinoJson** library (`v6.x` or `v7.x`).
3. Select Board: **ESP32 Dev Module**.
4. Upload `HARDWARE/PPP_ESP32_Node/PPP_ESP32_Node.ino`.
