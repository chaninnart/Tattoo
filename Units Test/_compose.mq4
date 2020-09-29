//+------------------------------------------------------------------+
//|                                          1_array_of_28_pairs.mq4 |
//|                                                       Chaninnart |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chaninnart"
#property link      "https://www.mql5.com"
#property version   "1.06"
//#property strict

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
string pair_score_symbol [8]= { "AUD", "CAD","EUR","GBP","NZD","USD","CHF","JPY" };
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

string text_comment;


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
   ArrayInitialize(pairs_point,EMPTY_VALUE);
   ArrayInitialize(open_pairs,EMPTY_VALUE);
   ArrayInitialize(open_pairs_profit,0);
   for(int x=0; x<28; x++){
      SymbolInfoTick(pairs[x],mqltick[x]);
      open_pairs[x]=CheckOpenOrders(pairs[x]);
      open_pairs_count[x] = CheckOpenOrders(pairs[x]);
      ccs_indicator (ccs_score_array,240,14,0); //update currency strength   
   }
   
//---
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---run sequence
   
//---update data 
   CheckOpenOrdersStatus();   
   ccs_indicator (ccs_score_array,240,14,0); //update currency strength 
   for(int x=0; x<28; x++){
      SymbolInfoTick(pairs[x],mqltick[x]);
      //open_pairs[x]=CheckOpenOrders(pairs[x]);
      //open_pairs_count[x] = CountOpenOrders(pairs[x]);
      
   }

   CheckLogicToManageOrder();
   CheckLogicToOpenOrder();
   printInfo();   
}

void  CheckLogicToOpenOrder (){
   
   ActivateOpenOrderStrategy(pairs[8]);
   for(int x=0; x<28; x++){
      if(pairs [x] != ccs_best_pair[0]){continue;}
      if(open_pairs[x] == 0){ActivateOpenOrderStrategy(pairs[x]);}
   }
   
}

void  CheckLogicToManageOrder (){
   for(int x=0; x<28; x++){
      //if(pairs [x] != ccs_best_pair){continue;}  
      if(open_pairs[x] != 0){ActivateManageOrderStrategy(pairs[x]);}      
   }
}

//*********************************************************************LOGIC HERE!!!!!!


void ActivateManageOrderStrategy(string symbol){   
//Comment ("IN Manage /"+symbol+" Profit:  "+open_pairs_profit[pair_string_convert_to_int(symbol)]);

   //if((symbol != ccs_best_pair)&& open_pairs_profit[pair_string_convert_to_int(symbol)]>0){closeAllOrder(1);closeAllOrder(2);}   
   bool hull30_is_pivot[28];
   bool hull30_pivot_status[28];   
   hma_indicator_all_pairs(30,14,hull30_is_pivot,hull30_pivot_status);
   
   int result=0;
  
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      result=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
      if((OrderType() == OP_BUY)&& hull30_is_pivot[pair_string_convert_to_int(OrderSymbol())]== true&& hull30_pivot_status[pair_string_convert_to_int(OrderSymbol())] ==0)
         {result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),1000,0);  };
      if((OrderType() == OP_SELL)&& hull30_is_pivot[pair_string_convert_to_int(OrderSymbol())]==true&& hull30_pivot_status[pair_string_convert_to_int(OrderSymbol())] ==1) 
         {result =OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),1000,0);};
   }        
}


void ActivateOpenOrderStrategy(string symbol){      
   double adx_value=0.0;   adx_value = iADX(symbol,30,14,PRICE_OPEN,MODE_MAIN,0);
   bool hull60_is_pivot[]= {false}; //declare single element dynamic array
   bool hull60_pivot_status[]={false};   
  
   hma_indicator(symbol,60,14,hull60_is_pivot,hull60_pivot_status);
   if (invert_symbol == 0 && hull60_is_pivot[0]){                  
         if(!hull60_pivot_status[0]){openBuy(symbol,symbol+"B");}
         if(hull60_pivot_status[0]){openSell(symbol,symbol+"S");}
   }
   if (invert_symbol == 1 && hull60_is_pivot[0]){                  
         if(!hull60_pivot_status[0]){openSell(symbol,symbol+"S");}
         if(hull60_pivot_status[0]){openBuy(symbol,symbol+"B");}
   }
   
   
   
text_comment = "Hull 60 on :" +symbol + " is pivot =" + hull60_is_pivot[0] + " /Pivot Status = " + hull60_pivot_status[1];  
 /*  
   // this is for real trade !!! not for backtesting   
   if(symbol== ccs_best_pair && adx_value > 20 && hull5_is_pivot  ){         
      if(!hull_pivot_status[pair_string_convert_to_int(symbol)]){openBuy(symbol,"*****open buy");}
      if(hull_pivot_status[pair_string_convert_to_int(symbol)]){openSell(symbol,"*****open sell");}
   }*/
     
}



