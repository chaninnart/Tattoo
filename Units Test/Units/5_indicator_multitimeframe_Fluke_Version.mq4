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
int OnInit() { EventSetTimer(1);  return(INIT_SUCCEEDED); }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double currency_score [8];
   ccs_indicator(ccs_score_array5,5,14,0);
   ccs_indicator(ccs_score_array30,30,14,0);
   ccs_indicator(ccs_score_array60,60,14,0);
   ccs_indicator(ccs_score_array240,240,14,0);
   ccs_indicator(ccs_score_array1440,1440,14,0);
   printInfo();

   
  }
  
double ccs_score_array5[8]; //global variable for ccs indicator
double ccs_score_array30[8]; //global variable for ccs indicator
double ccs_score_array60[8]; //global variable for ccs indicator
double ccs_score_array240[8]; //global variable for ccs indicator
double ccs_score_array1440[8]; //global variable for ccs indicator
string ccs_best_pair;
string ccs_prev_best_pair;
void ccs_indicator (double &array[],int timeframe,int period,int shift){   //array size=8      
   //timeframe 0 (current),1,5,15,30,60,240,1440,10080,43200
   string pairs[28] = {"AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD", "CADCHF",	"CADJPY", "CHFJPY", "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD", "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD", "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD", "USDCAD",   "USDCHF",	"USDJPY"};
   double pairs_value [28];  
   double score0_AUD,score1_CAD,score2_EUR,score3_GBP,score4_NZD,score5_USD,score6_CHF,score7_JPY;   
   
   for(int x=0; x<28; x++){
      if((iOpen(pairs[x],timeframe,0)-iOpen(pairs[x],timeframe,4))> 0){pairs_value[x] = 0;
         if((iOpen(pairs[x],timeframe,0)-iOpen(pairs[x],timeframe,4))> 0.02*(iOpen(pairs[x],timeframe,0))){pairs_value[x] = 1;}
      } 
      if((iOpen(pairs[x],timeframe,0)-iOpen(pairs[x],timeframe,4))< 0){pairs_value[x] = -1;
         if((iOpen(pairs[x],timeframe,0)-iOpen(pairs[x],timeframe,4))< 0.02*(iOpen(pairs[x],timeframe,0))){pairs_value[x] = -1;}
      }
       
           
   }   
            score0_AUD = pairs_value[0]+pairs_value[1]+pairs_value[2]+pairs_value[3]+pairs_value[4] -(pairs_value[8]+pairs_value[15]);
            score1_CAD = pairs_value[5]+pairs_value[6] -(pairs_value[0]+pairs_value[9]+pairs_value[16]+pairs_value[21]+pairs_value[25]);
            score2_EUR = pairs_value[14]+pairs_value[9]+pairs_value[10]+pairs_value[11]+pairs_value[12]+pairs_value[13]+pairs_value[14];
            score3_GBP = pairs_value[15]+pairs_value[16]+pairs_value[17]+pairs_value[18]+pairs_value[19]+pairs_value[20] -(pairs_value[11]);
            score4_NZD = pairs_value[21]+pairs_value[22]+pairs_value[23]+pairs_value[24] -(pairs_value[3]+pairs_value[13]+pairs_value[19]);
            score5_USD = pairs_value[25]+pairs_value[26]+pairs_value[27] -(pairs_value[4]+pairs_value[14]+pairs_value[20]+pairs_value[24]);
            score6_CHF = pairs_value[7] -(pairs_value[1]+pairs_value[5]+pairs_value[10]+pairs_value[17]+pairs_value[22]+pairs_value[26]);
            score7_JPY = 0- (pairs_value[2]+pairs_value[6]+pairs_value[7]+pairs_value[12]+pairs_value[18]+pairs_value[23]+pairs_value[27]);  
            
           /* 
            score0_AUD = (pairs_value[0]+pairs_value[1]+pairs_value[2]+pairs_value[3]+pairs_value[4]+pairs_value[8]+pairs_value[15]);
            score1_CAD = (pairs_value[5]+pairs_value[6] + pairs_value[0]+pairs_value[9]+pairs_value[16]+pairs_value[21]+pairs_value[25]);            
            score2_EUR = (pairs_value[14]+pairs_value[9]+pairs_value[10]+pairs_value[11]+pairs_value[12]+pairs_value[13]+pairs_value[14]);  
            score3_GBP = (pairs_value[15]+pairs_value[16]+pairs_value[17]+pairs_value[18]+pairs_value[19]+pairs_value[20] +pairs_value[11]); 
            score4_NZD = (pairs_value[21]+pairs_value[22]+pairs_value[23]+pairs_value[24] +pairs_value[3]+pairs_value[13]+pairs_value[19]);
            score5_USD = (pairs_value[25]+pairs_value[26]+pairs_value[27] +pairs_value[4]+pairs_value[14]+pairs_value[20]+pairs_value[24]);  
            score6_CHF = (pairs_value[7] +pairs_value[1]+pairs_value[5]+pairs_value[10]+pairs_value[17]+pairs_value[22]+pairs_value[26]); 
            score7_JPY = (pairs_value[2]+pairs_value[6]+pairs_value[7]+pairs_value[12]+pairs_value[18]+pairs_value[23]+pairs_value[27]);   */
      
      array[0]=score0_AUD;array[1]=score1_CAD; array[2]=score2_EUR; array[3]=score3_GBP; 
      array[4]=score4_NZD;array[5]=score5_USD; array[6]=score6_CHF; array[7]=score7_JPY; 
   }



