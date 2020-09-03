//+------------------------------------------------------------------+
//|                                          1_array_of_28_pairs.mq4 |
//|                                                       Chaninnart |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chaninnart"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict



//+------------------------------------------------------------------+
//| Send Order Variables                                 |
//+------------------------------------------------------------------+
int MagicNumber  = 5652534;         //Magic Number
double   Lotsize = 0.1;      //Order Setting (Lot Size)
double   StopLoss   = 100;    //min 40
double   TakeProfit = 100;    //min 40
int TS = 0;                  //Trailing Stop (in Points)

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(){OnTick();}
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(5);

   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   openBuy(Symbol(),"******B");
   openSell(Symbol(),"******S");
  }

int openBuy (string symbol,string comment) { 
   double vbid    = MarketInfo(symbol,MODE_BID); double vask    = MarketInfo(symbol,MODE_ASK);
   double vpoint  = MarketInfo(symbol,MODE_POINT); int    vdigits = (int)MarketInfo(symbol,MODE_DIGITS);
   int    vspread = (int)MarketInfo(symbol,MODE_SPREAD);
   
//Print(vbid+"/"+ vask+"/"+ vpoint+"/"+ vdigits+"/"+ vspread);
//Print(Bid +":"+Ask);  
   RefreshRates();  
   //Retrive Bid / Offer from Current Symbol Pair  
   double tp = NormalizeDouble((vask+(TakeProfit*vpoint)),vdigits);
   double sl = NormalizeDouble((vbid-(StopLoss*vpoint)),vdigits);
   if (TakeProfit == 0) { tp =0;} if (StopLoss == 0) { sl =0;} //if TP == 0 do set the TP to 0 avoiding error 130
   
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   
Print("Open Buy on "+ symbol+":"+ vask + ":"+sl+":"+tp+"*******************");   
   int result= OrderSend(symbol,OP_BUY,Lotsize ,vask,3,sl,tp,comment,MagicNumber,0,clrGreen); 
Print("Open Buy on "+ symbol+ " : condition "+comment + ":" +result); 
return(result);  
}

int openSell(string symbol,string comment){

   double vbid    = MarketInfo(symbol,MODE_BID); double vask    = MarketInfo(symbol,MODE_ASK);
   double vpoint  = MarketInfo(symbol,MODE_POINT); int    vdigits = (int)MarketInfo(symbol,MODE_DIGITS);
   int    vspread = (int)MarketInfo(symbol,MODE_SPREAD);   
//Print(vbid+"/"+ vask+"/"+ vpoint+"/"+ vdigits+"/"+ vspread);
//Print(Bid +":"+Ask);  
   RefreshRates(); 
   double tp = NormalizeDouble((vbid-(TakeProfit*vpoint)),vdigits);
   double sl = NormalizeDouble((vask+(StopLoss*vpoint)),vdigits);   
   if (TakeProfit == 0) { tp =0;} if (StopLoss == 0) { sl =0;}
   
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
Print("Open Buy on "+ symbol+":"+ vbid + ":"+sl+":"+tp+"*******************");      
   int result= OrderSend(symbol,OP_SELL,Lotsize ,vbid,3,sl,tp,comment,MagicNumber,0,clrRed);  
Print("Open Sell on "+ symbol+ " : condition "+comment + ":" +result); 
return(result); 
}




//+------------------------------------------------------------------+
//Helper Function
//+------------------------------------------------------------------+
void printInfo(){ 
   string text[30]; //Array of String store custom texts on screen
    text[0]  = "    PAIR      |     STR      |     SLOPE";
      //for(int x=0; x<28; x++){text[x+1]  = pairs[x]+ "    |     "+ x+ "    |     "+ "";}   
      //for(int x=0; x<28; x++){text[x] =x+" : "+  mqltick[x].time+ " : "+ pairs[x] + " : "+ open_pairs[x];}
      //for(int x=0; x<28; x++){text[x] =x+" : "+  pairs[x]  +  " : "+ pairs_point[x];}   
    text[29] = "----------------END-----------------";
     
    int i=0; int k=30;
    while (i<ArraySize(text))  //create text object and shift the distance x,y
    {
       string ChartInfo = DoubleToStr(i, 0);
       ObjectCreate(ChartInfo, OBJ_LABEL, 0, 0, 0);
       ObjectSetText(ChartInfo, text[i], 8, "Arial", White);
       ObjectSet(ChartInfo, OBJPROP_CORNER, 0);   
       ObjectSet(ChartInfo, OBJPROP_XDISTANCE, 7);  
       ObjectSet(ChartInfo, OBJPROP_YDISTANCE, k);
       i++;
       k=k+15;
    } 
} 


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }