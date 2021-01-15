import gifAnimation.*;
import processing.pdf.*;

final String TITLE = "Fish";
final String SUBTITLE = "@fishwastooshort";
int TEXTSIZE = 0;
final int ANIMATIONLENGTH = 4;
final int FRAMERATE = 60;
final boolean SAVEGIF = false; //helpful for previewing without saving
final boolean SAVEFRAMES = false; //Save the frames to create a non-gif video with processing's movie maker

PFont TitleFont;
PFont SubTitleFont;

final color BLUE = color(56, 144, 240);
final color GREEN = color(64, 204, 63);
final color PINK = color(248, 164, 248);
final color RED = color(240, 84, 64);
final color YELLOW = color(248, 216, 88);
final color FINALBLUE = color(0, 30, 254);

ArrayList<Integer> palette; //The palette of colors to change through
PGraphics textLayer;
PGraphics effectLayer;
int secs = 0;
boolean startedDrawingSubtitle = false;

GifMaker gif;

void setup() {
  size(640, 480, P2D);
  frameRate(FRAMERATE);

  //load the font
  TEXTSIZE = height / 6;
  TitleFont = createFont("data/GameBoy.ttf", TEXTSIZE, false);
  SubTitleFont = createFont("data/GameBoy.ttf", TEXTSIZE / 4, false);
  textFont(TitleFont);
  boolean reducedTextSize = false;
  while (textWidth(TITLE) > width * .7) {
    reducedTextSize = true;
    TEXTSIZE--;
    TitleFont = createFont("GameBoy.ttf", TEXTSIZE,false);
    textFont(TitleFont);
  }
  if (reducedTextSize) println("WARNING: TITLE might be a little too long");

  //initialize the gif maker
  gif = new GifMaker(this, TITLE + ".gif");
  gif.setRepeat(0); //loops forever
  gif.setDelay((int)(1000.0f / ((float)FRAMERATE)));

  //add the colors to the palette to shift though
  palette = new ArrayList<Integer>();

  /*
   The colors will slide by in opposite order of how you insert them. 
   The first color in is the last to stay on screen before fade out.
   
   The color before last will be the last in the opening 'slide'
   The whole title will gradually fade to the final one
   */
  palette.add(new Integer(color(FINALBLUE)));
  palette.add(new Integer(color(BLUE)));
  palette.add(new Integer(color(GREEN)));
  palette.add(new Integer(color(PINK)));
  palette.add(new Integer(color(RED)));
  palette.add(new Integer(color(YELLOW)));

  textLayer = createGraphics(width, height);
  effectLayer = createGraphics(width, height);

  updateText();
}

void draw() {
  background(248,252,248);
  
  //increment the animation and blend it with the text
  updateEffect();

  //Draw the final text
  image(effectLayer, 0, 0);

  //draw the subitle after some time
  float percentDone = ((float)frameCount / (float)(ANIMATIONLENGTH * FRAMERATE)) * 100.0f;
  if (percentDone > 60) {
    if(!startedDrawingSubtitle){
      println("Started subtitle");
      startedDrawingSubtitle = true;
    }
    fill(0);
    textMode(MODEL);
    textSize(TEXTSIZE / 4);
    textFont(SubTitleFont);
    textAlign(CENTER, BOTTOM);
    text(SUBTITLE, width/2, height - (height/3));
  }
  //start to fade out 
  if (percentDone > 75) {
    noStroke();
    fill(255, map(percentDone, 75, 100, 0, 255));
    rect(0, 0, width, height);
  }

  if (SAVEGIF && frameCount < (ANIMATIONLENGTH * FRAMERATE)) {
    gif.addFrame();
  }
  if (SAVEFRAMES && frameCount < (ANIMATIONLENGTH * FRAMERATE)) {
    saveFrame(TITLE+"-#####.png");
  }
  if (frameCount > (ANIMATIONLENGTH * FRAMERATE)) {
    println("Done!");
    if (SAVEGIF && gif.finish()) {
      println("Gif export successful");
    } else {
      println("Gif did not save");
    }
    noLoop();
    if (SAVEFRAMES || SAVEGIF) {
      delay(1500);
      exit();
    }
  }
}

void updateText() {
  textLayer.beginDraw();
  textLayer.background(0, 0, 0, 0);
  textLayer.textFont(TitleFont);
  textLayer.textSize(TEXTSIZE);
  textLayer.textAlign(CENTER, TOP);
  textLayer.fill(0, 0, 0, 255);
  textLayer.text(TITLE, width/2, height/3);
  textLayer.endDraw();
}

//increments through the animation and blends with the text layer
void updateEffect() {
  //draw the colors to be blended with text
  effectLayer.beginDraw();
  effectLayer.background(0, 0, 0, 0);

  //draw each rectangle left of the screen and slide them right as time progresses
  float slideStartTime = (float)(ANIMATIONLENGTH*FRAMERATE)*0.25f;
  float slideEndTime   = (float)(ANIMATIONLENGTH*FRAMERATE)*0.50f;
  float fadeEndTime    = (float)(ANIMATIONLENGTH*FRAMERATE)*0.65f;
  
  float dx = map(frameCount, slideStartTime, slideEndTime, -width, width);
  for (int i=palette.size()-1; i>=1; i--) {
    color c = palette.get(i).intValue();
    effectLayer.fill(c);
    effectLayer.noStroke();
    if (i!=1)
      effectLayer.rect(dx + (i-1) * (width / palette.size()), 0, width / palette.size(), height);
    else
      effectLayer.rect(0, 0, dx + (width / palette.size()), height);
  }
  if(frameCount > slideEndTime){
    float a = min(map(frameCount,slideEndTime,fadeEndTime,0,255), 64);
    color finalc = palette.get(0).intValue();
    finalc = color(red(finalc), green(finalc), blue(finalc), a);
    effectLayer.fill(finalc);
    effectLayer.noStroke();
    effectLayer.rect(0,0,width,height);
  }
  effectLayer.endDraw();

  //mask the effect layer with the text
  textLayer.loadPixels();
  effectLayer.loadPixels();
  for (int i=0; i<textLayer.pixels.length; i++) {
    if (alpha(textLayer.pixels[i]) == 0) {
      effectLayer.pixels[i] = color(0, 0, 0, 0);
    }
  }
  effectLayer.updatePixels();
}
