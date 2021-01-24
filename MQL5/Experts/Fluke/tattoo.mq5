//+------------------------------------------------------------------+
//|                                                  2020.mq4 |
//|                                       Copyright 2020, Chaninnart |
//|                                             longsorb@gmail.com
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Chaninnart"
#property version   "1.1"
//#property strict //disable for fix some bug in NormalizdDouble decimal error.
//+------------------------------------------------------------------+
//| Global Variable Declaration                                   |
//+------------------------------------------------------------------+
//--- Timer parameters checking new bar.
//bool ShowInfo = true; 
long myChartID =0 ; //open chart ID

//+------------------------------------------------------------------+
//| Order Setting                                  |
//+------------------------------------------------------------------+
int MagicNumber  = 5652534;         //Magic Number
double   Lotsize = 0.1;      //Order Setting (Lot Size)
double   StopLoss   = 500;    //Stop Loss (in Points)
double   TakeProfit = 500;    //Take Profit (in Points)
int TS = 0;                  //Trailing Stop (in Points)


// order structure
struct order_structure{string symbol;int type;double profit;double open;double lot;double sl;double tp;int ticket;string comment ;datetime time;order_structure(){symbol="";type=0;profit=0.0;open=0.0;lot=0.0;sl=0.0;tp=0.0;ticket=0;time=0;comment="";}};
order_structure my_open_orders[];
// order summary structure
struct order_summary{int total; int order_buy; int order_sell; double net_profit;string open_pairs_list; order_summary(){total=0;order_buy=0;order_sell=0;net_profit=0.0;open_pairs_list="";}};
order_summary my_order_summary;


//+------------------------------------------------------------------+
//| Custom Indicator Variable                                  |
//+------------------------------------------------------------------+
//1. Currency Strength

input int cc_score_period = 4;  //Currency Score Period
// define struct with contain consturctor method to set default value to the struct memebers
struct cc_score_structure{string currency; double score; double slope; cc_score_structure(){currency="";score = 0.0;slope=0.0;}};
cc_score_structure aud ,cad,eur,gbp ,nzd ,usd,chf,jpy;
cc_score_structure cc_score [8]; //
//cc_score_structure cc_score_bar0_sorted[8];
//1.1 Currency Strength, 28 pairs
//string CurrencyPair = "0AUDCAD1AUDCHF2AUDJPY3AUDNZD4AUDUSD5CADCHF6CADJPY7CHFJPY8EURAUD9EURCAD0EURCHF1EURGBP2EURJPY3EURNZD4EURUSD5GBPAUD6GBPCAD7GBPCHF8GBPJPY9GBPNZD0GBPUSD1NZDCAD2NZDCHF3NZDJPY4NZDUSD5USDCAD6USDCHF7USDJPY";
string pairs[28] = {
   "AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD",
   "CADCHF",	"CADJPY",
   "CHFJPY",	
   "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD",	
   "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD",	
   "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD",
   "USDCAD",   "USDCHF",	"USDJPY"};
//structure sample: AUDCAD score atr hull_pivot_status( 0 = none, 1 = pivot at top, 2 = pivot at bottom)
struct cc_strength_structure{string currency_pair; double strength;double slope;  cc_strength_structure(){currency_pair="";strength = 0.0;slope=0.0;}};
cc_strength_structure cc_strength [28];

string bestPairToTrade;
string previousBestPair;
bool  buyOrSell; //true = buy, false = sell

// Order Management Parameter//
input int exitProfit = 15; // Close when profit > (x)
input int exitLoss = -15; // Close when profit < (-x)






//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   //set Timer to proceed the OnTick while close market.
   EventSetTimer(3);
   
   //parameter initialization   
   aud.currency = "AUD";cad.currency = "CAD";eur.currency = "EUR";gbp.currency = "GBP"; nzd.currency = "NZD"; usd.currency = "USD";chf.currency = "CHF";jpy.currency = "JPY"; 
  
   //Fill Pairs of the currency into Currency Strength Structure
   for(int x=0; x<ArraySize(pairs); x++){cc_strength[x].currency_pair = pairs[x];}
 
   
   // process   
   getAllParameter();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+  
