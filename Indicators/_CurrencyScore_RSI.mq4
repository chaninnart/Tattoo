//+------------------------------------------------------------------+
//|                                             CurrencyStrength.mq4 |
//|                          Copyright 2020-2030, Chaninnart Chansiu |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "2020-2030, Chaninnart Chansiu"
#property link        ""
#property description "Currency Strength Index"
#property strict

#property indicator_separate_window          //output at separate window
//#property indicator_minimum    0             //set minimum scale start at 0
//#property indicator_maximum    100           //set maximum scale at 100
//#property indicator_level1     30.0          //set line at level 50
//#property indicator_level2     70.0          //set line at level 70
//#property indicator_levelcolor clrSilver     //set level color
//#property indicator_levelstyle STYLE_DOT     //set level style

#property indicator_buffers    8             //set numbers of indicator buffer    
#property indicator_color1     clrYellow     //AUD
#property indicator_color2     clrLawnGreen  //CAD
#property indicator_color3     DodgerBlue    //EUR
#property indicator_color4     clrAqua       //GBP
#property indicator_color5     clrOrange     //NZD
#property indicator_color6     clrGreen      //USD
#property indicator_color7     clrWhite      //CHF
#property indicator_color8     clrRed        //JPY

//--- input parameter
input int InputParameter1=14;  // Period
//--- data buffer (array that want to show in graph)
//string CurrencyPair = "0AUDCAD1AUDCHF2AUDJPY3AUDNZD4AUDUSD5CADCHF6CADJPY7CHFJPY8EURAUD9EURCAD0EURCHF1EURGBP2EURJPY3EURNZD4EURUSD5GBPAUD6GBPCAD7GBPCHF8GBPJPY9GBPNZD0GBPUSD1NZDCAD2NZDCHF3NZDJPY4NZDUSD5USDCAD6USDCHF7USDJPY";

double DataBuffer0[];double DataBuffer1[];double DataBuffer2[];double DataBuffer3[];double DataBuffer4[];double DataBuffer5[];double DataBuffer6[];double DataBuffer7[];
double AUDCAD,	AUDCHF,	AUDJPY,	AUDNZD,	AUDUSD, CADCHF, CADJPY, CHFJPY, EURAUD,	EURCAD,	EURCHF,	EURGBP,	EURJPY,   EURNZD,	EURUSD, GBPAUD,	GBPCAD,	GBPCHF,   GBPJPY,	GBPNZD,	GBPUSD,	NZDCAD,   NZDCHF,	NZDJPY,	NZDUSD,   USDCAD,   USDCHF,	USDJPY;
double score0_AUD,score1_CAD,score2_EUR,score3_GBP,score4_NZD,score5_USD,score6_CHF,score7_JPY;        

string pairs[28] = {
   "AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD",
   "CADCHF",	"CADJPY",
   "CHFJPY",	
   "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD",	
   "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD",	
   "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD",
   "USDCAD",   "USDCHF",	"USDJPY"};

double pairs_value [28];   

//double aud_score[],cad_score[],eur_score[],gbp_score[],nzd_score[],usd_score[],chf_score[],jpy_score[];  

