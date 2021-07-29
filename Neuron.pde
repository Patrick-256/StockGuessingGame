class NeuralNetwork
{
    NeuralNetLayer[] neuralNetwork;
    float[] outputArray;
    int[] nnConfig;
    float[] nnMultipliers;
    float[] nnBiases;
    float sumOfMultipliers; //used for ID purposes
    float sumOfBiases; //used for ID purposes

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

                    sumOfMultipliers += neuralNetMultipliers[connectionID];
                    connectionID++;
                }
                //now create the neuron with the array of inputs and the bias
                neuron = new Neuron(neuronInputs,neuralNetBiases[neuronID]);
                neuralNetLayer[n] = neuron;

                sumOfBiases += neuralNetBiases[neuronID];
                neuronID++;
            }
            neuralNetwork[l] = new NeuralNetLayer(neuralNetLayer);
        }

        //print the newly created neural network
        //println("the Nerual Network: "+neuralNetwork);
    }

    //simulate neuralnet ---------------------------------------------------------------------------------------------
    void runNeuralNetwork(float[] nnInputs)
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
    void print()
    {
        println("NeuralNet Multipliers:");
        printArray(nnMultipliers);
        println("NeuralNet Biases:");
        printArray(nnBiases);
    }
    NeuralNetwork copyNeuralNet()
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
    Neuron[] getNNlayer()
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
    void updateInputMultipliers(neuronInput[] uNeuronInputs)
    {
        neuronInputs = uNeuronInputs;
    }
    //set new bias for the neuron
    void updateBias(float uBias)
    {
        bias = uBias;
    }
    //set neuron input - used for input neurons
    void setNeuronInput(float sNeuronInputValue)
    {
        neuronInputs[0].setInputValue(sNeuronInputValue);
    }
    //loop through its inputs, and calculate this neurons output
    void updateNeuron()
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
    float getNeuronOutput()
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
    void setInputValue(float nInputValue)
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