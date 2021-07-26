class transactionEvent
{
    String type; //"buy" or "sell"
    float price; 
    float qty;
    float usdValue;
    //constructor
    transactionEvent(String _type,float _price,float _qty,float _usdValue) {
        type = _type;
        price = _price;
        qty = _qty;
        usdValue = _usdValue;
    }
}