//+------------------------------------------------------------------+
//Helper Function
//+------------------------------------------------------------------+
void printInfo(){ 
   string text[30]; //Array of String store custom texts on screen
    //text[0]  = "    PAIR      |     STR      |     SLOPE";
      //for(int x=0; x<28; x++){text[x+1]  = pairs[x]+ "    |     "+ x+ "    |     "+ "";}   
      //for(int x=0; x<28; x++){text[x] =x+" : "+  mqltick[x].time+ " : "+ pairs[x] + " : "+ open_pairs[x];}
      //for(int x=0; x<28; x++){text[x] =x+" : "+  pairs[x]  +  " : "+ pairs_point[x];} 
    //for(int x=0; x<8; x++){text[x] =ccs_score_array[x];}
    text[0] = "AUD Score DAY/4HR/1HR/30MIN = "+ ccs_score_array1440[0]+"/"+ccs_score_array240[0]+"/"+ccs_score_array60[0]+"/"+ccs_score_array30[0]+"/"+ccs_score_array5[0]; 
    text[1] = "CAD Score DAY/4HR/1HR/30MIN = "+ ccs_score_array1440[1]+"/"+ccs_score_array240[1]+"/"+ccs_score_array60[1]+"/"+ccs_score_array30[1]+"/"+ccs_score_array5[1];
    text[2] = "EUR Score DAY/4HR/1HR/30MIN = "+ ccs_score_array1440[2]+"/"+ccs_score_array240[2]+"/"+ccs_score_array60[2]+"/"+ccs_score_array30[2]+"/"+ccs_score_array5[2];
    text[3] = "GBP Score DAY/4HR/1HR/30MIN = "+ ccs_score_array1440[3]+"/"+ccs_score_array240[3]+"/"+ccs_score_array60[3]+"/"+ccs_score_array30[3]+"/"+ccs_score_array5[3];
    text[4] = "NZD Score DAY/4HR/1HR/30MIN = "+ ccs_score_array1440[4]+"/"+ccs_score_array240[4]+"/"+ccs_score_array60[4]+"/"+ccs_score_array30[4]+"/"+ccs_score_array5[4];
    text[5] = "USD Score DAY/4HR/1HR/30MIN = "+ ccs_score_array1440[5]+"/"+ccs_score_array240[5]+"/"+ccs_score_array60[5]+"/"+ccs_score_array30[5]+"/"+ccs_score_array5[5];
    text[6] = "CHF Score DAY/4HR/1HR/30MIN = "+ ccs_score_array1440[6]+"/"+ccs_score_array240[6]+"/"+ccs_score_array60[6]+"/"+ccs_score_array30[6]+"/"+ccs_score_array5[6]; 
    text[7] = "JPY Score DAY/4HR/1HR/30MIN = "+ ccs_score_array1440[7]+"/"+ccs_score_array240[7]+"/"+ccs_score_array60[7]+"/"+ccs_score_array30[7]+"/"+ccs_score_array5[7];
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