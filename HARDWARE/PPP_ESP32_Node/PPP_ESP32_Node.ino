/*
 * =================================================================================
 * PPP Smart Home System — ESP32 Hardware Node Firmware
 * Project: Smart Life (PPP System Protocol)
 * Folder: HARDWARE/PPP_ESP32_Node
 * =================================================================================
 * 
 * FEATURES:
 * 1. Smart Wi-Fi Provisioning (First-Time Setup):
 *    - Creates AP "PPP-SmartHome-Setup" (192.168.4.1) if no Wi-Fi credentials saved.
 *    - Captive Portal & REST API (/api/wifi-setup) to receive SSID & Password from mobile app.
 *    - Saves Wi-Fi & PPP Gateway config to NVS (Preferences) persistently.
 * 2. Hardware Control & Visual Feedback:
 *    - 4x Relay Output Channels (Lights, AC, Smart Lock, Plugs).
 *    - Onboard LED Pulse/Flash feedback on EVERY command received.
 *    - Factory Reset Button (Hold GPIO 0 for 5s to clear Wi-Fi & re-enter AP Mode).
 * 3. Serial Monitor Terminal (115200 Baud):
 *    - Real-time formatted command logging printed to Serial Monitor.
 *    - Interactive Serial Terminal: Type '1'..'4' to toggle relays, 'STATUS' for state.
 * =================================================================================
 */

#include <WiFi.h>
#include <WebServer.h>
#include <DNSServer.h>
#include <Preferences.h>
#include <ESPmDNS.h>
#include <ArduinoJson.h>

// --- Pin Definitions ---
#define RESET_BUTTON_PIN  0   // BOOT button on ESP32
#define STATUS_LED_PIN    2   // Onboard LED
#define RELAY_1_PIN       16  // Living Room Light Chandelier
#define RELAY_2_PIN       17  // Ambient LED Strip
#define RELAY_3_PIN       18  // HVAC AC Compressor Relay
#define RELAY_4_PIN       19  // Main Entrance Lock / Plug

// --- NVS Storage Key ---
Preferences preferences;

// --- Web Server & DNS ---
WebServer server(80);
DNSServer dnsServer;

// --- State Variables ---
bool isApMode = false;
String wifiSSID = "";
String wifiPassword = "";
String pppGatewayIp = "192.168.1.120";
int pppGatewayPort = 8080;
String pppApiKey = "ppp_sec_9942a8b27c1f";

unsigned long lastBlinkTime = 0;
bool ledState = false;

// Forward Declarations
void startApMode();
void startStationMode();
void setupRoutes();
void handleWifiSetup();
void handleGetStatus();
void handleToggleRelay();
void checkResetButton();
void checkSerialCommands();
void flashStatusLed(int count = 2);
void printSystemStatus();

void setup() {
  Serial.begin(115200);
  delay(500);

  Serial.println("\n==================================================");
  Serial.println("    PPP SMART HOME SYSTEM — ESP32 NODE FIRMWARE");
  Serial.println("==================================================");

  // Initialize GPIO Pins
  pinMode(STATUS_LED_PIN, OUTPUT);
  pinMode(RESET_BUTTON_PIN, INPUT_PULLUP);
  pinMode(RELAY_1_PIN, OUTPUT);
  pinMode(RELAY_2_PIN, OUTPUT);
  pinMode(RELAY_3_PIN, OUTPUT);
  pinMode(RELAY_4_PIN, OUTPUT);

  // Default Relays OFF (Active LOW relays initialized HIGH)
  digitalWrite(RELAY_1_PIN, HIGH);
  digitalWrite(RELAY_2_PIN, HIGH);
  digitalWrite(RELAY_3_PIN, HIGH);
  digitalWrite(RELAY_4_PIN, HIGH);

  // Initial LED Blink test
  flashStatusLed(3);

  // Load Saved Wi-Fi Credentials from NVS
  preferences.begin("ppp_config", false);
  wifiSSID = preferences.getString("ssid", "");
  wifiPassword = preferences.getString("pass", "");
  pppGatewayIp = preferences.getString("gateway", "192.168.1.120");
  pppApiKey = preferences.getString("apikey", "ppp_sec_9942a8b27c1f");

  if (wifiSSID == "" || wifiSSID.length() == 0) {
    Serial.println("[BOOT] No saved Wi-Fi found. Starting Provisioning AP Mode...");
    startApMode();
  } else {
    Serial.print("[BOOT] Connecting to saved Wi-Fi: ");
    Serial.println(wifiSSID);
    startStationMode();
  }
}

