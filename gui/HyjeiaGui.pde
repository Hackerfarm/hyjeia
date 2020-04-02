import controlP5.*;
import processing.serial.*;

Serial myPort; 
ControlP5 cp5;
ScrollableList portList;

String data = "0";
int dosCount = 0;
PImage img;
int horizOffset = 25;
int vertOffset = 200;
int indexPort = 0;

Dosimeter dos0;
//Dosimeter dos1;
//Dosimeter dos2;
//Dosimeter dos3;

void setup()
{
  size(700,500);
  cp5 = new ControlP5(this);
  
//  myPort = new Serial(this, "COM50", 57600); // Change this to your port
//  myPort.bufferUntil('\n');
    String[] portNames =Serial.list();
    
    portList = cp5.addScrollableList("dropdown") 
                  .setPosition(450, 0) 
                  .setSize(180, 100) 
                  .setBarHeight(20) 
                  .setItemHeight(20) 
                  .addItems(portNames) 
                  .setCaptionLabel("Please Select Port")
                  .setColorForeground(color(40, 128))
                  .setOpen(false)  
                  ;    
    
    
    dos0 = new Dosimeter(dosCount++);
//  dos1 = new Dosimeter(dosCount++);    
//  dos2 = new Dosimeter(dosCount++); 
//  dos3 = new Dosimeter(dosCount++); 
    
    img = loadImage("logo.png");

}

void draw()
{
  background(0);
  image(img, 50, 40);
  
  if (myPort != null)
  {
       while (myPort.available() > 0)
      {
          data = myPort.readStringUntil('\n');
          String[] vals = split(trim(data), ',');
          println(vals);
          dos0.intensityValue.setText(vals[0]);
          dos0.dosageValue.setText(vals[1]);
      }
  }
 
}

void dropdown(int n) 
{
    String port = cp5.get(ScrollableList.class, "dropdown").getItem(n).get("text").toString();
    println("Port " + port + " selected");
    myPort = new Serial(this, port, 57600);
}