//*********************************************************************INDICATOR HERE!!!!!!

double ccs_score_array[8]; //global variable for ccs indicator
double ccs_slope_1[8];
string ccs_best_pair [2] = {"PREV BEST PAIR","LAST BEST PAIR"};
bool invert_symbol=false;  //flag showing that best pair have to invert symbol
       
void ccs_indicator (double &array_score[],int timeframe,int period,int shift){   //array size=8 
       
   //timeframe 0 (current),1,5,15,30,60,240,1440,10080,43200
   //string pairs[28] = {"AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD", "CADCHF",	"CADJPY", "CHFJPY", "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD", "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD", "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD", "USDCAD",   "USDCHF",	"USDJPY"};

   double pairs_value [28];     
   string score_most_strength; string score_most_weekness;  
   string best_pair;
 
   
   /* calculate inside the expert
      for(int x=0; x<28; x++){pairs_value[x] =(iRSI(pairs[x],240,period,PRICE_OPEN,shift)-50);}   
   
      score0_AUD = pairs_value[0]+pairs_value[1]+pairs_value[2]+pairs_value[3]+pairs_value[4] -(pairs_value[8]+pairs_value[15]);
      score1_CAD = pairs_value[5]+pairs_value[6] -(pairs_value[0]+pairs_value[9]+pairs_value[16]+pairs_value[21]+pairs_value[25]);
      score2_EUR = pairs_value[14]+pairs_value[9]+pairs_value[10]+pairs_value[11]+pairs_value[12]+pairs_value[13]+pairs_value[14];
      score3_GBP = pairs_value[15]+pairs_value[16]+pairs_value[17]+pairs_value[18]+pairs_value[19]+pairs_value[20] -(pairs_value[11]);
      score4_NZD = pairs_value[21]+pairs_value[22]+pairs_value[23]+pairs_value[24] -(pairs_value[3]+pairs_value[13]+pairs_value[19]);
      score5_USD = pairs_value[25]+pairs_value[26]+pairs_value[27] -(pairs_value[4]+pairs_value[14]+pairs_value[20]+pairs_value[24]);
      score6_CHF = pairs_value[7] -(pairs_value[1]+pairs_value[5]+pairs_value[10]+pairs_value[17]+pairs_value[22]+pairs_value[26]);
      score7_JPY = 0- (pairs_value[2]+pairs_value[6]+pairs_value[7]+pairs_value[12]+pairs_value[18]+pairs_value[23]+pairs_value[27]);  
      array_score[0]=score0_AUD;array_score[1]=score1_CAD; array_score[2]=score2_EUR; array_score[3]=score3_GBP; 
      array_score[4]=score4_NZD;array_score[5]=score5_USD; array_score[6]=score6_CHF; array_score[7]=score7_JPY; */
      
      
      ccs_score_array[0] = iCustom(NULL,0,"_CurrencyScore",0,0);
      ccs_score_array[1] = iCustom(NULL,0,"_CurrencyScore",1,0);
      ccs_score_array[2] = iCustom(NULL,0,"_CurrencyScore",2,0);
      ccs_score_array[3] = iCustom(NULL,0,"_CurrencyScore",3,0);
      ccs_score_array[4] = iCustom(NULL,0,"_CurrencyScore",4,0);
      ccs_score_array[5] = iCustom(NULL,0,"_CurrencyScore",5,0);
      ccs_score_array[6] = iCustom(NULL,0,"_CurrencyScore",6,0);
      ccs_score_array[7] = iCustom(NULL,0,"_CurrencyScore",7,0); 

      ccs_slope_1[0] = iCustom(NULL,0,"_CurrencyScore",0,4);
      ccs_slope_1[1] = iCustom(NULL,0,"_CurrencyScore",1,4);
      ccs_slope_1[2] = iCustom(NULL,0,"_CurrencyScore",2,4);
      ccs_slope_1[3] = iCustom(NULL,0,"_CurrencyScore",3,4);
      ccs_slope_1[4] = iCustom(NULL,0,"_CurrencyScore",4,4);
      ccs_slope_1[5] = iCustom(NULL,0,"_CurrencyScore",5,4);
      ccs_slope_1[6] = iCustom(NULL,0,"_CurrencyScore",6,4);
      ccs_slope_1[7] = iCustom(NULL,0,"_CurrencyScore",7,4);       
   
      ccs_slope_1[0] = ccs_score_array[0] - ccs_slope_1[0] ;
      ccs_slope_1[1] = ccs_score_array[1] - ccs_slope_1[1] ;
      ccs_slope_1[2] = ccs_score_array[2] - ccs_slope_1[2] ;
      ccs_slope_1[3] = ccs_score_array[3] - ccs_slope_1[3] ;
      ccs_slope_1[4] = ccs_score_array[4] - ccs_slope_1[4] ;
      ccs_slope_1[5] = ccs_score_array[5] - ccs_slope_1[5] ;
      ccs_slope_1[6] = ccs_score_array[6] - ccs_slope_1[6] ;
      ccs_slope_1[7] = ccs_score_array[7] - ccs_slope_1[7] ; 
   
   score_most_strength = pair_score_symbol[ArrayMaximum(ccs_score_array,WHOLE_ARRAY,0)];
   score_most_weekness = pair_score_symbol[ArrayMinimum(ccs_score_array,WHOLE_ARRAY,0)];
   best_pair = score_most_strength+ score_most_weekness;  
   
   invert_symbol = false;
   if (MarketInfo(best_pair,MODE_BID)== 0){best_pair = score_most_weekness+ score_most_strength; invert_symbol = true;} //inverse bestpair CHFGBP -> GBPCHF   
   if (best_pair != ccs_best_pair[0]){ccs_best_pair[1] = ccs_best_pair[0];} //if changing the best pair collect the previous pair to variable ccs_prev_best_pair
   ccs_best_pair[0] = best_pair;
     
}