void loop() {
  checkResetButton();
  checkSerialCommands();

  if (isApMode) {
    dnsServer.processNextRequest();
    server.handleClient();

    // Fast Blink LED in AP Setup Mode
    if (millis() - lastBlinkTime > 150) {
      lastBlinkTime = millis();
      ledState = !ledState;
      digitalWrite(STATUS_LED_PIN, ledState);
    }
  } else {
    server.handleClient();

    // Solid LED when connected to Station Mode
    if (WiFi.status() == WL_CONNECTED) {
      digitalWrite(STATUS_LED_PIN, HIGH);
    } else {
      // Slow Blink if Wi-Fi connection lost
      if (millis() - lastBlinkTime > 600) {
        lastBlinkTime = millis();
        ledState = !ledState;
        digitalWrite(STATUS_LED_PIN, ledState);
      }
    }
  }
}

// --- Visual LED Flash Feedback on Command ---
void flashStatusLed(int count) {
  for (int i = 0; i < count; i++) {
    digitalWrite(STATUS_LED_PIN, LOW);
    delay(50);
    digitalWrite(STATUS_LED_PIN, HIGH);
    delay(50);
  }
}

// --- Start Access Point (Provisioning Mode) ---
void startApMode() {
  isApMode = true;
  WiFi.mode(WIFI_AP);
  WiFi.softAP("PPP-SmartHome-Setup", "12345678");

  IPAddress apIP(192, 168, 4, 1);
  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0));

  dnsServer.start(53, "*", apIP);
  setupRoutes();
  server.begin();

  Serial.println("\n==================================================");
  Serial.println("[AP MODE] SoftAP Started!");
  Serial.print("[AP MODE] SSID: PPP-SmartHome-Setup | IP: ");
  Serial.println(WiFi.softAPIP());
  Serial.println("==================================================");
}

// --- Start Station Mode (Connected to Home Wi-Fi) ---
void startStationMode() {
  isApMode = false;
  WiFi.mode(WIFI_STA);
  WiFi.begin(wifiSSID.c_str(), wifiPassword.c_str());

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n==================================================");
    Serial.println("  [STA MODE] CONNECTED TO WI-FI SUCCESSFULLY!");
    Serial.print("  [IP ADDRESS] : ");
    Serial.println(WiFi.localIP());
    Serial.print("  [SIGNAL RSSI]: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");

    // Start mDNS Responder
    if (MDNS.begin("ppp-node")) {
      Serial.println("  [mDNS URL]   : http://ppp-node.local");
    }
    Serial.println("--------------------------------------------------");
    Serial.println("  [SERIAL MONITOR COMMANDS ACTIVE (115200 Baud)]:");
    Serial.println("    - Type '1'..'4' to toggle Relay channels 1-4");
    Serial.println("    - Type 'STATUS' to print device state");
    Serial.println("    - Type 'RESET' to clear Wi-Fi credentials");
    Serial.println("==================================================\n");

    setupRoutes();
    server.begin();
  } else {
    Serial.println("\n[STA MODE] Failed to connect to Wi-Fi. Re-entering AP Mode...");
    startApMode();
  }
}

