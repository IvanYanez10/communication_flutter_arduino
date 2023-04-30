#include <SoftwareSerial.h>
SoftwareSerial bt(11,10);  //RXT,TXD
void setup()
{
  bt.begin(38400);
  Serial.begin(9600); 
}
 
void loop()
{
  if(bt.available())
  {
    Serial.write(bt.read());
  }
 
  if(Serial.available())
  {
     bt.write(Serial.read());
  }
}
