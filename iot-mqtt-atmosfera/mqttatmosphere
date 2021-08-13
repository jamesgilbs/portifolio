/*
  ******************************************************************************
    @Company    : James Gil
    @file       : mqttatmosphere
    @author     : James Gil Brito de Sousa
    @version    : 1.0
    @date       : 2020
    @brief      : This device reads and sends via MQTT data of temperature,
                  altitude, atmospheric pressure, humidity, detection of
                  atmospheric explosives.
  ******************************************************************************
*/

/*******************************************************************************
                             HOW TO USE THIS FIRMWARE
********************************************************************************
  /* Device sends two analog signals and four I2C signals BMP280. The values of analog sensors is 
   temperature(A3) and flammable gases(A0).

   Search time on NTP server and keep updated via wifi. The wifi connection at first, boots in access point
   mode to choose the local network in the browser(192.168.4.1), from there, automatically connects in Station
   mode to networks saved in the device's internal Flash, and connects to the best signal network.
   For choosing new networks, the reset can be done by the push button(26).

   The device displays the current time and data as a connected network on display, ddate and the four alarms.
   All data received and sent through the MQTT Broker in the Google Cloud on a Linux virtual machine
   Ubuntu Server 18.04 of IP fixed(XX.XXX.XXX.XXX).

   It shows, in a display coordinated with RTOS in the second core, the performance of the outputs and alarms, 
   as well as the logos.

   Device:ESP32 30 Pin DoIT

   Board version: ESP32 Dev Module
   CPU: 240MHz
   Flash: 80MHz

   Inputs:
   Analogs: LM35(ADC3) and MQ-2(ADC0) Gas
   Digitals: 26 - Reset of Wifi
   I2C: (14/15):  MAX6675 & BME280

   Outputs:
   Digital: Led32 / Led33
   
   ESP32 subscribe to topics on the mosquitto server via wifimanager that connects in AP mode:
   IP(AP): 192.168.4.1
   ESP_AP password: XXXXXXXX

   MQTT server on Google Cloud VM Linux:
   IP fixed: XX.XXX.XXX.XXX
   Port: 1883
   User: XXXXXXXXXX
   Password: XXXXXX

   This makes two sensor Publishs:
   LM35 of Temperature(ADC3)
   Sensor MQ-2 of gas(ADC0)
   BME280 I2C Temperature, Pression, Altitude, Humidity in I2C (14/15)
   
   Create user in the password file inside the server:
   $ sudo mosquitto_passwd -c /etc/mosquitto/pwfile {name_of_user}

   Reading command at the mosquitto terminal:
   $ mosquitto_sub -h XX.XXX.XXX.XXX -p 1883 -u XXXXXXXXX -P XXXXXX -t "esp32/protoboard/XXXX"
   $ mosquitto_pub -h XX.XXX.XXX.XXX -p 1883 -u XXXXXXXXX -P XXXXXX -t "esp32/protoboard/XXXX" -m "t" -d -i
   -d - for connection information
   -r - retain
   -n -d - clear held message

   Command patterns on the server:
   mosquitto_pub { [-h hostname] [-p port-number] [-u username] [-P password] -t message-topic... | -L URL } [-A bind-address] [-c] [-d] [-D command identifier value] [-i client-id] [-I client-id-prefix] [-k keepalive-time] [-q message-QoS] [--quiet] [-r] [--repeat count] [--repeat-delay seconds] [-S] { -f file | -l | -m message | -n | -s } [ --will-topic topic [--will-payload payload] [--will-qos qos] [--will-retain] ] [[ { --cafile file | --capath dir } [--cert file] [--key file] [--ciphers ciphers] [--tls-version version] [--tls-alpn protocol] [--tls-engine engine] [--keyform { pem | engine }] [--tls-engine-kpass-sha1 kpass-sha1] [--insecure] ] | [ --psk hex-key --psk-identity identity [--ciphers ciphers] [--tls-version version] ]] [--proxy socks-url] [-V protocol-version]
   mosquitto_sub { [-h hostname] [-p port-number] [-u username] [-P password] -t message-topic... | -L URL [-t message-topic...] } [-A bind-address] [-c] [-C msg-count] [-d] [-D command identifier value] [-E] [-i client-id] [-I client-id-prefix] [-k keepalive-time] [-N] [-q message-QoS] [--remove-retained] [ -R | --retained-only ] [--retain-as-published] [-S] [-T filter-out...] [-U unsub-topic...] [-v] [-V protocol-version] [-W message-processing-timeout] [--proxy socks-url] [--quiet] [ --will-topic topic [--will-payload payload] [--will-qos qos] [--will-retain] ] [[ { --cafile file | --capath dir } [--cert file] [--key file] [--tls-version version] [--tls-alpn protocol] [--tls-engine engine] [--keyform { pem | engine }] [--tls-engine-kpass-sha1 kpass-sha1] [--insecure] ] | [ --psk hex-key --psk-identity identity [--tls-version version] ]]

   Display Set:
   Pinning on User_Setup.h in the library folder
*/

