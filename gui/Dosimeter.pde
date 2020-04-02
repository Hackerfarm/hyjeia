class Dosimeter
{
    Textlabel intensity;
    Textlabel intensityValue;
    Textlabel dosage;
    Textlabel dosageValue;
    
    Dosimeter(int id)
    {
        Group thisGroup = cp5.addGroup("UV-C Dosimeter" + id)
                            .setPosition(horizOffset + 50,vertOffset + (id+1)*80)
                            .setBackgroundHeight(60)
                            .setWidth(550)
                            .setBackgroundColor(color(255,50))
                            ;               
                        
        intensity = cp5.addTextlabel("intensity" + id,"Intensity:", 10, 10)
                                 .setFont(createFont("Arial",20))
                                 .setGroup(thisGroup)
                                 ;   
 
        intensityValue = cp5.addTextlabel("intensityValue" + id,"000.000", 120, 10)
                                      .setFont(createFont("Arial",20))
                                      .setGroup(thisGroup)
                                      ;   
  
        dosage = cp5.addTextlabel("dosage" + id,"Dosage:", 300, 10)
                              .setFont(createFont("Arial",20))
                              .setGroup(thisGroup)
                              ;  
                        
        dosageValue = cp5.addTextlabel("dosageValue" + id,"000.000", 420, 10)
                                   .setFont(createFont("Arial",20))
                                   .setGroup(thisGroup)
                                   ;                             
    }
    
}

