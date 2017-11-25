final String TITLE = "THICC BOY";
final String SUBTITLE = "Down with the thiccness";
final int TEXTSIZE = 32;
final int ANIMATIONLENGTH = 4;
final int FRAMERATE = 60;
final boolean SAVEFRAMES = true; //helpful for previewing without saving
PFont earlyGameBoy;

final color BLUE = color(0, 0, 220);
final color GREEN = color(0, 220, 0);
final color PINK = color(220, 0, 220);
final color YELLOW = color(220, 220, 0);
final color FINALBLUE = color(0, 0, 150);

ArrayList<Integer> palette; //The palette of colors to change through
PGraphics textLayer;
PGraphics effectLayer;
int secs = 0;

void setup() {
  size(320, 240);
  frameRate(FRAMERATE);

  //load the font
  earlyGameBoy = createFont("GameBoy.ttf", TEXTSIZE);

  //add the colors to the palette to shift though
  palette = new ArrayList<Integer>();
  palette.add(new Integer(color(BLUE)));
  palette.add(new Integer(color(GREEN)));
  palette.add(new Integer(color(PINK)));
  palette.add(new Integer(color(YELLOW)));

  textLayer = createGraphics(width, height);
  effectLayer = createGraphics(width, height);

  updateText();
}

void draw() {
  background(250);

  float percentDone = ((float)frameCount / (float)(ANIMATIONLENGTH * FRAMERATE)) * 100.0f;

  //display what percentage complete we're at if we aren't saving the frames
  if (!SAVEFRAMES) {
    textAlign(LEFT, TOP);
    fill(PINK);
    textFont(earlyGameBoy);
    textSize(TEXTSIZE / 4);
    text(""+(int)percentDone, 0, 0);
  }

  //draw the subitle after some time
  if (percentDone > 50) {
    fill(0);
    textFont(earlyGameBoy);
    textSize(TEXTSIZE / 4);
    textAlign(CENTER, CENTER);
    text(SUBTITLE, width/2, height/2 + TEXTSIZE);
  }

  updateEffect();

  //Draw the final text
  image(effectLayer, 0, 0);


  if (SAVEFRAMES && frameCount < (ANIMATIONLENGTH * FRAMERATE)) {
    saveFrame(TITLE + "/" + TITLE + "-" +nf(frameCount,5) + ".png");
  }
  if (frameCount > (ANIMATIONLENGTH * FRAMERATE)) {
    println("Done!");
    noLoop();
  }
}

void updateText() {
  textLayer.beginDraw();
  textLayer.background(0, 0, 0, 0);
  textLayer.textFont(earlyGameBoy);
  textLayer.textAlign(CENTER, CENTER);
  textLayer.fill(0, 0, 0, 255);
  textLayer.text(TITLE, width/2, height/2);
  textLayer.endDraw();
}

void updateEffect() {
  //draw the colors to be blended with text
  effectLayer.beginDraw();
  effectLayer.background(0,0,0,0);
  
  //draw each rectangle left of the screen and slide them right as time progresses
  float dx = map(frameCount, 0f, (float)(ANIMATIONLENGTH * FRAMERATE)/4, -width, width);
  for (int i=palette.size()-1; i>=0; i--) {
    color c = palette.get(i).intValue();
    effectLayer.fill(c);
    effectLayer.noStroke();
    if(i!=0)
      effectLayer.rect(dx + i * (width / palette.size()), 0, width / palette.size(), height);
    else
      effectLayer.rect(0, 0, dx, height);
  }
  effectLayer.endDraw();

  //blend the text and effect layers
  textLayer.loadPixels();
  effectLayer.loadPixels();
  for (int i=0; i<textLayer.pixels.length; i++) {
    if (alpha(textLayer.pixels[i]) == 0) {
      effectLayer.pixels[i] = color(0, 0, 0, 0);
    }
  }
  effectLayer.updatePixels();
}