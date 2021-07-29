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
    void runPopulation(float[] tickPriceData)
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

            //print what each AI decides to do every tick
            //println("AI "+aiPopulation[i].brain_ID+" has made decision "+decision+" ; TotBuys: "+aiPopulation[i].totalBuys+" ; TotSells: "+aiPopulation[i].totalSells+" ; TotTransactions: "+aiPopulation[i].transactionLog.size());
        }
        totalTickWaits.add(waitThisTick);
        totalTickBuys.add(buyThisTick);
        totalTickSells.add(sellThisTick);
        totalTickBuyFails.add(buyThisTickFail);
        totalTickSellFails.add(sellThisTickFail);

        //Now visualize the amount of buys and sells
        //println("-------------------------------------------------------------------------------------------------");
        println("Tick: "+currentGameTick+" Waits: "+waitThisTick+" buys: "+buyThisTick+" sells: "+sellThisTick+" Failed buys: "+buyThisTickFail+" Failed sells: "+sellThisTickFail);

        sortPopulation(); 
        updateLeaderboard();  
    }
    void sortPopulation()
    {
        //sort by profit. best at index 0
        boolean arraySorted = false;
        while(arraySorted == false)
        {
            int movedItems = 0;
            for(int i = 0; i < aiPopulation.length-1; i++)
            {
                float firstAIprofit = aiPopulation[i].dollarsSpent;
                float secondAIprofit = aiPopulation[i+1].dollarsSpent;

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
    void updateLeaderboard()
    {
        int yPosition = 55;

        for(int i = 0; i < 40; i++)
        {
            fill(0);
            //Index
            text(aiPopulation[i].brain_ID,1305,yPosition);

            //USD spent
            text(aiPopulation[i].dollarsSpent,1485,yPosition);

            //USD harvest
            text(aiPopulation[i].dollarsHarvested,1585,yPosition);

            //Profit
            text(aiPopulation[i].totalProfit,1685,yPosition);

            yPosition+= 20;
        }
    }

    void clense()
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