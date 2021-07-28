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