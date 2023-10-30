// import libraries
import KinectPV2.*;

// declare variables
KinectPV2 kinect;
Word word[];
Star star[];
Photo photo[];

boolean foundUsers = false;

PGraphics topLayer, bgLayer;
PGraphics mask;

// PImage shiba;
//PImage[] shiba;
PImage kinectInput;

String[] wordsList;

boolean keepAspectRatio = true;

void setup() {
  size(960, 360, P3D);
  textureMode(NORMAL);
  
  // load the words
  wordsList = loadStrings("data/top_dog_names.txt");
  println("there are " + wordsList.length + " lines");
  word = new Word[50];
  for (int i = 0; i < word.length; i++) {
    float extraRange = 250;
    float verticalMargin = 10;
    float x = random(-extraRange, width);
    float y = random(verticalMargin, height -verticalMargin);
    float z = random(0.5, 1);
    word[i] = new Word(wordsList, x, y, z);
  }

  // load the stars
  star = new Star[500];
  for (int i = 0; i < star.length; i++) {
    float x = random(0, width);
    float y = random(0, height);
    star[i] = new Star(x, y, 1, 3);
  }

  int photoResolution = 180;
  int photoClumns = width / photoResolution;
  int photoRows = height / photoResolution;
  int photoAmount = photoClumns * photoRows;
  photo = new Photo[photoAmount];
  for (int i = 0; i < photo.length; i++) {
    float x = floor(i / photoRows) * photoResolution;
    float y = floor(i % photoRows) * photoResolution;
    photo[i] = new Photo("photos/"+int(random(8))+"_"+photoResolution+"x"+photoResolution+".jpg", x, y);
  }
  
  // setup kinect
  kinect = new KinectPV2(this);  
  kinect.enableBodyTrackImg(true);  
  kinect.init();
  
  // setup layers
  topLayer = createGraphics(width, height);  
  
  bgLayer = createGraphics(width, height);
  
  mask = createGraphics(width,height);
  mask.imageMode(CENTER);
  
  // load the shiba
  //shiba = new PImage[40];
  //for (int i = 0; i < shiba.length; i++) {
  // shiba[i] = loadImage("photos/shiba_90x90.jpg"); 
  //}
  
  // shiba = loadImage("shiba.jpg");
  // shiba.resize(0, height);
  
  //setup spout
  //spout = new Spout(this);
  //spout.setSenderName("spoutIcon");
}

void draw() {  
  background(0);
  
  // top layer
  topLayer.beginDraw();
  topLayer.background(0);
  
  for (int i = 0; i < star.length; i++) {
   star[i].getLayer(topLayer);
   star[i].blink(0.05);
   star[i].display();
  }
  
   for (int i = 0; i < word.length; i++) {
      word[i].getLayer(topLayer);
      word[i].move(1);
      word[i].display();
   }
  topLayer.endDraw();

  // mask
  mask.beginDraw();
  kinectInput = kinect.getBodyTrackImage();
  
  if (keepAspectRatio)
    mask.image(kinectInput, width*0.5, height, width, width*1.2);
  else
    mask.image(kinectInput, width*0.5, height*0.5, width, height);
  mask.endDraw();
  
  topLayer.mask(mask);
  
  // background layer
  bgLayer.beginDraw();
  bgLayer.background(100, 200, 0);
  if (random(1) < 0.2) {
    photo[int(random(photo.length))].changePhoto("photos/"+int(random(8))+"_180x180.jpg");
  }
  for (int i = 0; i < photo.length; i++) {
    photo[i].getLayer(bgLayer);
    photo[i].display();
  }
  //for (int i = 0; i < shiba.length; i++) {
  //  bgLayer.image(shiba[i], width/2, height/2);
  //}
  // bgLayer.image(shiba, width/3, 0);
  bgLayer.image(topLayer, 0, 0);
  bgLayer.endDraw();
  
  // draw the layers
  image(bgLayer,0,0);
  
  //image(topLayer,0,0);
  
  //spout.sendTexture(bgLayer);
  
  // draw the frame rate
  textSize(60);
  fill(255,0,0);
  text(frameRate, 50, 90);
}

void mousePressed() {
  keepAspectRatio = !keepAspectRatio;
  println(keepAspectRatio);
}
