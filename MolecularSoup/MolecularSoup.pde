                    //*******************MOLECULAR SOUP*******************//
                    //*****************by DEEPAK GOPINATH******************//
                    
                    //************* Project 1 - Graphical Tool ***************//
                    //********************  LMC 6310 ***********************//


ArrayList organismList = new ArrayList(); // List containing all organisms.
float growthThreshold = 0.94; //The actual growth threshold for random node generation
int growthValueDisplay = 10; //The display value for the user. 

int startFlag = 0; //Flag to keep track of front page, instruction page etc...
float colorPerlin = 0;

void setup()
{
  size(640, 480, P3D);
  background(0);
  fill(255);
  noStroke();
}



void draw()
{
  background(0);
 
  
  if(startFlag == 0){
    
    //FRONT PAGE
 
    fill(255,25, 0);
    textAlign(CENTER);
    textSize(38);
    text("MoLeCulAr sOuP", width/2 , height/2 - 100);
    textSize(22);
    text("CrEAted bY", width/2, height/2 - 40);
    textSize(28);
    text("DeEpaK goPiNatH", width/2, height/2 + 15 );
    textSize(20);
    fill(255,255,0);
    text("Hit Space to Continue", width/2, height/2 + 170);
    
  }else if(startFlag == 1){
    
    //INSTRUCTION PAGE
    
    fill(255,25, 0);
    textAlign(CENTER);
    textSize(30);
    text("How to Use!", width/2, height/2 - 150);
    textSize(18);
    
    text("Click anywhere to instantiate a molecular cluster", width/2, height/2 - 40);
    text("Click 'H' or 'L' at the top right corner to change the growth rate", width/2, height/2 + 20);
    text("Click and drag the mouse and wait to see the whole system ", width/2, height/2 + 80);
    text("sway towards the direction of mouse movement", width/2, height/2 + 100);
    fill(255,255,0);
    textSize(20);
    text("Hit Space to Continue", width/2, height/2 + 170);
  }
  
  else if(startFlag > 1) {
  
  //Render the spheres
  background(0);
  stroke(3);   // Display the growth rate and also draw the up and down buttons
  fill(0,255, 0);
  textAlign(CENTER);
  textSize(18);
  text("Growth Rate", 580, 30);
  textSize(18);
  text("H", 580,50);
  text(growthValueDisplay, 580, 85);
  text("L", 580, 120);
  
  //Set up some lighting which glimmers
  
  colorPerlin = colorPerlin + 0.05;
  directionalLight(map(noise(colorPerlin), 0, 1, 10, 200), map(noise(1002+ colorPerlin), 0, 1, 10, 255), map(noise(2000+ colorPerlin), 0, 1, 160, 200), 0, 0, -1); // Set up some directional lighting. White Light shining from -z direction
  lightSpecular(204, 204, 204);
  directionalLight(102, 102, 102, 0, 1, -1);  
  lightSpecular(102, 102, 102);
  
  noStroke();
  fill(255);
  
  for(int i=organismList.size() - 1; i >= 0; i--) // Render each organism. Do the loop in the reverse order so that the list
                                                  //   can be dynamically modified within the loop and still we would not miss an organism
    {
      Organism individual = (Organism)organismList.get(i);
      
      if(!individual.isDead()){ // Check if dead. If not continue with rendering.
      
           individual.updateAlphaMultiplier(organismList.size()); // The rate at which each organism dies becomes faster as the number of
                                                                  // organisms in the environment goes higher.
       
           if(!individual.isAboutToDie())// If it is about to die, trigger decayFunction, if not continue with growth
              individual.growthFunction(growthThreshold); 
            else
              individual.decayFunction();
              
       
          individual.updateLocation();
          individual.drawOrganism();
      }else {
        organismList.remove(i); /// If the organism is dead, remove it from the organism List, so that memory is not wasted
      }
      }//for loop

  }
}//function end

void mouseReleased()
{
  if(startFlag > 1){ // To make sure mouse clicks will instantiate the organism ONLY after the front and instruction page have been already passed
  if(!((mouseX > 560 && mouseX < 610) && 
      ((mouseY > 40 && mouseY < 70) || (mouseY > 110 && mouseY < 140) || (mouseY > 20 && mouseY < 60)))){
   //To check whether the click was in the growth rate/up/down boxes or not  
      organismList.add(new Organism()); 

   }else{
  
    if(mouseY > 40 && mouseY < 70)
       updateGrowthParam(1);   // If "UP" button was pressed
    else if(mouseY > 110 && mouseY < 140)
       updateGrowthParam(-1); // If "DOWN" button was pressed.
       
   }
  } 
}

void keyPressed(){ //Keeping track of space bar hits to increment the flag.
   
    if(key == ' ')
      startFlag += 1 ;
  
}

void updateGrowthParam(int direction){
  
    if(direction ==  1){ //If direction was up, reduce the actual randomization threshold, so that the rate is higher
      
      growthThreshold = growthThreshold - 0.005;
      if(growthThreshold <= 0.89)
        growthThreshold = 0.89;
      
      growthValueDisplay = growthValueDisplay + 1;
      
      
    }else if (direction == -1){ //If direction was down, increase the actual randomization threshold, so that the rate is lower
      growthThreshold = growthThreshold + 0.005;
      if(growthThreshold >= 0.99)
        growthThreshold = 0.99;
      
      growthValueDisplay = growthValueDisplay - 1;
     
    }

    if(growthValueDisplay >= 20) // Bound the display value between 1 and 20
         growthValueDisplay = 20;
     if(growthValueDisplay <= 1)
        growthValueDisplay = 1;
}

void mouseDragged() 
{
  PVector currentMousePoint = new PVector(mouseX, mouseY,0);
  PVector oldMousePoint = new PVector(pmouseX, pmouseY,0);  
  
  PVector accelVector = PVector.sub(currentMousePoint, oldMousePoint); //To determine the direction of motion of the organisms
  accelVector.normalize(); //Just needs the direction
  
  for(int i=0; i < organismList.size(); i++)
  {
    Organism individual = (Organism)organismList.get(i);
    individual.applyForce(accelVector);
  }

}