void OnTimer()
  {
//---
   OnTick();
  }
 
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
      getAllParameter();
      getOrdersDetail();
      getOrderSummary();
      orderManagement(); 
      openOrderStrategy();
      printInfo(); 
//Comment("Open order Toal: "+my_order_summary.total+" / Net Profit: "+my_order_summary.net_profit+" / Open Pair(s) List: "+my_order_summary.open_pairs_list+" / Server Time: "+TimeToStr(TimeCurrent(),TIME_SECONDS)+(" /Previous Best Pair: "+previousBestPair+ " / Current Best Pair: "+bestPairToTrade));  

  }
  
//+------------------------------------------------------------------+

void  getAllParameter(){ 
      get_CurrencyStrength(1);   //bar back to cal slope  
      getBestPairToTrade(4);     //bar back to cal slope
}     

void orderManagement(){
   //Print(StringFind(my_open_orders[0].comment,"CCSS")+"********************");
      for( int i = 0 ; i < OrdersTotal() ; i++ ) {
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true){
            int result=0 ; 
            //Strategy to Manage Order Press Here"
            if((my_open_orders[i].profit > exitProfit)){//||(my_open_orders[i].profit < exitLoss)){
               if(StringFind(my_open_orders[0].comment,"5652534B")==0){ 
                  result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),1000,0);
                  if(result<0){Print("***********OrderSend failed with error #",GetLastError());}else Print("************OrderSend placed successfully"); 
               }
               if(StringFind(my_open_orders[0].comment,"5652534S")==0){ 
                  result =OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),1000,0);
                  if(result<0){Print("***********OrderSend failed with error #",GetLastError());}else Print("************OrderSend placed successfully"); 
               } 
            }
         }      
      }    
}

