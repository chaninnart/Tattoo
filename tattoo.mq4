//+------------------------------------------------------------------+
//|                                                  2020.mq4 |
//|                                       Copyright 2020, Chaninnart |
//|                                             longsorb@gmail.com
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Chaninnart"
#property version   "1.1"
//#property strict //disable for fix some bug in NormalizdDouble decimal error.

struct order_structure{string symbol;int type;double profit;double open;double lot;double sl;double tp;int ticket;order_structure(){symbol="";type=0;profit=0.0;open=0.0;lot=0.0;sl=0.0;tp=0.0;ticket=0;}};
order_structure my_open_orders[];

struct order_summary{int total; int order_buy; int order_sell; double net_profit;string open_pairs_list; order_summary(){total=0;order_buy=0;order_sell=0;net_profit=0.0;open_pairs_list="";}};
order_summary my_order_summary;


//+------------------------------------------------------------------+
//| Global Variable Declaration                                   |
//+------------------------------------------------------------------+
//--- Timer parameters checking new bar.
bool thisIsNewBar = false;
// show info on screen
bool ShowInfo = true; 
int barCount=0;


//+------------------------------------------------------------------+
//| Order Setting                                  |
//+------------------------------------------------------------------+
int MagicNumber  = 5652534;         //Magic Number
extern double   Lotsize = 0.1;   //Order Setting (Lot Size)
extern double   StopLoss   = 00;       //Stop Loss (in Points)
extern double   TakeProfit   = 00;       //Take Profit (in Points)
extern int TS = 0;               //Trailing Stop (in Points)
int spread_value;                 //get spred_value
int max_open_order = 7;    //maximum open order to open
//+------------------------------------------------------------------+
//| Indicator Variable                                  |
//+------------------------------------------------------------------+
//1. ATR  //use for select the most interested pair.
input int atr_parameter = 14;  //ATR period
double atr_bar0[28];



//+------------------------------------------------------------------+
//| Custom Indicator Variable                                  |
//+------------------------------------------------------------------+
//1. Currency Strength

input int cc_str_parameter = 14;  //CCS parameter
// define struct with contain consturctor method to set default value to the struct memebers
struct ccs_structure{string currency; double score; double slope; ccs_structure(){currency="";score = 0.0;slope= 0.0;}};
ccs_structure aud ,cad,eur,gbp ,nzd ,usd,chf,jpy;
ccs_structure ccs_bar0[8];
ccs_structure ccs_sorted_score[8];
ccs_structure ccs_sorted_slope[8];

//1.1 Currency Score, 28 pairs
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

struct ccs_score_structure{string currency_pair; double score; double atr;int hull_pivot_status;bool; ccs_score_structure(){currency_pair="";score = 0.0;atr= 0.0;hull_pivot_status= 0;}};
ccs_score_structure ccs_score_map[28];


//2. Hull's Moving Average
input int hull_parameter = 14;  //Hull period
double hull_buffer0_val0;double hull_buffer0_val1;double hull_buffer0_val2;
double hull_buffer1_val0;double hull_buffer1_val1;double hull_buffer1_val2;
bool hull_revert_from_Hi_Low ; bool hull_revert_from_Low_Hi; // : for measure the turning point of hull-MA




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //set Timer to proceed the OnTick while close market.
   EventSetTimer(3);
   //parameter initialization
   aud.currency = "AUD";cad.currency = "CAD";eur.currency = "EUR";gbp.currency = "GBP"; nzd.currency = "NZD"; usd.currency = "USD";chf.currency = "CHF";jpy.currency = "JPY"; 
  
     
   for(int i=0; i<ArraySize(pairs); i++){ccs_score_map[i].currency_pair = pairs[i];}//Print(ccs_score_map[i].currency_pair); 
   
   // process
   OnTick();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+  
void OnTimer()
  {
//---
   OnTick();
  }
//+------------------------------------------------------------------+


  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   getAllOrdersDetail();
   getAllParameter(); 

   trading_strategy_controller();
   printInfo(); 
   Comment("Open order Toal: "+my_order_summary.total+" / Net Profit: "+my_order_summary.net_profit+" / Open Pair(s) List: "+my_order_summary.open_pairs_list);   
  
  }

void getAllOrdersDetail(){
   getOrdersDetail();   
   getOrderSummary();
}
  
void  getAllParameter(){  
   getCCS();
   getATR(); 
   getHull();
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
      }      
   } 
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



