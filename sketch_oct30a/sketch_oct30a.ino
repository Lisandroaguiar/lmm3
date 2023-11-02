int incomingByte = 0; // for incoming serial data
int pinLed = 3;
int controlarVariabilidad = 0;
bool estaSumando=true;
bool estaRestando;
void setup() {
  Serial.begin(9600); // opens serial port, sets data rate to 9600 bps
  pinMode(pinLed, OUTPUT);
}

void loop() {
  // send data only when you receive data:
  if (Serial.available() > 0) {
    // read the incoming byte:
    incomingByte = Serial.read();

    // say what you got:
    Serial.print("I received: ");
    Serial.println(incomingByte, DEC);
  }
  if (incomingByte == 0) {
    digitalWrite(pinLed, LOW);
  }

  if (incomingByte == 1) {
    analogWrite(pinLed, controlarVariabilidad);
          if(controlarVariabilidad>=255){estaRestando=true;
          estaSumando=false;}
           if(controlarVariabilidad<=0){estaSumando=true;
          estaRestando=false;}

    if (estaSumando) {
      controlarVariabilidad++;
      
    }

  if ( estaRestando) {
    controlarVariabilidad--;
  }
  delay(4);
    }
}