/*******************************************************************************
                                  LIBRARIES
********************************************************************************/
#include <Arduino.h>
#if defined(ESP8266)
#include <ESP8266WiFi.h>  //ESP8266 Core WiFi Library
#else
#include <WiFi.h>      //ESP32 Core WiFi Library
#endif

//SPIFFS file system
#include <FS.h>
#include <SPIFFS.h>

//RTOS
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <esp_ipc.h>

//Wifimanager
#include <DNSServer.h> //https://github.com/zhouhan0126/DNSServer---esp32
#if defined(ESP8266)
#include <ESP8266WebServer.h>
#else
#include <WebServer.h> //https://github.com/zhouhan0126/WebServer-esp32
#endif
#include <WiFiManager.h>   //https://github.com/zhouhan0126/WIFIMANAGER-ESP32 >> https://github.com/tzapu/WiFiManager (ORIGINAL)

//Flag to indicate whether a new wifi network configuration has been saved
bool shouldSaveConfig = false;

//Display
#include <SPI.h>
#include <TFT_eSPI.h>
TFT_eSPI display = TFT_eSPI();

//MQTT
#include <ArduinoJson.h>
#include <PubSubClient.h>
#include <NTPClient.h> //Modified NTPClient library Taranais

//Hour UDP
#include <WiFiUdp.h> //Socket UDP
#include <sys/time.h>

//Temperature type K
#include <max6675.h>

//BME280 sensor
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BME280.h>
#include "printValueBME280.h"
#include "drawBmp.h"

/*******************************************************************************
                                 MQTT CONFIG
********************************************************************************/
const char *mqtt_server = "XX.XXX.XXX.XXX"; //MQTT Mosquitto Server on Google Cloud Linux Ubuntu 18.04 Server
const int mqtt_port = 1883; //Default MQTT server port
const char *mqtt_user = "XXXXXXXXXX"; //Default username and password saved in password_file / etc / mosquitto / pwfile
const char *mqtt_pass = "XXXXXX";

/*******************************************************************************
                         MQTT PUBLISH AND SUBSCRIBE
********************************************************************************/
const char *root_topic_subscribe_led32 = "esp32/protoboard/led32";
const char *root_topic_subscribe_led33 = "esp32/protoboard/led33";
const char *root_topic_subscribe_alarm1 = "esp32/protoboard/alarm1";
const char *root_topic_subscribe_alarm2 = "esp32/protoboard/alarm2";
const char *root_topic_subscribe_alarm3 = "esp32/protoboard/alarm3";
const char *root_topic_subscribe_alarm4 = "esp32/protoboard/alarm4";
const char *root_topic_publish_temp = "esp32/protoboard/temp";
const char *root_topic_publish_gas = "esp32/protoboard/gas";
const char *root_topic_publish_bme280temp = "esp32/protoboard/bme280temp";
const char *root_topic_publish_bme280press = "esp32/protoboard/bme280press";
const char *root_topic_publish_bme280alt = "esp32/protoboard/bme280alt";
const char *root_topic_publish_bme280hum = "esp32/protoboard/bme280hum";

/*******************************************************************************
                                  GLOBAL
********************************************************************************/
WiFiClient espClient;
PubSubClient client(espClient); //Pubsubclient Wifi/GSM
WiFiManager wifiManager;

