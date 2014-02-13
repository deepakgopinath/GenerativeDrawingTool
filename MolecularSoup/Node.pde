// Class describing each node of the organism with respect to the organism's center.

class Node{

  PVector centerLoc; //This is wrt the organism center.
  float radius;    //Final radius of the sphere
  float radInc;   // variable to keep track of increasing radius
  boolean isFirst; //Bool to keep track of the first sphere in the organism. This sphere does not grow with time...but is drawn at the full radius
                   //right in the beginning itself
  float perlinInc; //Perlin noise param.

  
  Node(PVector center, float rad, boolean setIsFirst){
    
  this.centerLoc = center.get();
  radius = rad;
  radInc = 0;
  isFirst = setIsFirst;
  perlinInc = 0;
 
  }
  
  void drawNode(){
    
    pushMatrix();
    shininess(map(noise(perlinInc), 0, 1, 10, 50)); // random shininess for the sphere.
    
    radInc += 0.3;
    if(radInc >= radius)
      radInc = radius;
      
    translate(centerLoc.x,centerLoc.y,centerLoc.z); 
    
    if(!isFirst)
      sphere(radInc);
    else
      sphere(radius); // The central node doesnt grow...it is drawn at the full radius right from the beginning. 
      
    popMatrix();
  
    perlinInc += 0.7;
  }
  
  void moveOutwards(){ // The organism breaks apart and the nodes will fly away from each other.
    centerLoc.mult(1.053);
  }
  
}
