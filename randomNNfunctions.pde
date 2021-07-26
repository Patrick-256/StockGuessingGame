float[] generateRandomNN_Multipliers(int amount)
{
    float[] randNNmultipliers = new float[amount];

    for(int i = 0; i < amount; i++)
    {
        randNNmultipliers[i] = random(-1,1);
    }

    return randNNmultipliers;
}

float[] generateRandomNN_Biases(int amount)
{
    float[] randNNbiases = new float[amount];

    for(int i = 0; i < amount; i++)
    {
        randNNbiases[i] = random(-0.5,0.5);
    }

    return randNNbiases;
}

NeuralNetwork generateRandomNeuralNetwork(int[] nNetConfig)
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

NeuralNetwork mutateNeuralNetwork(NeuralNetwork neuralNetwork,float stepChange)
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

NeuralNetwork mutateNeuralNetworkV2(NeuralNetwork neuralNetwork,float stepChange)
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