//*********************************************************************INDICATOR HERE!!!!!!

void hma_indicator(string symbol,int timeframe,int period ,bool &hull_is_pivot[], bool &hull_pivot_status[]){
   hull_is_pivot[0]= false;
   double hull_buffer0_val1;double hull_buffer0_val2;
   double hull_buffer1_val1;double hull_buffer1_val2;
   bool hull_revert_from_Hi_Low ; bool hull_revert_from_Low_Hi; // : for measure the turning point of hull-MA  
       
      hull_buffer0_val1 = iCustom(symbol,timeframe,"hull_moving_average_2.0_nmc",period,0,1);
      hull_buffer0_val2 = iCustom(symbol,timeframe,"hull_moving_average_2.0_nmc",period,0,2);
      hull_buffer1_val1 = iCustom(symbol,timeframe,"hull_moving_average_2.0_nmc",period,1,1);
      hull_buffer1_val2 = iCustom(symbol,timeframe,"hull_moving_average_2.0_nmc",period,1,2);
    
      hull_revert_from_Hi_Low = ((hull_buffer1_val2 == EMPTY_VALUE)&&(hull_buffer1_val1 != EMPTY_VALUE));
      hull_revert_from_Low_Hi = ((hull_buffer1_val2 != EMPTY_VALUE)&&(hull_buffer1_val1 == EMPTY_VALUE));
      hull_is_pivot[0] = (hull_revert_from_Hi_Low || hull_revert_from_Low_Hi);
      
         if (hull_is_pivot[0]){      
            if (hull_revert_from_Hi_Low){hull_pivot_status[0] = 0;}
            if (hull_revert_from_Low_Hi){hull_pivot_status[0] = 1;}
         } 
//Comment(symbol+" : Hull is pivot = "+hull_is_pivot +" / Status = "+hull_pivot_status[pair_string_convert_to_int(symbol)]); 
}

