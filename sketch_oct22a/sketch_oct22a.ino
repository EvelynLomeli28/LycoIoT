/*
#include "BluetoothSerial.h"

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run make menuconfig to and enable it
#endif

BluetoothSerial puerto;

void setup() {
  puerto.begin("espinf32");
  Serial.begin(115200);

}

void loop() {
  int pot = analogRead(32);
  int n2 = random(1,100);
  String n = String(n1)+ "," + String(n2);
  int mappot = map(pot,0,4095,0,100);
  puerto.println(n);
  Serial.println(n);
  delay(1000);
}
*/
#include <DHT.h>
#include "BluetoothSerial.h"

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run make menuconfig to and enable it
#endif

BluetoothSerial puerto;
#define DHTTYPE DHT11
#define led 5
#define buz 4
#define lrd 34
#define po 35
#define DHTPIN 2

DHT dht(DHTPIN, DHTTYPE);
void setup() {
  pinMode(led,OUTPUT);
  pinMode(buz,OUTPUT);
  puerto.begin("ESPINFO");
  Serial.begin(115200); 
  dht11.begin();
}
void loop() {
  delay(2000);
  int pot = analogRead(po);
  potm= map(pot,0,4095,0,150)
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  float f = dht.readTemperature(true);
  /*
  int h = random(1,50);
  int t = random(1,50);
  int f= random(1,50);
  */
  String datos = String(h)+","+String(t)+","+String(f)+","+String(potm);
  //Serial.print("Humedad: ");
  //Serial.print(h);
  //Serial.print(",");
  //Serial.print("%  Temperatura: ");
  //Serial.print(t);
  //Serial.print(",");
  //Serial.print("°C  ");
  Serial.println(datos);
  puerto.println(datos);
  //Serial.println("°F");
  delay(500);
}