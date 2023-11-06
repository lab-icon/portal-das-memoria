// import libraries
import KinectPV2.*;
import gab.opencv.*;

// declare variables
KinectPV2 kinect;
OpenCV opencv;

String[] wordList;
Word word[];
Star star[];
Photo photo[];

int photoResolution;
int totalOfPhotos;

float maskScaleFactor = 2.5;
boolean foundUsers = false;

PGraphics topLayer, bgLayer;
PGraphics mask;

PImage kinectInput;

//opencv variables
float polygonFactor = 1;
int threshold = 30;
int maxD = 1800;
int minD = 1200;
boolean contourBodyIndex = false;

// toggleable variables
boolean toggleFPS = true;

void setup() {
  size(960*2, 360*2, P3D);

  // setup layers
  topLayer = createGraphics(width, height);  
  
  bgLayer = createGraphics(width, height);
  
  mask = createGraphics(width,height);
  mask.imageMode(CENTER);
  
  // load the words
  loadJSON();
  float wordExtraRange = 250;
  float wordVerticalMargin = 20;
  textAlign(CENTER, CENTER);
  word = new Word[50];
  for (int i = 0; i < word.length; i++) {
    float x = random(-wordExtraRange, width + wordExtraRange);
    float y = random(wordVerticalMargin, height -wordVerticalMargin);
    float z = random(0.5, 1.5);
    float diraction = random(1) < 0.5 ? -1 : 1;
    String firstWord = wordList[int(random(wordList.length))];
    word[i] = new Word(firstWord, x, y, z, diraction);
  }

  // load the stars
  star = new Star[500];
  for (int i = 0; i < star.length; i++) {
    float x = random(0, width);
    float y = random(0, height);
    star[i] = new Star(x, y, 1, 3);
  }

  // load the photos
  photoResolution = 45;
  totalOfPhotos = 669;
  int photoClumns = width / photoResolution + 1;
  int photoRows = height / photoResolution;
  int displayedPhotos = photoClumns * photoRows;
  photo = new Photo[displayedPhotos];
  for (int i = 0; i < photo.length; i++) {
    int x = floor(i / photoRows) * photoResolution;
    int y = floor(i % photoRows) * photoResolution;
    photo[i] = new Photo("fotos_escolhidas_"+photoResolution+"x"+photoResolution+"/foto"+int(random(totalOfPhotos))+".jpg", x, y);
  }
  
  // setup kinect
  kinect = new KinectPV2(this);  
  kinect.enableDepthImg(true);
  kinect.enablePointCloud(true);
  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);
  kinect.init();

  // setup opencv
  opencv = new OpenCV(this, 512, 424);
}

void loadJSON() {
  JSONArray wordJSON = loadJSONArray("data/wordList.json");
  wordList = new String[wordJSON.size()];
  for (int i = 0; i < wordJSON.size(); i++) {
    JSONObject word = wordJSON.getJSONObject(i);
    String wordText = word.getString("replaced");
    wordList[i] = wordText;
  }
}

void draw() {  
  // top layer
  drawTopLayer();
  
  // mask
  drawOpencvMaskLayer();
  topLayer.mask(mask);

  // background layer
  drawBgLayer();

  // display the layers
  image(bgLayer,0,0);
  
  // draw the frame rate
  displayFPS(toggleFPS);
}

void displayFPS(boolean showFPS) {
  if (showFPS) {
    fill(255,0,0);
    textSize(60);
    text(frameRate, 100, 90);
  }
}

void opencvContour() {
  boolean contourBodyIndex = false;
  opencv.loadImage(kinect.getPointCloudDepthImage());
  opencv.threshold(threshold);

  ArrayList<Contour> contours = opencv.findContours(false, false);

  if (contours.size() > 0) {
    for (Contour contour : contours) {
      contour.setPolygonApproximationFactor(polygonFactor);
      if (contour.numPoints() > 50) {
        mask.noStroke();
        mask.fill(0);
        mask.beginShape();
        for (PVector point : contour.getPolygonApproximation().getPoints()) {
          mask.vertex(point.x * maskScaleFactor, point.y * maskScaleFactor);
        }
        mask.endShape();
      }
    }
  }
  // comment after threshold callibration
  // kinect.setLowThresholdPC(minD);
  // kinect.setHighThresholdPC(maxD);
}

void drawTopLayer() {
  topLayer.beginDraw();
  topLayer.background(0);
  for (int i = 0; i < star.length; i++) {
   star[i].blink(0.05);
   star[i].display(topLayer);
  }
  for (int i = 0; i < word.length; i++) {
    if (word[i].move(1.8)) {
      String nextWord = wordList[int(random(wordList.length))];
      word[i].resetPosition(nextWord, topLayer.height);
    }
    word[i].display(topLayer);
  }
  topLayer.endDraw();
}

void drawOpencvMaskLayer() {
  mask.beginDraw();
  mask.background(255);
  opencvContour();
  mask.endDraw();
}

void drawBgLayer() {
  bgLayer.beginDraw();
  bgLayer.background(100, 200, 0);
  if (random(1) < 0.6) {
    photo[int(random(photo.length))].changePhoto("fotos_escolhidas_"+photoResolution+"x"+photoResolution+"/foto"+int(random(totalOfPhotos))+".jpg");
  }
  for (int i = 0; i < photo.length; i++) {
    photo[i].display(bgLayer);
  }
  bgLayer.image(topLayer, 0, 0);
  bgLayer.endDraw();
}

void keyReleased() {
  if (key == 'f') {
    toggleFPS = !toggleFPS;
  }
  if (key == 'h') {
    threshold += 10;
    println("threshold: " + threshold);
  }
  if (key == 'b') {
    threshold -= 10;
    println("threshold: " + threshold);
  }
  if (key == 'j') {
    minD += 10;
    println("minD: " + minD);
  }
  if (key == 'n') {
    minD -= 10;
    println("minD: " + minD);
  }
  if (key == 'k') {
    maxD += 10;
    println("maxD: " + maxD);
  }
  if (key == 'm') {
    maxD -= 10;
    println("maxD: " + maxD);
  }
  if (key == 'g') {
    maskScaleFactor += 0.1;
    println("maskScaleFactor: " + maskScaleFactor);
  }
  if (key == 'v') {
    maskScaleFactor -= 0.1;
    println("maskScaleFactor: " + maskScaleFactor);
  }
}