//I2C
#define I2C_SDA 14
#define I2C_SCL 15

unsigned long delayTime;

//Wifi reset port
const int PIN_AP = 26; //Wifi in AP mode
float PinA0 = A0; //Analog Input A0
float PinA3 = A3; //Analog Input A3
float fTemp; //Analog signal read A0
float fGas; //Analog signal read A3
float fBme280Temperature; //bme280 sensor
float fBme280Pression; //bme280 sensor
float fBme280Altitude; //bme280 sensor
float fBme280Humidity; //bme280 sensor

//Digital Relay Output
const char led32 = 32; //Digital output 32
const char led33 = 33; //Digital output 33

//Time variables on the display
byte omm = 99;
boolean initial = 1;
byte xcolon = 0;
unsigned int colour = 0;

//Flag indicating whether the display is busy
bool displayIsBusy = false;

String setAlarm1 = ""; //Variable saved in the alarm file, alarm setpoint
String setAlarm2 = "";
String setAlarm3 = "";
String setAlarm4 = "";
String horaAtual = ""; //Current time HH: MM: SS via NTP

//Time structure within the internal RTC
struct tm timeinfo;
int hour;
int minute;
int second;

//NTP Client
//Time Zone, in the case of Brasilia
int timeZone = -3;

//Struct with day and time data
struct Date {
  int dayOfWeek;
  int day;
  int month;
  int year;
  int hours;
  int minutes;
  int seconds;
};

//UDP socket that lib uses to retrieve time data
WiFiUDP udp;

//Object responsible for retrieving time data
NTPClient ntpClient(
  udp,                    //socket udp
  "0.br.pool.ntp.org",    //URL of NTPserver
  timeZone * 3600,        //Time shift in relation to GMT 0
  60000);                 //Interval between online checks

//Weekday names
char* dayOfWeekNames[] = {"Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"};

/*******************************************************************************
                                  FUNCTIONS
********************************************************************************/
void setup(); //Setup Firmware Core 1
void loop(); //Loop Core 1
void disconnectionWifi(); //Check wifi connection
void setupDisplay(); //Initializes TFT Display
void showDisplay(String msg, bool clear); //Checks whether display is busy
void resetDisplay(); //Reset basic display
void createTasks(); //Creates Multicore Tasks
void resetWifibutton(); //Waiting signal for forgetting Wifi networks
void setupNTP(); //Boot NTP time server
Date getDate(); //Formats NTP date and time
int setUnixtime(int32_t unixtime); //Hit Internal RTC
void printLocalTime(); //Prints Internal RTC
void displayHourAlarm(void* pvParameters); //Shows data on the Display (Task core 0)
void reconnect(); //Inscreve nos tópicos
void receivedCallback(char* topic, byte* payload, unsigned int length); //Subscribe
void publicmqtt(); //Publish
void configModeCallback (WiFiManager *myWiFiManager); //Wifi AP Mode
void saveConfigCallback(); //Saves networks
void listDir(fs::FS &fs, const char * dirname, uint8_t levels); //List directories
void createDir(fs::FS &fs, const char * path); //Create directory
void removeDir(fs::FS &fs, const char * path); //Delete directory
void readFile(fs::FS &fs, const char * path); //Le file
void writeFile(fs::FS &fs, const char * path, const char * message); //Write to file
void appendFile(fs::FS &fs, const char * path, const char * message); //Add to file
void renameFile(fs::FS &fs, const char * path1, const char * path2); //Renames file
void deleteFile(fs::FS &fs, const char * path); //Delete file
String readAlarm(fs::FS &fs, const char * path); //Monitors alarms
void drawBmp(const char *filename, int16_t x, int16_t y); //Configure Bitmap reading
uint16_t read16(fs::File &f); //Reading bmp 16
uint32_t read32(fs::File &f); //Reading bmp 32
void printValuesBME280();

