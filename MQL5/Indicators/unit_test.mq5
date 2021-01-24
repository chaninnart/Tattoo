//+------------------------------------------------------------------+
//|                                      FlukeMultiCurrencyIndex.mq5 |
//|                               Copyright 2020, Chaninnart Chansiu |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Chaninnart Chansiu"
#property link      ""
#property version   "1.00"
#property indicator_separate_window



//--- input parameters



string symbols[28] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};

  //+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   

//---

for(int i=0; i < ArraySize(symbols); i++)
   {   
   MqlRates rates[];
   int copied=CopyRates(symbols[i],0,0,100,rates);
   if(copied<=0)
      Print("Error copying price data ",GetLastError());
   else Print("Copied ",ArraySize(rates)," bars");     

   Print(symbols[i] + ":" + SeriesInfoInteger(symbols[i],PERIOD_H1,SERIES_BARS_COUNT));
   }
   
   return(INIT_SUCCEEDED);
  }





//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