// --- Web Server API Routes ---
void setupRoutes() {
  server.enableCORS(true);

  // Captive Portal / Root Page
  server.on("/", HTTP_GET, []() {
    flashStatusLed(2);
    String html = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1'>"
                  "<style>body{font-family:Arial;background:#0d1117;color:#fff;text-align:center;padding:20px;}"
                  ".card{background:#161b22;padding:20px;border-radius:16px;max-width:350px;margin:0 auto;border:1px solid #30363d;}"
                  "input{width:100%;padding:10px;margin:8px 0;border-radius:8px;border:1px solid #30363d;background:#21262d;color:#fff;}"
                  "button{background:#6366f1;color:#fff;border:none;padding:12px;width:100%;border-radius:10px;font-size:16px;font-weight:bold;cursor:pointer;}"
                  "</style></head><body><div class='card'>"
                  "<h2>PPP Smart Home</h2><p>Provision ESP32 Wi-Fi Node</p>"
                  "<form action='/setup' method='POST'>"
                  "<input type='text' name='ssid' placeholder='Wi-Fi SSID' required>"
                  "<input type='password' name='pass' placeholder='Wi-Fi Password' required>"
                  "<input type='text' name='gateway' value='192.168.1.120' placeholder='PPP Gateway IP'>"
                  "<button type='submit'>Save & Connect</button>"
                  "</form></div></body></html>";
    server.send(200, "text/html", html);
  });

  // Provisioning Endpoint (Form POST)
  server.on("/setup", HTTP_POST, []() {
    flashStatusLed(3);
    String ssid = server.arg("ssid");
    String pass = server.arg("pass");
    String gateway = server.arg("gateway");

    if (ssid.length() > 0) {
      preferences.putString("ssid", ssid);
      preferences.putString("pass", pass);
      if (gateway.length() > 0) preferences.putString("gateway", gateway);

      Serial.println("\n[SETUP] New Wi-Fi Credentials Received from Web Form!");
      Serial.print("[SETUP] SSID: ");
      Serial.println(ssid);

      server.send(200, "text/html", "<h3>Credentials Saved! Rebooting ESP32...</h3>");
      delay(1500);
      ESP.restart();
    } else {
      server.send(400, "text/html", "Invalid SSID");
    }
  });

  // REST API Provisioning Endpoint (JSON POST from Flutter App)
  server.on("/api/wifi-setup", HTTP_POST, handleWifiSetup);

  // Status API Endpoint
  server.on("/api/status", HTTP_GET, handleGetStatus);

  // Relay Control API Endpoint (/api/relay?id=1&state=1)
  server.on("/api/relay", HTTP_GET, handleToggleRelay);
}

// --- JSON Wi-Fi Setup API Handler ---
void handleWifiSetup() {
  flashStatusLed(3);
  if (server.hasArg("plain") == false) {
    server.send(400, "application/json", "{\"error\":\"No JSON body\"}");
    return;
  }

  String body = server.arg("plain");
  StaticJsonDocument<256> doc;
  DeserializationError error = deserializeJson(doc, body);

  if (error) {
    server.send(400, "application/json", "{\"error\":\"Invalid JSON\"}");
    return;
  }

  String ssid = doc["ssid"];
  String pass = doc["password"];
  String gateway = doc["gateway"];
  String apikey = doc["apiKey"];

  Serial.println("\n==========================================");
  Serial.println("  [APP PROVISIONING] JSON Wi-Fi Setup Received!");
  Serial.print("  [SSID]   : "); Serial.println(ssid);
  Serial.print("  [GATEWAY]: "); Serial.println(gateway);
  Serial.println("==========================================");

  preferences.putString("ssid", ssid);
  preferences.putString("pass", pass);
  if (gateway != "") preferences.putString("gateway", gateway);
  if (apikey != "") preferences.putString("apikey", apikey);

  server.send(200, "application/json", "{\"status\":\"success\",\"message\":\"Saved! Rebooting ESP32...\"}");
  delay(1200);
  ESP.restart();
}

// --- Status API Handler ---
void handleGetStatus() {
  flashStatusLed(1);
  StaticJsonDocument<256> doc;
  doc["node"] = "PPP-ESP32-Node-01";
  doc["ip"] = WiFi.localIP().toString();
  doc["rssi"] = WiFi.RSSI();
  doc["relay_1"] = digitalRead(RELAY_1_PIN) == LOW ? 1 : 0;
  doc["relay_2"] = digitalRead(RELAY_2_PIN) == LOW ? 1 : 0;
  doc["relay_3"] = digitalRead(RELAY_3_PIN) == LOW ? 1 : 0;
  doc["relay_4"] = digitalRead(RELAY_4_PIN) == LOW ? 1 : 0;

  String jsonStr;
  serializeJson(doc, jsonStr);
  server.send(200, "application/json", jsonStr);
}