/*******************************************************************************
                                  SETUP
********************************************************************************/
void setup() {
  Serial.begin(115200);

  //Ports
  pinMode(led32, OUTPUT);
  pinMode(led33, OUTPUT);
  pinMode(PIN_AP, INPUT);

  if (!SPIFFS.begin()) {
    Serial.println("SPPFIS Falhou");
    return;
  }
  Serial.println("");
  listDir(SPIFFS, "/", 0);
  Serial.println("");

  setupDisplay();
  display.setRotation(1);
  display.fillScreen(TFT_BLACK); //Clean the display with black color
  drawBmp("/logo.bmp", 0, 0); //Reads the BMP saved in Flash via ESP32 Sketch Data Upload
  delay(3000);
  display.fillScreen(TFT_BLACK); //Clean the display with black color
  display.setCursor(0, 0);

  // Criamos tasks
  createTasks(); //Core 0

  //Conecta Wifi
  Serial.println("");
  wifiManager.setAPCallback(configModeCallback);
  wifiManager.setSaveConfigCallback(saveConfigCallback);
  wifiManager.autoConnect("ESP_AP", "XXXXXXXX"); //Create a network

  //Find hour NTP and set the internal clock
  Serial.println("");
  setupNTP(); //Force the time to be updated
  Serial.println("");
  int unixHour; //Search NTP time in Epoch with Unixtime format
  unixHour = ntpClient.getEpochTime();
  Serial.print("Unixtime:");
  Serial.println(unixHour);
  setUnixtime(unixHour); //Function that sets the RTC internal clock
  Serial.print("RTC Esp32: ");
  printLocalTime(); //Shows internal time
  Serial.println("");

  //Conect MQTT
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(receivedCallback);

  //BME280
  Serial.println(F("BME280 teste"));
  I2CBME.begin(I2C_SDA, I2C_SCL, 100000);
  Serial.println();

  bool status;//Status BME280
  status = bme.begin(0x76, &I2CBME);
  if (!status) {
    Serial.println("Nao encontrado um BME280 Valido");
    while (1);
  }

  Serial.println("-- Default Teste --");
  delayTime = 1000;

  Serial.println();
}

/*******************************************************************************
                                  LOOP
********************************************************************************/
void loop() {

  resetWifibutton(); //Check the manual reset of the Wifi

  publicmqtt(); //Publish (send) topics to the MQTT server

  //disconnectionWifi(); //Disconnection Wifi
  Serial.println("Alarms:");
  readAlarm(SPIFFS, "/Alarm1.txt"); //Conference of the current time with file saved from the MQTT server
  readAlarm(SPIFFS, "/Alarm2.txt");
  readAlarm(SPIFFS, "/Alarm3.txt");
  readAlarm(SPIFFS, "/Alarm4.txt");
  Serial.println();

  Serial.println("BME280:");
  printValuesBME280();

  client.loop();
}

/*******************************************************************************
                                  WIFI
********************************************************************************/
void disconnectionWifi() {
  if (WiFi.status() != WL_CONNECTED) {
    wifiManager.setAPCallback(configModeCallback);
    wifiManager.setSaveConfigCallback(saveConfigCallback);
    wifiManager.autoConnect("ESP_AP", "XXXXXXXX"); //Create a network
  }
}

/*******************************************************************************
                                 DISPLAY
********************************************************************************/
void setupDisplay() {
  display.init();
  display.setRotation(1);
  display.fillScreen(TFT_BLACK); //Clean the display with black color
  display.setTextColor(TFT_YELLOW, TFT_BLACK); //Puts text as white with black background
  display.setTextWrap(true, true);//Enable line break
  display.setTextSize(1);
  display.setCursor(0, 0, 2); //X, y position and text font
  Serial.println("Display Ok");
}

/*******************************************************************************
                               DISPLAY BUSY
********************************************************************************/
void showDisplay(String msg, bool clear) {
  if (!displayIsBusy)
  {
    displayIsBusy = true;
    if (clear)
      resetDisplay();
    display.print(msg);
    displayIsBusy = false;
  }
}

/*******************************************************************************
                               DISPLAY RESET
********************************************************************************/
void resetDisplay() {
  display.fillScreen(TFT_BLACK); //Clean the display with black color
  display.setTextColor(TFT_YELLOW, TFT_BLACK); //Puts text as white with black background
}