//---------------Parameter-----------------
void getCCS(){
      aud.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,0,0),3);
      cad.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,1,0),3);
      eur.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,2,0),3);
      gbp.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,3,0),3);
      nzd.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,4,0),3);
      usd.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,5,0),3);
      chf.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,6,0),3);
      jpy.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,7,0),3); 
 
      aud.slope = NormalizeDouble(aud.score - iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,0,1),3);
      cad.slope = NormalizeDouble(cad.score - iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,1,1),3);
      eur.slope = NormalizeDouble(eur.score - iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,2,1),3);
      gbp.slope = NormalizeDouble(gbp.score - iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,3,1),3);
      nzd.slope = NormalizeDouble(nzd.score - iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,4,1),3);
      usd.slope = NormalizeDouble(usd.score - iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,5,1),3);
      chf.slope = NormalizeDouble(chf.score - iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,6,1),3);
      jpy.slope = NormalizeDouble(jpy.score - iCustom(NULL,0,"_CurrencyStrength",cc_str_parameter,7,1),3);   
    
      ccs_bar0 [0] = aud; ccs_bar0 [1] = cad; ccs_bar0 [2] = eur; ccs_bar0 [3] = gbp; 
      ccs_bar0 [4] = nzd; ccs_bar0 [5] = usd; ccs_bar0 [6] = chf; ccs_bar0 [7] = jpy;
    
      sorting_score();
      sorting_slope();
      
      
      //insert 28 pairs formular PAIR1-PAIR2
      ccs_score_map[0].score = aud.score - cad.score;  //0. AUD-CAD
      ccs_score_map[1].score = aud.score - chf.score;  //1. AUD-CHF
      ccs_score_map[2].score = aud.score - jpy.score;  //2. AUD-JPY
      ccs_score_map[3].score = aud.score - nzd.score;  //3. AUD-NZD
      ccs_score_map[4].score = aud.score - usd.score;  //4. AUD-USD
      ccs_score_map[5].score = cad.score - chf.score;  //5. CAD-CHF
      ccs_score_map[6].score = cad.score - jpy.score;  //6. CAD-JPY
      ccs_score_map[7].score = chf.score - jpy.score;  //7. CHF-JPY
      ccs_score_map[8].score = eur.score - aud.score;  //8. EUR-AUD
      ccs_score_map[9].score = eur.score - cad.score;  //9. EUR-CAD
      ccs_score_map[10].score = eur.score - chf.score; //10. EUR-CHF
      ccs_score_map[11].score = eur.score - gbp.score; //11. EUR-GBP
      ccs_score_map[12].score = eur.score - jpy.score; //12. EUR-JPY
      ccs_score_map[13].score = eur.score - nzd.score; //13. EUR-NZD
      ccs_score_map[14].score = eur.score - usd.score; //14. EUR-USD
      ccs_score_map[15].score = gbp.score - aud.score; //15. GBP-AUD
      ccs_score_map[16].score = gbp.score - cad.score; //16. GBP-CAD
      ccs_score_map[17].score = gbp.score - chf.score; //17. GBP-CHF
      ccs_score_map[18].score = gbp.score - jpy.score; //18. GBP-JPY
      ccs_score_map[19].score = gbp.score - nzd.score; //19. GBP-NZD
      ccs_score_map[20].score = gbp.score - usd.score; //20. GBP-USD
      ccs_score_map[21].score = nzd.score - cad.score; //21. NZD-CAD
      ccs_score_map[22].score = nzd.score - chf.score; //22. NZD-CHF
      ccs_score_map[23].score = nzd.score - jpy.score; //23. NZD-JPY
      ccs_score_map[24].score = nzd.score - usd.score; //24. NZD-USD
      ccs_score_map[25].score = usd.score - cad.score; //25. USD-CAD
      ccs_score_map[26].score = usd.score - chf.score; //26. USD-CHF
      ccs_score_map[27].score = usd.score - jpy.score; //27. USD-JPY

//for(int i=0; i<ArraySize(pairs); i++){ Print(ccs_score_map[i].currency_pair+":"+ccs_score_map[i].score);}  

}

void getATR(){
   for(int i=0; i<ArraySize(pairs); i++){ccs_score_map[i].atr = NormalizeDouble(iATR(pairs[i],PERIOD_H1,atr_parameter,0),5);}//Print(ccs_score_map[i].atr);}  

}


