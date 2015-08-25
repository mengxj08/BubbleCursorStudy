interface JavaScript {
}
void bindJavascript(JavaScript js) {
  javascript = js;
}
JavaScript javascript;
                     
int numpoints = 10; //number of points
int width = 1800;
int height = 750;
int clicks = 5;
int currmin = 0; //tracks index of nearest target
int secondmin = 0; //tracks index of second-nearest target
int currTarget = 0; //tracks index of target to click in test mode
int numHits = 0;
int numMisses = 0;
int runningTotalTime = 0;
int numClicks = 0;

float A;
float EW;
float radius;
float unit = 1.3;

//floats and float arrays to handle position, movement, timing
float x, y;              //old cursor position
float cursorX, cursorY;  //cursor position
float[] pointsX, pointsY;
float[] diameter;
float[] containDistances;
float[] intersectDistances;
float[] distances;
float cursorDiameter;
float startTime=0;
float timeElapsed=0;

int[] movementTimes = new int[clicks-1];

//booleans to track program mode and bubble behavior
boolean morphed; //tracks if the bubble needs to be morphed
boolean regularCursor; //turns off the bubble cursor entirely
boolean testMode; // activates the target-timing test
boolean infoOn=true; //displays useful information, deactivate with "i"
boolean collisionsFound; //used only in initializing points to prevent overlap
boolean init = true; //initial setup for layout of bubbles
boolean bubbleCursor; 
boolean passDataToJS = true;

void startTest(){
  startTime = millis();
  int oldTarget = currTarget;
  while (currTarget == oldTarget){
    currTarget = abs(oldTarget - 1);  
  }
}

void mousePressed(){
 numClicks++;
 if (testMode)
 {
   if (currmin==currTarget)
   {
     timeElapsed = millis()-startTime;
     runningTotalTime += timeElapsed;
     
     if(numHits > 0){
       movementTimes[numHits-1] = (int)timeElapsed;
     }
     numHits++;
     startTest();
     //println(numHits);
   }
   else
   {
      numMisses++;
   }
 }
}

void initializePoints(float x,float y,float d) { // x amplitude, y effective width, d
  pointsX = new float[numpoints];
  pointsY = new float[numpoints];
  diameter = new float[numpoints];
  
  containDistances = new float[numpoints];
  intersectDistances = new float[numpoints];
  distances = new float[numpoints];

  pointsX[0] = width/2 - x/2;
  pointsY[0] = height/2;
  pointsX[1] = width/2 + x/2;
  pointsY[1] = height/2;
  
  float padding = (y + d)*2 + 1;
  pointsX[2] = pointsX[0];
  pointsY[2] = height/2 - padding;
  pointsX[3] = pointsX[0];
  pointsY[3] = height/2 + padding;
  
  pointsX[4] = pointsX[0] - padding;
  pointsY[4] = pointsY[0];
  pointsX[5] = pointsX[0] + padding;
  pointsY[5] = pointsY[0];
  
  pointsX[6] = pointsX[1];
  pointsY[6] = height/2 - padding;
  pointsX[7] = pointsX[1];
  pointsY[7] = height/2 + padding;
  
  pointsX[8] = pointsX[1] - padding;
  pointsY[8] = pointsY[1];
  pointsX[9] = pointsX[1] + padding;
  pointsY[9] = pointsY[1];

  for(int i = 0; i < numpoints; i++)
     diameter[i] = d;
}

void decideTrial()
{
    // for all trials the information will not be displayed to the user
  infoOn = false;
  testMode = true;
  regularCursor = false;
  numClicks = 0;
  numHits = 0;
  numMisses = 0;
  initializePoints(A,EW,radius);
  startTest();
}