/*******************************************************************************
                               CREATE TASKS
********************************************************************************/
void createTasks() {
  //Create Core routine 0 Clock display
  xTaskCreatePinnedToCore(
    displayHourAlarm,   //Function that will be performed
    "displayHourAlarm", //task name
    10000,      //Stack Size
    NULL,       //Task parameter (in case we don't use it)
    2,          //Task priority (25 levels)
    NULL,       //Identifier, rarely used. RTOS has API to get the ID of a task after it is created
    0);         //Number of the core that the task will run (we use core 0 for the loop to be free with core 1)
  //PRO_CPU, APP_CPU​ , or pass tskNO_AFFINITY to choose RTOS
  Serial.println("Display trabalha em Core 0");
  Serial.println("");
}

/*******************************************************************************
                                 RESET WIFI
********************************************************************************/
void resetWifibutton() {
  //Reset button ESP AP mode
  if (digitalRead(PIN_AP) == HIGH) {

    Serial.println("Esp AP modo"); //Try to open the portal for network selection
    Serial.println("Pressione Reset...");
    //display.fillScreen(TFT_BLACK); //Clean the display with black color
    if (!wifiManager.startConfigPortal("ESP_AP", "XXXXXXXX") ) {
      Serial.println("Falha ao conectar");
      delay(2000);
      ESP.restart();
      delay(1000);
    }
    Serial.println("Conectado ESP_AP");
  }
}

/*******************************************************************************
                                  SETUP NTP
********************************************************************************/
void setupNTP() {

  ntpClient.begin();

  Serial.println("Esperando pela hora NTP...");
  while (!ntpClient.update())
  {
    Serial.print(".");
    ntpClient.forceUpdate();
    delay(500);
  }
  Serial.println("Hora Ok");
}

/*******************************************************************************
                             DATA AND TIME REQUEST
********************************************************************************/
Date getDate() {
  //Retrieves date and time data using the NTP client
  char* strDate = (char*)ntpClient.getFormattedDate().c_str();

  //Pass string data to struct
  Date date;
  sscanf(strDate, "%d-%d-%dT%d:%d:%dZ",
         &date.year,
         &date.month,
         &date.day,
         &date.hours,
         &date.minutes,
         &date.seconds);

  //Day of the week from 0 to 6, with 0 being Sunday
  date.dayOfWeek = ntpClient.getDay();
  return date;
}

/*******************************************************************************
                                  CHANGE RTC
********************************************************************************/
int setUnixtime(int32_t unixtime) {
  timeval epoch = {unixtime, 0};
  return settimeofday((const timeval*)&epoch, 0);
}

/*******************************************************************************
                                  PRINT RTC
********************************************************************************/
void printLocalTime() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Falha ao obter hora");
    return;
  }
  Serial.println(&timeinfo, "%A, %B %d %Y %H:%M:%S");
  hour = timeinfo.tm_hour;
  minute = timeinfo.tm_min;
  second = timeinfo.tm_sec;
  
/*******************************************************************************
                                  PRINT HOUR
********************************************************************************/
void displayHourAlarm(void* pvParameters) { //Task performed in Core 0
  while (true)
  {
    //Retrieves date and time data
    Date date = getDate();

    //char hh = hour, mm = minute, ss = second; //Shows time by internal RTC
    char hh = date.hours, mm = date.minutes, ss = date.seconds; //Shows NTP time even without internet

    horaAtual = ntpClient.getFormattedTime(); //Current time for comparison with SPIFFS file

    display.setCursor(0, 0);

    if (ss == 60) {
      omm = mm;
    }

    display.setTextColor(TFT_WHITE, TFT_BLACK);

    if (ss == 0 || initial) {
      initial = 0;
      display.setTextColor(0xFFFF, TFT_BLACK);
      display.setCursor (52, 52);
    }

    //Update digital time
    byte xpos = 6;
    byte ypos = 2;
    if (omm != mm) { //Just redraw every minute to minimize flicker
      display.setTextColor(0x39C4, TFT_BLACK);
      display.drawString("88:88", xpos, ypos, 7);
      display.setTextColor(TFT_WHITE, TFT_BLACK);
      omm = mm;

      if (hh < 10) xpos += display.drawChar('0', xpos, ypos, 7);
      xpos += display.drawNumber(hh, xpos, ypos, 7);
      xcolon = xpos;
      xpos += display.drawChar(':', xpos, ypos, 7);
      if (mm < 10) xpos += display.drawChar('0', xpos, ypos, 7);
      display.drawNumber(mm, xpos, ypos, 7);
    }

    if (ss % 2) { //Flashes seconds
      display.setTextColor(0x39C4, TFT_BLACK);
      xpos += display.drawChar(':', xcolon, ypos, 7);
      display.setTextColor(TFT_WHITE, TFT_BLACK);
    }
    else {
      display.drawChar(':', xcolon, ypos, 7);
      colour = random(0xFFFF);
    }

    //Displays Time on the display
    display.setTextColor(0x94B2, TFT_BLACK);
    display.setCursor (12, 53, 1);
    display.printf("Wifi:%s", WiFi.SSID().c_str());

    display.setCursor (12, 62, 1);
    display.printf("%s %02d/%02d/%d %02d:%02d:%02d",
                   dayOfWeekNames[date.dayOfWeek],
                   date.day,
                   date.month,
                   date.year,
                   date.hours,
                   date.minutes,
                   date.seconds);

    //Task 5ms delay. It is done in ticks. To run in millis we divide by the constant portTICK_PERIOD_MS
    TickType_t taskDelay = 5 / portTICK_PERIOD_MS;
    vTaskDelay(taskDelay);
  }
}