void getHull(){
bool hull_is_pivot;
   for(int i=0; i<ArraySize(pairs); i++){
      hull_buffer0_val1 = iCustom(pairs[i],PERIOD_H1,"hull_moving_average_2.0_nmc",14,0,1);
      hull_buffer0_val2 = iCustom(pairs[i],PERIOD_H1,"hull_moving_average_2.0_nmc",14,0,2);
      hull_buffer1_val1 = iCustom(pairs[i],PERIOD_H1,"hull_moving_average_2.0_nmc",14,1,1);
      hull_buffer1_val2 = iCustom(pairs[i],PERIOD_H1,"hull_moving_average_2.0_nmc",14,1,2);
      hull_revert_from_Hi_Low = ((hull_buffer1_val2 == EMPTY_VALUE)&&(hull_buffer1_val1 != EMPTY_VALUE));
      hull_revert_from_Low_Hi = ((hull_buffer1_val2 != EMPTY_VALUE)&&(hull_buffer1_val1 == EMPTY_VALUE));
      hull_is_pivot = (hull_revert_from_Hi_Low || hull_revert_from_Low_Hi);
      ccs_score_map[i].hull_pivot_status = 0;
      
      if (hull_is_pivot){
         if (hull_revert_from_Hi_Low){ccs_score_map[i].hull_pivot_status = 1;}
         else ccs_score_map[i].hull_pivot_status = 2;
      }    
   }  
}




//+-------------------------------------------------------------------------------------------------------------------->>>>>>>>>>>>

void  trading_strategy_controller(){ 

   // INSTALL TRADING STRATEGY 2 : ORDER MANAGEMENT 
   if(OrdersTotal()!= 0){ts2_opened_order_management();}
   
   
   // INSTALL TRADING STRATEGY 1 : OPEN ORDER 
   ts1_open_order();
  

}

void ts1_open_order(){
   
   for(int i=0; i<ArraySize(ccs_score_map); i++){ //looping check all value in all currency
  
      int result;
   //ccs_score_map[7].hull_pivot_status = 1;        
      int get_hull_pivot_status = ccs_score_map[i].hull_pivot_status;
      // case 0 = no pivot, case 1 = pivot on top, case 2 = pivot on bottom
      switch (get_hull_pivot_status){
         case 0:  break; // 
         case 1:  if(!is_this_pair_already_opened(ccs_score_map[i].currency_pair)){                        
                     if(ccs_score_map[i].score < -20 && OrdersTotal()<max_open_order){  // && ccs_score_map[i].atr >50;                          
                        openChart(ccs_score_map[i].currency_pair);
                        result = openSell(ccs_score_map[i].currency_pair,"HULL_OPEN_SELL_Pivot_TOP");
                        Print("******1: "+result);}
                       
         }break;
                     
         case 2:  if(!is_this_pair_already_opened(ccs_score_map[i].currency_pair)){                       
                     if(ccs_score_map[i].score > 20&& OrdersTotal()<max_open_order){
                        openChart(ccs_score_map[i].currency_pair);
                        result= openBuy(ccs_score_map[i].currency_pair,"HULL_OPEN_BUY_Pivot_BOTTOM");
                        Print("******3: "+result);}
                         
         }break;                     
      }
   }
}

void ts2_opened_order_management(){
   //closing all orders
   if(AccountProfit() > 100){closeAllOrder(1);closeAllOrder(2);}
   //closing all buy orders
   if(AccountProfit() > 500){closeAllOrder(1);}
   //closing all sell orders
   if(AccountProfit() > 1000){closeAllOrder(2);}
   //closing by currency pairs
   
   
   //profit_controller(){}; 
   //modify order 
   
   //open more order



}














//-------------------------------------------------------------------------------------
void openChart(string pair){
   long chartToOpen;
   chartToOpen=ChartOpen(pair,PERIOD_H1);
   ChartApplyTemplate(chartToOpen,"_hull_only.tpl");
}