void closeAllOrder(int type){ //int type 1 = close all order buy, type 2 = close all order sell
   int result;
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

void openOrderStrategy(){
   // get best pair to trade and open order if there is no order in open list
//Print("Previous Best Pair: "+previousBestPair+ " / Current Best Pair: "+bestPairToTrade);
   if((previousBestPair!= bestPairToTrade)&&(is_this_pair_in_OpenPairList(bestPairToTrade)!=1)){
      int result;
      RefreshRates();
      switch (buyOrSell){         
         case 0:  result= openSell(bestPairToTrade,MagicNumber+"S");Print("open sell order result: "+result);break;
         case 1:  result= openBuy(bestPairToTrade,MagicNumber+"B");Print("open buy order result: "+result);break; 
      }
      
   }  
   previousBestPair = bestPairToTrade ;   
}



int openBuy (string symbol,string comment) { 
   double vbid    = MarketInfo(symbol,MODE_BID); double vask    = MarketInfo(symbol,MODE_ASK);
   double vpoint  = MarketInfo(symbol,MODE_POINT); int    vdigits = (int)MarketInfo(symbol,MODE_DIGITS);
   int    vspread = (int)MarketInfo(symbol,MODE_SPREAD);
   double vstop=MarketInfo(symbol,MODE_STOPLEVEL);
//Print(vbid+"/"+ vask+"/"+ vpoint+"/"+ vdigits+"/"+ vspread);
 
   RefreshRates();  
   //Retrive Bid / Offer from Current Symbol Pair  
double lowest_tattoo = iLow(symbol,0,(iLowest(symbol,0,MODE_LOW,4,0))); //SL at the lowest at 4 bars

   double sl=NormalizeDouble(vbid-vstop*vpoint,vdigits);
   double tp=NormalizeDouble(vask+vstop*vpoint,vdigits);
   if (lowest_tattoo<sl){sl =lowest_tattoo;}
   tp = 0;
//   double sl=NormalizeDouble(vbid-vstop*vpoint,vdigits); 
//   double tp=NormalizeDouble(vask+vstop*vpoint,vdigits);
//   double sl = vbid-(StopLoss*PipPoint(symbol));
//   double tp = vbid+(TakeProfit*PipPoint(symbol));
//   double sl = iLow(symbol,0,(iLowest(symbol,0,MODE_LOW,4,0))); //SL at the highest at 4 bars      
//Comment("TP: "+tp+" / "+"SL :"+sl);   

   if (StopLoss == 0) { sl =0;}//if SL == 0 do set the SL to 0 avoiding error 130
   if (TakeProfit == 0) { tp =0;} //if TP == 0 do set the TP to 0 avoiding error 130

   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   int result=false;
   result= OrderSend(symbol,OP_BUY,Lotsize ,vask,3,sl,tp,comment,MagicNumber,0,clrGreen); 
Print("Open Buy on "+ symbol+ " : condition "+comment + ":" +result); 
return(result);  
}

int openSell(string symbol,string comment){

   double vbid    = MarketInfo(symbol,MODE_BID); double vask    = MarketInfo(symbol,MODE_ASK);
   double vpoint  = MarketInfo(symbol,MODE_POINT); int    vdigits = (int)MarketInfo(symbol,MODE_DIGITS);
   int    vspread = (int)MarketInfo(symbol,MODE_SPREAD);  
   double vstop=MarketInfo(symbol,MODE_STOPLEVEL); 
//Print(vbid+"/"+ vask+"/"+ vpoint+"/"+ vdigits+"/"+ vspread);
  
   RefreshRates();

//   double sl=NormalizeDouble(vask+vstop*vpoint,vdigits);
   double highest_tattoo = iHigh(symbol,0,(iHighest(symbol,0,MODE_HIGH,4,0))); //SL at the highest at 4 bars 

   double sl=NormalizeDouble(vask+vstop*vpoint,vdigits);      
   double tp=NormalizeDouble(vbid-vstop*vpoint,vdigits); 
   if (highest_tattoo>sl){sl = highest_tattoo;} 
   tp=0;
//   double sl=NormalizeDouble(vask+vstop*vpoint,vdigits); 
//   double tp=NormalizeDouble(vbid-vstop*vpoint,vdigits);    
//   double sl = vask+(StopLoss*PipPoint(symbol));
//   double tp = vask-(TakeProfit*PipPoint(symbol));
//   double sl = iHigh(symbol,0,(iHighest(symbol,0,MODE_HIGH,4,0))); //SL at the highest at 4 bars   
//Comment("TP: "+tp+" / "+"SL :"+sl);      
   if (TakeProfit == 0) { tp =0;} 
   if (StopLoss == 0) { sl =0;}
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   int result= OrderSend(symbol,OP_SELL,Lotsize ,vbid,3,sl,tp,comment,MagicNumber,0,clrRed);  
Print("Open Sell on "+ symbol+ " : condition "+comment + ":" +result); 
return(result); 
}



//+------------------------------------------------------------------+
//Helper Function
//+------------------------------------------------------------------+
void printInfo(){ 
   string text[30]; //Array of String store custom texts on screen
// TEXT SHOW CURRENSY STRENGTH SCORE
/*    text[0]  = "    PAIR      |     STR      |     SLOPE";
      for(int x=0; x<28; x++){text[x+1]  = cc_strength[x].currency_pair+ "    |     "+ cc_strength[x].strength+ "    |     "+ cc_strength[x].slope;}  */
// TEXT SHOW ORDER DETAILS      
      for(int x=0; x<ArraySize(my_open_orders); x++){
         string buy_sell;
         if(my_open_orders[x].type==0){
            buy_sell = "BUY";}
          else {buy_sell ="SELL";
          }
         //text[x]  = my_open_orders[x].symbol+" | "+ buy_sell +" | "+my_open_orders[x].open+" | "+my_open_orders[x].lot+" | "+my_open_orders[x].sl+" | "+my_open_orders[x].tp+" | "+my_open_orders[x].ticket+" | "+my_open_orders[x].profit+" | "+my_open_orders[x].comment+" | "+ ((3600-(TimeCurrent()-my_open_orders[x].time))); //TimeToStr((TimeCurrent()-my_open_orders[x].time),TIME_MINUTES)   
         text[x]  = my_open_orders[x].symbol+" | "+ buy_sell +" | "+my_open_orders[x].profit+" | "+my_open_orders[x].comment; //TimeToStr((TimeCurrent()-my_open_orders[x].time),TIME_MINUTES)   
      }          
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


void sorting_score(){
   double c[8];
      c [0] = aud.score; c [1] = cad.score; c [2] = eur.score; c [3] = gbp.score; 
      c [4] = nzd.score; c [5] = usd.score; c [6] = chf.score; c [7] = jpy.score; 
   
      ArraySort(c,WHOLE_ARRAY,0,MODE_DESCEND);  //sorting
         for(int i=0; i<ArraySize(c); i++)
            {
               //Print("Soring Loop "+ cc_score[0][1].score);
           /*    for(int j=0; j<ArraySize(c); j++)
               {if (c[i]== cc_score[0][j].score){cc_score_bar0_sorted[i] = cc_score[0][j];}} */ 
            } 
} 

void sorting_slope(void){
   double c[8];
     // c [0] = aud.slope; c [1] = cad.slope; c [2] = eur.slope; c [3] = gbp.slope; 
     // c [4] = nzd.slope; c [5] = usd.slope; c [6] = chf.slope; c [7] = jpy.slope; 
   
      ArraySort(c,WHOLE_ARRAY,0,MODE_DESCEND);  //sorting
         for(int i=0; i<ArraySize(c); i++)
            {
               string str="";
               for(int j=0; j<ArraySize(c); j++)
   //            {if (c[i]== cc_score_bar0[j].slope){ccs_sorted_slope[i] = cc_score_bar0[j];}}  
            } 
}  






bool is_this_pair_in_OpenPairList(string pair_to_check){
   bool a = true ;
   if(((StringFind(my_order_summary.open_pairs_list,pair_to_check,0)))==-1){
      a = false;
   }
   return(a);
}
     
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
         my_open_orders[i].comment= OrderComment();
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


/*  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit(){
   ObjectsDeleteAll(); 
   return(0);
}  */



//---------------Parameter-----------------
void get_CurrencyStrength(int bar){     
         aud.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,0,0),3);
         cad.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,1,0),3);
         eur.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,2,0),3);
         gbp.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,3,0),3);
         nzd.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,4,0),3);
         usd.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,5,0),3);
         chf.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,6,0),3);
         jpy.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,7,0),3);         
         
         aud.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,0,1),3) - aud.score;
         cad.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,1,1),3) - cad.score;
         eur.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,2,1),3) - eur.score;
         gbp.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,3,1),3) - gbp.score;
         nzd.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,4,1),3) - nzd.score;
         usd.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,5,1),3) - usd.score;
         chf.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,6,1),3) - chf.score;
         jpy.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,7,1),3) - jpy.score;
         
         cc_score [0] = aud; cc_score [1] = cad; cc_score [2] = eur; cc_score [3] = gbp; 
         cc_score [4] = nzd; cc_score [5] = usd; cc_score [6] = chf; cc_score [7] = jpy; 