/*******************************************************************************
                         MQTT CONNECTION AND SUBSCRIPTION
********************************************************************************/
void reconnect() {
  while (!client.connected()) {
    Serial.println("Inicio Link MQTT");

    //We created a client ID Mac address
    String clientId;
    clientId = WiFi.macAddress(); //Search mac address of ESP32 to form the ClientID

    //Connection
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass)) {
      Serial.println("MQTT Broker conectado");
      Serial.println("");

      Serial.println("Mac Adress:");
      Serial.println(clientId);
      Serial.println("");

      //Subscribe
      //First topic Led 12
      if (client.subscribe(root_topic_subscribe_led32)) {
        Serial.println("Primeiro topico ok");
      } else {
        Serial.println("Primeiro topico falha");
      }

      //Second topic Led 33 Relay
      if (client.subscribe(root_topic_subscribe_led33)) {
        Serial.println("Segundo topico ok");
      } else {
        Serial.println("Segundo topico falha");
      }

      //Third topic (alarme 1)
      if (client.subscribe(root_topic_subscribe_alarm1)) {
        Serial.println("Terceiro topico ok");
      } else {
        Serial.println("Terceiro topico falha");
      }

      //Fourth topic (alarm 2)
      if (client.subscribe(root_topic_subscribe_alarm2)) {
        Serial.println("Quarto topico ok");
      } else {
        Serial.println("Quarto topico falha");
      }

      //Fifth topic (alarm 3)
      if (client.subscribe(root_topic_subscribe_alarm3)) {
        Serial.println("Quinto topico ok");
      } else {
        Serial.println("Quinto topico falha");
      }

      //Sixth topic (alarm 4)
      if (client.subscribe(root_topic_subscribe_alarm4)) {
        Serial.println("Sexto topico ok");
      } else {
        Serial.println("Sexto topico falha");
      }

      //Failure in all Topics
    } else {
      Serial.print("Falha :( error:");
      Serial.print(client.state());
      Serial.println("Tentativa em 5s");

      delay(5000);
    }
  }
  Serial.println("");
}

