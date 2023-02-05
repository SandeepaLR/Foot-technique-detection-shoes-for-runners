 #include <SoftwareSerial.h>

SoftwareSerial btSerial(10, 11); //RX, TX
int input_1, input_2, input_3, input_4, input_5;
int fR = 0;
int fL = 0;
int hE = 0;
String result_1 ="Correct heel technique \n";
String result_2 ="Correct forefoot technique \n";
void setup()
{
  Serial.begin(9600);
  btSerial.begin(9600);
}

void loop()
{
  //Read inputs
  input_1 = analogRead(A1);
  input_2 = analogRead(A0);
  input_3 = analogRead(A2);
  input_4 = analogRead(A3);
  input_5 = analogRead(A7);

//  Display Values
//  LOGIC
//Serial.print("A0 ");
//Serial.println(input_1);
//Serial.print("A1 ");
//Serial.println(input_2);
//
//Serial.print("A2 ");
//Serial.println(input_3);
//Serial.print("A3 ");
//Serial.println(input_4);
//Serial.print("A4 ");
//Serial.println(input_5);

  if (input_1 > 100 || input_2>100) {
    if (input_1 > input_2) {

      hE++;
      if (hE == 5) {
        result_1="Wrong heel technique";
        Serial.println("Wrong heel technique");
        hE = 0;
      }
    }
    else {
      result_2="Correct heel technique";
      Serial.println("Correct heel technique");
    }
  }
  if (input_3 > 80 || input_4 > 80 || input_5 > 80 ) {
    input_4 = input_4 + 20;
    if (input_4 > input_3) {
      if (input_4 > input_5) {
        result_2="Correct forefoot technique\n";
        Serial.println("Correct forefoot technique");
      }
      else {
        fL++;
        if (fL == 5) {
          result_2="Supination\n";
          Serial.println("Supination");
          fL = 0;
        }

      }
    }
    else {
      if (input_3 > input_5) {
        fR++;
        if (fR == 5) {
          result_2 = "Overpronation\n";
          Serial.println("Overpronation");
          fR = 0;
        }

      }
      else {
        fL++;
        if (fL == 5) {
          result_2="Supination\n";
          Serial.println("Supination");
          fL = 0;
        }

      }
    }

  }
    btSerial.println(result_1);
    btSerial.println(result_2);
  delay(150);
}
