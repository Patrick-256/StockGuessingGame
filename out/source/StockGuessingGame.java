import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class StockGuessingGame extends PApplet {

//2021-07-25  Patrick Whitlock
//This is my second attempt at working with nerual nets on Processing. This will be a game where several (~20 or so) data points will
//be entered into a neural network and it will decide to Buy, Sell, or Wait.
//Each tick will increment the price points over by one, so the latest price can be entered into the neural net.


public void setup() {
    frameRate(20);
    
    background(100);
}

public void draw() {

}
  public void settings() {  size(900,700); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "StockGuessingGame" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
