//+------------------------------------------------------------------+
//|                                          1_array_of_28_pairs.mq4 |
//|                                                       Chaninnart |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chaninnart"
#property link      "https://www.mql5.com"
#property version   "1.00"
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
double   StopLoss   = 100; //100;    //min 40
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
ccs_indicator (ccs_score_array,240,14,0); //update currency strength   
   CheckLogicToManageOrder();
   //CheckLogicToOpenOrder();
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
   bool hull5 = false;   
      hull5 = hma_indicator(symbol,5,14);
   
      
   if(symbol== ccs_best_pair && adx_value > 20 && hull5  ){      
      if(!hull_pivot_status[pair_string_convert_to_int(symbol)]){openBuy(symbol,"*****open buy");}
      if(hull_pivot_status[pair_string_convert_to_int(symbol)]){openSell(symbol,"*****open sell");}
   }


//Comment(symbol+" : "+adx_value);      
}

void ActivateManageOrderStrategy(int int_pair){
   if(open_pairs_profit[int_pair]>20){closeAllOrder(1);}
}



//*********************************************************************INDICATOR HERE!!!!!!
double ccs_score_array[8]; //global variable for ccs indicator
string ccs_best_pair;
string ccs_prev_best_pair;
bool ccs_reverse_order = false; //if reverse symbol we habe to reverse order from buy -> sell 
void ccs_indicator (double &array[],int timeframe,int period,int shift){   //array size=8      
   //timeframe 0 (current),1,5,15,30,60,240,1440,10080,43200
   //string pairs[28] = {"AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD", "CADCHF",	"CADJPY", "CHFJPY", "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD", "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD", "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD", "USDCAD",   "USDCHF",	"USDJPY"};
   string pair_score_symbol [8]= { "AUD", "CAD","EUR","GBP","NZD","USD","CHF","JPY" };
   double pairs_value [28];  
   double score0_AUD,score1_CAD,score2_EUR,score3_GBP,score4_NZD,score5_USD,score6_CHF,score7_JPY; 
   string score_most_strength; string score_most_weekness;  
   
   for(int x=0; x<28; x++){pairs_value[x] =(iRSI(pairs[x],timeframe,period,PRICE_OPEN,shift)-50);}   
   
      score0_AUD = pairs_value[0]+pairs_value[1]+pairs_value[2]+pairs_value[3]+pairs_value[4] -(pairs_value[8]+pairs_value[15]);
      score1_CAD = pairs_value[5]+pairs_value[6] -(pairs_value[0]+pairs_value[9]+pairs_value[16]+pairs_value[21]+pairs_value[25]);
      score2_EUR = pairs_value[14]+pairs_value[9]+pairs_value[10]+pairs_value[11]+pairs_value[12]+pairs_value[13]+pairs_value[14];
      score3_GBP = pairs_value[15]+pairs_value[16]+pairs_value[17]+pairs_value[18]+pairs_value[19]+pairs_value[20] -(pairs_value[11]);
      score4_NZD = pairs_value[21]+pairs_value[22]+pairs_value[23]+pairs_value[24] -(pairs_value[3]+pairs_value[13]+pairs_value[19]);
      score5_USD = pairs_value[25]+pairs_value[26]+pairs_value[27] -(pairs_value[4]+pairs_value[14]+pairs_value[20]+pairs_value[24]);
      score6_CHF = pairs_value[7] -(pairs_value[1]+pairs_value[5]+pairs_value[10]+pairs_value[17]+pairs_value[22]+pairs_value[26]);
      score7_JPY = 0- (pairs_value[2]+pairs_value[6]+pairs_value[7]+pairs_value[12]+pairs_value[18]+pairs_value[23]+pairs_value[27]);  
      array[0]=score0_AUD;array[1]=score1_CAD; array[2]=score2_EUR; array[3]=score3_GBP; 
      array[4]=score4_NZD;array[5]=score5_USD; array[6]=score6_CHF; array[7]=score7_JPY; 
   
   score_most_strength = pair_score_symbol[ArrayMaximum(ccs_score_array,WHOLE_ARRAY,0)];
   score_most_weekness = pair_score_symbol[ArrayMinimum(ccs_score_array,WHOLE_ARRAY,0)];
   string best_pair = score_most_strength+ score_most_weekness;

   ccs_reverse_order = false; // reset reverse order flag
   if (MarketInfo(best_pair,MODE_BID)== 0){best_pair = score_most_weekness+ score_most_strength;} //inverse bestpair CHFGBP -> GBPCHF   
   if (ccs_best_pair != best_pair){ccs_prev_best_pair = ccs_best_pair; ccs_reverse_order = true;} //if changing the best pair collect the previous pair to variable ccs_prev_best_pair
   ccs_best_pair = best_pair;
      //score_most_strength = cc_score_array[ArrayMaximum(temp,WHOLE_ARRAY,0)];   
Comment(ccs_best_pair); 
     
}




