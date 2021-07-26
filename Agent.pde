class Agent
{
    NeuralNetwork brain;
    float dollarsInWallet;
    float coinsInWallet;
    float dollarsSpent;
    float dollarsHarvested;
    ArrayList<transactionEvent> transactionLog;

    //constructor
    Agent(NeuralNetwork newBrain, float startDollars)
    {
        brain = newBrain;
        dollarsInWallet = startDollars;
        coinsInWallet = 0;
        dollarsSpent = 0;
        dollarsHarvested = 0;
        transactionLog = new ArrayList<transactionEvent>();
    }   

    //Assess the situation, and use brain to make a decision
    int updateAI(float[] tickPriceData)
    {
        //prepare inputs
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

        //Feed the input array into the brain
        float[] outputArray = brain.runNeuralNetwork(neuralNetInputs);

        //choose the option with the highest output value
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

        return highestChoiceIndex;
    }

    boolean buyCoins()
    {
        if(dollarsInWallet
    }
    boolean sellCoins()
    {

    }
}