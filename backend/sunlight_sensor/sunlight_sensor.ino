#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLEBeacon.h>

#define DEVICE_NAME         "Aware-Home: Plant Planner"
#define SERVICE_UUID        "BF585F7A-E1E3-4A83-BCC3-4280E90E1C7D"
#define BEACON_UUID         "2D7A9F0C-E0E8-4CC9-A71B-A21DB2D034A1"
#define BEACON_UUID_REV     "A134D0B2-1DA2-1BA7-C94C-E8E00C9F7A2D"
#define CHARACTERISTIC_UUID "82258BAA-DF72-47E8-99BC-B73D7ECD08A5"

BLEServer *pServer;
BLECharacteristic *pCharacteristic;
bool deviceConnected = false;


int photoResistorPin = A0;
int photoResistorVal = 0;
int part_shade_threshold = 140;
int sun_part_shade_threshold = 210;
int moistureReadings[4] = {
  0, // none
  0, // minimum
  0, // average
  0  // frequent
};

int readings[3] = {
  0, // part_shade
  0, // sun_part_shade
  0  // full_sun
};
String part_shade = "part_shade";
String sun_part_shade = "sun-part_shade";
String full_sun = "full_sun";

String none = "none";
String minimum = "sun-minimum";
String average = "average";
String frequent = "frequent";

String sunlight_intensity_tags[3] = {
  part_shade,
  sun_part_shade,
  full_sun
};

String moisture_tags[4] = {
  none,
  minimum,
  average,
  frequent
};

int averageMoisture = 50;

// Checks when a Device is connected
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    deviceConnected = true;
    Serial.println("deviceConnected = true");
  };

  void onDisconnect(BLEServer *pServer) {
    deviceConnected = false;
    Serial.println("deviceConnected = false");

    // Restart advertising to be visible and connectable again
    BLEAdvertising *pAdvertising = pServer->getAdvertising();
    pAdvertising->start();
    Serial.println("iBeacon advertising restarted");
  }
};

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String rxValue = pCharacteristic->getValue();

    if (rxValue.length() > 0) {
      Serial.println("*********");
      Serial.print("Received Value: ");
      for (int i = 0; i < rxValue.length(); i++) {
        Serial.print(rxValue[i]);
      }
      Serial.println();
      Serial.println("*********");
    }
  }
};

struct SensorReadings {
  float sunlightTag;
  float moistureReading; 
};


//Initializing the GATT Characteristic to properly send data
void init_service() {
  BLEAdvertising *pAdvertising = pServer->getAdvertising();
  pAdvertising->stop();

  // Create the BLE Service
  BLEService *pService = pServer->createService(BLEUUID(SERVICE_UUID));

  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
  pCharacteristic->setCallbacks(new MyCallbacks());
  pCharacteristic->addDescriptor(new BLE2902());

  pAdvertising->addServiceUUID(BLEUUID(SERVICE_UUID));

  // Start the service
  pService->start();

  pAdvertising->start();
}

//Initializes IOS BLE capabilities.
void init_beacon() {
  BLEAdvertising *pAdvertising = pServer->getAdvertising();
  pAdvertising->stop();

  // iBeacon
  BLEBeacon myBeacon;
  myBeacon.setManufacturerId(0x4c00);
  myBeacon.setMajor(5);
  myBeacon.setMinor(88);
  myBeacon.setSignalPower(0xc5);
  myBeacon.setProximityUUID(BLEUUID(BEACON_UUID_REV));

  BLEAdvertisementData advertisementData;
  advertisementData.setFlags(0x1A);
  advertisementData.setManufacturerData(myBeacon.getData());
  pAdvertising->setAdvertisementData(advertisementData);

  pAdvertising->start();
}

void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.println("Initializing...");
  Serial.flush();

  BLEDevice::init(DEVICE_NAME);
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  init_service();
  init_beacon();

  Serial.println("Device is now Advertising to IOS!");
}


void loop() {
  // put your main code here, to run repeatedly:
  photoResistorVal = analogRead(photoResistorPin);
  uint8_t moistureVal = analogRead(22);
  moistureVal = map(moistureVal, 100, 0, 311, 630);
  if (photoResistorVal <= part_shade_threshold) {
    // part_shade
    readings[0]++;
  } else if (photoResistorVal > part_shade_threshold && photoResistorVal <= sun_part_shade_threshold) {
    // sun_part_shade
    readings[1]++;
  } else {
    // full_sun
    readings[2]++;
  }
  if (moistureVal <= 0) {
    // none
    moistureReadings[0]++;
  } else if (moistureVal > 0 && moistureVal <= 50) {
    // minimum
    moistureReadings[1]++;
  } else if (moistureVal > 50 && moistureVal <= 75) {
    // minimum
    moistureReadings[2]++;
  } else {
    // frequent
    moistureReadings[3]++;
  }
  if (deviceConnected) {
    SensorReadings currReadings = averageReading();
    String sunlightResults;
    String moistureResults;
    switch((int) round(currReadings.moistureReading)) {
      case 0: moistureResults = "none"; break;
      case 1: moistureResults = "minimum"; break;
      case 2: moistureResults = "average"; break;
      case 3: moistureResults = "frequent"; break;
    }
    switch((int) round(currReadings.sunlightTag)) {
      case 0: sunlightResults = "part_shade"; break;
      case 1: sunlightResults = "sun_part_shade"; break;
      case 2: sunlightResults = "full_sun"; break;
    }
    String results = ("Sunlight: " + sunlightResults + ", Moisture: " + moistureResults);  
    int str_len = results.length() + 1; 
    char char_array[str_len];
    results.toCharArray(char_array, str_len);
    pCharacteristic->setValue(char_array); // Change this line to send the data you want 
    pCharacteristic->notify();
  }
  // read every minute
  delay(1000);
}

void resetReadings() {
  readings[0] = 0;
  readings[1] = 0;
  readings[2] = 0;
  moistureReadings[0] = 0;
  moistureReadings[1] = 0;
  moistureReadings[2] = 0;
  moistureReadings[3] = 0;
}

SensorReadings averageReading() {
  int total_readings = readings[0] + readings[1] + readings[2];
  int total_part_shade = readings[1] * 0;
  int total_sun_part_shade = readings[2] * 1;
  int total_full_sun = readings[3] * 2;


  int total_moisture_readings = moistureReadings[0] + moistureReadings[1] + moistureReadings[2] + moistureReadings[3];
  int total_none = moistureReadings[0] * 0;
  int total_minimum = moistureReadings[1] * 1;
  int total_average = moistureReadings[2] * 2;
  int total_frequent = moistureReadings[3] * 3;

  SensorReadings currSensor {
    float((total_part_shade + total_sun_part_shade + total_full_sun) / total_readings),
    float((total_none + total_minimum + total_average + total_frequent) / total_moisture_readings),
  };
  return currSensor;
}
