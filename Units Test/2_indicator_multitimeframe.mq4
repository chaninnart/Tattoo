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
//| Currency Strength pairs Variables                                 |
//+------------------------------------------------------------------+
input int ccs_parameter = 4;

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
     

   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
  double currency_score [8];
  ccs_indicator(currency_score,60,ccs_parameter,0);  //pass array by reference to function called
  Comment (currency_score[0]+"\n"+currency_score[1]+"\n"+currency_score[2]+"\n"+currency_score[3]+"\n"+currency_score[4]+"\n"+currency_score[5]+"\n"+currency_score[6]+"\n"+currency_score[7]);
   
  }

void ccs_indicator (double &array[],int timeframe,int period,int shift){   //array size=8      
   //timeframe 0 (current),1,5,15,30,60,240,1440,10080,43200
   string pairs[28] = {"AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD", "CADCHF",	"CADJPY", "CHFJPY", "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD", "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD", "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD", "USDCAD",   "USDCHF",	"USDJPY"};
   double pairs_value [28];  
   double score0_AUD,score1_CAD,score2_EUR,score3_GBP,score4_NZD,score5_USD,score6_CHF,score7_JPY;   
   
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
   }

void sma_indicator (double &array[],int timeframe,int period,int shift){   //array size=28
   string pairs[28] = {"AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD", "CADCHF",	"CADJPY", "CHFJPY", "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD", "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD", "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD", "USDCAD",   "USDCHF",	"USDJPY"};
   //double pairs_value [28];    
   for(int x=0; x<28; x++){
      array[x] =iMA(pairs[x],timeframe,period,0,MODE_SMA,PRICE_OPEN,shift);  //iMA(NULL,0,13,8,MODE_SMMA,PRICE_MEDIAN,i);
   }
}

void adx_indicator (double &array[],int timeframe,int period,int shift){   //array size=28
   string pairs[28] = {"AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD", "CADCHF",	"CADJPY", "CHFJPY", "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD", "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD", "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD", "USDCAD",   "USDCHF",	"USDJPY"};
   //double pairs_value [28];    
   for(int x=0; x<28; x++){
      array[x] =iADX(pairs[x],timeframe,period,PRICE_OPEN,MODE_SMA,shift); //iADX(NULL,0,14,PRICE_HIGH,MODE_MAIN,0)
   }
}

void hma_indicator(double &array[],int timeframe,int period,int shift){
string pairs[28] = {"AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD", "CADCHF",	"CADJPY", "CHFJPY", "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD", "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD", "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD", "USDCAD",   "USDCHF",	"USDJPY"};  
   int hull_period = 14;  //Hull period
   bool hull_is_pivot;
   bool hull_pivot_status;
   double hull_buffer0_val0;double hull_buffer0_val1;double hull_buffer0_val2;
   double hull_buffer1_val0;double hull_buffer1_val1;double hull_buffer1_val2;
   bool hull_revert_from_Hi_Low ; bool hull_revert_from_Low_Hi; // : for measure the turning point of hull-MA
   
   for(int x=0; x<28; x++){   
      hull_buffer0_val1 = iCustom(pairs[x],timeframe,"hull_moving_average_2.0_nmc",hull_period,0,1);
      hull_buffer0_val2 = iCustom(pairs[x],timeframe,"hull_moving_average_2.0_nmc",hull_period,0,2);
      hull_buffer1_val1 = iCustom(pairs[x],timeframe,"hull_moving_average_2.0_nmc",hull_period,1,1);
      hull_buffer1_val2 = iCustom(pairs[x],timeframe,"hull_moving_average_2.0_nmc",hull_period,1,2);
      hull_revert_from_Hi_Low = ((hull_buffer1_val2 == EMPTY_VALUE)&&(hull_buffer1_val1 != EMPTY_VALUE));
      hull_revert_from_Low_Hi = ((hull_buffer1_val2 != EMPTY_VALUE)&&(hull_buffer1_val1 == EMPTY_VALUE));
      hull_is_pivot = (hull_revert_from_Hi_Low || hull_revert_from_Low_Hi);
         if (hull_is_pivot){
            if (hull_revert_from_Hi_Low){hull_pivot_status = 0;}
            else hull_pivot_status = 1;
         } 
   }
   
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