//Print("BAR "+i+" : "+cc_score [i][0].score+"/"+cc_score [i][1].score+"/"+cc_score [i][2].score+"/"+cc_score [i][3].score+"/"+cc_score [i][4].score+"/"+cc_score [i][5].score+"/"+cc_score [i][6].score+"/"+cc_score [i][7].score);   
//Print("BAR 0"+" : "+cc_score [0][0].score+"/"+cc_score [0][1].score+"/"+cc_score [0][2].score+"/"+cc_score [0][3].score+"/"+cc_score [0][4].score+"/"+cc_score [0][5].score+"/"+cc_score [0][6].score+"/"+cc_score [0][7].score);   
         //*******insert 28 pairs formular PAIR1-PAIR2
         cc_strength [0].strength = aud.score - cad.score;  //0. AUD-CAD
         cc_strength [1].strength = aud.score - chf.score;  //1. AUD-CHF
         cc_strength [2].strength = aud.score - jpy.score;  //2. AUD-JPY
         cc_strength [3].strength = aud.score - nzd.score;  //3. AUD-NZD
         cc_strength [4].strength = aud.score - usd.score;  //4. AUD-USD
         cc_strength [5].strength = cad.score - chf.score;  //5. CAD-CHF
         cc_strength [6].strength = cad.score - jpy.score;  //6. CAD-JPY
         cc_strength [7].strength = chf.score - jpy.score;  //7. CHF-JPY
         cc_strength [8].strength = eur.score - aud.score;  //8. EUR-AUD
         cc_strength [9].strength = eur.score - cad.score;  //9. EUR-CAD
         cc_strength [10].strength = eur.score - chf.score; //10. EUR-CHF
         cc_strength [11].strength = eur.score - gbp.score; //11. EUR-GBP
         cc_strength [12].strength = eur.score - jpy.score; //12. EUR-JPY
         cc_strength [13].strength = eur.score - nzd.score; //13. EUR-NZD
         cc_strength [14].strength = eur.score - usd.score; //14. EUR-USD
         cc_strength [15].strength = gbp.score - aud.score; //15. GBP-AUD
         cc_strength [16].strength = gbp.score - cad.score; //16. GBP-CAD
         cc_strength [17].strength = gbp.score - chf.score; //17. GBP-CHF
         cc_strength [18].strength = gbp.score - jpy.score; //18. GBP-JPY
         cc_strength [19].strength = gbp.score - nzd.score; //19. GBP-NZD
         cc_strength [20].strength = gbp.score - usd.score; //20. GBP-USD
         cc_strength [21].strength = nzd.score - cad.score; //21. NZD-CAD
         cc_strength [22].strength = nzd.score - chf.score; //22. NZD-CHF
         cc_strength [23].strength = nzd.score - jpy.score; //23. NZD-JPY
         cc_strength [24].strength = nzd.score - usd.score; //24. NZD-USD
         cc_strength [25].strength = usd.score - cad.score; //25. USD-CAD
         cc_strength [26].strength = usd.score - chf.score; //26. USD-CHF
         cc_strength [27].strength = usd.score - jpy.score; //27. USD-JPY 
