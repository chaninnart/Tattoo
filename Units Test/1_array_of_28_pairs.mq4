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
bool open_pairs[28];
double pairs_point[28];

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
for(int x=0; x<28; x++){SymbolInfoTick(pairs[x],mqltick[x]);pairs_point[x]=MarketInfo(pairs[x],MODE_POINT);}
ArrayInitialize(open_pairs,EMPTY_VALUE);    
  
   
//---
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   for(int x=0; x<28; x++){SymbolInfoTick(pairs[x],mqltick[x]);open_pairs[x]=CheckOpenOrders(pairs[x]);}
   printInfo();
   Comment(CheckOpenOrders("EURUSD"));
   
  }

bool CheckOpenOrders(string symbol){
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
      if( OrderSymbol() == symbol ) return(true);
   }
   return(false);
}


//+------------------------------------------------------------------+
//Helper Function
//+------------------------------------------------------------------+
void printInfo(){ 
   string text[30]; //Array of String store custom texts on screen
    text[0]  = "    PAIR      |     STR      |     SLOPE";
      //for(int x=0; x<28; x++){text[x+1]  = pairs[x]+ "    |     "+ x+ "    |     "+ "";}   
      //for(int x=0; x<28; x++){text[x] =x+" : "+  mqltick[x].time+ " : "+ pairs[x] + " : "+ open_pairs[x];}
      for(int x=0; x<28; x++){text[x] =x+" : "+  pairs[x]  +  " : "+ pairs_point[x];}   
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