//+------------------------------------------------------------------+
//Helper Function
//+------------------------------------------------------------------+
void printInfo(){
   string text[30]; //Array of String store custom texts on screen
 //   text[0]  = "    PAIR      |    HULL   |      ATR      |     SCORE";
    //if (ArraySize(my_open_orders)>29){return;}
  
      for(int x=0; x<ArraySize(my_open_orders); x++){

         text[x]  = my_open_orders[x].symbol+" | "+my_open_orders[x].type+" | "+my_open_orders[x].profit+" | "+my_open_orders[x].open+" | "+my_open_orders[x].lot+" | "+my_open_orders[x].sl+" | "+my_open_orders[x].tp+" | "+my_open_orders[x].ticket;
   
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
void drawYellowDownArrowOnScreen(int index){ 
   int bar;
   bar=Bars;
   string name2 = "Dn"+string(bar);
   ObjectCreate(name2,OBJ_ARROW, 0, Time[index], High[index]+10*Point); 
   ObjectSet(name2, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name2, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
   ObjectSet(name2, OBJPROP_COLOR,Yellow);   
}
void drawGreenUpArrowOnScreen(int index){ 
   int bar;
   bar=Bars;
   string name2 = "Dn"+string(bar);
   ObjectCreate(name2,OBJ_ARROW, 0, Time[index], Low[index]-10*Point); 
   ObjectSet(name2, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name2, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
   ObjectSet(name2, OBJPROP_COLOR,Green);   
}

void sorting_score(){
   double c[8];
      c [0] = aud.score; c [1] = cad.score; c [2] = eur.score; c [3] = gbp.score; 
      c [4] = nzd.score; c [5] = usd.score; c [6] = chf.score; c [7] = jpy.score; 
   
      ArraySort(c,WHOLE_ARRAY,0,MODE_DESCEND);  //sorting
         for(int i=0; i<ArraySize(c); i++)
            {
               string str="";
               for(int j=0; j<ArraySize(c); j++)
               {if (c[i]== ccs_bar0[j].score){ccs_sorted_score[i] = ccs_bar0[j];}}  
            } 
} 

void sorting_slope(void){
   double c[8];
      c [0] = aud.slope; c [1] = cad.slope; c [2] = eur.slope; c [3] = gbp.slope; 
      c [4] = nzd.slope; c [5] = usd.slope; c [6] = chf.slope; c [7] = jpy.slope; 
   
      ArraySort(c,WHOLE_ARRAY,0,MODE_DESCEND);  //sorting
         for(int i=0; i<ArraySize(c); i++)
            {
               string str="";
               for(int j=0; j<ArraySize(c); j++)
               {if (c[i]== ccs_bar0[j].slope){ccs_sorted_slope[i] = ccs_bar0[j];}}  
            } 
} 
 

void resetAll(){
   thisIsNewBar = false;
}


//Calculate Next Bar-----------------------------------------+
void DetectNewBar(void){
   static datetime time = Time[0];
   if(Time[0] > time){
      time = Time[0]; //newbar, update time
      thisIsNewBar = true;
      barCount++;
   }
}   
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit(){
   ObjectsDeleteAll(); 
   return(0);
}  



//---------------Press Order-----------------
// Order send
int openBuy (string symbol,string comment) { 
   double vbid    = MarketInfo(symbol,MODE_BID); double vask    = MarketInfo(symbol,MODE_ASK);
   double vpoint  = MarketInfo(symbol,MODE_POINT); int    vdigits = (int)MarketInfo(symbol,MODE_DIGITS);
   int    vspread = (int)MarketInfo(symbol,MODE_SPREAD);
   
//Print(vbid+"/"+ vask+"/"+ vpoint+"/"+ vdigits+"/"+ vspread);
//Print(Bid +":"+Ask);  
   RefreshRates();  
   //Retrive Bid / Offer from Current Symbol Pair  
   double tp = vask+(TakeProfit*PipPoint(symbol));
   double sl = vbid-(StopLoss*PipPoint(symbol));
   if (TakeProfit == 0) { tp =0;} //if TP == 0 do set the TP to 0 avoiding error 130
   if (StopLoss == 0) { sl =0;}
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
//Print(vbid+"/"+ vask+"/"+ vpoint+"/"+ vdigits+"/"+ vspread);
//Print(Bid +":"+Ask);  
   RefreshRates(); 
   double tp = vbid-(TakeProfit*Point);
   double sl = vask+(StopLoss*Point);   
   if (TakeProfit == 0) { tp =0;} 
   if (StopLoss == 0) { sl =0;}
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   int result= OrderSend(symbol,OP_SELL,Lotsize ,vbid,3,sl,tp,comment,MagicNumber,0,clrRed);  
Print("Open Sell on "+ symbol+ " : condition "+comment + ":" +result); 
return(result); 
}

// Pip Point Function
double PipPoint(string Currency){
   double CalcDigits; double CalcPoint = 0.0 ;
      CalcDigits = MarketInfo(Currency,MODE_DIGITS);
         if(CalcDigits == 2 || CalcDigits == 3) CalcPoint = 0.01;
         else if(CalcDigits == 4 || CalcDigits == 5) CalcPoint = 0.0001;
   return(CalcPoint);
}

// Get Slippage Function
double GetSlippage(string Currency, int SlippagePips){
   double CalcDigits ;  double CalcSlippage =0.0;
      CalcDigits = MarketInfo(Currency,MODE_DIGITS);
         if(CalcDigits == 2 || CalcDigits == 4) CalcSlippage = SlippagePips;
         else if(CalcDigits == 3 || CalcDigits == 5) CalcSlippage = SlippagePips * 10;
   return(CalcSlippage);
}



bool is_this_pair_already_opened(string pair_to_check){
   bool a = true ;
   if(((StringFind(my_order_summary.open_pairs_list,pair_to_check,0)))==-1){
      a = false;
   }
   return(a);
}

void closeAllOrder(int type){
   int result=false;
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
      
   
  if(result<0)
     {
      Print("***********OrderSend failed with error #",GetLastError());
     }
  else
      Print("************OrderSend placed successfully");
  
}