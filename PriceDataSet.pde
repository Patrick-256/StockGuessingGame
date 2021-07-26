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
        priceData[i] = float(lines[i]);
        }
    }
    //fetch a subset of the data
    float[] fetchSubsetOfData(int currentIndex,int pastIndexes)
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