int counter=0;     
       
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {

   string short_name;
//--- indicator line
   SetIndexStyle(0,DRAW_LINE,0,2); SetIndexBuffer(0,DataBuffer0);
   SetIndexStyle(1,DRAW_LINE,0,2); SetIndexBuffer(1,DataBuffer1);
   SetIndexStyle(2,DRAW_LINE,0,2); SetIndexBuffer(2,DataBuffer2);   
   SetIndexStyle(3,DRAW_LINE,0,2); SetIndexBuffer(3,DataBuffer3);   
   SetIndexStyle(4,DRAW_LINE,0,2); SetIndexBuffer(4,DataBuffer4);
   SetIndexStyle(5,DRAW_LINE,0,2); SetIndexBuffer(5,DataBuffer5);
   SetIndexStyle(6,DRAW_LINE,0,2); SetIndexBuffer(6,DataBuffer6);   
   SetIndexStyle(7,DRAW_LINE,0,2); SetIndexBuffer(7,DataBuffer7);    


//--- name for DataWindow and indicator subwindow label
   short_name="Currency Strength RSI("+IntegerToString(InputParameter1)+") ";
   IndicatorShortName(short_name);
   // Set Label showing in Data Window
   SetIndexLabel(0,"AUD (Yellow)");SetIndexLabel(1,"CAD (l.Green)");SetIndexLabel(2,"EUR (Blue)");SetIndexLabel(3,"GBP (l.Blue)");
   SetIndexLabel(4,"NZD (Orange)");SetIndexLabel(5,"USD (Green)");SetIndexLabel(6,"CHF (White)");SetIndexLabel(7,"JPY (Red)"); 
     
//--- check for input parameter
   if(InputParameter1<=0)
     {
      Print("Wrong input parameter Momentum Period=",InputParameter1);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,InputParameter1);
   
   ArrayInitialize(pairs_value,EMPTY_VALUE); //initialize array to store the value each pair
  
        
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {


//--- check for bars count and input parameter
   if(rates_total<=InputParameter1 || InputParameter1<=0)return(0);  
//--- prevent total recalculation
   int i=rates_total-prev_calculated-1;
//--- current value should be recalculated
   if(i<0)
      {i=0;}
//---
   while(i>=0)  
     {
      int j=27; 
      while(j >= 0){
         pairs_value[j] =(iRSI(pairs[j],0,InputParameter1,PRICE_OPEN,i)-50);  //RSI Approach
//Print(pairs [j] +" : "+pairs_value[j]);      
            /* "AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD",   "CADCHF",	"CADJPY",   "CHFJPY",	"EURAUD",	"EURCAD",	
            "EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD",	"GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	
            "GBPUSD",	"NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD",   "USDCAD",   "USDCHF",	"USDJPY"*/
            
            /*  score0_AUD = AUDCAD+AUDCHF+AUDJPY+AUDNZD+AUDUSD -(EURAUD+GBPAUD);
            score1_CAD = CADCHF+CADJPY -(AUDCAD+EURCAD+GBPCAD+NZDCAD+USDCAD);
            score2_EUR = EURUSD+EURCAD+EURCHF+EURGBP+EURJPY+EURNZD+EURUSD;
            score3_GBP = GBPAUD+GBPCAD+GBPCHF+GBPJPY+GBPNZD+GBPUSD -(EURGBP);
            score4_NZD = NZDCAD+NZDCHF+NZDJPY+NZDUSD -(AUDNZD+EURNZD+GBPNZD);
            score5_USD = USDCAD+USDCHF+USDJPY -(AUDUSD+EURUSD+GBPUSD+NZDUSD);
            score6_CHF = CHFJPY -(AUDCHF+CADCHF+EURCHF+GBPCHF+NZDCHF+USDCHF);
            score7_JPY = 0- (AUDJPY+CADJPY+CHFJPY+EURJPY+GBPJPY+NZDJPY+USDJPY);    */
         
           
            score0_AUD = pairs_value[0]+pairs_value[1]+pairs_value[2]+pairs_value[3]+pairs_value[4] -(pairs_value[8]+pairs_value[15]);
            score1_CAD = pairs_value[5]+pairs_value[6] -(pairs_value[0]+pairs_value[9]+pairs_value[16]+pairs_value[21]+pairs_value[25]);
            score2_EUR = pairs_value[14]+pairs_value[9]+pairs_value[10]+pairs_value[11]+pairs_value[12]+pairs_value[13]+pairs_value[14];
            score3_GBP = pairs_value[15]+pairs_value[16]+pairs_value[17]+pairs_value[18]+pairs_value[19]+pairs_value[20] -(pairs_value[11]);
            score4_NZD = pairs_value[21]+pairs_value[22]+pairs_value[23]+pairs_value[24] -(pairs_value[3]+pairs_value[13]+pairs_value[19]);
            score5_USD = pairs_value[25]+pairs_value[26]+pairs_value[27] -(pairs_value[4]+pairs_value[14]+pairs_value[20]+pairs_value[24]);
            score6_CHF = pairs_value[7] -(pairs_value[1]+pairs_value[5]+pairs_value[10]+pairs_value[17]+pairs_value[22]+pairs_value[26]);
            score7_JPY = 0- (pairs_value[2]+pairs_value[6]+pairs_value[7]+pairs_value[12]+pairs_value[18]+pairs_value[23]+pairs_value[27]); 
               
       
           
            //plot graph  --- adjust data's range for display  by -50   
            DataBuffer0[i] = score0_AUD;
            DataBuffer1[i] = score1_CAD;
            DataBuffer2[i] = score2_EUR;
            DataBuffer3[i] = score3_GBP;
            DataBuffer4[i] = score4_NZD;
            DataBuffer5[i] = score5_USD;
            DataBuffer6[i] = score6_CHF;
            DataBuffer7[i] = score7_JPY;
         j--;
      }  
      i--;
     }
//---
     // Comment(ArraySize(DataBuffer1));
     //Comment(counter++);
   return(rates_total);
  }

      
 
   





















void drawWhiteUpArrowOnScreen(int index){ 
   int i;
   i=Bars;
   string name = "Up"+string(i);
   ObjectCreate(name,OBJ_ARROW, 0, Time[index], Low[index]-50*Point); 
   ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
   ObjectSet(name, OBJPROP_COLOR,White);   
}

void drawYellowDownArrowOnScreen(int index){ 
   int i;
   i=Bars;
   string name = "Dn"+string(i);
   ObjectCreate(name,OBJ_ARROW, 0, Time[index], High[index]+Low[index]); 
   ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
   ObjectSet(name, OBJPROP_COLOR,Yellow);   
}

void drawLine(){
ObjectSet("HLine", OBJPROP_PRICE1,Low[1]) ;   
}
