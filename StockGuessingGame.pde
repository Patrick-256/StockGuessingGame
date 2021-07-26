//2021-07-25  Patrick Whitlock
//This is my second attempt at working with nerual nets on Processing. This will be a game where several (~20 or so) data points will
//be entered into a neural network and it will decide to Buy, Sell, or Wait.
//Each tick will increment the price points over by one, so the latest price can be entered into the neural net.

//Global Variables
PriceDataSet priceData;
int currentGameTick;
int amountOfPriceDataToDisplay = 100;

void setup() {
    //Prepare the game
    priceData = new PriceDataSet("PriceData.txt");
    currentGameTick = 0;

    frameRate(60);
    size(1700,900);
    background(100);
}

void draw() {
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