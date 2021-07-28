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
Population aiPopulation;

int[] testNNconfig = {102,7,3};
NeuralNetwork testNN;

public void setup() {
    testNN = generateRandomNeuralNetwork(testNNconfig);
    testNN.print();

    //Prepare the game
    priceData = new PriceDataSet("PriceData.txt");
    currentGameTick = 0;

    //Prepare the AI population
    aiPopulation = new Population(1000,testNNconfig);

    frameRate(60);
    
    background(100);
}

public void draw() {
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
class Agent
{
    NeuralNetwork brain;
    float dollarsInWallet;
    float coinsInWallet;
    int totalBuys;
    float dollarsSpent;
    int totalSells;
    float dollarsHarvested;
    float totalProfit;
    ArrayList<TransactionEvent> transactionLog;
    int evoPoints;
    
    

    //constructor
    Agent(NeuralNetwork newBrain, float startDollars)
    {
        brain = newBrain;
        dollarsInWallet = startDollars;
        coinsInWallet = 0;
        dollarsSpent = 0;
        dollarsHarvested = 0;
        transactionLog = new ArrayList<TransactionEvent>();
        totalBuys = 0;
        totalSells = 0;
        totalProfit = 0;
        evoPoints = 0;
    }   

    //Assess the situation, and use brain to make a decision
    public int updateAI(float[] tickPriceData)
    {
        //----[ STEP 1: Prepare inputs ]---------------------------------------------------------♦
        float[] neuralNetInputs = new float[102];

        //input #1: available USD to spend
        neuralNetInputs[0] = dollarsInWallet;

        //input #2: USD value of Coins held
        neuralNetInputs[1] = tickPriceData[0] * coinsInWallet;

        //input #3 thru #102: price data
        for(int i = 0; i < 100; i++)
        {
            neuralNetInputs[2+i] = tickPriceData[i];
        }

        //----[ STEP 2: Feed the input array into the brain ]─────────────────────────────────────■
        brain.runNeuralNetwork(neuralNetInputs);
        float[] outputArray = brain.outputArray;

        //----[ STEP 3: Choose the option with the highest output value ]------------------------♦
        float highestChoice = 0;
        int highestChoiceIndex = 0; //0 = wait, 1 = buy, 2 = sell

        for(int i = 0; i < brain.outputArray.length; i++)
        {
            if(brain.outputArray[i] > highestChoice)
            {
                highestChoice = brain.outputArray[i];
                highestChoiceIndex = i;
            }
        }

        //----[ STEP 4: Carry out decision ]-----------------------------------------------------♦
        if(highestChoiceIndex == 0) {
            //waitThisTick++; current price: tickPriceData[0]
            //Wait. do not buy or sell
            return 0;
        } else if(highestChoiceIndex == 1) {
            //buyThisTick++;
            boolean buySuccess = buyCoins(tickPriceData[0]);
            if(buySuccess == true) {
                //successfully bought coins
                return 1;
            } else {
                //tried to buy but unsuccessful
                return 11;
            }
        } else {
            //sellThisTick++;
            boolean sellSuccess = sellCoins(tickPriceData[0]);
            if(sellSuccess == true) {
                //successfully sold coins
                return 2;
            } else {
                //tried to sell but not successful
                return 22;
            }
        }
    }

    public boolean buyCoins(float price)
    {
        //check if theres cash to buy
        if(dollarsInWallet > 0.01f)
        {
            //calculate qty of coins to buy
            float qtyToBuy = dollarsInWallet / price;
            float usdValue = qtyToBuy * price;

            //adjust Agent balances
            dollarsInWallet -= usdValue;
            coinsInWallet += qtyToBuy;

            //create new transaction log entry
            TransactionEvent transaction = new TransactionEvent("BUY",price,qtyToBuy,usdValue,currentGameTick);
            transactionLog.add(transaction);
            totalBuys++;
            dollarsSpent += usdValue;

            evoPoints++;

            return true;
        }
        return false;
    }
    public boolean sellCoins(float price)
    {
        //check if theres coins to sell
        if(coinsInWallet > 0.0001f)
        {
            float usdValue = coinsInWallet * price;

            //adjust Agent balances
            dollarsInWallet += usdValue;
            coinsInWallet = 0;

            //create new transaction log entry
            TransactionEvent transaction = new TransactionEvent("SELL",price,coinsInWallet,usdValue,currentGameTick);
            transactionLog.add(transaction);
            totalSells++;
            dollarsHarvested += usdValue;

            //calculate total profit
            totalProfit = dollarsHarvested - dollarsSpent;

            //calculate the total profit of this transaaction
            float lastUSDspent = transactionLog.get(transactionLog.size()-2).usdValue;
            float thisProfit = dollarsHarvested - lastUSDspent;
            evoPoints += 2;

            if(thisProfit > 0) {
                evoPoints += 10*thisProfit;
            } else {
                evoPoints -= 1;
            }

            return true;
        }
        return false;
    }

    public Agent copy()
    {
        Agent copyOfThis = new Agent(brain, 100);
        return copyOfThis;
    }
}
class NeuralNetwork
{
    NeuralNetLayer[] neuralNetwork;
    float[] outputArray;
    int[] nnConfig;
    float[] nnMultipliers;
    float[] nnBiases;

    //constructor - build a new neural network
    NeuralNetwork(int[] nueralNetLayerConfig, float[] neuralNetMultipliers, float[] neuralNetBiases)
    {
        nnConfig = nueralNetLayerConfig;
        nnMultipliers = neuralNetMultipliers;
        nnBiases = neuralNetBiases;

        neuralNetwork = new NeuralNetLayer[nueralNetLayerConfig.length];
        //Start at the input layer
        int neuronID = 0;     //used for the biases
        int connectionID = 0; //used for the multipliers
        //do all the layers
        for(int l = 0; l < nueralNetLayerConfig.length; l++)
        {
            //create an array to hold the amount of neurons in that layer
            Neuron[] neuralNetLayer = new Neuron[nueralNetLayerConfig[l]];

            //do all the neurons in the layer
            for(int n = 0; n < nueralNetLayerConfig[l]; n++)
            {
                Neuron neuron;
                //for each neuron, gather an array of all its inputs (neurons of the previous layer)
                int amountOfNeuronInputs;
                //Amount of neural connects = 1 for input neurons, and for all other neurons its the amount of neurons in the previous layer
                if(l == 0) { amountOfNeuronInputs = 1; }
                else { amountOfNeuronInputs = nueralNetLayerConfig[l-1]; }

                neuronInput[] neuronInputs = new neuronInput[amountOfNeuronInputs];

                for(int c = 0; c < amountOfNeuronInputs; c++)
                {
                    //make the connection and add it to an array that will eventually given to the neuron on creation
                    neuronInput connection;
                    int cLayer = l-1;

                    connection = new neuronInput(cLayer,c,neuralNetMultipliers[connectionID]);
                    neuronInputs[c] = connection;
                    connectionID++;
                }
                //now create the neuron with the array of inputs and the bias
                neuron = new Neuron(neuronInputs,neuralNetBiases[neuronID]);
                neuralNetLayer[n] = neuron;
                neuronID++;
            }
            neuralNetwork[l] = new NeuralNetLayer(neuralNetLayer);
        }

        //print the newly created neural network
        //println("the Nerual Network: "+neuralNetwork);
    }

    //simulate neuralnet ---------------------------------------------------------------------------------------------
    public void runNeuralNetwork(float[] nnInputs)
    {
        //do the input layers first - plug the provided nnInputs into the nn input neurons
        // println("Simulate the Nerual Network INPUT: ");
        // printArray(nnInputs);

        //do all the neurons in the first layer first
        for(int n = 0; n < neuralNetwork[0].getNNlayer().length; n++)
        {
            //for each input neuron, insert its corrisponding input, then call its update function to have its output calculated
            neuralNetwork[0].getNNlayer()[n].setNeuronInput(nnInputs[n]);
            //neuralNetwork.get(0).get(n).neuronInputs.get(0).inputValue = nnInputs.get(n);
            neuralNetwork[0].getNNlayer()[n].updateNeuron();
        }
        
        //do the rest of the layers
        for(int l = 1; l < neuralNetwork.length; l++)
        {
            //do all the neurons in the layer
            for(int n = 0; n < neuralNetwork[l].getNNlayer().length; n++)
            {
                //for each neuron, process each of its inputs then add them all up
                for(int c = 0; c < neuralNetwork[l].getNNlayer()[n].neuronInputs.length; c++)
                {
                    //process the input - for each input, reference its source neuron's output and set it as this connections input value
                    int sourceNeuronLayer = l-1;
                    int sourceNeuronIndex = neuralNetwork[l].getNNlayer()[n].neuronInputs[c].inputNeuronLayerLocation;

                    neuralNetwork[l].getNNlayer()[n].neuronInputs[c].inputValue = neuralNetwork[sourceNeuronLayer].getNNlayer()[sourceNeuronIndex].getNeuronOutput();
                }
                //with all the connection input values set, call the neurons update function to calculate its own output
                neuralNetwork[l].getNNlayer()[n].updateNeuron();
            }
        }

        //now return the output values of all the output neurons
        int amountOfOutputNeurons = neuralNetwork[neuralNetwork.length-1].getNNlayer().length;
        float[] outArray = new float[amountOfOutputNeurons];

        for(int i = 0; i < amountOfOutputNeurons; i++)
        {
            outArray[i] = neuralNetwork[neuralNetwork.length-1].getNNlayer()[i].output;
        }

        // println("Simulate the Nerual Network OUTPUT: ");
        // printArray(outArray);

        outputArray = outArray;
    }
    public void print()
    {
        println("NeuralNet Multipliers:");
        printArray(nnMultipliers);
        println("NeuralNet Biases:");
        printArray(nnBiases);
    }
    public NeuralNetwork copyNeuralNet()
    {
        NeuralNetwork copyOfThisNN = new NeuralNetwork(nnConfig,nnMultipliers,nnBiases);
        return copyOfThisNN;
    }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------------

class NeuralNetLayer
{
    Neuron[] layer;

    //Constructor
    NeuralNetLayer(Neuron[] nLayer)
    {
        layer = nLayer;
    }
    public Neuron[] getNNlayer()
    {
        return layer;
    }
}
//---------------------------------------------------------------------------------------------------------------------------------------------------------------

class Neuron
{
    //Neuron variables
    neuronInput[] neuronInputs;
    float bias;
    float output;

    //Constructor
    Neuron(neuronInput[] nNeuronInputs, float nBias)
    {
        neuronInputs = nNeuronInputs;
        bias = nBias;
    }

    //Set new input multipliers for the neuron
    public void updateInputMultipliers(neuronInput[] uNeuronInputs)
    {
        neuronInputs = uNeuronInputs;
    }
    //set new bias for the neuron
    public void updateBias(float uBias)
    {
        bias = uBias;
    }
    //set neuron input - used for input neurons
    public void setNeuronInput(float sNeuronInputValue)
    {
        neuronInputs[0].setInputValue(sNeuronInputValue);
    }
    //loop through its inputs, and calculate this neurons output
    public void updateNeuron()
    {
        float total = 0;
        //add up all the inputs multiplied by their multipliers
        for(int c = 0; c < neuronInputs.length; c++)
        {
            total += neuronInputs[c].inputValue * neuronInputs[c].multiplier;
        }
        //add the bias
        total += bias;
        //now feed the result through the sigmoid function and set the neuron output
        output = 1 / (1 + exp(total));
    }
    //get output
    public float getNeuronOutput()
    {
        return output;
    }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------------

class neuronInput
{
    //Neuron Input variables
    int inputNeuronLayerIndex;
    int inputNeuronLayerLocation;
    float inputValue;
    float multiplier;

    //constructor
    neuronInput(int nLayerIndex, int nLayerLocation,float nMutliplier)
    {
        inputNeuronLayerIndex = nLayerIndex;       //Which layer the neuron is in within the neural net
        inputNeuronLayerLocation = nLayerLocation; //the index the neuron is within its layer
        multiplier = nMutliplier;
    }
    //set input value manually - used by input neurons
    public void setInputValue(float nInputValue)
    {
        inputValue = nInputValue;
    }
    // //find the input value from provided NN - will be used by all neurons except input neurons
    // void findInputValue(NeuralNetwork theNeuralNetwork)
    // {
    //     Neuron theTargetNeuron = theNeuralNetwork.neuralNetwork.get(inputNeuronLayerIndex).get(inputNeuronLayerLocation);
    // }
}










//2021-07-18
//ArrayList version. doesnt seem to work becasue I cant seem to access function within objects that are within an arraylist which is inside another arraylist within an object

// class NeuralNetwork
// {
//     ArrayList<ArrayList> neuralNetwork;

//     //constructor - build a new neural network
//     NeuralNetwork(ArrayList<Integer> nueralNetLayerConfig, ArrayList<Float> neuralNetMultipliers, ArrayList<Float> neuralNetBiases)
//     {
//         neuralNetwork = new ArrayList <ArrayList>();
//         //Start at the input layer
//         int neuronID = 0;     //used for the biases
//         int connectionID = 0; //used for the multipliers
//         //do all the layers
//         for(int l = 0; l < nueralNetLayerConfig.size(); l++)
//         {
//             ArrayList<Neuron> neuralNetLayer = new ArrayList <Neuron>();

//             //do all the neurons in the layer
//             for(int n = 0; n < nueralNetLayerConfig.get(l); n++)
//             {
//                 Neuron neuron;
//                 //for each neuron, gather an array of all its inputs (neurons of the previous layer)
//                 ArrayList<neuronInput> neuronInputs = new ArrayList <neuronInput>();
//                 int amountOfNeuronInputs;
//                 //Amount of neural connects = 1 for input neurons, and for all other neurons its the amount of neurons in the previous layer
//                 if(l == 0) { amountOfNeuronInputs = 1; }
//                 else { amountOfNeuronInputs = nueralNetLayerConfig.get(l-1); }

//                 for(int c = 0; c < amountOfNeuronInputs; c++)
//                 {
//                     //make the connection and add it to an array that will eventually given to the neuron on creation
//                     neuronInput connection;
//                     int cLayer = l-1;

//                     connection = new neuronInput(cLayer,c,neuralNetMultipliers.get(connectionID));
//                     neuronInputs.add(connection);
//                     connectionID++;
//                 }
//                 //now create the neuron with the array of inputs and the bias
//                 neuron = new Neuron(neuronInputs,neuralNetBiases.get(neuronID));
//                 neuralNetLayer.add(neuron);
//             }
//             neuralNetwork.add(neuralNetLayer);
//         }

//         //print the newly created neural network
//         println("the Nerual Network: "+neuralNetwork);
//     }

    
// }

// //simulate neuralnet ---------------------------------------------------------------------------------------------
// ArrayList runNeuralNetwork(ArrayList<Float> nnInputs, ArrayList<ArrayList> neuralNetwork)
// {
//     //do the input layers first - plug the provided nnInputs into the nn input neurons
    
//     //do all the neurons in the first layer first
//     for(int n = 0; n < neuralNetwork.get(0).size(); n++)
//     {
//         //for each input neuron, insert its corrisponding input, then call its update function to have its output calculated
//         neuralNetwork.get(0).get(n).setNeuronInput(nnInputs.get(n));
//         //neuralNetwork.get(0).get(n).neuronInputs.get(0).inputValue = nnInputs.get(n);
//         neuralNetwork.get(0).get(n).updateNeuron();
//     }
    
//     //do the rest of the layers
//     for(int l = 1; l < neuralNetwork.size(); l++)
//     {
//         //do all the neurons in the layer
//         for(int n = 0; n < neuralNetwork.get(l).size(); n++)
//         {
//             //for each neuron, process each of its inputs then add them all up
//             for(int c = 0; c < neuralNetwork.get(l).get(n).neuronInputs.size(); c++)
//             {
//                 //process the input - for each input, reference its source neuron's output and set it as this connections input value
//                 int sourceNeuronLayer = l-1;
//                 int sourceNeuronIndex = neuralNetwork.get(l).get(n).neuronInputs.get(c).inputNeuronLayerLocation;

//                 neuralNetwork.get(l).get(n).neuronInputs.get(c).inputValue = neuralNetwork.get(sourceNeuronLayer).get(sourceNeuronIndex).getNeuronOutput();
//             }
//             //with all the connection input values set, call the neurons update function to calculate its own output
//             neuralNetwork.get(l).get(n).updateNeuron();
//         }
//     }
// }

// //---------------------------------------------------------------------------------------------------------------------------------------------------------------

// class Neuron
// {
//     //Neuron variables
//     ArrayList<neuronInput> neuronInputs;
//     float bias;
//     float output;

//     //Constructor
//     Neuron(ArrayList<neuronInput> nNeuronInputs, float nBias)
//     {
//         neuronInputs = nNeuronInputs;
//         bias = nBias;
//     }

//     //Set new input multipliers for the neuron
//     void updateInputMultipliers(ArrayList<neuronInput> uNeuronInputs)
//     {
//         neuronInputs = uNeuronInputs;
//     }
//     //set new bias for the neuron
//     void updateBias(float uBias)
//     {
//         bias = uBias;
//     }
//     //set neuron input - used for input neurons
//     void setNeuronInput(float sNeuronInputValue)
//     {
//         neuronInputs.get(0).setInputValue(sNeuronInputValue);
//     }
//     //loop through its inputs, and calculate this neurons output
//     void updateNeuron()
//     {
//         float total = 0;
//         //add up all the inputs multiplied by their multipliers
//         for(int c = 0; c < neuronInputs.size(); c++)
//         {
//             total += neuronInputs.get(c).inputValue * neuronInputs.get(c).multiplier;
//         }
//         //add the bias
//         total += bias;
//         //now feed the result through the sigmoid function and set the neuron output
//         output = 1 / (1 + exp(total));
//     }
//     //get output
//     float getNeuronOutput()
//     {
//         return output;
//     }
// }

// //---------------------------------------------------------------------------------------------------------------------------------------------------------------

// class neuronInput
// {
//     //Neuron Input variables
//     int inputNeuronLayerIndex;
//     int inputNeuronLayerLocation;
//     float inputValue;
//     float multiplier;

//     //constructor
//     neuronInput(int nLayerIndex, int nLayerLocation,float nMutliplier)
//     {
//         inputNeuronLayerIndex = nLayerIndex;       //Which layer the neuron is in within the neural net
//         inputNeuronLayerLocation = nLayerLocation; //the index the neuron is within its layer
//         multiplier = nMutliplier;
//     }
//     //set input value manually - used by input neurons
//     void setInputValue(float nInputValue)
//     {
//         inputValue = nInputValue;
//     }
//     // //find the input value from provided NN - will be used by all neurons except input neurons
//     // void findInputValue(NeuralNetwork theNeuralNetwork)
//     // {
//     //     Neuron theTargetNeuron = theNeuralNetwork.neuralNetwork.get(inputNeuronLayerIndex).get(inputNeuronLayerLocation);
//     // }
// }
class Population
{
    Agent[] aiPopulation;
    int popAmount;
    NeuralNetwork populationBestNeuralNet;
    float bestNeuralNetProfits;

    //keep track of all the buys/sells/waits for all the AIs
    ArrayList<Integer> totalTickWaits;
    ArrayList<Integer> totalTickBuys;
    ArrayList<Integer> totalTickSells;
    ArrayList<Integer> totalTickBuyFails;
    ArrayList<Integer> totalTickSellFails;

    //constructor
    Population(int amountOfAIs,int[] nnConfig)
    {
        popAmount = amountOfAIs;
        totalTickWaits = new ArrayList<Integer>();
        totalTickBuys = new ArrayList<Integer>();
        totalTickSells = new ArrayList<Integer>();
        totalTickBuyFails = new ArrayList<Integer>();
        totalTickSellFails = new ArrayList<Integer>();

        aiPopulation = new Agent[amountOfAIs];
        //generate a bunch of random AIs for this population
        for(int i = 0; i < amountOfAIs; i++)
        {
            //firstly generate a random neuralnet 
            NeuralNetwork randNN = generateRandomNeuralNetwork(nnConfig);
            aiPopulation[i] = new Agent(randNN,100);
        }
    }

    //Simulate the population for the tick
    public void runPopulation(float[] tickPriceData)
    {
        int waitThisTick = 0;
        int buyThisTick = 0;
        int sellThisTick = 0;
        int buyThisTickFail = 0;
        int sellThisTickFail = 0;
        //make each ai decide what to do
        for(int i = 0; i < popAmount; i++) {
            int decision = aiPopulation[i].updateAI(tickPriceData);
            if(decision == 0) {
                waitThisTick++;
            } else if(decision == 1) {
                buyThisTick++;
            } else if(decision == 11) {
                buyThisTickFail++;
            } else if(decision == 2) {
                sellThisTick++;
            } else {
                sellThisTickFail++;
            }
        }
        totalTickWaits.add(waitThisTick);
        totalTickBuys.add(buyThisTick);
        totalTickSells.add(sellThisTick);
        totalTickBuyFails.add(buyThisTickFail);
        totalTickSellFails.add(sellThisTickFail);

        //Now visualize the amount of buys and sells
        println("Tick: "+currentGameTick+" Waits: "+waitThisTick+" buys: "+buyThisTick+" sells: "+sellThisTick+" Failed buys: "+buyThisTickFail+" Failed sells: "+sellThisTickFail);

        sortPopulation(); 
        updateLeaderboard();  
    }
    public void sortPopulation()
    {
        //sort by profit. best at index 0
        boolean arraySorted = false;
        while(arraySorted == false)
        {
            int movedItems = 0;
            for(int i = 0; i < aiPopulation.length-1; i++)
            {
                float firstAIprofit = aiPopulation[i].evoPoints;
                float secondAIprofit = aiPopulation[i+1].evoPoints;

                if(secondAIprofit > firstAIprofit)
                {
                    //switch places    
                    Agent tempHoldingAI = aiPopulation[i].copy();
                    aiPopulation[i] = aiPopulation[i+1].copy();
                    aiPopulation[i+1] = tempHoldingAI.copy();

                    movedItems++;
                }
            }
            if(movedItems == 0) {
                //we iterated thru the whole array without moving anything, it must be sorted!
                arraySorted = true;
            }
        }
    }
    public void updateLeaderboard()
    {
        int yPosition = 55;

        for(int i = 0; i < 40; i++)
        {
            fill(0);
            //Index
            text(i,1305,yPosition);

            //USD spent
            text(aiPopulation[i].dollarsSpent,1355,yPosition);

            //USD harvest
            text(aiPopulation[i].dollarsHarvested,1455,yPosition);

            //Profit
            text(aiPopulation[i].totalProfit,1555,yPosition);

            yPosition+= 20;
        }
    }

    public void clense()
    {
        //Kill all Agents who have not made any profit 
    }





























    // void drawTransactions()
    // {
    //     //draw from left to right
    //     int startTick = currentGameTick - 99;
    //     int startAdjustment = 0;
    //     if(startTick < 0) {
    //         startAdjustment = 99 - startTick;
    //     }
    //     int endTick = currentGameTick;

    //     //each price column is 12px wide
    //     int xPosition = 0;

    //     //draw the transactions for each tick
    //     for(int i = 0; i < 100;i++)
    //     {
    //         //skip if the start adjustment is active
    //         if(i >= startAdjustment) {
    //            int totBuys = totalTickBuys.get(currentGameTick+i-startAdjustment);
    //             println("totBuys: "+totBuys);
    //             if( totBuys > 0)
    //             {
    //                 fill(255, 148, 25);
    //                 rect(xPosition+2,400,8,4*totalTickBuys.get(currentGameTick));
    //             }
    //             //Sells
    //             int totSells = totalTickSells.get(currentGameTick+i-startAdjustment);
    //             if(totSells > 0)
    //             {
    //                 fill(31, 242, 116);
    //                 rect(xPosition+2,400-4*totSells,8,4*totSells);
    //             } 
    //         }
    //         xPosition +=12;
    //     }

        
    // }
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
class TransactionEvent
{
    String type; //"buy" or "sell"
    float price; 
    float qty;
    float usdValue;
    int tickOccurred;
    //constructor
    TransactionEvent(String _type,float _price,float _qty,float _usdValue,int currentTick) {
        type = _type;
        price = _price;
        qty = _qty;
        usdValue = _usdValue;
        tickOccurred = currentTick;
    }
}
public float[] generateRandomNN_Multipliers(int amount)
{
    float[] randNNmultipliers = new float[amount];

    for(int i = 0; i < amount; i++)
    {
        randNNmultipliers[i] = random(-1,1);
    }

    return randNNmultipliers;
}

public float[] generateRandomNN_Biases(int amount)
{
    float[] randNNbiases = new float[amount];

    for(int i = 0; i < amount; i++)
    {
        randNNbiases[i] = random(-0.5f,0.5f);
    }

    return randNNbiases;
}

public NeuralNetwork generateRandomNeuralNetwork(int[] nNetConfig)
{
    int amountOfMultipliers = 0;
    int amountOfBiases = 0;

    //figure out how many multipliers are needed
    for(int l = 0; l < nNetConfig.length; l++)
    {
        if(l == 0)
        {
            //For the first layer, only 1 multiplier is needed per neuron
            amountOfMultipliers += nNetConfig[0];
        } else {
            //For all other layers, each neuron needs the previous layers worth of neurons,
            //so the entire layer needs (previousLayer)*(currentLayer) amount of multipliers
            int currentLayerMultipliers = nNetConfig[l-1] * nNetConfig[l];

            amountOfMultipliers += currentLayerMultipliers;
        }
    }
    
    //figure out how many biases are needed
    //amount of biases needed = amount of neurons in the neural net
    for(int l = 0; l < nNetConfig.length; l++)
    {
        amountOfBiases += nNetConfig[l];
    }

    //Now use the two randomizing functions above to generate some multipliers and biases
    float[] nnMultipliers = generateRandomNN_Multipliers(amountOfMultipliers);
    float[] nnBiases = generateRandomNN_Biases(amountOfBiases);

    NeuralNetwork randomNeuralNet = new NeuralNetwork(nNetConfig,nnMultipliers,nnBiases);

    return randomNeuralNet;
}

public NeuralNetwork mutateNeuralNetwork(NeuralNetwork neuralNetwork,float stepChange)
{
    //go through each neuron, slightly modify the bias, and slightly modify each of the neurons connections
    for(int l = 0; l < neuralNetwork.neuralNetwork.length; l++)
    {
        //do all the neurons in the layer
        for(int n = 0; n < neuralNetwork.neuralNetwork[l].getNNlayer().length; n++)
        {
            //for each connection in the neuron, randomly change its multiplier a little bit
            for(int c = 0; c < neuralNetwork.neuralNetwork[l].getNNlayer()[n].neuronInputs.length; c++)
            {
                float randNumber = random(3);
                float originalMultiplier = neuralNetwork.neuralNetwork[l].getNNlayer()[n].neuronInputs[c].multiplier;
                float newMultiplier;
                if(randNumber < 1) {
                    newMultiplier = originalMultiplier - stepChange;
                } else if(randNumber < 2) {
                    newMultiplier = originalMultiplier;
                } else {
                    newMultiplier = originalMultiplier + stepChange;
                }
                
                neuralNetwork.neuralNetwork[l].getNNlayer()[n].neuronInputs[c].multiplier = newMultiplier;
            }
            //for the bais, randomly change it a little bit
            float randNumber = random(3);
            float originalBias = neuralNetwork.neuralNetwork[l].getNNlayer()[n].bias;
            float newBias;
            if(randNumber < 1) {
                newBias = originalBias - stepChange;
            } else if(randNumber < 2) {
                newBias = originalBias;
            } else {
                newBias = originalBias + stepChange;
            }
            neuralNetwork.neuralNetwork[l].getNNlayer()[n].bias = newBias;
        }
    }
    return neuralNetwork;
}

public NeuralNetwork mutateNeuralNetworkV2(NeuralNetwork neuralNetwork,float stepChange)
{
    //go through each neuron, slightly modify the bias, and slightly modify each of the neurons connections
    for(int l = 0; l < neuralNetwork.neuralNetwork.length; l++)
    {
        //do all the neurons in the layer
        for(int n = 0; n < neuralNetwork.neuralNetwork[l].getNNlayer().length; n++)
        {
            //for each connection in the neuron, randomly change its multiplier a little bit
            for(int c = 0; c < neuralNetwork.neuralNetwork[l].getNNlayer()[n].neuronInputs.length; c++)
            {
                float randNumber = random(-1,1);
                float originalMultiplier = neuralNetwork.neuralNetwork[l].getNNlayer()[n].neuronInputs[c].multiplier;
                float change = stepChange * randNumber;
                
                neuralNetwork.neuralNetwork[l].getNNlayer()[n].neuronInputs[c].multiplier = originalMultiplier + change;
            }
            //for the bais, randomly change it a little bit
            float randNumber = random(-1,1);
            float originalBias = neuralNetwork.neuralNetwork[l].getNNlayer()[n].bias;
            float bchange = stepChange * randNumber;
            
            neuralNetwork.neuralNetwork[l].getNNlayer()[n].bias = originalBias + bchange;
        }
    }
    return neuralNetwork;
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
