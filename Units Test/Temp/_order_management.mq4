//+------------------------------------------------------------------+
//|                                            _order_management.mq4 |
//|                                                       Chaninnart |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Chaninnart"
#property link      ""
#property version   "1.1"
//#property strict

struct order_structure{string symbol;int type;double profit;double open;double lot;double sl;double tp;int ticket ;datetime time;order_structure(){symbol="";type=0;profit=0.0;open=0.0;lot=0.0;sl=0.0;tp=0.0;ticket=0;time=0;}};
order_structure my_open_orders[];

struct order_summary{int total; int order_buy; int order_sell; double net_profit;string open_pairs_list; order_summary(){total=0;order_buy=0;order_sell=0;net_profit=0.0;open_pairs_list="";}};
order_summary my_order_summary;

//+------------------------------------------------------------------+
//| Order Setting                                  |
//+------------------------------------------------------------------+
int MagicNumber  = 5652534;         //Magic Number
extern double   Lotsize = 0.1;      //Order Setting (Lot Size)
extern double   StopLoss = 50;      //in pip (have to check the server digits with the PipPoint () function
extern double   TakeProfit = 100;   //in pip (have to check the server digits with the PipPoint () function
int spread_value;                   //get spred_value

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
void OnTimer(){OnTick();}

int OnInit()
  {
//--- check the system pip point and apply to the variable
   EventSetTimer(1);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   getOrdersDetail();
   getOrderSummary();

   printInfo();


//   Comment(is_this_pair_in_OpenPairList("USDCAD"));
Comment("Open order Toal: "+my_order_summary.total+" / Net Profit: "+my_order_summary.net_profit+" / Open Pair(s) List: "+my_order_summary.open_pairs_list+" / Server Time: "+TimeToStr(TimeCurrent(),TIME_SECONDS));  
   
   
}


 
//+------------------------------------------------------------------+
void getOrdersDetail(){      
   ArrayResize(my_open_orders,OrdersTotal()); //array initialize
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true){
         my_open_orders[i].symbol = OrderSymbol();
         my_open_orders[i].type = OrderType();
         my_open_orders[i].profit= OrderProfit();
         my_open_orders[i].open=OrderOpenPrice();
         my_open_orders[i].lot=OrderLots();
         my_open_orders[i].sl=OrderStopLoss();
         my_open_orders[i].tp=OrderTakeProfit();
         my_open_orders[i].ticket= OrderTicket();
         my_open_orders[i].time= OrderOpenTime();
      }      
   } 
}
void getOrdersDetail(string symbol){
}

void getOrderSummary(){
    my_order_summary.total = OrdersTotal();
    //my_order_summary.order_buy =
   // my_order_summary.order_sell =
    my_order_summary.net_profit = AccountProfit();
    my_order_summary.open_pairs_list = getOpenPairList();
}

string getOpenPairList(){
   string result [];
   string temp;
   for(int i=0; i<ArraySize(my_open_orders);i++){     
      if ((StringFind(temp,my_open_orders[i].symbol))==-1){
         temp=my_open_orders[i].symbol + "|" +temp ;
      }
   }
   
   string to_split=temp;   // A string to split into substrings
   string sep="|";                // A separator as a character
   ushort u_sep;                  // The code of the separator character
   u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(to_split,u_sep,result);
return(temp);
}



//Order Type 1.Market 2.Stip 3.Limit
/*int  OrderSend(
   string   symbol,              // symbol
   int      cmd,                 // operation (OP_BUY, OP_SELL, OP_BUYLIMIT, OP_SELLLIMIT,OP_BUYSTOP, OP_SELLSTOP)
   double   volume,              // volume
   double   price,               // price
   int      slippage,            // slippage
   double   stoploss,            // stop loss
   double   takeprofit,          // take profit
   string   comment=NULL,        // comment
   int      magic,               // magic number
   datetime expiration=0,        // pending order expiration
   color    arrow_color=clrNONE  // color
   );*/

/*bool  OrderSelect(
   int     index,            // index or order ticket
   int     select,           // flag (SELECT_BY_POS, SELECT_BY_TICKET)
   int     pool=MODE_TRADES  // mode
   );*/

/*if(OrderSelect(12470, SELECT_BY_TICKET)==true){} else Print("OrderSelect returned the error of ",GetLastError());*/