//Print("BAR "+i+" : "+cc_strength [0].strength+"/"+cc_strength [1].strength+"/"+cc_strength [2].strength+"/"+cc_strength [3].strength+"/"+cc_strength [4].strength+"/"+cc_strength [5].strength+"/"+cc_strength [6].strength+"/"+cc_strength [7].strength);            
         
         aud.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,0,bar),3);
         cad.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,1,bar),3);
         eur.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,2,bar),3);
         gbp.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,3,bar),3);
         nzd.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,4,bar),3);
         usd.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,5,bar),3);
         chf.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,6,bar),3);
         jpy.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,7,bar),3);
         
         // fill value of Currency Strength at bar N for temporary
         cc_strength [0].slope = aud.score - cad.score;  //0. AUD-CAD
         cc_strength [1].slope = aud.score - chf.score;  //1. AUD-CHF
         cc_strength [2].slope = aud.score - jpy.score;  //2. AUD-JPY
         cc_strength [3].slope = aud.score - nzd.score;  //3. AUD-NZD
         cc_strength [4].slope = aud.score - usd.score;  //4. AUD-USD
         cc_strength [5].slope = cad.score - chf.score;  //5. CAD-CHF
         cc_strength [6].slope = cad.score - jpy.score;  //6. CAD-JPY
         cc_strength [7].slope = chf.score - jpy.score;  //7. CHF-JPY
         cc_strength [8].slope = eur.score - aud.score;  //8. EUR-AUD
         cc_strength [9].slope = eur.score - cad.score;  //9. EUR-CAD
         cc_strength [10].slope = eur.score - chf.score; //10. EUR-CHF
         cc_strength [11].slope = eur.score - gbp.score; //11. EUR-GBP
         cc_strength [12].slope = eur.score - jpy.score; //12. EUR-JPY
         cc_strength [13].slope = eur.score - nzd.score; //13. EUR-NZD
         cc_strength [14].slope = eur.score - usd.score; //14. EUR-USD
         cc_strength [15].slope = gbp.score - aud.score; //15. GBP-AUD
         cc_strength [16].slope = gbp.score - cad.score; //16. GBP-CAD
         cc_strength [17].slope = gbp.score - chf.score; //17. GBP-CHF
         cc_strength [18].slope = gbp.score - jpy.score; //18. GBP-JPY
         cc_strength [19].slope = gbp.score - nzd.score; //19. GBP-NZD
         cc_strength [20].slope = gbp.score - usd.score; //20. GBP-USD
         cc_strength [21].slope = nzd.score - cad.score; //21. NZD-CAD
         cc_strength [22].slope = nzd.score - chf.score; //22. NZD-CHF
         cc_strength [23].slope = nzd.score - jpy.score; //23. NZD-JPY
         cc_strength [24].slope = nzd.score - usd.score; //24. NZD-USD
         cc_strength [25].slope = usd.score - cad.score; //25. USD-CAD
         cc_strength [26].slope = usd.score - chf.score; //26. USD-CHF
         cc_strength [27].slope = usd.score - jpy.score; //27. USD-JPY  
         
         //calculate slope using bar0 strength score - barN strength score
         cc_strength [0].slope = cc_strength [0].strength - cc_strength [0].slope;  //0. AUD-CAD
         cc_strength [1].slope = cc_strength [1].strength - cc_strength [1].slope;  //1. AUD-CHF
         cc_strength [2].slope = cc_strength [2].strength - cc_strength [2].slope;  //2. AUD-JPY
         cc_strength [3].slope = cc_strength [3].strength - cc_strength [3].slope;  //3. AUD-NZD
         cc_strength [4].slope = cc_strength [4].strength - cc_strength [4].slope;  //4. AUD-USD
         cc_strength [5].slope = cc_strength [5].strength - cc_strength [5].slope;  //5. CAD-CHF
         cc_strength [6].slope = cc_strength [6].strength - cc_strength [6].slope;  //6. CAD-JPY
         cc_strength [7].slope = cc_strength [7].strength - cc_strength [7].slope;  //7. CHF-JPY
         cc_strength [8].slope = cc_strength [8].strength - cc_strength [8].slope;  //8. EUR-AUD
         cc_strength [9].slope = cc_strength [9].strength - cc_strength [9].slope;  //9. EUR-CAD
         cc_strength [10].slope =cc_strength [10].strength - cc_strength [10].slope; //10. EUR-CHF
         cc_strength [11].slope =cc_strength [11].strength - cc_strength [11].slope; //11. EUR-GBP
         cc_strength [12].slope =cc_strength [12].strength - cc_strength [12].slope; //12. EUR-JPY
         cc_strength [13].slope =cc_strength [13].strength - cc_strength [13].slope; //13. EUR-NZD
         cc_strength [14].slope =cc_strength [14].strength - cc_strength [14].slope; //14. EUR-USD
         cc_strength [15].slope =cc_strength [15].strength - cc_strength [15].slope; //15. GBP-AUD
         cc_strength [16].slope =cc_strength [16].strength - cc_strength [16].slope; //16. GBP-CAD
         cc_strength [17].slope =cc_strength [17].strength - cc_strength [17].slope; //17. GBP-CHF
         cc_strength [18].slope =cc_strength [18].strength - cc_strength [18].slope; //18. GBP-JPY
         cc_strength [19].slope =cc_strength [19].strength - cc_strength [19].slope; //19. GBP-NZD
         cc_strength [20].slope =cc_strength [20].strength - cc_strength [20].slope; //20. GBP-USD
         cc_strength [21].slope =cc_strength [21].strength - cc_strength [21].slope; //21. NZD-CAD
         cc_strength [22].slope =cc_strength [22].strength - cc_strength [22].slope; //22. NZD-CHF
         cc_strength [23].slope =cc_strength [23].strength - cc_strength [23].slope; //23. NZD-JPY
         cc_strength [24].slope =cc_strength [24].strength - cc_strength [24].slope; //24. NZD-USD
         cc_strength [25].slope =cc_strength [25].strength - cc_strength [25].slope; //25. USD-CAD
         cc_strength [26].slope =cc_strength [26].strength - cc_strength [26].slope; //26. USD-CHF
         cc_strength [27].slope =cc_strength [27].strength - cc_strength [27].slope; //27. USD-JPY  
     // sorting_score();      
   /*     for(int j=0; j<ArraySize(cc_score_bar0_sorted); j++){
         //Print(j+" : "+cc_score_bar0_sorted[j].score);           
      }*/
}

