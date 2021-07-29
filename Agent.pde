class Agent
{
    NeuralNetwork brain;
    String brain_ID;
    float dollarsInWallet;
    float coinsInWallet;
    int totalBuys;
    float dollarsSpent;
    int totalSells;
    float dollarsHarvested;
    float totalProfit;
    ArrayList<TransactionEvent> transactionLog;
    int evoPoints;
    String nextTransaction;
    
    

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
        brain_ID = brain.sumOfMultipliers+"_"+brain.sumOfBiases;
        nextTransaction = "BUY";
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
                //println("AI has made decision 1");
                return 1;
            } else {
                //tried to buy but unsuccessful
                //println("AI has made decision 11");
                return 11;
            }
        } else {
            //sellThisTick++;
            boolean sellSuccess = sellCoins(tickPriceData[0]);
            if(sellSuccess == true) {
                //successfully sold coins
                //println("AI has made decision 2");
                return 2;
            } else {
                //tried to sell but not successful
                //println("AI has made decision 22");
                return 22;
            }
        }
    }

    boolean buyCoins(float price)
    {
        //check if theres cash to buy
        if(dollarsInWallet > 1 && nextTransaction == "BUY")
        {
            //println("AI "+brain_ID+" buy - Dollars in wallet: "+dollarsInWallet+" nextTransaction: "+nextTransaction);
            totalBuys++;
            //calculate qty of coins to buy
            float qtyToBuy = dollarsInWallet / price;

            //create new transaction log entry
            TransactionEvent transaction = new TransactionEvent("BUY",price,qtyToBuy,dollarsInWallet,currentGameTick);
            transactionLog.add(transaction);
            
            dollarsSpent += dollarsInWallet;

            //adjust Agent balances
            dollarsInWallet = 0;
            coinsInWallet += qtyToBuy;

            evoPoints++;
            nextTransaction = "SELL";

            //println("AI "+brain_ID+" buyCompleted - Dollars in wallet: "+dollarsInWallet+" nextTransaction: "+nextTransaction);

            return true;
        }
        return false;
    }
    boolean sellCoins(float price)
    {
        //check if theres coins to sell
        if(coinsInWallet > 1 && nextTransaction == "SELL")
        {
            //println("AI "+brain_ID+" sell - Dollars in wallet: "+dollarsInWallet+" nextTransaction: "+nextTransaction);
            totalSells++;
            float usdValue = coinsInWallet * price;

            //create new transaction log entry
            TransactionEvent transaction = new TransactionEvent("SELL",price,coinsInWallet,usdValue,currentGameTick);
            transactionLog.add(transaction);
            
            dollarsHarvested += usdValue;

            //calculate total profit
            totalProfit = dollarsHarvested - dollarsSpent;

            //calculate the total profit of this transaaction
            float lastUSDspent = transactionLog.get(transactionLog.size()-2).usdValue;
            float thisProfit = dollarsHarvested - lastUSDspent;
            evoPoints += 2;

            //adjust Agent balances
            dollarsInWallet += usdValue;
            coinsInWallet = 0;

            if(thisProfit > 0) {
                evoPoints += 10*thisProfit;
            } else {
                evoPoints -= 1;
            }
            nextTransaction = "BUY";

            //println("AI "+brain_ID+" sellCompleted - Dollars in wallet: "+dollarsInWallet+" nextTransaction: "+nextTransaction);

            return true;
        }
        return false;
    }

    Agent copy()
    {
        Agent copyOfThis = new Agent(brain, 100);
        copyOfThis.dollarsInWallet = dollarsInWallet;
        copyOfThis.coinsInWallet = coinsInWallet;
        copyOfThis.totalBuys = totalBuys;
        copyOfThis.dollarsSpent = dollarsSpent;
        copyOfThis.totalSells = totalSells;
        copyOfThis.dollarsHarvested = dollarsHarvested;
        copyOfThis.evoPoints = evoPoints;
        copyOfThis.nextTransaction = nextTransaction;
        copyOfThis.transactionLog = new ArrayList<TransactionEvent>();
        for(int i = 0; i < transactionLog.size(); i++)
        {
            copyOfThis.transactionLog.add(transactionLog.get(i).copy());
        }
        return copyOfThis;
    }
}