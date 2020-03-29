import controlP5.*;
import processing.serial.*;

Serial myPort; 
ControlP5 cp5;
ScrollableList portList;

String data = "0";
int dosCount = 0;
PImage img;
int horizOffset = 25;
int vertOffset = 150;
int indexPort = 0;

void setup()
{
  size(700,600);
  cp5 = new ControlP5(this);
  
//  myPort = new Serial(this, "COM50", 57600); // Change this to your port
//  myPort.bufferUntil('\n');
    String[] portNames =Serial.list();
    
    portList = cp5.addScrollableList("Available Ports") 
                  .setPosition(450, 0) 
                  .setSize(180, 100) 
                  .setBarHeight(20) 
                  .setItemHeight(20) 
                  .addItems(portNames) 
                  .setColorForeground(color(40, 128))
                  .setValue(indexPort)
                  .setOpen(false)  
                  ;    
    
    
    Dosimeter dos0 = new Dosimeter(dosCount++);
    Dosimeter dos1 = new Dosimeter(dosCount++);    
    Dosimeter dos2 = new Dosimeter(dosCount++); 
    Dosimeter dos3 = new Dosimeter(dosCount++); 
    
    img = loadImage("logo.png");

}

void draw()
{
  background(0);
  image(img, 50, 40);
}

class Dosimeter
{
    Dosimeter(int id)
    {
        Group thisGroup = cp5.addGroup("UV-C Dosimeter" + id)
                            .setPosition(horizOffset + 50,vertOffset + (id+1)*80)
                            .setBackgroundHeight(60)
                            .setWidth(550)
                            .setBackgroundColor(color(255,50))
                            ;               
                        
        Textlabel intensity = cp5.addTextlabel("intensity" + id,"Intensity:", 10, 10)
                                 .setFont(createFont("Arial",20))
                                 .setGroup(thisGroup)
                                 ;   
 
        Textlabel intensityValue = cp5.addTextlabel("intensityValue" + id,"000.000", 120, 10)
                                      .setFont(createFont("Arial",20))
                                      .setGroup(thisGroup)
                                      ;   
  
        Textlabel dosage = cp5.addTextlabel("dosage" + id,"Dosage:", 300, 10)
                              .setFont(createFont("Arial",20))
                              .setGroup(thisGroup)
                              ;  
                        
        Textlabel dosageValue = cp5.addTextlabel("dosageValue" + id,"000.000", 420, 10)
                                   .setFont(createFont("Arial",20))
                                   .setGroup(thisGroup)
                                   ;                             
    }
    
}

void controlEvent(ControlEvent theEvent)
{
  if(theEvent.getController() == portList)
  {
    println("port selected");
  }
}

void serialEvent(Serial myPort)
{
  data=myPort.readStringUntil('\n');
}