/*******************************************************************************
                         CALLBACK SUBSCRIBE MQTT
********************************************************************************/
void receivedCallback(char* topic, byte * payload, unsigned int length) {

  //Write received byte by byte payload to serial 0 and display
  Serial.print("Mensagem recebida: ");
  Serial.println(topic);
  Serial.print("Carga: ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println("");

  //Compare load received by topics and perform an action
  String strTopic = String((char*)topic);

  //First topic Led 32
  if (strTopic == root_topic_subscribe_led32)
  {
    if ((char)payload[0] == 't') {
      digitalWrite(led32, HIGH);
    } else {
      digitalWrite(led32, LOW);
    }
  }

  //Second topic Led 33
  if (strTopic == root_topic_subscribe_led33)
  {
    if ((char)payload[0] == 't') {
      digitalWrite(led33, HIGH);
      delay(220);
      digitalWrite(led33, LOW);
    } else {
      digitalWrite(led33, LOW);
    }
  }

  //Third topic (alarme 1)
  if (strTopic == root_topic_subscribe_alarm1)
  {
    //Get the received payload string
    for (int i = 0; i < length; i++)
    {
      char c = (char)payload[i];
      setAlarm1 += c;
    }
    deleteFile(SPIFFS, "/Alarm1.txt");
    writeFile(SPIFFS, "/Alarm1.txt", setAlarm1.c_str());
    readFile(SPIFFS, "/Alarm1.txt");
  }

  //Fourth topic (alarm 2)
  if (strTopic == root_topic_subscribe_alarm2)
  {
    for (int i = 0; i < length; i++)
    {
      char c = (char)payload[i];
      setAlarm2 += c;
    }
    deleteFile(SPIFFS, "/Alarm2.txt");
    writeFile(SPIFFS, "/Alarm2.txt", setAlarm2.c_str());
    readFile(SPIFFS, "/Alarm2.txt");
  }

  //Fifth topic (alarm 3)
  if (strTopic == root_topic_subscribe_alarm3)
  {
    for (int i = 0; i < length; i++)
    {
      char c = (char)payload[i];
      setAlarm3 += c;
    }
    deleteFile(SPIFFS, "/Alarm3.txt");
    writeFile(SPIFFS, "/Alarm3.txt", setAlarm3.c_str());
    readFile(SPIFFS, "/Alarm3.txt");
  }

  //Sixth topic (alarm 4)
  if (strTopic == root_topic_subscribe_alarm4)
  {
    for (int i = 0; i < length; i++)
    {
      char c = (char)payload[i];
      setAlarm4 += c;
    }
    deleteFile(SPIFFS, "/Alarm4.txt");
    writeFile(SPIFFS, "/Alarm4.txt", setAlarm4.c_str());
    readFile(SPIFFS, "/Alarm4.txt");
  }
}

/*******************************************************************************
                                 PUBLISH MQTT
********************************************************************************/
void publicmqtt() {
  if (!client.connected()) { //Checks connection to the Mosquitto
    reconnect();
  }
  //Preparation of information sent
  fTemp = analogRead(PinA3) * 0.1; //°C
  fGas = analogRead(PinA0) / 2.5; //ppm
  fBme280Temperature = bme.readTemperature();
  fBme280Pression = bme.readPressure() / 100.0F;
  fBme280Altitude = bme.readAltitude(SEALEVELPRESSURE_HPA);
  fBme280Humidity = bme.readHumidity();

  //Send publications
  if (client.connected()) {
    String sTemp = String(fTemp); //String Analogic Temperature
    client.publish(root_topic_publish_temp, sTemp.c_str());

    String sGas = String(fGas); //String Analogic Gas
    client.publish(root_topic_publish_gas, sGas.c_str());

    //BME280
    String sTemperature = String(fBme280Temperature); //String Temperature
    client.publish(root_topic_publish_bme280temp, sTemperature.c_str());

    String sPression = String(fBme280Pression);
    client.publish(root_topic_publish_bme280press, sPression.c_str());

    String sAltitude = String(fBme280Altitude); //String Temperature
    client.publish(root_topic_publish_bme280alt, sAltitude.c_str());

    String sHumidity = String(fBme280Humidity);
    client.publish(root_topic_publish_bme280hum, sHumidity.c_str());
    //End BME280

    delay(1000); //Time between publications
  }
}

/*******************************************************************************
                             CALLBACK WIFIMANAGER
********************************************************************************/
//callback indicating that ESP has entered AP mode
void configModeCallback (WiFiManager * myWiFiManager) {
  Serial.println("Wifi Modo AP");
  Serial.println(WiFi.softAPIP()); //Print the IP of the AP
  Serial.println(myWiFiManager->getConfigPortalSSID());
}

//Callback indicating that ESP has entered AP mode
void saveConfigCallback () {
  Serial.println("Configuração salva");
  Serial.println(WiFi.softAPIP()); //Prints the IP of the AP
}

/*******************************************************************************
                                FILE HANDLING
********************************************************************************/
//Directory list
void listDir(fs::FS & fs, const char * dirname, uint8_t levels) {
  Serial.printf("Lista diretorio SPIFFS: %s\n", dirname);

  File root = fs.open(dirname);
  if (!root) {
    Serial.println("falha ao abrir o diretorio");
    return;
  }
  if (!root.isDirectory()) {
    Serial.println("Este nao e um diretorio");
    return;
  }

  File file = root.openNextFile();
  while (file) {
    if (file.isDirectory()) {
      Serial.print(" Dir: ");
      Serial.print (file.name());

      if (levels) {
        listDir(fs, file.name(), levels - 1);
      }
    } else {
      Serial.print(" Arquivo: ");
      Serial.print(file.name());
      Serial.print(" Tamanho: ");
      Serial.println(file.size());
    }
    file = root.openNextFile();
  }
}

//Create directory
void createDir(fs::FS & fs, const char * path) {
  Serial.printf("Criando um diretorio: %s\n", path);
  if (fs.mkdir(path)) {
    Serial.println("Diretorio criado");
  } else {
    Serial.println("Diretorio Falha");
  }
}

//Remove directory
void removeDir(fs::FS & fs, const char * path) {
  Serial.printf("Apagando o diretorio: %s\n", path);
  if (fs.rmdir(path)) {
    Serial.println("Diretorio apagado");
  } else {
    Serial.println("Falha em apagar o diretorio");
  }
}

//Read file
void readFile(fs::FS & fs, const char * path) {
  Serial.printf("Lendo arquivo: %s\n", path);

  File file = fs.open(path);
  if (!file) {
    Serial.println("Falha ao abrir arquivo");
    return;
  }

  Serial.print("Lendo do arquivo: ");
  while (file.available()) {
    Serial.write(file.read());
  }
  Serial.println("");
  file.close();
}

//Write file
void writeFile(fs::FS & fs, const char * path, const char * message) {
  Serial.printf("Escrevendo no arquivo: %s\n", path);

  File file = fs.open(path, FILE_WRITE);
  if (!file) {
    Serial.println("Falha ao abrir aquivo para leitura");
    return;
  }
  if (file.print(message)) {
    Serial.println("Escrita ok");
  } else {
    Serial.println("Falha na escrita");
  }
  file.close();
}

//Append file
void appendFile(fs::FS & fs, const char * path, const char * message) {
  Serial.printf("Acrescentado ao arquivo: %s\n", path);

  File file = fs.open(path, FILE_APPEND);
  if (!file) {
    Serial.println("Falha ao abrir arquivo para escrita");
    return;
  }
  if (file.print(message)) {
    Serial.println("Mensagem adicionada");
  } else {
    Serial.println("Adicao falhou");
  }
  file.close();
}

//Rename file
void renameFile(fs::FS & fs, const char * path1, const char * path2) {
  Serial.printf("Renomeando aquivo %s para %s\n", path1, path2);
  if (fs.rename(path1, path2)) {
    Serial.println("Arquivo renomeado");
  } else {
    Serial.println("Arquivo renomeado");
  }
}

//Delete file
void deleteFile(fs::FS & fs, const char * path) {
  Serial.printf("Deletando arquivo: %s\n", path);
  if (fs.remove(path)) {
    Serial.println("Arquivo deletado");
  } else {
    Serial.println("Falha ao deletar");
  }
}

/*******************************************************************************
                           ALARM OUTPUT DRIVING
********************************************************************************/
//Routine for triggering the alarm, read the contents of the file and compare with the current time
String readAlarm(fs::FS &fs, const char * path) {
  File file = fs.open(path, "r");

  String fileContent;

  while (file.available()) {
    fileContent += String((char)file.read());
  }
  Serial.print(horaAtual);
  Serial.print("==");
  Serial.print(fileContent);
  Serial.print(" | ");

  if (horaAtual == fileContent) {
    digitalWrite(led33, HIGH);
    delay(235); //Dispenser turning time
    digitalWrite(led33, LOW);
  }
  else {
    digitalWrite(led33, LOW);
  }
  file.close();
  //return fileContent;
}

/*****************************END OF FILE**************************************/