// --- Relay Control Handler ---
void handleToggleRelay() {
  flashStatusLed(2); // LED pulse on command
  if (server.hasArg("id") && server.hasArg("state")) {
    int id = server.arg("id").toInt();
    int state = server.arg("state").toInt(); // 1 = ON, 0 = OFF

    int pin = -1;
    String name = "";
    if (id == 1) { pin = RELAY_1_PIN; name = "Chandelier Light"; }
    if (id == 2) { pin = RELAY_2_PIN; name = "LED Wall Strip"; }
    if (id == 3) { pin = RELAY_3_PIN; name = "HVAC AC Compressor"; }
    if (id == 4) { pin = RELAY_4_PIN; name = "Main Entrance Lock"; }

    if (pin != -1) {
      digitalWrite(pin, state == 1 ? LOW : HIGH); // Active LOW relay

      Serial.println("\n==========================================");
      Serial.print("  [HTTP COMMAND] Relay Channel: "); Serial.print(id);
      Serial.print(" ("); Serial.print(name); Serial.println(")");
      Serial.print("  [NEW STATE]   : "); Serial.println(state == 1 ? "ON (ACTIVE)" : "OFF (INACTIVE)");
      Serial.print("  [GPIO PIN]    : GPIO "); Serial.print(pin);
      Serial.println(state == 1 ? " -> LOW" : " -> HIGH");
      Serial.println("==========================================");

      server.send(200, "application/json", "{\"status\":\"success\"}");
      return;
    }
  }
  server.send(400, "application/json", "{\"error\":\"Invalid arguments\"}");
}

// --- Interactive Serial Terminal Reader ---
void checkSerialCommands() {
  if (Serial.available() > 0) {
    String input = Serial.readStringUntil('\n');
    input.trim();
    input.toUpperCase();

    if (input == "1" || input == "2" || input == "3" || input == "4") {
      int ch = input.toInt();
      int pin = (ch == 1) ? RELAY_1_PIN : ((ch == 2) ? RELAY_2_PIN : ((ch == 3) ? RELAY_3_PIN : RELAY_4_PIN));
      bool currState = (digitalRead(pin) == LOW); // LOW = ON
      digitalWrite(pin, currState ? HIGH : LOW);

      flashStatusLed(3);
      Serial.println("\n==========================================");
      Serial.print("  [SERIAL TERMINAL TOGGLE] Relay "); Serial.println(ch);
      Serial.print("  [NEW STATE] : "); Serial.println(!currState ? "ON (ACTIVE)" : "OFF (INACTIVE)");
      Serial.println("==========================================");
    } else if (input == "STATUS" || input == "INFO") {
      printSystemStatus();
    } else if (input == "RESET") {
      Serial.println("[RESET] Manual Serial Reset Requested! Clearing NVS...");
      preferences.clear();
      flashStatusLed(5);
      ESP.restart();
    }
  }
}

// --- Print System Status Summary to Serial ---
void printSystemStatus() {
  flashStatusLed(1);
  Serial.println("\n==========================================");
  Serial.println("            ESP32 NODE SYSTEM STATUS      ");
  Serial.println("==========================================");
  Serial.print("  [MODE]       : "); Serial.println(isApMode ? "SoftAP Setup" : "Wi-Fi Station");
  Serial.print("  [IP ADDRESS] : "); Serial.println(isApMode ? WiFi.softAPIP().toString() : WiFi.localIP().toString());
  Serial.print("  [RELAY 1]    : "); Serial.println(digitalRead(RELAY_1_PIN) == LOW ? "ON" : "OFF");
  Serial.print("  [RELAY 2]    : "); Serial.println(digitalRead(RELAY_2_PIN) == LOW ? "ON" : "OFF");
  Serial.print("  [RELAY 3]    : "); Serial.println(digitalRead(RELAY_3_PIN) == LOW ? "ON" : "OFF");
  Serial.print("  [RELAY 4]    : "); Serial.println(digitalRead(RELAY_4_PIN) == LOW ? "ON" : "OFF");
  Serial.println("==========================================\n");
}

// --- Factory Reset Button Handler (Press & Hold 5 Seconds) ---
void checkResetButton() {
  static unsigned long pressStartTime = 0;
  if (digitalRead(RESET_BUTTON_PIN) == LOW) {
    if (pressStartTime == 0) {
      pressStartTime = millis();
    } else if (millis() - pressStartTime > 5000) {
      Serial.println("[RESET] BOOT button held for 5 seconds. Factory Resetting NVS...");
      preferences.clear();
      
      // Fast blink to indicate reset
      for (int i = 0; i < 10; i++) {
        digitalWrite(STATUS_LED_PIN, HIGH);
        delay(100);
        digitalWrite(STATUS_LED_PIN, LOW);
        delay(100);
      }
      ESP.restart();
    }
  } else {
    pressStartTime = 0;
  }
}
