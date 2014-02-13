
class Organism{
  
 
  PVector organismCenterLoc3D; // Origin of the organism with respect to top left corner of the window
  PVector translationVelocity; //The component of translational velocity that will be affected gusts of wind.
  PVector jiggleVelocity;      //The component of translational velocity that will be affected by jiggles

 
  float blendFactor; float green, blue;
  
  //*******Lists for nodes and parents***********
  
  ArrayList nodeList;
  ArrayList parentList;
  
  
  float OrganismLifeMultiplier; // This variable will be dynamically updated before the growth(), decay() and also from the main sketch as other organism die and take birth. 
  float lifeTime;
  
  float theta, translateStepSize;
  
  color colorAliveOrganism;
  color colorDyingOrganism;
  
  
  
  ///******Constructor*********
  
  Organism(){
     
      //The multiplier variable should be assigned depending on how many other organism are already out there...So when an organism take birth, if there are already lot of organisms in the pool it wont have resources to live long thereofre the lifetime variable will be small
  //The constructor is only called at the BEGINNING of the life cycle of an organism. That is the constructor will be called when the mouse is clicked. 
  //The constructor will add the first node (sphere) to the node list. The first node will be centered at the origin of the coordinate system associated with the organism (this coordinate
  //system will have its origin at mouseX, mouseY and big -ve z.
    
    nodeList = new ArrayList();
    parentList = new ArrayList();
    colorAliveOrganism = color(255); //Pure white for the time being
    colorDyingOrganism = color(255, 255, 255);  //To facilitate blending from white to red
    
    organismCenterLoc3D = new PVector(mouseX, mouseY, 0); //Center of the organism with respect to world coordinates;
    translationVelocity = new PVector(0,0,0);
    
    PVector firstNodeCenter = new PVector(0,0,0); //First node is at the origin of the coordinate system assocaited with the organism. 
    nodeList.add(new Node(firstNodeCenter, 10 + random(40), true)); //initialize and allocate the first element of the node list and add it to the node list array.
    parentList.add(-1); // make the first element of parentList to be -1 indicating no parent for node number 1.
    
    
    OrganismLifeMultiplier = 1;
    theta = 0;
    translateStepSize = random(2000); //The param for PerlinNoiseStep size.
    lifeTime = 200 + random(150);
    blendFactor = 0.97;
    green = 255;
    blue = 255;
    
  }
  
  //*********Member functions*****************
  
  
  ///************Update Functions - Movement and Lifetime*****************
  void updateAlphaMultiplier(float multiplier){
    
    OrganismLifeMultiplier = multiplier;
  }
  
   void updateLifetime(){
    
   lifeTime -= 0.4*OrganismLifeMultiplier;
    if(lifeTime<= 0)
      lifeTime= 0;
  }
  
  void updateRotational(){
    
    rotateX(map(noise(theta), 0, 1, 0, TWO_PI));
    rotateY(map(noise(theta + 1000), 0, 1, 0, TWO_PI));
    rotateZ(map(noise(theta + 2000), 0, 1, 0, TWO_PI));
    theta += 0.005;
  }
  
    void jiggle(){
    
    translateStepSize += 0.05;
    float randomTemp = random(1);// (A number between 0 and 1)  
    float stepSizeX = map(noise(translateStepSize), 0, 1, -4, 4);  // Brownian motion kind of behaviour using perlin noise
    float stepSizeY = map(noise(translateStepSize+3000), 0, 1, -4, 4);
    
    jiggleVelocity = new PVector(stepSizeX, stepSizeY, -random(-2, 6)); //The z coordinate is constantly reduced during the jiggle so 
                                                                    //that the organism recedes further and farther away from the user
  }       
  
  void updateLocation(){
    
    jiggle(); //This is always happening. So include it in the beginning of updateLocation
    effectOfPush();
     
    organismCenterLoc3D.add(translationVelocity);  // Gust of wind  triggered by mouse dragging.
    organismCenterLoc3D.add(jiggleVelocity);   //always happening   

    checkEdges(); 
   
  }
  
  ///******************************Force and edge detection************************
  
  void effectOfPush(){
       translationVelocity.mult(1.1);
  }
  
//  void fluidResistance(){
//    
////   if(translationVelocity.mag() >= 60){
////     translationVelocity.mult(0.89);   
//     if(translationVelocity.mag() < 20)
//       translationVelocity.mult(0);
//   
//  }
  