void hma_indicator_all_pairs(int timeframe,int period ,bool &hull_is_pivot[], bool &hull_pivot_status[]){
//string pairs[28] = {"AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD", "CADCHF",	"CADJPY", "CHFJPY", "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD", "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD", "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD", "USDCAD",   "USDCHF",	"USDJPY"};  
   
   double hull_buffer0_val1;double hull_buffer0_val2;
   double hull_buffer1_val1;double hull_buffer1_val2;
   bool hull_revert_from_Hi_Low ; bool hull_revert_from_Low_Hi; // : for measure the turning point of hull-MA  

      for(int x=0; x<28; x++){ 
         hull_buffer0_val1 = iCustom(pairs[x],timeframe,"hull_moving_average_2.0_nmc",period,0,1);
         hull_buffer0_val2 = iCustom(pairs[x],timeframe,"hull_moving_average_2.0_nmc",period,0,2);
         hull_buffer1_val1 = iCustom(pairs[x],timeframe,"hull_moving_average_2.0_nmc",period,1,1);
         hull_buffer1_val2 = iCustom(pairs[x],timeframe,"hull_moving_average_2.0_nmc",period,1,2);
   
         hull_revert_from_Hi_Low = ((hull_buffer1_val2 == EMPTY_VALUE)&&(hull_buffer1_val1 != EMPTY_VALUE));
         hull_revert_from_Low_Hi = ((hull_buffer1_val2 != EMPTY_VALUE)&&(hull_buffer1_val1 == EMPTY_VALUE));
         hull_is_pivot[x] = (hull_revert_from_Hi_Low || hull_revert_from_Low_Hi);
        
         if (hull_is_pivot[x]){      
            if (hull_revert_from_Hi_Low){hull_pivot_status[x] = 0;}
            if (hull_revert_from_Low_Hi){hull_pivot_status[x] = 1;}
         } 
      } 
}

int pair_string_convert_to_int(string symbol){
   int pair_int;
   /*   0"AUDCAD",	1"AUDCHF",	2"AUDJPY",	3"AUDNZD",	4"AUDUSD",
     5"CADCHF",	6"CADJPY",  7"CHFJPY",  8"EURAUD",	9"EURCAD",	
     10"EURCHF",	11"EURGBP",	12"EURJPY", 13"EURNZD",	14"EURUSD",	
     15"GBPAUD",	16"GBPCAD",	17"GBPCHF", 18"GBPJPY",	19"GBPNZD",	
     20"GBPUSD",	21"NZDCAD", 22"NZDCHF",	23"NZDJPY",	24"NZDUSD",
     25"USDCAD",  26"USDCHF",	27"USDJPY"*/
   if (symbol == "AUDCAD"){pair_int = 0;}   if (symbol == "AUDCHF"){pair_int = 1;}   if (symbol == "AUDJPY"){pair_int = 2;}   if (symbol == "AUDNZD"){pair_int = 3;}   if (symbol == "AUDUSD"){pair_int = 4;}
   if (symbol == "CADCHF"){pair_int = 5;}   if (symbol == "CADJPY"){pair_int = 6;}   if (symbol == "CHFJPY"){pair_int = 7;}   if (symbol == "EURAUD"){pair_int = 8;}   if (symbol == "EURCAD"){pair_int = 9;}
   if (symbol == "EURCHF"){pair_int = 10;}  if (symbol == "EURGBP"){pair_int = 11;}  if (symbol == "EURJPY"){pair_int = 12;}  if (symbol == "EURNZD"){pair_int = 13;}  if (symbol == "EURUSD"){pair_int = 14;}
   if (symbol == "GBPAUD"){pair_int = 15;}  if (symbol == "GBPCAD"){pair_int = 16;}  if (symbol == "GBPCHF"){pair_int = 17;}  if (symbol == "GBPJPY"){pair_int = 18;}  if (symbol == "GBPNZD"){pair_int = 19;}
   if (symbol == "GBPUSD"){pair_int = 20;}  if (symbol == "NZDCAD"){pair_int = 21;}  if (symbol == "NZDCHF"){pair_int = 22;}  if (symbol == "NZDJPY"){pair_int = 23;}  if (symbol == "NZDUSD"){pair_int = 24;}
   if (symbol == "USDCAD"){pair_int = 25;}  if (symbol == "USDCHF"){pair_int = 26;}  if (symbol == "USDJPY"){pair_int = 27;}
   return (pair_int);
}

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
   int result= OrderSend(symbol,OP_BUY,Lotsize ,vask,10,sl,tp,comment,MagicNumber,0,clrGreen); 
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
   int result= OrderSend(symbol,OP_SELL,Lotsize ,vbid,10,sl,tp,comment,MagicNumber,0,clrRed);  
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
            Print("Close All Order BUY: "+OrderSymbol());
            break;
         case 2:
            result =OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),1000,0);
            Print("Close All Order SELL: "+OrderSymbol());
            break;
      }         
  }   
  if(result<0){Print("***********OrderSend failed with error #",GetLastError());}else Print("************OrderSend placed successfully");  
}