//*********************************************************************INDICATOR HERE!!!!!!
bool hull_pivot_status[28]; //global variable for return hull pivot status: 0 = HI -> LOW , 1 = LOW -> HI
bool hma_indicator(string symbol,int timeframe,int period){
//string pairs[28] = {"AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD", "CADCHF",	"CADJPY", "CHFJPY", "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD", "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD", "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD", "USDCAD",   "USDCHF",	"USDJPY"};  
   bool hull_is_pivot;
   //bool hull_pivot_status;
   double hull_buffer0_val0;double hull_buffer0_val1;double hull_buffer0_val2;
   double hull_buffer1_val0;double hull_buffer1_val1;double hull_buffer1_val2;
   bool hull_revert_from_Hi_Low ; bool hull_revert_from_Low_Hi; // : for measure the turning point of hull-MA  
  
      hull_buffer0_val1 = iCustom(symbol,timeframe,"hull_moving_average_2.0_nmc",period,0,1);
      hull_buffer0_val2 = iCustom(symbol,timeframe,"hull_moving_average_2.0_nmc",period,0,2);
      hull_buffer1_val1 = iCustom(symbol,timeframe,"hull_moving_average_2.0_nmc",period,1,1);
      hull_buffer1_val2 = iCustom(symbol,timeframe,"hull_moving_average_2.0_nmc",period,1,2);
      hull_revert_from_Hi_Low = ((hull_buffer1_val2 == EMPTY_VALUE)&&(hull_buffer1_val1 != EMPTY_VALUE));
      hull_revert_from_Low_Hi = ((hull_buffer1_val2 != EMPTY_VALUE)&&(hull_buffer1_val1 == EMPTY_VALUE));
      hull_is_pivot = (hull_revert_from_Hi_Low || hull_revert_from_Low_Hi);
         if (hull_is_pivot){
            if (hull_revert_from_Hi_Low){hull_pivot_status[pair_string_convert_to_int(symbol)] = 0;}
            else hull_pivot_status[pair_string_convert_to_int(symbol)] = 1;
         } 
//Comment(symbol+" : Hull is pivot = "+hull_is_pivot +" / Status = "+hull_pivot_status[pair_string_convert_to_int(symbol)]);         
   return(hull_is_pivot);
   
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
   for(int y=0; y<28; y++){if (open_pairs[y] == true){open_pairs_count[y] = CountOpenOrders(pairs[y]); open_pairs_profit[y] = CountOrdersProfit(pairs[y]);}}
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

double CountAllOrdersProfit(){
   double profit=0;
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
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
      //for(int x=0; x<28; x++){text[x] =x+" : "+  mqltick[x].time+ " : "+ pairs[x] + " : "+ open_pairs[x]+ " : "+ open_pairs_count[x]+ " : "+ open_pairs_profit[x];}
      //for(int x=0; x<28; x++){text[x] =x+" : "+  pairs[x]  +  " : "+ pairs_point[x];}   
    /*MqlTick last_tick;
      for(int x=0; x<28; x++){
         SymbolInfoTick(pairs[x],last_tick);
         text[x] = last_tick.time + " : "+pairs[x] +" : "+ NormalizeDouble(last_tick.bid,4) +" : "+ NormalizeDouble(last_tick.ask,4)+" : OPEN = "+ open_pairs_count[x]+ " : Profit= "+ open_pairs_profit[x] ;
      }*/
    
    //for(int x=0; x<28; x++){text[x] =pairs[x]+" Hull 5,14 = "+  hma_indicator(pairs[x],5,14)  +  " : "+ hull_pivot_status[x];}
    for(int x=0; x<8; x++){text[x] = " CCS Score: "+ x  +  " : "+ ccs_score_array[x];}  //print ccs score
    
    text[29] = "**********All Order(s) profit = "+ CountAllOrdersProfit();
     
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