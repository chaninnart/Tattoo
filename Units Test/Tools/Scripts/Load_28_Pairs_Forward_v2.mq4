//+------------------------------------------------------------------+
//|                                           Load_All_Timeframe.mq4 |
//|                           Copyright 2016, Viroj Siriwattanakamol |
//+------------------------------------------------------------------+
#property version   "6.00"
#property strict
#property show_inputs
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
extern string Suffix        = "";
extern int    StartCcy      = 0;   //Start Currency 0 - 27
extern int    EndCcy        = 27;  //End Currency 0 - 27
extern int    SleepTime     = 300; //Milli Second
extern string Programmed_By = "Viroj Siriwattanakamol";

string CcyPairCode[28]={"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF",
                        "EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD",
                        "NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};
//
ENUM_TIMEFRAMES TfVal[9]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
//                            0,        1,         2,         3,        4,        5,        6,        7,         8
long wChartId[9];
//+------------------------------------------------------------------+
void OnStart() {
   int j,k;
   string wBarCount;
   Print("------------------------------------------------------------------------------");
   Print("start of loading");
   for (k=StartCcy; k<=EndCcy+1; k++) {
      if (k<=EndCcy) {
         Print("-------> Loading "+IntegerToString(k)+"-"+CcyPairCode[k]);
      }
      for (j=0;j<9;j++) {
         if (k==StartCcy) {
            wChartId[j]=ChartOpen(CcyPairCode[k]+Suffix,TfVal[j]);
            ChartNavigate(wChartId[j],CHART_END,0);
            wBarCount=IntegerToString(iBars(CcyPairCode[k]+Suffix,TfVal[j]));
            Print("--> "+EnumToString(TfVal[j])+"   "+wBarCount+" bars");
         }
         else if (k==EndCcy+1) {
            ChartClose(wChartId[j]);
         }
         else {
            ChartClose(wChartId[j]);
            wChartId[j]=ChartOpen(CcyPairCode[k]+Suffix,TfVal[j]);
            ChartNavigate(wChartId[j],CHART_END,0);
            wBarCount=IntegerToString(iBars(CcyPairCode[k]+Suffix,TfVal[j]));
            Print("--> "+EnumToString(TfVal[j])+"   "+wBarCount+" bars");
         }
         Sleep(SleepTime);
      }
   }
   Print("end of loading");
}
//+------------------------------------------------------------------+
int OnInit() {
   for (int i=0; i<28; i++) {
      if (SymbolSelect(CcyPairCode[i]+Suffix,true)==false) {
         Print("Select currency error --> "+CcyPairCode[i]);
         //return(INIT_FAILED);
      }
   }
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
