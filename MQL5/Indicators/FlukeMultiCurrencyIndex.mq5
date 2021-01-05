//+------------------------------------------------------------------+
//|                                      FlukeMultiCurrencyIndex.mq5 |
//|                               Copyright 2020, Chaninnart Chansiu |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Chaninnart Chansiu"
#property link      ""
#property version   "1.00"
#property indicator_separate_window

#include <Math\Stat\Normal.mqh>

#property indicator_buffers 31
#property indicator_plots   8
//+------------------------------------------------------------------+
//| enumeration of indicator types                                    |
//+------------------------------------------------------------------+
enum Indicator_Type
  {
   Use_ROC_on_indexs              = 0, // ROC of the index  
   Use_RSI_on_indexes             = 1, // RSI of the index  
   Use_MACD_on_indexes            = 2, // MACD from the index  
   Use_Stochastic_Main_on_indexes = 3  // Stochastic on the index
  };
input Indicator_Type ind_type=Use_ROC_on_indexs ;  // type of the indicator from the index

bool AUD=true;
bool CAD=true;
bool CHF=true;
bool EUR=true;
bool GBP=true;
bool NZD=true;
bool USD=true;
bool JPY=true;

string rem000        =  ""; // depending on the type of the indicator
string rem0000       =  ""; // requires a value :
input int roc_period        =  9; // Reference Bar for Rate of Change index
input int rsi_period       =   9; // period RSI
input int MACD_fast        =   5; // period MACD_fast
input int MACD_slow        =  34; // period MACD_slow
input int stoch_period_k   =   8; // period Stochastic %K
input int stoch_period_sma =   5; // period of smoothing for Stochastics %K
input int shiftbars        = 500; // number of bars for calculating the indicator

color Color_AUD = clrYellow;              // AUD line color
color Color_CAD = clrLawnGreen;           // CAD line color
color Color_CHF = clrWhite;               // CHF line color
color Color_EUR = clrDodgerBlue;          // EUR line color
color Color_GBP = clrAqua;                // GBP line color
color Color_NZD = clrOrange;              // NZD line color
color Color_USD = clrGreen;               // USD line color
color Color_JPY = clrRed;                 // JPY line color

ENUM_LINE_STYLE style_slave = STYLE_DOT; //Style of alternative lines for current chart
double  EURUSD[], // quotes
        GBPUSD[],
        USDCHF[],
        USDJPY[],
        AUDUSD[],
        USDCAD[],
        NZDUSD[];                  
double    USDx[], // indexes
          EURx[],
          GBPx[],
          JPYx[],
          CHFx[],
          CADx[],
          AUDx[],
          NZDx[];                         
double USDplot[], // results of currency lines
       EURplot[],
       GBPplot[],
       JPYplot[],
       CHFplot[],
       CADplot[],
       AUDplot[],
       NZDplot[]; 
double USDstoch[], // buffers of intermediate data schotastics by the close/close type without smoothing
       EURstoch[],
       GBPstoch[],
       JPYstoch[],
       CHFstoch[],
       CADstoch[],
       AUDstoch[],
       NZDstoch[];

// buffer indexes
// 0-7 inclusive   - buffers for drawing final lines
// 8-14 inclusive  - buffers for main currency pairs, containing USD
// 15-22 inclusive - buffers for currency indexes
// 23-30 inclusive - buffers for intermediate data of stochastic for close/close type without smoothing

