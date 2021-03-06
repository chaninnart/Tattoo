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
double   StopLoss   = 00;    //Stop Loss (in Points)
double   TakeProfit = 00;    //Take Profit (in Points)
int TS = 0;                  //Trailing Stop (in Points)

//+------------------------------------------------------------------+
//| Custom Indicator Variable                                  |
//+------------------------------------------------------------------+
//1. Currency Strength

input int cc_score_period = 10;  //Currency Score Period
// define struct with contain consturctor method to set default value to the struct memebers
struct cc_score_structure{string currency; double score;  cc_score_structure(){currency="";score = 0.0;}};
cc_score_structure aud ,cad,eur,gbp ,nzd ,usd,chf,jpy;
cc_score_structure cc_score [8][8]; //[bar0-7],[score0-7]

cc_score_structure cc_score_bar0_sorted[8];


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

struct cc_strength_structure{string currency_pair; double strength; double atr; cc_strength_structure(){currency_pair="";strength = 0.0;}};
cc_strength_structure cc_strength [8][28];



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   //set Timer to proceed the OnTick while close market.
   EventSetTimer(3);
   //parameter initialization
   aud.currency = "AUD";cad.currency = "CAD";eur.currency = "EUR";gbp.currency = "GBP"; nzd.currency = "NZD"; usd.currency = "USD";chf.currency = "CHF";jpy.currency = "JPY"; 
   //Fill Pairs of the currency into Currency Strength Structure
   for(int i=0; i<ArraySize(pairs); i++){for(int j=0; j<8 ; j++){cc_strength[j][i].currency_pair = pairs[i];}}    
   
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
   printInfo(); 
  }
  
//+------------------------------------------------------------------+

void  getAllParameter(){ 
//spread_value = (int)MarketInfo("EURGBP",MODE_SPREAD);
   get_CurrencyScore(8); //get currency score for 8 bars   
}     
  
  
//---------------Parameter-----------------
void get_CurrencyScore(int bar){
      for(int i=0; i<bar; i++){
         aud.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,0,i),3);
         cad.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,1,i),3);
         eur.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,2,i),3);
         gbp.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,3,i),3);
         nzd.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,4,i),3);
         usd.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,5,i),3);
         chf.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,6,i),3);
         jpy.score = NormalizeDouble(iCustom(NULL,0,"_CurrencyScore",cc_score_period,7,i),3);
         
         cc_score [i][0] = aud; cc_score [i][1] = cad; cc_score [i][2] = eur; cc_score [i][3] = gbp; 
         cc_score [i][4] = nzd; cc_score [i][5] = usd; cc_score [i][6] = chf; cc_score [i][7] = jpy; 
      //Print("BAR "+i+" : "+cc_score [i][0].score+"/"+cc_score [i][1].score+"/"+cc_score [i][2].score+"/"+cc_score [i][3].score+"/"+cc_score [i][4].score+"/"+cc_score [i][5].score+"/"+cc_score [i][6].score+"/"+cc_score [i][7].score);   
         //*******insert 28 pairs formular PAIR1-PAIR2
         cc_strength [i][0].strength = aud.score - cad.score;  //0. AUD-CAD
         cc_strength [i][1].strength = aud.score - chf.score;  //1. AUD-CHF
         cc_strength [i][2].strength = aud.score - jpy.score;  //2. AUD-JPY
         cc_strength [i][3].strength = aud.score - nzd.score;  //3. AUD-NZD
         cc_strength [i][4].strength = aud.score - usd.score;  //4. AUD-USD
         cc_strength [i][5].strength = cad.score - chf.score;  //5. CAD-CHF
         cc_strength [i][6].strength = cad.score - jpy.score;  //6. CAD-JPY
         cc_strength [i][7].strength = chf.score - jpy.score;  //7. CHF-JPY
         cc_strength [i][8].strength = eur.score - aud.score;  //8. EUR-AUD
         cc_strength [i][9].strength = eur.score - cad.score;  //9. EUR-CAD
         cc_strength [i][10].strength = eur.score - chf.score; //10. EUR-CHF
         cc_strength [i][11].strength = eur.score - gbp.score; //11. EUR-GBP
         cc_strength [i][12].strength = eur.score - jpy.score; //12. EUR-JPY
         cc_strength [i][13].strength = eur.score - nzd.score; //13. EUR-NZD
         cc_strength [i][14].strength = eur.score - usd.score; //14. EUR-USD
         cc_strength [i][15].strength = gbp.score - aud.score; //15. GBP-AUD
         cc_strength [i][16].strength = gbp.score - cad.score; //16. GBP-CAD
         cc_strength [i][17].strength = gbp.score - chf.score; //17. GBP-CHF
         cc_strength [i][18].strength = gbp.score - jpy.score; //18. GBP-JPY
         cc_strength [i][19].strength = gbp.score - nzd.score; //19. GBP-NZD
         cc_strength [i][20].strength = gbp.score - usd.score; //20. GBP-USD
         cc_strength [i][21].strength = nzd.score - cad.score; //21. NZD-CAD
         cc_strength [i][22].strength = nzd.score - chf.score; //22. NZD-CHF
         cc_strength [i][23].strength = nzd.score - jpy.score; //23. NZD-JPY
         cc_strength [i][24].strength = nzd.score - usd.score; //24. NZD-USD
         cc_strength [i][25].strength = usd.score - cad.score; //25. USD-CAD
         cc_strength [i][26].strength = usd.score - chf.score; //26. USD-CHF
         cc_strength [i][27].strength = usd.score - jpy.score; //27. USD-JPY 
//Print("BAR "+i+" : "+cc_strength [i][0].strength+"/"+cc_strength [i][1].strength+"/"+cc_strength [i][2].strength+"/"+cc_strength [i][3].strength+"/"+cc_strength [i][4].strength+"/"+cc_strength [i][5].strength+"/"+cc_strength [i][6].strength+"/"+cc_strength [i][7].strength);            
      }    
      sorting_score();      
      /*  for(int j=0; j<ArraySize(cc_score_bar0_sorted); j++){
         Print(j+" : "+cc_score_bar0_sorted[j].score);           
      }*/
}

//+------------------------------------------------------------------+
//Helper Function
//+------------------------------------------------------------------+
void printInfo(){ 
   string text[30]; //Array of String store custom texts on screen
    text[0]  = "    PAIR      |      STRENGTH";
      for(int x=0; x<28; x++){text[x+1]  = cc_strength[0][x].currency_pair+ "    |       "+ cc_strength[0][x].strength;}     
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
               string str="";
               for(int j=0; j<ArraySize(c); j++)
               {if (c[i]== cc_score[0][j].score){cc_score_bar0_sorted[i] = cc_score[0][j];}}  
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


  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit(){
   ObjectsDeleteAll(); 
   return(0);
}  



