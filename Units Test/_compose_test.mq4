//+------------------------------------------------------------------+
//|                                          1_array_of_28_pairs.mq4 |
//|                                                       Chaninnart |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chaninnart"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

/*   0"AUDCAD",	1"AUDCHF",	2"AUDJPY",	3"AUDNZD",	4"AUDUSD",
     5"CADCHF",	6"CADJPY",  7"CHFJPY",  8"EURAUD",	9"EURCAD",	
     10"EURCHF",	11"EURGBP",	12"EURJPY", 13"EURNZD",	14"EURUSD",	
     15"GBPAUD",	16"GBPCAD",	17"GBPCHF", 18"GBPJPY",	19"GBPNZD",	
     20"GBPUSD",	21"NZDCAD", 22"NZDCHF",	23"NZDJPY",	24"NZDUSD",
     25"USDCAD",  26"USDCHF",	27"USDJPY"*/

//+------------------------------------------------------------------+
//| 28 pairs Variables                                 |
//+------------------------------------------------------------------+
string pairs[28] = {
   "AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD",
   "CADCHF",	"CADJPY",
   "CHFJPY",	
   "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD",	
   "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD",	
   "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD",
   "USDCAD",   "USDCHF",	"USDJPY"};

MqlTick mqltick [28];
double pairs_point[28];
bool open_pairs[28];
int open_pairs_count[28];
double open_pairs_profit [28];

//+------------------------------------------------------------------+
//| Send Order Variables                                 |
//+------------------------------------------------------------------+
int MagicNumber  = 5652534;         //Magic Number
double   Lotsize = 0.1;      //Order Setting (Lot Size)
double   StopLoss   = 0; //100;    //min 40
double   TakeProfit = 0; //100;    //min 40




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
   EventSetTimer(1);
//--- Array Initialize
   for(int x=0; x<28; x++){
      SymbolInfoTick(pairs[x],mqltick[x]);
      open_pairs[x]=CheckOpenOrders(pairs[x]);
      open_pairs_count[x] = CheckOpenOrders(pairs[x]);
   }
   ArrayInitialize(open_pairs,EMPTY_VALUE);
//---
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---run sequence
   CheckopenordersStatus();
   CheckLogicToManageOrder();
   CheckLogicToOpenOrder();
   printInfo();   
}

void  CheckLogicToOpenOrder (){
   for(int x=0; x<28; x++){
      if(open_pairs[x] == 0){ActivateOpenOrderStrategy(pairs[x]);}      
   }
}

void  CheckLogicToManageOrder (){
   for(int x=0; x<28; x++){
      if(open_pairs[x] > 0){ActivateManageOrderStrategy(x);}      
   }
}

//*********************************************************************LOGIC HERE!!!!!!
void ActivateOpenOrderStrategy(string symbol){      
   double adx_value=0.0;
      adx_value = iADX(symbol,30,14,PRICE_OPEN,MODE_MAIN,0);
   double sma_value=0.0;
      sma_value = iMA(symbol,30,14,0,MODE_SMMA,PRICE_OPEN,1); 

   if(adx_value > 20 && Ask < sma_value){openBuy(symbol,"*****openbuy");}
   //if(adx_value > 25 && Ask < sma_value){openBuy(symbol,"*****openbuy");}

Comment(symbol+" : "+adx_value);      
}

void ActivateManageOrderStrategy(int int_pair){
   if(open_pairs_profit[int_pair]>20){closeAllOrder(1);}
}

//*********************************************************************LOGIC HERE!!!!!!

int openBuy (string symbol,string comment) {
//Comment(symbol); 
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
//Print("Open Buy on "+ symbol+":"+ vbid + ":"+sl+":"+tp+"*******************");      
   int result= OrderSend(symbol,OP_SELL,Lotsize ,vbid,3,sl,tp,comment,MagicNumber,0,clrRed);  
//Print("Open Sell on "+ symbol+ " : condition "+comment + ":" +result); 
   return(result); 
}

void closeAllOrder(int type){ //int type 1 = close all order buy, type 2 = close all order sell
   int result=0;
   for(int i = OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
         Print("ERROR - Unable to select the order - ",GetLastError());
         break;
      }
   RefreshRates();
      switch(type){
         case 1:
            result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),1000,0);
            break;
         case 2:
            result =OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),1000,0);
            break;
      }         
  }   
  if(result<0){Print("***********OrderSend failed with error #",GetLastError());}else Print("************OrderSend placed successfully");  
}


void CheckopenordersStatus(){
   for(int x=0; x<28; x++){SymbolInfoTick(pairs[x],mqltick[x]);   open_pairs[x]=CheckOpenOrders(pairs[x]);} 
   for(int x=0; x<28; x++){if (open_pairs[x] == true){open_pairs_count[x] = CountOpenOrders(pairs[x]); open_pairs_profit[x] = CountOrdersProfit(pairs[x]);}}
}

bool CheckOpenOrders(string symbol){
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
      if( OrderSymbol() == symbol ) return(true);
   }  return(false);
}

int CountOpenOrders(string symbol){
   int counter=0;
//Comment (OrdersTotal());   
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
      if( OrderSymbol() == symbol ) counter++;
   }  return(counter);
}

double CountOrdersProfit(string symbol){
   double profit=0;
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
      if( OrderSymbol() == symbol ) profit=profit+OrderProfit();
   }  return(profit);
}


//+------------------------------------------------------------------+
//Helper Function
//+------------------------------------------------------------------+
void printInfo(){ 
   string text[30]; //Array of String store custom texts on screen
    text[0]  = "    PAIR      |     STR      |     SLOPE";
      //for(int x=0; x<28; x++){text[x+1]  = pairs[x]+ "    |     "+ x+ "    |     "+ "";}   
      for(int x=0; x<28; x++){text[x] =x+" : "+  mqltick[x].time+ " : "+ pairs[x] + " : "+ open_pairs[x]+ " : "+ open_pairs_count[x]+ " : "+ open_pairs_profit[x];}
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