int              i,ii;
int         y_pos = 0; // Y coordinate variable for the informatory objects  
datetime   arrTime[7]; // Array with the last known time of a zero valued bar (needed for synchronization)  
int        bars_tf[7]; // To check the number of available bars in different currency pairs  
int      countVal = 0; // Number of executable Rates  
int         index = 0;
datetime  tmp_time[1]; // Intermediate array for the time of the bar 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   if(ind_type==0)
     {
      IndicatorSetInteger(INDICATOR_DIGITS,10);                    // number of digits after period, if MA
     }
   if(ind_type==1 || ind_type==3)
     {
      IndicatorSetInteger(INDICATOR_DIGITS,1);                    // number of digits after period, if RSI or Stochastic
     }
   if(ind_type==2)
     {
      IndicatorSetInteger(INDICATOR_DIGITS,5);                    // number of digits after period, if MACD
     }
   string nameInd="MultiCurrencyIndex";
   if(ind_type==Use_ROC_on_indexs){nameInd+=" ROC("+IntegerToString(roc_period)+")";}
   if(ind_type==Use_RSI_on_indexes){nameInd+=" RSI("+IntegerToString(rsi_period)+")";}
   if(ind_type==Use_MACD_on_indexes){nameInd+=" MACD("+IntegerToString(MACD_fast)+","+IntegerToString(MACD_slow)+")";}
   if(ind_type==Use_Stochastic_Main_on_indexes){nameInd+=" Stochastic("+IntegerToString(stoch_period_k)+","+IntegerToString(stoch_period_sma)+")";}
   IndicatorSetString(INDICATOR_SHORTNAME,nameInd);

   if(AUD)
     {
      countVal++;
      SetIndexBuffer(0,AUDplot,INDICATOR_DATA);
      PlotIndexSetString(0,PLOT_LABEL,"AUDplot");
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,Color_AUD);
      PlotIndexSetInteger(0,PLOT_LINE_WIDTH,2);
      ArraySetAsSeries(AUDplot,true);
      ArrayInitialize(AUDplot,EMPTY_VALUE);
      SetIndexBuffer(13,AUDUSD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(AUDUSD,true);
      ArrayInitialize(AUDUSD,EMPTY_VALUE);
      SetIndexBuffer(15,AUDx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(AUDx,true);
      ArrayInitialize(AUDx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(23,AUDstoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(AUDstoch,true);
         ArrayInitialize(AUDstoch,EMPTY_VALUE);
        }
      f_draw("AUD",Color_AUD);
     }
   if(CAD)
     {
      countVal++;
      SetIndexBuffer(1,CADplot,INDICATOR_DATA);
      PlotIndexSetString(1,PLOT_LABEL,"CADplot");
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(1,PLOT_LINE_COLOR,Color_CAD);
      PlotIndexSetInteger(1,PLOT_LINE_WIDTH,2);
      ArraySetAsSeries(CADplot,true);
      ArrayInitialize(CADplot,EMPTY_VALUE);
      SetIndexBuffer(12,USDCAD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(USDCAD,true);
      ArrayInitialize(USDCAD,EMPTY_VALUE);
      SetIndexBuffer(16,CADx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(CADx,true);
      ArrayInitialize(CADx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(24,CADstoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(CADstoch,true);
         ArrayInitialize(CADstoch,EMPTY_VALUE);
        }
      f_draw("CAD",Color_CAD);
     }  

   if(CHF)
     {
      countVal++;
      SetIndexBuffer(2,CHFplot,INDICATOR_DATA);
      PlotIndexSetString(2,PLOT_LABEL,"CHFplot");
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,Color_CHF);
      PlotIndexSetInteger(2,PLOT_LINE_WIDTH,2);
      ArraySetAsSeries(CHFplot,true);
      ArrayInitialize(CHFplot,EMPTY_VALUE);
      SetIndexBuffer(11,USDCHF,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(USDCHF,true);
      ArrayInitialize(USDCHF,EMPTY_VALUE);
      SetIndexBuffer(17,CHFx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(CHFx,true);
      ArrayInitialize(CHFx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(25,CHFstoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(CHFstoch,true);
         ArrayInitialize(CHFstoch,EMPTY_VALUE);
        }
      f_draw("CHF",Color_CHF);
     }

   if(EUR)
     {
      countVal++;
      SetIndexBuffer(3,EURplot,INDICATOR_DATA);                // array for rendering
      PlotIndexSetString(3,PLOT_LABEL,"EURplot");              // name of the indicator line (when pointed to with a mouse)
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,shiftbars);        // which we begin rendering from
      PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_LINE);         // drawing style (lines)
      PlotIndexSetInteger(3,PLOT_LINE_COLOR,Color_EUR);        // the color of rendering lines
      PlotIndexSetInteger(3,PLOT_LINE_WIDTH,2);     // if the symbol name contains EUR
      ArraySetAsSeries(EURplot,true);                          // indexation of the array as a time series
      ArrayInitialize(EURplot,EMPTY_VALUE);                    // zero values
      SetIndexBuffer(8,EURUSD,INDICATOR_CALCULATIONS);         // data of Close currency pair EURUSD
      ArraySetAsSeries(EURUSD,true);                           // indexation of the array as a time series
      ArrayInitialize(EURUSD,EMPTY_VALUE);                     // zero values
      SetIndexBuffer(18,EURx,INDICATOR_CALCULATIONS);          // array of the EURO index for calculations
                                                               // (not displayed on the indicator as a line) 
      ArraySetAsSeries(EURx,true);
      ArrayInitialize(EURx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(26,EURstoch,INDICATOR_CALCULATIONS);   // if the indicator destination as a Use_Stochastic_Main_on_indexes,
                                                               // then this intermediate array is needed
         ArraySetAsSeries(EURstoch,true);                      // indexation of the array as a time series
         ArrayInitialize(EURstoch,EMPTY_VALUE);                // zero values
        }
      f_draw("EUR",Color_EUR);                                 // rendering in the indicator information window
     }
   if(GBP)
     {
      countVal++;
      SetIndexBuffer(4,GBPplot,INDICATOR_DATA);
      PlotIndexSetString(4,PLOT_LABEL,"GBPplot");
      PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(4,PLOT_LINE_COLOR,Color_GBP);
      PlotIndexSetInteger(4,PLOT_LINE_WIDTH,2);
      ArraySetAsSeries(GBPplot,true);
      ArrayInitialize(GBPplot,EMPTY_VALUE);
      SetIndexBuffer(9,GBPUSD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(GBPUSD,true);
      ArrayInitialize(GBPUSD,EMPTY_VALUE);
      SetIndexBuffer(19,GBPx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(GBPx,true);
      ArrayInitialize(GBPx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(27,GBPstoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(GBPstoch,true);
         ArrayInitialize(GBPstoch,EMPTY_VALUE);
        }
      f_draw("GBP",Color_GBP);
     }
     
   if(USD)
     {
      countVal++;
      SetIndexBuffer(5,USDplot,INDICATOR_DATA);                // array for rendering
      PlotIndexSetString(5,PLOT_LABEL,"USDplot");              // name of the indicator line (when selected with a mouse)
      PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,shiftbars);        // from which we begin rendering
      PlotIndexSetInteger(5,PLOT_DRAW_TYPE,DRAW_LINE);         // drawing style (line)
      PlotIndexSetInteger(5,PLOT_LINE_COLOR,Color_USD);        // color of line rendering
      PlotIndexSetInteger(5,PLOT_LINE_WIDTH,2);     // if the symbol name contains USD 
      ArraySetAsSeries(USDplot,true);                          // indexation of array as a timeseries
      ArrayInitialize(USDplot,EMPTY_VALUE);                    // zero values 
      f_draw("USD",Color_USD);                                 // rendering in the indicator information window 
     }
   SetIndexBuffer(20,USDx,INDICATOR_CALCULATIONS);             // array of dollar index for calculations
                                                               // (is not displayed in the indicator as a line) 
   ArraySetAsSeries(USDx,true);                                // indexation of an array as a time series
   ArrayInitialize(USDx,EMPTY_VALUE);                          // zero values

   if(ind_type==Use_Stochastic_Main_on_indexes)
     {
      SetIndexBuffer(28,USDstoch,INDICATOR_CALCULATIONS);      // if the destination of the indicator as a Use_Stochastic_Main_on_indexes,
                                                               // then this intermediate array is needed
      ArraySetAsSeries(USDstoch,true);                         // indexation of array as a time series
      ArrayInitialize(USDstoch,EMPTY_VALUE);                   // zero values
     }     
     
   if(JPY)
     {
      countVal++;
      SetIndexBuffer(6,JPYplot,INDICATOR_DATA);
      PlotIndexSetString(6,PLOT_LABEL,"JPYplot");
      PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(6,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(6,PLOT_LINE_COLOR,Color_JPY);
      PlotIndexSetInteger(6,PLOT_LINE_WIDTH,2);
      ArraySetAsSeries(JPYplot,true);
      ArrayInitialize(JPYplot,EMPTY_VALUE);
      SetIndexBuffer(10,USDJPY,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(USDJPY,true);
      ArrayInitialize(USDJPY,EMPTY_VALUE);
      SetIndexBuffer(21,JPYx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(JPYx,true);
      ArrayInitialize(JPYx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(29,JPYstoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(JPYstoch,true);
         ArrayInitialize(JPYstoch,EMPTY_VALUE);
        }
      f_draw("JPY",Color_JPY);
     }
     
   if(NZD)
     {
      countVal++;
      SetIndexBuffer(7,NZDplot,INDICATOR_DATA);
      PlotIndexSetString(7,PLOT_LABEL,"NZDplot");
      PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(7,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(7,PLOT_LINE_COLOR,Color_NZD);
      PlotIndexSetInteger(7,PLOT_LINE_WIDTH,2);
      ArraySetAsSeries(NZDplot,true);
      ArrayInitialize(NZDplot,EMPTY_VALUE);
      SetIndexBuffer(14,NZDUSD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(NZDUSD,true);
      ArrayInitialize(NZDUSD,EMPTY_VALUE);
      SetIndexBuffer(22,NZDx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(NZDx,true);
      ArrayInitialize(NZDx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(30,NZDstoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(NZDstoch,true);
         ArrayInitialize(NZDstoch,EMPTY_VALUE);
        }
      f_draw("NZD",Color_NZD);
     }
   ArrayResize(arrTime,countVal-1);
   ArrayResize(bars_tf,countVal-1);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int     rates_total, // size of incoming time series
                const int prev_calculated, // processing of bars on the previous request
                const datetime&    time[], // Time
                const double&      open[], // Open
                const double&      high[], // High
                const double&       low[], // Low
                const double&     close[], // Close
                const long& tick_volume[], // Tick Volume
                const long&      volume[], // Real Volume
                const int&       spread[]) // Spread
  {
   int limit=shiftbars;

   if(prev_calculated>0)
     {limit=1;}
   else
     {limit=shiftbars;}
   int copied;

// initializing charts of used currency pairs
   init_tf();

   if(AUD){copied=CopyClose("AUDUSD",PERIOD_CURRENT,0,shiftbars,AUDUSD);if(copied==-1){f_comment("Wait...AUDUSD");return(0);}}
   if(CAD){copied=CopyClose("USDCAD",PERIOD_CURRENT,0,shiftbars,USDCAD);if(copied==-1){f_comment("Wait...USDCAD");return(0);}}
   if(CHF){copied=CopyClose("USDCHF",PERIOD_CURRENT,0,shiftbars,USDCHF);if(copied==-1){f_comment("Wait...USDCHF");return(0);}}
   if(EUR){copied=CopyClose("EURUSD",PERIOD_CURRENT,0,shiftbars,EURUSD);if(copied==-1){f_comment("Wait...EURUSD");return(0);}}
   if(GBP){copied=CopyClose("GBPUSD",PERIOD_CURRENT,0,shiftbars,GBPUSD);if(copied==-1){f_comment("Wait...GBPUSD");return(0);}}
   if(JPY){copied=CopyClose("USDJPY",PERIOD_CURRENT,0,shiftbars,USDJPY);if(copied==-1){f_comment("Wait...USDJPY");return(0);}}
   if(NZD){copied=CopyClose("NZDUSD",PERIOD_CURRENT,0,shiftbars,NZDUSD);if(copied==-1){f_comment("Wait...NZDUSD");return(0);}}

   for(i=limit-1;i>=0;i--)
     {
      //calculating USD index
      USDx[i]=1.0;
      if(AUD){USDx[i]+=AUDUSD[i];}
      if(CAD){USDx[i]+=1/USDCAD[i];}
      if(CHF){USDx[i]+=1/USDCHF[i];}
      if(EUR){USDx[i]+=EURUSD[i];}
      if(GBP){USDx[i]+=GBPUSD[i];}
      if(JPY){USDx[i]+=1/USDJPY[i];}
      if(NZD){USDx[i]+=NZDUSD[i];}
      USDx[i]=1/USDx[i];
      //calculating other currency indexes
      if(AUD){AUDx[i]=AUDUSD[i]*USDx[i];}
      if(CAD){CADx[i]=USDx[i]/USDCAD[i];}
      if(CHF){CHFx[i]=USDx[i]/USDCHF[i];}
      if(EUR){EURx[i]=EURUSD[i]*USDx[i];}
      if(GBP){GBPx[i]=GBPUSD[i]*USDx[i];}
      if(JPY){JPYx[i]=USDx[i]/USDJPY[i];}
      if(NZD){NZDx[i]=NZDUSD[i]*USDx[i];}

     }
//calculating buffers for drawing, depending on chosen indicator purpose
   if(ind_type==Use_ROC_on_indexs)
     {         

     for(i=500;i>=0;i--)
        {
         if(AUD){AUDplot[i]= 100*(AUDx[i]- AUDx[roc_period ])/AUDx[roc_period ];}
         if(CAD){CADplot[i]= 100*(CADx[i]- CADx[roc_period ])/CADx[roc_period ];}
         if(CHF){CHFplot[i]= 100*(CHFx[i]- CHFx[roc_period ])/CHFx[roc_period ];}
         if(EUR){EURplot[i]= 100*(EURx[i]- EURx[roc_period ])/EURx[roc_period ];}
         if(GBP){GBPplot[i]= 100*(GBPx[i]- GBPx[roc_period ])/GBPx[roc_period ];}
         if(JPY){JPYplot[i]= 100*(JPYx[i]- JPYx[roc_period ])/JPYx[roc_period ];}
         if(USD){USDplot[i]= 100*(USDx[i]- USDx[roc_period ])/USDx[roc_period ];}
         if(NZD){NZDplot[i]= 100*(NZDx[i]- NZDx[roc_period ])/NZDx[roc_period ];}
        }

     }


   if(ind_type==Use_RSI_on_indexes)
     {
      if(limit>1){ii=limit-rsi_period-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
         if(AUD){AUDplot[i]=f_RSI(AUDx,rsi_period,i);}
         if(CAD){CADplot[i]=f_RSI(CADx,rsi_period,i);}
         if(CHF){CHFplot[i]=f_RSI(CHFx,rsi_period,i);}
         if(EUR){EURplot[i]=f_RSI(EURx,rsi_period,i);}
         if(GBP){GBPplot[i]=f_RSI(GBPx,rsi_period,i);}
         if(JPY){JPYplot[i]=f_RSI(JPYx,rsi_period,i);}
         if(USD){USDplot[i]=f_RSI(USDx,rsi_period,i);}
         if(NZD){NZDplot[i]=f_RSI(NZDx,rsi_period,i);}
        }
     }
     
   if(ind_type==Use_MACD_on_indexes)
     {
      if(limit>1){ii=limit-MACD_slow-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
         if(AUD){AUDplot[i]=f_MACD(AUDx,MACD_fast,MACD_slow,i);}
         if(CAD){CADplot[i]=f_MACD(CADx,MACD_fast,MACD_slow,i);}
         if(CHF){CHFplot[i]=f_MACD(CHFx,MACD_fast,MACD_slow,i);}
         if(EUR){EURplot[i]=f_MACD(EURx,MACD_fast,MACD_slow,i);}
         if(GBP){GBPplot[i]=f_MACD(GBPx,MACD_fast,MACD_slow,i);}
         if(JPY){JPYplot[i]=f_MACD(JPYx,MACD_fast,MACD_slow,i);}
         if(USD){USDplot[i]=f_MACD(USDx,MACD_fast,MACD_slow,i);}
         if(NZD){NZDplot[i]=f_MACD(NZDx,MACD_fast,MACD_slow,i);}
        }
     }
     
   if(ind_type==Use_Stochastic_Main_on_indexes)
     {
      if(limit>1){ii=limit-stoch_period_k-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
         if(AUD){AUDstoch[i]=f_Stoch(AUDx,stoch_period_k,i);}
         if(CAD){CADstoch[i]=f_Stoch(CADx,stoch_period_k,i);}
         if(CHF){CHFstoch[i]=f_Stoch(CHFx,stoch_period_k,i);}
         if(EUR){EURstoch[i]=f_Stoch(EURx,stoch_period_k,i);}
         if(GBP){GBPstoch[i]=f_Stoch(GBPx,stoch_period_k,i);}
         if(JPY){JPYstoch[i]=f_Stoch(JPYx,stoch_period_k,i);}
         if(USD){USDstoch[i]=f_Stoch(USDx,stoch_period_k,i);}
         if(NZD){NZDstoch[i]=f_Stoch(NZDx,stoch_period_k,i);}
        }
      if(limit>1){ii=limit-stoch_period_sma-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
         if(AUD){AUDplot[i]=SimpleMA(i,stoch_period_sma,AUDstoch);}
         if(CAD){CADplot[i]=SimpleMA(i,stoch_period_sma,CADstoch);}
         if(CHF){CHFplot[i]=SimpleMA(i,stoch_period_sma,CHFstoch);}
         if(EUR){EURplot[i]=SimpleMA(i,stoch_period_sma,EURstoch);}
         if(GBP){GBPplot[i]=SimpleMA(i,stoch_period_sma,GBPstoch);}
         if(JPY){JPYplot[i]=SimpleMA(i,stoch_period_sma,JPYstoch);}
         if(USD){USDplot[i]=SimpleMA(i,stoch_period_sma,USDstoch);}
         if(NZD){NZDplot[i]=SimpleMA(i,stoch_period_sma,NZDstoch);}
        }

     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
///                        Auxiliary functions
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
///                        Calculating RSI
//+------------------------------------------------------------------+
double f_RSI(double &buf_in[],int period,int shift)
  {
   double pos=0.00000000,neg=0.00000000;
   double diff=0.0;
   for(int j=shift;j<=shift+period;j++)
     {
      diff=buf_in[j]-buf_in[j+1];
      pos+=(diff>0?diff:0.0);
      neg+=(diff<0?-diff:0.0);
     }
   if(neg<0.000000001){return(100.0);}//Protection from division by zero
   pos/=period;
   neg/=period;
   return(100.0 -(100.0/(1.0+pos/neg)));
  }
//+------------------------------------------------------------------+
///                        Calculating MACD
//+------------------------------------------------------------------+   
double f_MACD(double &buf_in[],int period_fast,int period_slow,int shift)
  {
   return(SimpleMA(shift,period_fast,buf_in)-SimpleMA(shift,period_slow,buf_in));
  }
//+------------------------------------------------------------------+
///                        Calculating SMA
//+------------------------------------------------------------------+   
double SimpleMA(const int position,const int period,const double &price[])
  {
   double result=0.0;
   for(int i=0;i<period;i++) result+=price[position+i];
   result/=period;
   return(result);
  }
//+------------------------------------------------------------------+
///        Calculating Stochastic close/close without smoothing
//+------------------------------------------------------------------+   
double f_Stoch(double &price[],int period_k,int shift)
  {
   double result=0.0;
   double max=price[ArrayMaximum(price,shift,period_k)];
   double min=price[ArrayMinimum(price,shift,period_k)];
   result=(price[shift]-min)/(max-min)*100.0;
   return(result);
  }
//+------------------------------------------------------------------+
///        Drawing objects
//+------------------------------------------------------------------+   
int f_draw(string name,color _color)
  {
   ObjectCreate(0,name,OBJ_LABEL,ChartWindowFind(),0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,0);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y_pos);
   ObjectSetString(0,name,OBJPROP_TEXT,name);
   ObjectSetInteger(0,name,OBJPROP_COLOR,_color);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
   y_pos+=15;
   return(0);
  }
//+------------------------------------------------------------------+
///        Comment in the lower right corner of indicator
//+------------------------------------------------------------------+   
int f_comment(string  text)
  {
   string name="f_comment";
   color _color=Crimson;
   if(ObjectFind(0,name)>=0){ObjectSetString(0,name,OBJPROP_TEXT,text);}
   else
     {
      ObjectCreate(0,name,OBJ_LABEL,ChartWindowFind(),0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,0);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,0);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_COLOR,_color);
     }
   return(0);
  }
//+------------------------------------------------------------------+
///        initializing used TF currency pairs 
//+------------------------------------------------------------------+   
int init_tf()
  {
   int copy;
   ArrayInitialize(arrTime,0);
   ArrayInitialize(bars_tf,0);
   bool writeComment=true;
   for(int n=0;n<10;n++) // Loop for initializing used currency pairs with the same TF
     {
      index=0;
      int exit=-1;
      if(writeComment){f_comment("Synchronizing TF");writeComment=false;}
      if(EUR)
        {
         bars_tf[index]=Bars("EURUSD",PERIOD_CURRENT);
         copy=CopyTime("EURUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(GBP)
        {
         bars_tf[index]=Bars("GBPUSD",PERIOD_CURRENT);
         copy=CopyTime("GBPUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(CHF)
        {
         bars_tf[index]=Bars("USDCHF",PERIOD_CURRENT);
         copy=CopyTime("USDCHF",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(JPY)
        {
         bars_tf[index]=Bars("USDJPY",PERIOD_CURRENT);
         copy=CopyTime("USDJPY",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(CAD)
        {
         bars_tf[index]=Bars("USDCAD",PERIOD_CURRENT);
         copy=CopyTime("USDCAD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(AUD)
        {
         bars_tf[index]=Bars("AUDUSD",PERIOD_CURRENT);
         copy=CopyTime("AUDUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(NZD)
        {
         bars_tf[index]=Bars("NZDUSD",PERIOD_CURRENT);
         copy=CopyTime("NZDUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
        }

      for(int h=1;h<=index;h++)
        {
         if(arrTime[0]==arrTime[h]&&  arrTime[0]!=0 && exit==-1){exit=1;}
         if(arrTime[0]!=arrTime[h] &&  arrTime[0]!=0 && exit==1){exit=0;}
         if(bars_tf[h]<shiftbars){exit=0;}
        }
      if(exit==1){f_comment("Timeframes sinchronized");return(0);}
     }
   f_comment("Unable to synchronize TF");
   return(0);
  }
//+------------------------------------------------------------------+
