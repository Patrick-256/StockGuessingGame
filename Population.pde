class Population
{
    Agent[] aiPopulation;
    int popAmount;
    NeuralNetwork populationBestNeuralNet;
    float bestNeuralNetProfits;

    //constructor
    Population(int amountOfAIs,int[] nnConfig)
    {
        popAmount = amountOfAIs;
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
        //make each ai decide what to do
        for(int i = 0; i < popAmount; i++) {
            int decision = aiPopulation[i].updateAI(tickPriceData);
            if(decision == 0) {
                waitThisTick++;
            } else if(decision == 1) {
                buyThisTick++;
            } else {
                sellThisTick++;
            }
        }

        //Now visualize the amount of buys and sells
        
    }
}