void getBestPairToTrade(int bar){
/*
string bestPairToTrade;
string previousBestPair;
bool  buyOrSell; //true = buy, false = sell
*/
         aud.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,0,0),3);
         cad.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,1,0),3);
         eur.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,2,0),3);
         gbp.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,3,0),3);
         nzd.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,4,0),3);
         usd.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,5,0),3);
         chf.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,6,0),3);
         jpy.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,7,0),3);

         aud.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,0,bar),3) - aud.score;
         cad.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,1,bar),3) - cad.score;
         eur.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,2,bar),3) - eur.score;
         gbp.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,3,bar),3) - gbp.score;
         nzd.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,4,bar),3) - nzd.score;
         usd.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,5,bar),3) - usd.score;
         chf.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,6,bar),3) - chf.score;
         jpy.slope = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,7,bar),3) - jpy.score;
         
         cc_score [0] = aud; cc_score [1] = cad; cc_score [2] = eur; cc_score [3] = gbp; 
         cc_score [4] = nzd; cc_score [5] = usd; cc_score [6] = chf; cc_score [7] = jpy;
         
         double temp [8];
         for (int i=0;i<8;i++){
            temp[i] =cc_score[i].score;
            //Print (i+": "+temp[i]);
         }
//Print ("Maximum: "+  ArrayMaximum(temp,WHOLE_ARRAY,0));
//Print ("Minimum: "+  ArrayMinimum(temp,WHOLE_ARRAY,0));
         cc_score_structure cc_score_most_strength = cc_score[ArrayMaximum(temp,WHOLE_ARRAY,0)];
//Print(cc_score_most_strength.currency+" "+cc_score_most_strength.score+" "+cc_score_most_strength.slope);
         cc_score_structure cc_score_most_weekness = cc_score[ArrayMinimum(temp,WHOLE_ARRAY,0)];
//Print(cc_score_most_weekness.currency+" "+cc_score_most_weekness.score+" "+cc_score_most_weekness.slope);         
         string pair = cc_score_most_strength.currency+cc_score_most_weekness.currency;
         string pair_inverse = cc_score_most_weekness.currency+cc_score_most_strength.currency;
//Print(SymbolSelect(pair_inverse,true)+"***********************");     
         buyOrSell = true ; //trigger to buy 
         
         bestPairToTrade = pair;
         if(SymbolSelect(pair,true)==false){bestPairToTrade = pair_inverse;buyOrSell=false;}
//Print("Best Pair to trade is : "+bestPairToTrade);
//Print("Spread : "+ (int)MarketInfo(pair,MODE_SPREAD));
//Print("BID : "+ (double)MarketInfo(pair,MODE_BID));
//Print("ASK : "+ (double)MarketInfo(pair,MODE_ASK));
         
}