void CheckOpenOrdersStatus(){
   for(int x=0; x<28; x++){SymbolInfoTick(pairs[x],mqltick[x]);   open_pairs[x]=CheckOpenOrders(pairs[x]);} 
   for(int y=0; y<28; y++){if (open_pairs[y] == true){open_pairs_count[y] = CountOpenOrders(pairs[y]); open_pairs_profit[y] = CountOrdersProfit(pairs[y]);}}
   //for(int x=0; x<28; x++){if (open_pairs[x] == true){open_pairs_count[x] = CountOpenOrders(pairs[x]); open_pairs_profit[x] = CountOrdersProfit(pairs[x]);}}

}

bool CheckOpenOrders(string symbol){
   int result=0;
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      result=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
      if( OrderSymbol() == symbol ) return(true);
   }  return(false);
}



int CountOpenOrders(string symbol){   
   int result=0;
   int counter=0;
//Comment (OrdersTotal());   
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      result = OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
      if( OrderSymbol() == symbol ) counter++;
      if( OrderSymbol() == "EURGBP" ) Print(OrdersTotal()+" /"+i+" : "+counter+" : "+symbol);
   }  return(counter);
}

double CountOrdersProfit(string symbol){
   int result=0;
   double profit=0;
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      result = OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
      if( OrderSymbol() == symbol ) profit=profit+OrderProfit();
   }  return(profit);
}

double CountAllOrdersProfit(){
   int result=0;
   double profit=0;
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      result = OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
      profit=profit+OrderProfit();
   }  return(profit);
}

//+------------------------------------------------------------------+
//Helper Function
//+------------------------------------------------------------------+
void printInfo(){ 
   string text[30]; //Array of String store custom texts on screen
    text[0]  = "    PAIR      |     STR      |     SLOPE";
      //for(int x=0; x<28; x++){text[x+1]  = pairs[x]+ "    |     "+ x+ "    |     "+ "";}   
     //for(int x=0; x<28; x++){text[x] =x+" : "+  mqltick[x].time+ " : "+ pairs[x] + " : "+  open_pairs_count[x]+ " : "+ open_pairs_profit[x];}
      
      //for(int x=0; x<28; x++){text[x] =x+" : "+  pairs[x]  +  " : "+ pairs_point[x];}   
    /*MqlTick last_tick;
      for(int x=0; x<28; x++){
         SymbolInfoTick(pairs[x],last_tick);
         text[x] = last_tick.time + " : "+pairs[x] +" : "+ NormalizeDouble(last_tick.bid,4) +" : "+ NormalizeDouble(last_tick.ask,4)+" : OPEN = "+ open_pairs_count[x]+ " : Profit= "+ open_pairs_profit[x] ;
      }*/
    
    //DANGER THIS LINE LOAD TO MUCH PROCESSING POWER !!!!!!!!!
    //for(int x=0; x<28; x++){text[x] =pairs[x]+" Hull 30,14 = "+  hull_is_pivot_test[x]  +  " : "+ hull_pivot_status_test[x];}
    
    for(int x=0; x<8; x++){text[x] = " CCS Score: "+ x  +  " : "+pair_score_symbol[x]+" : "+ NormalizeDouble(ccs_score_array[x],2) +"  /  SLOPE1:  "+ MathRound(ccs_slope_1[x]);}  //print ccs score
 
//    text[29] = "**********All Order(s) profit = "+ CountAllOrdersProfit();
Comment("Previous Best PAIR = "+ ccs_best_pair[1] + " / Best Pair To Trade = " + ccs_best_pair[0] + " || Invert Symbol: " + invert_symbol+ " / "+ text_comment);        
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