  void checkEdges(){
    
   if(organismCenterLoc3D.x < 0)
       organismCenterLoc3D.x = 0;
  
    if(organismCenterLoc3D.x > width)
      organismCenterLoc3D.x = width;
    
    if(organismCenterLoc3D.y < 0)
      organismCenterLoc3D.y = 0;
    
    if(organismCenterLoc3D.y > height)
      organismCenterLoc3D.y = height;
  }
  
  void applyForce(PVector force){
     translationVelocity = new PVector(force.x, force.y, 0);
 
  }
  


///*************Growth and Decay Functions***********************

  void growthFunction(float growthThreshold){
  // This is the method where new nodes will be added randomly(or this is the place to implement growth algorithms
  // This will add new nodes to the node list. when a new node is being created a random node from the existing list is taken and made a parent node to this new born node. 
  //As the organism grows the z becomes more and more positive
  //Do not add a node EVERYTIME the growth is called...The organism will be a super monster...
  
  float growthRand = random(1);
  
  if(abs(growthRand) > growthThreshold){ // Two levels of threshold so that the organism dont end up becoming a MONSTER!! 
      float secondGrowthRand = random(1);
      if(abs(secondGrowthRand) > 0.2){
        
        int randParent = (int)random(5000) % nodeList.size(); // Choose a random parent from the existing node list for the next new born node. 
        parentList.add(randParent); //Add the new parent index to the parentList
        
        Node parentNode = (Node)nodeList.get(randParent); 
        
        float parentRadius = parentNode.radius;
        PVector parentCenterLoc = parentNode.centerLoc.get();
        
        float distOfNewNodeFromParentCenter = parentRadius + random(500)%(parentRadius - 20) + 20; // Created a random combined radii for parent and child
        float newNodeRadius = distOfNewNodeFromParentCenter - parentRadius;  // Extract the value for child radius, needed while we instantiate a new node
        float combinedRadius = parentRadius + newNodeRadius;
        
        float randTheta = random(TWO_PI);  // Spherical coordinates - random theta and phi. to determine the direction of growth.
        float randPhi = random(TWO_PI) - PI; //azimuthal angle
        
        PVector vectorBetweenSpheres = new PVector(combinedRadius*sin(randTheta)*cos(randPhi),
                                                   combinedRadius*cos(randTheta)*cos(randPhi),
                                                   combinedRadius*sin(randPhi));
        
        PVector newNodeCenterLoc = PVector.add(parentCenterLoc,vectorBetweenSpheres); //Calculate new sphere center vector. This is with respect to the center of the organism
        nodeList.add(new Node((newNodeCenterLoc), newNodeRadius, false));    // Add a new sphere to the node list.
        
      
       // colorAliveOrganism = color(255, 255,255);
        fill(colorAliveOrganism, 255);   
     
      } //secondGrowthRand If Statement
    } //growthRand IFstatement
    
  }  //End of FunctionBRace;

  void decayFunction(){
    
    green = green*blendFactor; // slowly blend from white to red. decrease green and blue equally by a constant factor everytime the decay Function is called..
    blue = blue*blendFactor;
    
    
    colorDyingOrganism = color(255, green, blue);
    fill(colorDyingOrganism, 255);
    
    for(int i=0; i<nodeList.size(); i++){ // To have the individual nodes fly apart, by moving the spheres along the lines connecting the center of the organism and the node center
      Node node = (Node)nodeList.get(i);
      node.moveOutwards();
    }  
  }
  
  void drawOrganism(){
    
    pushMatrix();
    updateLifetime();
   
    translate(organismCenterLoc3D.x,organismCenterLoc3D.y, organismCenterLoc3D.z); // translate to organism center
    updateRotational(); //Topple the organism a little bit
    
    for(int i=0; i<nodeList.size(); i++){
      Node node = (Node)nodeList.get(i);
      node.drawNode(); // Render each node with respect to the organism center.
    }  
   
    popMatrix();
 
    fill(colorAliveOrganism, 255); // This is needed here or else after one organism dies, everything else after that will be ready.. 
                                   //  We have to reset the alive color everytime this func is called.
  }  
  
  
  ///*********Checking state functions****************
  
  
   boolean isDead(){
     
    if(lifeTime<= 40) // If the lifeTime drops below 50 declare the organism to be dead so that it can be removed from the main list
      return true;
    else
     return false;
  }
  
  boolean isAboutToDie(){ // Indicator for when to trigger the decay sequence
    
    if(lifeTime<= 120)
      return true;
    else
      return false;
  }
  
} // End of Class
