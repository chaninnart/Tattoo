//+------------------------------------------------------------------+
//|                                      CURRENCY_STRENGTH_INDEX.mq5 |
//|                                        Copyright © 2020, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "2.000"
#property description "A technical indicator to chart the strength momentum of the 8 major currencies. (EUR, GBP, AUD, NZD, USD, CAD, CHF, JPY)"
#property description "The indicator is based on mathematical decorrelation of 28 cross currency pairs."
#property description "It uses the percentage difference in the Linear-weighted averaging (LWMA) of the closing prices."
//---
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   8

//---
#property indicator_color1 clrYellow
#property indicator_color2 clrLawnGreen
#property indicator_color3 clrWhite
#property indicator_color4 clrDodgerBlue
#property indicator_color5 clrAqua
#property indicator_color6 clrOrange
#property indicator_color7 clrGreen
#property indicator_color8 clrRed

#property indicator_label1 "AUD"
#property indicator_label2 "CAD"
#property indicator_label3 "CHF"
#property indicator_label4 "EUR"
#property indicator_label5 "GBP"
#property indicator_label6 "NZD"
#property indicator_label7 "USD"
#property indicator_label8 "JPY"
//---
#property indicator_level1 0.0
//+------------------------------------------------------------------+
input int ma_period_=10;      //--- input variables
int ma_delta=1;         
bool ShowAUD=true;
bool ShowCAD=true;
bool ShowCHF=true;
bool ShowEUR=true;
bool ShowGBP=true;
bool ShowNZD=true;
bool ShowUSD=true;
bool ShowJPY=true;
//+------------------------------------------------------------------+
//--- indicator buffers for drawing
double    EURx[], // indexes
          GBPx[],
          AUDx[],
          NZDx[],
          USDx[],
          CADx[],
          CHFx[],
          JPYx[];

//--- currency rates for calculation
double EUR,GBP,AUD,NZD,USD,CAD,CHF,JPY,A1,A2,A3,A4,A5,A6,A7;

//--- Currency names and colors
string Currencies[]= {"AUD","CAD","CHF","EUR","GBP","NZD","USD","JPY"};
int Colors[]= {indicator_color1, indicator_color2, indicator_color3, indicator_color4,
               indicator_color5, indicator_color6, indicator_color7, indicator_color8
              };

//--- Class of the "Moving Average" indicator
#include <Indicators\Trend.mqh>
CiMA ma[28];
//---
string symbols[28] =
  {
   "AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY",
   "CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD",
   "EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD",
   "NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"
  };
#define AUDCAD 0
#define AUDCHF 1
#define AUDJPY 2
#define AUDNZD 3
#define AUDUSD 4
#define CADCHF 5
#define CADJPY 6
#define CHFJPY 7
#define EURAUD 8
#define EURCAD 9
#define EURCHF 10
#define EURGBP 11
#define EURJPY 12
#define EURNZD 13
#define EURUSD 14
#define GBPAUD 15
#define GBPCAD 16
#define GBPCHF 17
#define GBPJPY 18
#define GBPNZD 19
#define GBPUSD 20
#define NZDCAD 21
#define NZDCHF 22
#define NZDJPY 23
#define NZDUSD 24
#define USDCAD 26
#define USDCHF 26
#define USDJPY 27
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set name to be displayed
   string ShortName="Currency Strength Index MA("+(string)ma_period_+"/"+(string)ma_delta+") >>";
   IndicatorSetString(INDICATOR_SHORTNAME,ShortName);

//--- assignment of array to indicator buffer
   SetIndexBuffer(0,AUDx,INDICATOR_DATA);
   SetIndexBuffer(1,CADx,INDICATOR_DATA);
   SetIndexBuffer(2,CHFx,INDICATOR_DATA);
   SetIndexBuffer(3,EURx,INDICATOR_DATA);
   SetIndexBuffer(4,GBPx,INDICATOR_DATA);
   SetIndexBuffer(5,NZDx,INDICATOR_DATA);
   SetIndexBuffer(6,USDx,INDICATOR_DATA);
   SetIndexBuffer(7,JPYx,INDICATOR_DATA);

