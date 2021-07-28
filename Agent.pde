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
    int updateAI(float[] tickPriceData)
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

    boolean buyCoins(float price)
    {
        //check if theres cash to buy
        if(dollarsInWallet > 0.01)
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
    boolean sellCoins(float price)
    {
        //check if theres coins to sell
        if(coinsInWallet > 0.001)
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

    Agent copy()
    {
        Agent copyOfThis = new Agent(brain, 100);
        return copyOfThis;
    }
}