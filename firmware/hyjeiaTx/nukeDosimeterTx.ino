#include "LiquidCrystal_I2C.h"
#include "chibi.h"

#define DEST_ADDR               0x5
#define LCD_ADDRESS             0x27
#define DARK_THRESHOLD          0.05
#define AVG_CYCLES              1000
#define REF_VOLTAGE             3.3
#define TRANSIMPEDANCE_GAIN     10000000
#define VOLTAGE_GAIN            4.3
#define RESPONSIVITY            0.04
#define DIE_SIZE                0.00076
#define CONSTANT (VOLTAGE_GAIN*TRANSIMPEDANCE_GAIN*RESPONSIVITY*DIE_SIZE)

LiquidCrystal_I2C lcd(LCD_ADDRESS, 16, 2);

float dosage = 0.0;
uint32_t startTime;
char buf[50];
uint8_t payload[100];

void setup()
{    
    Serial.begin(57600);
    Serial.println("NukeDosimeter UV-C Dosimeter v0.5");

    chibiInit();
    
    lcd.begin();   
    lcd.print("Nuke Dosimeter");
    lcd.setCursor(0, 1);
    lcd.print("v0.5");
    delay(5000);
    lcd.clear();
    lcd.setCursor(0, 0);
}

void loop()
{   
    uint8_t *pbuf;
    uint16_t sensorVal;
    uint32_t sensorSum = 0;
    uint32_t elapsedTime;
    float sensorAvg, sensorVoltage, intensity;

    // start timer to measure time interval for dosage
    startTime = millis();

    // average ADC values over many readings
    for (int i=0; i<AVG_CYCLES; i++)
    {
        sensorVal = analogRead(A0);
        sensorSum += sensorVal;
        delay(2);
    }
    sensorAvg = (float)sensorSum / (float)AVG_CYCLES;

    // convert ADC value to voltage
    sensorVoltage = sensorAvg * (REF_VOLTAGE / 1024.0);

    // if voltage is below our "dark" threshold, assume there is no UV light.
    // it's just noise. 
    if (sensorVoltage < DARK_THRESHOLD)
    {
        sensorVoltage = 0.0;
    }
    
    Serial.print(sensorVoltage); 
    Serial.print(",: ");    

    /* 
     * Intensity is calculated based on voltage
     * totalCurrent = voltage / (VOLTAGE_GAIN * TRANSIMPEDANCE_GAIN) 
     * totalPower = totalCurrent / RESPONSIVITY 
     * intensity = totalPower / DIE_SIZE
     * 
     * For  reference
     * VOLTAGE_GAIN = 4.3 and comes from the circuit configuration
     * TRANSIMPEDANCE_GAIN = 10x10^6 and comes from the feedback resistor on the transimpedance amplifier
     * RESPONSIVITY = 0.04 A/W at 260 nm and comes from the GUVA-S12SD datasheet
     * DIE_SIZE = 0.076 mm^2 = 0.00076 cm^2 and comes from the GUVA-S12SD datasheet
     */

    // intensity is in mW/cm^2
    intensity = sensorVoltage * 1000.0 / CONSTANT; 
    Serial.print(intensity); 
    Serial.print(", ");

    //calculate dosage
    // average dosage is calculated by multiplying intensity * elapsed time
    // measured in mW*s/cm^2
    // total dosage will be accumulated until the system is reset
    elapsedTime = millis() - startTime;
    dosage += intensity * (elapsedTime/1000.0);
    
    Serial.print(dosage); 
    Serial.println(); 

    // print to LCD
    lcd.setCursor(0, 0);
    lcd.print("Intensity: ");
    memset(buf, 0, sizeof(buf));
    dtostrf(intensity, 5, 3, buf);
    lcd.print(buf);

    lcd.setCursor(0, 1);
    lcd.print("Dosage: ");
    memset(buf, 0, sizeof(buf));
    dtostrf(dosage, 8, 3, buf);
    lcd.print(buf);    

    // we're going to send the data. First copy it all 
    // into temporary buffer we will send.
    // using a pointer since it's easier to work with
    pbuf = payload;
    memcpy(pbuf, &intensity, sizeof(intensity));
    pbuf += sizeof(intensity);
    memcpy(pbuf, &dosage, sizeof(dosage));
    pbuf += sizeof(dosage);

    // send the data wirelessly. the len of the payload 
    // is (pbuf - buf) which is just the number of bytes 
    // pbuf is currently at from the beginning of buf
    chibiTx(DEST_ADDR, payload, pbuf - payload);
}