void setup() 
{
  size(width, height); 
  smooth();
  noStroke();
}
void draw() 
{ 
  if(init)
  {
//    if(javascript != null)
//    {
      //radius = javascript.ID3;

//      switch(javascript.ID2)
//      {
//        case 25:
//          Xrows = Ycols = 5;
//          break;
//        case 36:
//          Xrows = Ycols = 6;
//          break;
//        case 64:
//          Xrows = Ycols = 8;
//          break;
//        default:
//          println("ID2: No matched in SWITCH");
//          break;
//      }

//      if(javascript.ID1 == "Bubble")
//        bubbleCursor = true;
//      else
//        bubbleCursor = false;
      
      bubbleCursor = true;
      init = false;
      
      A = 768 * unit;
      EW = 96 * unit;
      radius = 24 * unit;
      decideTrial();
//    }
   }
   else if(bubbleCursor)//This is for the Bubble Cursor
   {
  if(numHits == clicks){
    currTarget = numpoints + 1;
    background( 51 );
    fill(0, 102, 153);
    textSize(50);
    text("Please click the \"Next task\" buttion...", width/2 - 350, height/2);
    if(passDataToJS){
      passDataToJS = false;
      javascript.passDataToJS(runningTotalTime,numMisses);
    }
    return;
  }

  background( 51 );
  cursorX = mouseX;  
  
  //here we follow the strategy on processing.org's tutorial for tracking mouse movement
  float dx = cursorX - x; //change in xposition
  if(abs(dx) > 1) { 
    x += dx;               
  }
  
  cursorY = mouseY;
  float dy = cursorY - y; //change in yposition
  if(abs(dy) > 1) {
    y += dy;
  }
  morphed=false; //true iff we need a morphed cursor bubble
  currmin=0; 
  secondmin=0;

  //compute distances to center, outermost and innermost
  //sides of all neighbors
  for (int i=0; i<pointsX.length; i++)
  {
    distances[i] = dist(x,y,pointsX[i],pointsY[i]); //distance to centers
    containDistances[i] = distances[i] + diameter[i]; //distance to contain
    intersectDistances[i] = distances[i]-(diameter[i]/2); //distance to intersect
    
    //find the nearest neighbor
    if ((intersectDistances[i]< intersectDistances[currmin]))
    {

      currmin=i;
    }
  }
  
    cursorDiameter = 2*distances[currmin] + diameter[currmin];
    
  //find the second-nearest neighbor, if needed
  for (int i=0;i<pointsX.length;i++){
    
    //check if we intersect the ith point, and if so, if the ith point is smaller
    if (!regularCursor && (i!= currmin) && (cursorDiameter/2 > intersectDistances[i])){
      morphed=true;
      secondmin = i;
      cursorDiameter = 2*intersectDistances[i];
    }
  }

  fill(255,200,200);
  
  if (morphed && !regularCursor)
  {
    ellipse(pointsX[currmin], pointsY[currmin], diameter[currmin]+10, diameter[currmin]+10 );
    
 }
  if (!regularCursor){
    ellipse(x, y, cursorDiameter, cursorDiameter);
  }
  
  //draw targets
  fill(234,211,237);
  for (int i=0;i<pointsX.length;i++){  
    if (testMode && (i ==currTarget))
    {
      // target color
      fill(0,255,102);
      ellipse(pointsX[i],pointsY[i],diameter[i],diameter[i]);
      fill(234,211,237);
    }
    else{
      ellipse(pointsX[i],pointsY[i],diameter[i],diameter[i]);
    }
  }
 }
 else if(!bubbleCursor)//This is the test for traditional pointing mouse test
 {
    if(numHits == clicks){
    currTarget = numpoints + 1;
    background( 51 );
    fill(0, 102, 153);
    textSize(50);
    text("Please click the \"Next task\" buttion...", width/2 - 350, height/2);
    if(passDataToJS){
      passDataToJS = false;
      javascript.passDataToJS(runningTotalTime,numMisses);
    }
    return;
  }

  background( 51 );
  cursorX = mouseX;  
  
  //here we follow the strategy on processing.org's tutorial for tracking mouse movement
  float dx = cursorX - x; //change in xposition
  if(abs(dx) > 1) { 
    x += dx;               
  }
  
  cursorY = mouseY;
  float dy = cursorY - y; //change in yposition
  if(abs(dy) > 1) {
    y += dy;
  }
  currmin=0; 

  //compute distances to center
  for (int i=0; i<pointsX.length; i++)
  {
    float distanceToBubbleCenter = dist(x,y,pointsX[i],pointsY[i]); //distance to centers
    //find the current bubble that pointer is in
    if (distanceToBubbleCenter <= diameter[i])
    {
      currmin=i;
      break;
    }
  }
  //draw targets
  fill(234,211,237);
  for (int i=0;i<pointsX.length;i++){  
    if (testMode && (i ==currTarget))
    {
      // target color
      fill(0,255,102);
      ellipse(pointsX[i],pointsY[i],diameter[i],diameter[i]);
      fill(234,211,237);
    }
    else{
      ellipse(pointsX[i],pointsY[i],diameter[i],diameter[i]);
    }
  }
 }
 else
 {
   println("No match in bubbleCursor");
 }
}