//--- set up indicator buffers
   for(int i=0; i < ArraySize(Currencies); i++)
     {
      PlotIndexSetInteger(i,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(i,PLOT_LINE_STYLE,STYLE_SOLID);
      PlotIndexSetInteger(i,PLOT_LINE_WIDTH,2);
      PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,0);
      PlotIndexSetString(i,PLOT_LABEL,Currencies[i]);
     }

//--- set AsSeries
   ArraySetAsSeries(AUDx,true);
   ArraySetAsSeries(CADx,true);
   ArraySetAsSeries(CHFx,true);
   ArraySetAsSeries(EURx,true);
   ArraySetAsSeries(GBPx,true);
   ArraySetAsSeries(NZDx,true);
   ArraySetAsSeries(USDx,true);
   ArraySetAsSeries(JPYx,true);

//---
   if(!CreateLabels())
      //--- the indicator is stopped early
      return(INIT_FAILED);

   if(!CreateHandles())
      //--- the indicator is stopped early
      return(INIT_FAILED);

//--- normal initialization of the indicator
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete all objects we created
   ObjectsDeleteAll(0,"obj_csi_");
  }
//+-------------------------------------------------------------------+
//| Create all text labels (colored names of the displayed currencies)|
//+-------------------------------------------------------------------+
bool CreateLabels()
  {
//--- start of X and Y coordinates
   int x=0;
   int y=0;

//--- create all labels
   for(int i=0; i < ArraySize(Currencies); i++)
     {
      if(!LabelCreate(Currencies[i], ChartWindowFind(), x, y, Colors[i]))
         return(false);
         y += 15;
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a single descriptive object at the given coordinates      |
//+------------------------------------------------------------------+
bool LabelCreate(string currency, int sub_window, int x, int y, int clr)
  {
   const string name="obj_csi_"+currency;
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(0,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code=",GetLastError());
      return(false);
     }
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);  
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetString(0,name,OBJPROP_TEXT,currency);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
//--- successful execution
   return(true);
  }
//+-------------------------------------------------------------------+
//| Create handles of the moving average indicators                   |
//+-------------------------------------------------------------------+
bool CreateHandles()
  {
//--- symbol suffix of the current chart symbol
   string SymbolSuffix=StringSubstr(Symbol(),6,StringLen(Symbol())-6);

//--- create handles of the indicator
   for(int i=0; i < ArraySize(symbols); i++)
     {
      string symbol=symbols[i]+SymbolSuffix;
      //---
      if(!CheckMarketWatch(symbol))
        {
         //--- if symbol is not in the market watch
         return(false);
        }
      //---
      if(!ma[i].Create(symbol,PERIOD_CURRENT,ma_period_,0,MODE_LWMA,PRICE_OPEN))
        {
         //--- if the handle is not created
         Print(__FUNCTION__,
               ": failed to create handle of iMA indicator for symbol ",symbol);
         return(false);
        }
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Checks if symbol is selected in the MarketWatch                  |
//| and adds symbol to the MarketWatch, if necessary                 |
//+------------------------------------------------------------------+
bool CheckMarketWatch(string symbol)
  {
//--- check if symbol is selected in the MarketWatch
   if(!SymbolInfoInteger(symbol,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL)
        {
         printf(__FUNCTION__+": Unknown symbol '%s'",symbol);
         return(false);
        }
      if(!SymbolSelect(symbol,true))
        {
         printf(__FUNCTION__+": Error adding symbol %d",GetLastError());
         return(false);
        }
     }
//--- succeed
   return(true);
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
//--- the necessary amount of data to be calculated
   int limit=rates_total;
//---
   for(int i=0; i < ArraySize(ma); i++)
     {
      //--- check if all data is calculated
      if(ma[i].BarsCalculated()<0)
        {
         Print(__FUNCTION__+": ",symbols[i]," not ready.");
         return(0);
        }
      //--- update the ma indicator data
      ma[i].Refresh();

      //--- the amount of calculated data for the ma indicator
      limit=(int)MathMin(limit,ma[i].BarsCalculated());
     }

//--- checking for the first start of the indicator calculation
   if(prev_calculated>rates_total || prev_calculated<=0)
     {
      limit=limit-ma_delta;
     }
   else
      limit=rates_total-prev_calculated+1;

//--- https://www.tradingview.com/chart/GBPUSD/CjY0z8cG-Trading-the-STRONG-against-the-weak-currency-strength-calc/
//--- https://www.mql5.com/en/articles/83
//--- http://fxcorrelator.wixsite.com/nvp100
   for(int i=0; i<limit; i++)
     {
      if(ShowAUD)
        {
         A1=ma[EURAUD].Main(i)/ma[EURAUD].Main(i+ma_delta);  //EURAUD*
         A2=ma[GBPAUD].Main(i)/ma[GBPAUD].Main(i+ma_delta);  //GBPAUD*
         A3=ma[AUDNZD].Main(i)/ma[AUDNZD].Main(i+ma_delta);  //AUDNZD
         A4=ma[AUDUSD].Main(i)/ma[AUDUSD].Main(i+ma_delta);  //AUDUSD
         A5=ma[AUDCAD].Main(i)/ma[AUDCAD].Main(i+ma_delta);  //AUDCAD
         A6=ma[AUDCHF].Main(i)/ma[AUDCHF].Main(i+ma_delta);  //AUDCHF
         A7=ma[AUDJPY].Main(i)/ma[AUDJPY].Main(i+ma_delta);  //AUDJPY
         AUD=(1/A1*1/A2*A3*A4*A5*A6*A7)-1;

         AUDx[i]=AUD;
        } 

      if(ShowCAD)
        {
         A1=ma[EURCAD].Main(i)/ma[EURCAD].Main(i+ma_delta);  //EURCAD*
         A2=ma[GBPCAD].Main(i)/ma[GBPCAD].Main(i+ma_delta);  //GBPCAD*
         A3=ma[AUDCAD].Main(i)/ma[AUDCAD].Main(i+ma_delta);  //AUDCAD*
         A4=ma[NZDCAD].Main(i)/ma[NZDCAD].Main(i+ma_delta);  //NZDCAD*
         A5=ma[USDCAD].Main(i)/ma[USDCAD].Main(i+ma_delta);  //USDCAD*
         A6=ma[CADCHF].Main(i)/ma[CADCHF].Main(i+ma_delta);  //CADCHF
         A7=ma[CADJPY].Main(i)/ma[CADJPY].Main(i+ma_delta);  //CADJPY
         CAD=(1/A1*1/A2*1/A3*1/A4*1/A5*A6*A7)-1;

         CADx[i]=CAD;
        }

      if(ShowCHF)
        {
         A1=ma[EURCHF].Main(i)/ma[EURCHF].Main(i+ma_delta);  //EURCHF*
         A2=ma[GBPCHF].Main(i)/ma[GBPCHF].Main(i+ma_delta);  //GBPCHF*
         A3=ma[AUDCHF].Main(i)/ma[AUDCHF].Main(i+ma_delta);  //AUDCHF*
         A4=ma[NZDCHF].Main(i)/ma[NZDCHF].Main(i+ma_delta);  //NZDCHF*
         A5=ma[USDCHF].Main(i)/ma[USDCHF].Main(i+ma_delta);  //USDCHF*
         A6=ma[CADCHF].Main(i)/ma[CADCHF].Main(i+ma_delta);  //CADCHF*
         A7=ma[CHFJPY].Main(i)/ma[CHFJPY].Main(i+ma_delta);  //CHFJPY
         CHF=(1/A1*1/A2*1/A3*1/A4*1/A5*1/A6*A7)-1;

         CHFx[i]=CHF;
        }
            
      if(ShowEUR)
        {
         A1=ma[EURGBP].Main(i)/ma[EURGBP].Main(i+ma_delta);  //EURGBP
         A2=ma[EURAUD].Main(i)/ma[EURAUD].Main(i+ma_delta);  //EURAUD
         A3=ma[EURNZD].Main(i)/ma[EURNZD].Main(i+ma_delta);  //EURNZD
         A4=ma[EURUSD].Main(i)/ma[EURUSD].Main(i+ma_delta);  //EURUSD
         A5=ma[EURCAD].Main(i)/ma[EURCAD].Main(i+ma_delta);  //EURCAD
         A6=ma[EURCHF].Main(i)/ma[EURCHF].Main(i+ma_delta);  //EURCHF
         A7=ma[EURJPY].Main(i)/ma[EURJPY].Main(i+ma_delta);  //EURJPY
         EUR=(A1*A2*A3*A4*A5*A6*A7)-1;

         EURx[i]=EUR;
        }

      if(ShowGBP)
        {
         A1=ma[EURGBP].Main(i)/ma[EURGBP].Main(i+ma_delta);  //EURGBP*
         A2=ma[GBPAUD].Main(i)/ma[GBPAUD].Main(i+ma_delta);  //GBPAUD
         A3=ma[GBPNZD].Main(i)/ma[GBPNZD].Main(i+ma_delta);  //GBPNZD
         A4=ma[GBPUSD].Main(i)/ma[GBPUSD].Main(i+ma_delta);  //GBPUSD
         A5=ma[GBPCAD].Main(i)/ma[GBPCAD].Main(i+ma_delta);  //GBPCAD
         A6=ma[GBPCHF].Main(i)/ma[GBPCHF].Main(i+ma_delta);  //GBPCHF
         A7=ma[GBPJPY].Main(i)/ma[GBPJPY].Main(i+ma_delta);  //GBPJPY
         GBP=(1/A1*A2*A3*A4*A5*A6*A7)-1;

         GBPx[i]=GBP;
        }

      if(ShowNZD)
        {
         A1=ma[EURNZD].Main(i)/ma[EURNZD].Main(i+ma_delta);  //EURNZD*
         A2=ma[GBPNZD].Main(i)/ma[GBPNZD].Main(i+ma_delta);  //GBPNZD*
         A3=ma[AUDNZD].Main(i)/ma[AUDNZD].Main(i+ma_delta);  //AUDNZD*
         A4=ma[NZDUSD].Main(i)/ma[NZDUSD].Main(i+ma_delta);  //NZDUSD
         A5=ma[NZDCAD].Main(i)/ma[NZDCAD].Main(i+ma_delta);  //NZDCAD
         A6=ma[NZDCHF].Main(i)/ma[NZDCHF].Main(i+ma_delta);  //NZDCHF
         A7=ma[NZDJPY].Main(i)/ma[NZDJPY].Main(i+ma_delta);  //NZDJPY
         NZD=(1/A1*1/A2*1/A3*A4*A5*A6*A7)-1;

         NZDx[i]=NZD;
        }

      if(ShowUSD)
        {
         A1=ma[EURUSD].Main(i)/ma[EURUSD].Main(i+ma_delta);  //EURUSD*
         A2=ma[GBPUSD].Main(i)/ma[GBPUSD].Main(i+ma_delta);  //GBPUSD*
         A3=ma[AUDUSD].Main(i)/ma[AUDUSD].Main(i+ma_delta);  //AUDUSD*
         A4=ma[NZDUSD].Main(i)/ma[NZDUSD].Main(i+ma_delta);  //NZDUSD*
         A5=ma[USDCAD].Main(i)/ma[USDCAD].Main(i+ma_delta);  //USDCAD
         A6=ma[USDCHF].Main(i)/ma[USDCHF].Main(i+ma_delta);  //USDCHF
         A7=ma[USDJPY].Main(i)/ma[USDJPY].Main(i+ma_delta);  //USDJPY
         USD=(1/A1*1/A2*1/A3*1/A4*A5*A6*A7)-1;

         USDx[i]=USD;
        }

      if(ShowJPY)
        {
         A1=ma[EURJPY].Main(i)/ma[EURJPY].Main(i+ma_delta);  //EURJPY*
         A2=ma[GBPJPY].Main(i)/ma[GBPJPY].Main(i+ma_delta);  //GBPJPY*
         A3=ma[AUDJPY].Main(i)/ma[AUDJPY].Main(i+ma_delta);  //AUDJPY*
         A4=ma[NZDJPY].Main(i)/ma[NZDJPY].Main(i+ma_delta);  //NZDJPY*
         A5=ma[USDJPY].Main(i)/ma[USDJPY].Main(i+ma_delta);  //USDJPY*
         A6=ma[CADJPY].Main(i)/ma[CADJPY].Main(i+ma_delta);  //CADJPY*
         A7=ma[CHFJPY].Main(i)/ma[CHFJPY].Main(i+ma_delta);  //CHFJPY*
         JPY=(1/A1*1/A2*1/A3*1/A4*1/A5*1/A6*1/A7)-1;

         JPYx[i]=JPY;
        }
     }
//--- return the prev_calculated value for the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
