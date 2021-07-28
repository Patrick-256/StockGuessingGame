//2021-07-25  Patrick Whitlock
//This is my second attempt at working with nerual nets on Processing. This will be a game where several (~20 or so) data points will
//be entered into a neural network and it will decide to Buy, Sell, or Wait.
//Each tick will increment the price points over by one, so the latest price can be entered into the neural net.

//Global Variables
PriceDataSet priceData;
int currentGameTick;
int amountOfPriceDataToDisplay = 100;
Population aiPopulation;

int[] testNNconfig = {102,7,3};
NeuralNetwork testNN;

void setup() {
    testNN = generateRandomNeuralNetwork(testNNconfig);
    testNN.print();

    //Prepare the game
    priceData = new PriceDataSet("PriceData.txt");
    currentGameTick = 0;

    //Prepare the AI population
    aiPopulation = new Population(1000,testNNconfig);

    frameRate(60);
    size(1700,900);
    background(100);
}

void draw() {
    //Draw static text
    background(100);
    textSize(14);
    fill(0);
    text("CurrentTick # "+currentGameTick,20,20);
    text("Current Price: $"+priceData.priceData[currentGameTick+100],200,20);



    //fetch this tick's data and draw it out
    fill(50);
    rect(0,30,1200,820);
    //first price in array is the "newest/current price", the last price in the array is the "oldest price"
    float[] tickPriceData = priceData.fetchSubsetOfData(currentGameTick+amountOfPriceDataToDisplay,amountOfPriceDataToDisplay);

    //feed this tick's worth of data to the AIs and let them make their decisions
    aiPopulation.runPopulation(tickPriceData);

    //Update the Leaderboard
    fill(0);
    line(1300,15,1650,15);
    line(1300,35,1650,35);
    line(1300,15,1300,850);
    text("Index",1305,30);
    line(1350,15,1350,850);
    text("USD Spent",1355,30);
    line(1450,15,1450,850);
    text("USD Harvest",1455,30);
    line(1550,15,1550,850);
    text("Profit",1555,30);
    line(1650,15,1650,850);

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
    // println("highPrice: "+highPrice);
    // println("lowPrice: "+ lowPrice);
    fill(0);
    text("$"+highPrice,1202,40);
    text("$"+lowPrice,1202,850);

    //now figure out the pixel scale
    //we have a total of 820 vertical pixels, allow a 10 pixel pad on top and bottom, for a total of 800 usable pixel space
    float deltaPrice = highPrice - lowPrice;
    float pricePerPixel = deltaPrice / 800;

    // println("deltaPrice: "+deltaPrice);
    // println("PPP: "+ pricePerPixel);

    //now graph each price point
    int chartStartX = 1188;
    for(int i = 0; i <tickPriceData.length; i++)
    {
        //Calculate Y pixel location
        float priceToGraph = highPrice - tickPriceData[i];
        float pixelsFromTop = priceToGraph *(1 / pricePerPixel) + 10 + 30;

        //Draw the price bar
        fill(66, 135, 245);
        rect(chartStartX,pixelsFromTop-1,12,3); //the -1 is so the element is vertically centered

        //check the population to see if any historical AI trades have happened on this tick
        //Buys

        if(i <= currentGameTick) {
            int totBuys = aiPopulation.totalTickBuys.get(currentGameTick-i);
            //println("totBuys: "+totBuys);
            if( totBuys > 0)
            {
                fill(255, 148, 25);
                rect(chartStartX+2,pixelsFromTop+3,8,4*totBuys);
            }
            //Sells
            int totSells = aiPopulation.totalTickSells.get(currentGameTick-i);
            if(totSells > 0)
            {
                fill(31, 242, 116);
                rect(chartStartX+2,pixelsFromTop-2-4*totSells,8,4*totSells);
            }
        }

        chartStartX -= 12;
    }

    // //now graph each price point
    // int chartStartX = 0;
    // for(int i = tickPriceData.length-1; i >= 0; i--)
    // {
    //     //Calculate Y pixel location
    //     float priceToGraph = highPrice - tickPriceData[i];
    //     float pixelsFromTop = priceToGraph *(1 / pricePerPixel) + 10 + 30;

    //     //Draw the price bar
    //     fill(66, 135, 245);
    //     rect(chartStartX,pixelsFromTop-1,12,3); //the -1 is so the element is vertically centered

    //     //check the population to see if any historical AI trades have happened on this tick
    //     //Buys
    //     int skipOffset = 99-currentGameTick;

    //     if(i >= skipOffset) {
    //         int totBuys = aiPopulation.totalTickBuys.get(currentGameTick+i-99);
    //         println("totBuys: "+totBuys);
    //         if( totBuys > 0)
    //         {
    //             fill(255, 148, 25);
    //             rect(chartStartX+2,pixelsFromTop+3,8,4*aiPopulation.totalTickBuys.get(currentGameTick));
    //         }
    //         //Sells
    //         int totSells = aiPopulation.totalTickSells.get(currentGameTick+i-99);
    //         if(totSells > 0)
    //         {
    //             fill(31, 242, 116);
    //             rect(chartStartX+2,pixelsFromTop-2-4*totSells,8,4*totSells);
    //         }
    //     }

    //     chartStartX += 12;
    // }



    //update leaderboard
    //-------------------------------------------------------------------------------------------------------------


    currentGameTick++;
}