//---------------Order Command Assembler-----------------


void closeAllOrder(){
}

// open buy order on 'market' price.
void openBuy (string symbol,string comment) {    
   double vbid    = MarketInfo(symbol,MODE_BID); double vask    = MarketInfo(symbol,MODE_ASK);
   double vpoint  = MarketInfo(symbol,MODE_POINT); int    vdigits = (int)MarketInfo(symbol,MODE_DIGITS);
   int    vspread = (int)MarketInfo(symbol,MODE_SPREAD);
   
   //Print(vbid+"/"+ vask+"/"+ vpoint+"/"+ vdigits+"/"+ vspread); // 0.6536/0.65426/0.00001/5/66

   RefreshRates();  
   //Retrive Bid / Offer from Current Symbol Pair  
   double tp = vask+(TakeProfit*PipPoint(symbol));
   double sl = vbid-(StopLoss*PipPoint(symbol));
   if (TakeProfit == 0) { tp =0;} //if TP == 0 do set the TP to 0 avoiding error 130
   if (StopLoss == 0) { sl =0;}
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   bool result=false;
   result= OrderSend(symbol,OP_BUY,Lotsize ,vask,3,sl,tp,comment,MagicNumber,0,clrGreen); 
   //Print("Open Buy on "+ symbol+ " : condition "+comment + ":" +result);   
}

void openSell(string symbol,string comment){
   double vbid    = MarketInfo(symbol,MODE_BID); double vask    = MarketInfo(symbol,MODE_ASK);
   double vpoint  = MarketInfo(symbol,MODE_POINT); int    vdigits = (int)MarketInfo(symbol,MODE_DIGITS);
   int    vspread = (int)MarketInfo(symbol,MODE_SPREAD);
   
   //Print(vbid+"/"+ vask+"/"+ vpoint+"/"+ vdigits+"/"+ vspread);
   double tp = vbid-(TakeProfit*PipPoint(symbol));
   double sl = vask+(StopLoss*PipPoint(symbol)); //setting stop loss when open buy 100   
   if (TakeProfit == 0) { tp =0;}
   if (StopLoss == 0) { sl =0;}
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   bool result=false;
   result= OrderSend(symbol,OP_SELL,Lotsize ,vbid,3,sl,tp,comment,MagicNumber,0,clrRed);  
   //Print("Open Sell on "+ symbol+ " : condition "+comment + ":" +result);  
}



// Pip Point Function
double PipPoint(string Currency){
   double CalcDigits; double CalcPoint = 0.0 ;
      CalcDigits = MarketInfo(Currency,MODE_DIGITS);
         if(CalcDigits == 2 || CalcDigits == 3) CalcPoint = 0.01;
         else if(CalcDigits == 4 || CalcDigits == 5) CalcPoint = 0.0001;
   return(CalcPoint);
}

/*
// Get Slippage Function
double GetSlippage(string Currency, int SlippagePips){
   double CalcDigits ;  double CalcSlippage =0.0;
      CalcDigits = MarketInfo(Currency,MODE_DIGITS);
         if(CalcDigits == 2 || CalcDigits == 4) CalcSlippage = SlippagePips;
         else if(CalcDigits == 3 || CalcDigits == 5) CalcSlippage = SlippagePips * 10;
   return(CalcSlippage);
}*/


void printInfo(){
   string text[30]; //Array of String store custom texts on screen
 //   text[0]  = "    PAIR      |    HULL   |      ATR      |     SCORE";
    //if (ArraySize(my_open_orders)>29){return;}
  
      for(int x=0; x<ArraySize(my_open_orders); x++){
   
         text[x]  = my_open_orders[x].symbol+" | "+my_open_orders[x].type+" | "+my_open_orders[x].profit+" | "+my_open_orders[x].open+" | "+my_open_orders[x].lot+" | "+my_open_orders[x].sl+" | "+my_open_orders[x].tp+" | "+my_open_orders[x].ticket+" | "+ ((3600-(TimeCurrent()-my_open_orders[x].time))); //TimeToStr((TimeCurrent()-my_open_orders[x].time),TIME_MINUTES)
   
      }        
      text[20] = "012345678901234567890123456789012345678901234567890123456789";
   
      
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


