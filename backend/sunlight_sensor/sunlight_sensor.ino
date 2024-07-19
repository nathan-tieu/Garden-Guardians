#include <SoftwareSerial.h>

SoftwareSerial Bluetooth(10, 11); // RX, TX

int photoResistorPin = A0;
int photoResistorVal = 0;
int full_shade_threshold = 70;
int part_shade_threshold = 140;
int sun_part_shade_threshold = 210;
int readings[4] = {
  0, // full_shade
  0, // part_shade
  0, // sun_part_shade
  0  // full_sun
};
char full_shade[] = "full_shade";
char part_shade[] = "part_shade";
char sun_part_shade[] = "sun-part_shade";
char full_sun[] = "full_sun";
char* sunlight_intensity_tags[4] = {
  full_shade,
  part_shade,
  sun_part_shade,
  full_sun
};

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Bluetooth.begin(9600);
}

void loop() {
  if (Bluetooth.available()) {
    char r = Bluetooth.read();
    Serial.write(r);
    char w = Bluetooth.write(sunlight_intensity_tags[round(averageReading())]);
    Serial.write(w);
    resetReadings();
  }
  // put your main code here, to run repeatedly:
  photoResistorVal = analogRead(photoResistorPin);
  if (photoResistorVal <= full_shade_threshold) {
    // full_shade
    readings[0]++;
  } else if (photoResistorVal > full_shade_threshold && photoResistorVal <= part_shade_threshold) {
    // part_shade
    readings[1]++;
  } else if (photoResistorVal > part_shade_threshold && photoResistorVal <= sun_part_shade_threshold) {
    // sun_part_shade
    readings[2]++;
  } else {
    // full_sun
    readings[3]++;
  }
  // read every minute
  delay(60000);
}

void resetReadings() {
  readings[0] = 0;
  readings[1] = 0;
  readings[2] = 0;
  readings[3] = 0;
}

float averageReading() {
  int total_readings = readings[0] + readings[1] + readings[2] + readings[3];
  int total_full_shade = readings[0] * 0;
  int total_part_shade = readings[1] * 1;
  int total_sun_part_shade = readings[2] * 2;
  int total_full_sun = readings[3] * 3;
  return float(total_full_shade + total_part_shade + total_sun_part_shade + total_full_sun) / total_readings;
}