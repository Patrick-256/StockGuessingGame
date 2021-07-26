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

//Global Variables
PriceDataSet priceData;
int currentGameTick;
int amountOfPriceDataToDisplay = 100;

public void setup() {
    //Prepare the game
    priceData = new PriceDataSet("PriceData.txt");
    currentGameTick = 0;

    frameRate(60);
    
    background(100);
}

public void draw() {
    //Draw static text
    //-----------------------------------------------------------------------------------------------------------------------------------------------------

    textSize(14);
    fill(0);
    text("CurrentTick # "+currentGameTick,20,20);


    //fetch this tick's data and draw it out
    //-----------------------------------------------------------------------------------------------------------------------------------------------------
    fill(50);
    rect(0,30,1200,820);
    float[] tickPriceData = priceData.fetchSubsetOfData(currentGameTick+amountOfPriceDataToDisplay,amountOfPriceDataToDisplay);

    //draw each individual price element. First find high and low prices
    float highPrice = 0;
    float lowPrice = 999999999;
    for(int i = 0; i < tickPriceData.length; i++)
    {
        if(tickPriceData[i] > highPrice) {
            //we have a new high price
            highPrice = tickPriceData[i];
        }
        if(tickPriceData[i] < lowPrice) {
            //we have a new low price
            lowPrice = tickPriceData[i];
        }
    }
    println("highPrice: "+highPrice);
    println("lowPrice: "+ lowPrice);

    //now figure out the pixel scale
    //we have a total of 820 vertical pixels, allow a 10 pixel pad on top and bottom, for a total of 800 usable pixel space
    float deltaPrice = highPrice - lowPrice;
    float pricePerPixel = deltaPrice / 800;

    println("deltaPrice: "+deltaPrice);
    println("PPP: "+ pricePerPixel);

    //now graph each price point
    int chartStartX = 0;
    for(int i = tickPriceData.length-1; i >= 0; i--)
    {
        //Calculate Y pixel location
        float priceToGraph = highPrice - tickPriceData[i];
        float pixelsFromTop = priceToGraph *(1 / pricePerPixel) + 10 + 30;

        fill(66, 135, 245);
        rect(chartStartX,pixelsFromTop,12,3);

        chartStartX += 12;
    }


    //provide data to AIs and have them make their decisions
    //-----------------------------------------------------------------------------------------------------------------------------------------------------

    //draw thier choices on the chart
    //-----------------------------------------------------------------------------------------------------------------------------------------------------


    //update leaderboard
    //-----------------------------------------------------------------------------------------------------------------------------------------------------


    currentGameTick++;
}
class PriceDataSet
{
    float[] priceData;
    int currentDataPoint;

    //constructor
    PriceDataSet(String fileName)
    {
        //read the file and load price data
        String[] lines = loadStrings(fileName);
        println("there are " + lines.length + " lines");
        priceData = new float[lines.length];

        for(int i = 0 ; i < lines.length; i++) {
        //println(lines[i]);
        priceData[i] = PApplet.parseFloat(lines[i]);
        }
    }
    //fetch a subset of the data
    public float[] fetchSubsetOfData(int currentIndex,int pastIndexes)
    {
        float[] tickPriceData = new float[pastIndexes];
        int p = 0;

        for(int i = currentIndex; i > currentIndex-pastIndexes; i--)
        {
            //Check if there is data at the specified index
            if(i > priceData.length) {
                float[] error = { 0 };
                println("!!!!++++!!!!++++!!!! ERROR: i="+i +" priceData length="+priceData.length);
                return error;
            } else {
                tickPriceData[p] = priceData[i];
                p++;
            }
        }
        return tickPriceData;
    }
}
  public void settings() {  size(1700,900); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "StockGuessingGame" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
