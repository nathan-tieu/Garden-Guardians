int photoResistorPin = A0;
int photoResistorVal = 0;
int shady = 70;
int sunny = 140;

void setup() {
  // put your setup code here, to run once:

}

void loop() {
  // put your main code here, to run repeatedly:
  photoResistorVal = analogRead(photoResistorPin);
  if (photoResistorVal <= shady) {
    // is shady
  } else if (photoResistorVal > shady && photoResistorVal <= sunny) {
    // is partially shady
  } else {
    // is sunny
  }
  // read every second
  delay(1000);
}
