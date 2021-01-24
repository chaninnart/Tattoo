//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2020"
#property version     "2.4"
#property description " "
#include <Trade\PositionInfo.mqh> CPositionInfo     m_position;
#include <Trade\Trade.mqh> CTrade trade;

enum ENUM_SYMBOL_TYPE
  {
   CurrentSymbol, //Only Manage Current Symbol on Chart
   AllMarketWatch, //Manage All Available Symbols on MarketWatch
   SelectedSymbols //Only Manage Symbol in the Lists
  };
input    ENUM_TIMEFRAMES         tmf                 = PERIOD_H4; //Strength Period Calculation
input    int                     NumberOfCandles     = 25;        //Number of Candle to Calculate
input    bool                    ApplySmoothing      = true;      //Apply Smoothing
input    bool                    TriangularWeighting = true;      //Triangular Weighting
input    int                     HistoricalShift     = 0;         //Shift
input    double                  UpperLimit          = 7.0;   //Upper Limit Value
input    double                  LowerLimit          = 2.0;   //Lower Limit Value
input    int                     Stoploss            = 50;    // Stoploss
input    int                     Takeprofit          = 50;    //Takeprofit
input    int                     StartTime          = 10;    //Opening Time (GMT Time)
input    int                     FinishTime         = 16;    //Last Open Position Time (GMT Time)
input    double                  Lot                 = 0.01;  //lot
input    int                     iMagicNumber        = 227;   // Magic Number (in number)
input    int                     iSlippage           = 3;     // Slippage (in pips)
input    int                     TrailingStop        = 70;    // Trailing Stop (in Points)
input    int                     TrailingStep        = 10;    // Trailing Step (in Points)
input    string                  Commentary          = "Currency Strength EA";  // Order Comment
input ENUM_SYMBOL_TYPE  SymbolChoose      = CurrentSymbol; //Select the Symbol Mode
//input string symbols="AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY" ;
input string symbols="AUDUSD,EURUSD,GBPUSD,NZDUSD,USDCAD,USDCHF,USDJPY" ;
input string symbolPrefix=""; //Symbol Prefix (Symbol Lists Mode)
input string symbolSuffix=""; //Symbol Suffix (Symbol Lists Mode)
int numSymbols=0; //the number of symbols to scan
string symbolList[]; // array of symbols
string symbolListFinal[]; // array of symbols after merging post and prefix
string sym;
//---
double PipValue=1;    // this variable is here to support 5-digit brokers
//************************************************************************************************/
//*  0843292299                                                                                            */
//************************************************************************************************/
int OnInit()
  {
   Comment("");
   trade.LogLevel(LOG_LEVEL_ERRORS);
   trade.SetExpertMagicNumber(iMagicNumber);
   trade.SetDeviationInPoints(iSlippage);
   trade.SetMarginMode();
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar(string symbol)
  {
   static datetime old_time=NULL;
   datetime        new_time=iTime(symbol,Period(),0);

   if(new_time!=old_time)
     {
      old_time=new_time;
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
void OnTick(void)
  {
Print( "EA Still Working :" + TimeCurrent());   
   if(SymbolChoose == SelectedSymbols)
     {
      string sep=",";
      ushort u_sep;
      int i;
      u_sep=StringGetCharacter(sep,0);
      StringSplit(symbols,u_sep,symbolList);
      numSymbols=ArraySize(symbolList);//get the number of how many symbols are in the symbolList array
      ArrayResize(symbolListFinal,numSymbols);//resize finals symbol list to correct size
      for(i=0; i<numSymbols; i++) //combines postfix , symbol , prefix names together
        {
         symbolListFinal[i]=symbolPrefix+symbolList[i]+symbolSuffix;
         if(NewBar(symbolListFinal[i]))
           {
            Trade(symbolListFinal[i]);
           }
        }
     }
   if(SymbolChoose == AllMarketWatch)
     {
      int i;
      int numSymbolsMarketWatch=SymbolsTotal(false);
      numSymbols=numSymbolsMarketWatch;
      ArrayResize(symbolListFinal,numSymbolsMarketWatch);
      for(i=0; i<numSymbolsMarketWatch; i++)
        {
         symbolListFinal[i]=SymbolName(i,false);
         if(NewBar(symbolListFinal[i]))
           {
            Trade(symbolListFinal[i]);
           }
        }
     }
   if(SymbolChoose == CurrentSymbol)
     {
      if(NewBar(Symbol()))
        {
         Trade(Symbol());
        }
     }
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade(string symbol)
  {
   if(!Refresh(symbol))
      return;
   if(Strength(symbol) >= UpperLimit  && CheckMoneyForTrade(symbol,Lot,ORDER_TYPE_BUY) && CheckVolumeValue(symbol, Lot))
     {
      if(Timer())
         Buy(symbol);
     }
   else
      if(Strength(symbol) <= LowerLimit  && CheckMoneyForTrade(symbol,Lot,ORDER_TYPE_SELL) && CheckVolumeValue(symbol, Lot))
        {
         if(Timer())
            Sell(symbol);
        }
   Trailing(symbol);

   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Strength(string symbol)
  {
   if(!Refresh(symbol))
      return (0);

   int hi_bar, lo_bar;
   double curr_bid, candle_high, candle_low, bid_ratio;
   double CandleSum = NumberOfCandles*(NumberOfCandles+1)/2;
   curr_bid     = SymbolInfoDouble(symbol,SYMBOL_BID);
   if(curr_bid == 0)
      curr_bid = iClose(symbol,tmf,HistoricalShift);
   if(ApplySmoothing)
     {
      bid_ratio = 0;
      for(int k=1; k<=NumberOfCandles; k++)
        {
         hi_bar       = iHighest(symbol,tmf,MODE_HIGH,k,HistoricalShift);
         lo_bar       = iLowest(symbol,tmf,MODE_LOW,k,HistoricalShift);
         candle_high  = iHigh(symbol,tmf,hi_bar);
         candle_low   = iLow(symbol,tmf,lo_bar);
         if(TriangularWeighting)
            bid_ratio    += DivZero(curr_bid - candle_low, candle_high - candle_low) * (NumberOfCandles+1-k)/CandleSum;
         else
            bid_ratio    += DivZero(curr_bid - candle_low, candle_high - candle_low) / NumberOfCandles;
        }
     }
   else
     {
      hi_bar       = iHighest(symbol,tmf,MODE_HIGH,NumberOfCandles,HistoricalShift);
      lo_bar       = iLowest(symbol,tmf,MODE_LOW,NumberOfCandles,HistoricalShift);
      candle_high  = iHigh(symbol,tmf,hi_bar);
      candle_low   = iLow(symbol,tmf,lo_bar);
      bid_ratio    = DivZero(curr_bid - candle_low, candle_high - candle_low);
     }
   double ind_strength = 10 * bid_ratio;
   return (ind_strength);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DivZero(double n, double d)
//+------------------------------------------------------------------+
// Divides N by D, and returns 0 if the denominator (D) = 0
// Usage:   double x = DivZero(y,z)  sets x = y/z
  {
   if(d == 0)
      return(0);
   else
      return(n/d);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Buy(string symbol)
  {
   bool exists = false;

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   if(digits == 3 || digits == 5)
      PipValue = 10;

   double SL = NormalizeDouble(ask - Stoploss*PipValue*point,digits);      // Stop Loss specified
   double TP = NormalizeDouble(ask + Takeprofit*PipValue*point,digits);    // Take Profit specified
// go through all positions
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      sym = PositionGetSymbol(i);
      if(sym == symbol)
        {
         // position with appropriate ORDER_MAGIC, symbol and order type
         if(PositionGetInteger(POSITION_MAGIC) == iMagicNumber)
            exists = true;
        }
     }
   if(exists == false)
     {
      trade.Buy(Lot,symbol,ask,SL,TP,Commentary);
     }
  }
//+------------------------------------------------------------------+
void Sell(string symbol)
  {
   bool exists = false;

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   if(digits == 3 || digits == 5)
      PipValue = 10;

   double SL = NormalizeDouble(bid + Stoploss*PipValue*point,digits);      // Stop Loss specified
   double TP = NormalizeDouble(bid - Takeprofit*PipValue*point,digits);    // Take Profit specified

// go through all positions
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      sym = PositionGetSymbol(i);
      if(sym == symbol)
        {
         // position with appropriate ORDER_MAGIC, symbol and order type
         if(PositionGetInteger(POSITION_MAGIC) == iMagicNumber)
            exists = true;
        }
     }
   if(exists == false)
     {
      trade.Sell(Lot,symbol,bid,SL,TP,Commentary);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   return;
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
bool CheckVolumeValue(string symbol, double volume)
  {
   double min_volume=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
      return(false);

   double max_volume=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
      return(false);

   double volume_step=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
      return(false);

   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
  {
//--- Getting the opening price
   MqlTick mqltick;
   SymbolInfoTick(symb,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL)
      price=mqltick.bid;
//--- values of the required and free margin
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//--- call of the checking function
   if(!OrderCalcMargin(type,symb,lots,price,margin))
     {
      //--- something went wrong, report and return false
      return(false);
     }
//--- if there are insufficient funds to perform the operation
   if(margin>free_margin)
     {
      //--- report the error and return false
      return(false);
     }
//--- checking successful
   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Timer()
  {
   MqlDateTime currTime;
   TimeGMT(currTime);
   int hour0 = currTime.hour;

   if(StartTime < FinishTime)
      if(hour0 < StartTime || hour0 >= FinishTime)
         return (false);

   if(StartTime > FinishTime)
      if(hour0 >= FinishTime || hour0 < StartTime)
         return(false);

   return (true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trailing(string symbol)
  {
   int b=0,s=0;
   ulong TicketB=0,TicketS=0;
   double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int StopLevel =(int)SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
   double TS = TrailingStop*point;
   double TST = TrailingStep*point;
   if(TS <= StopLevel*point)
      TS = StopLevel*point;
   else
      TS = TS;
   if(TST <= StopLevel*point)
      TST = StopLevel*point;
   else
      TST = TST;

   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==symbol)
            if(m_position.Magic()==iMagicNumber)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  b++;
                  TicketB=m_position.Ticket();
                 }
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  s++;
                  TicketS=m_position.Ticket();
                 }
              }
//---
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==symbol)
            if(m_position.Magic()==iMagicNumber)
              {
               if(b>0)
                 {
                  if(m_position.StopLoss() <  m_position.PriceOpen())
                    {
                     if(bid - m_position.PriceOpen() > TS+TST-1*point)
                       {
                        trade.PositionModify(TicketB,bid-TS,m_position.TakeProfit());
                       }
                    }
                  else
                     if(m_position.StopLoss() >  m_position.PriceOpen())
                       {
                        if(bid -m_position.StopLoss() > TST+(5*point))
                          {
                           trade.PositionModify(TicketB,bid-TST,m_position.TakeProfit());
                          }
                       }
                 }
               else
                  if(s>0)
                    {
                     if(m_position.StopLoss() >  m_position.PriceOpen())
                       {
                        if(m_position.PriceOpen() - ask > TS+TST-1*point)
                          {
                           trade.PositionModify(TicketS,ask+TS,m_position.TakeProfit());
                          }
                       }
                     else
                        if(m_position.StopLoss() <  m_position.PriceOpen())
                          {
                           if(m_position.StopLoss() - ask > TST+(5*point))
                             {
                              trade.PositionModify(TicketS,ask+TST,m_position.TakeProfit());
                             }
                          }
                    }
              }
  }
//+------------------------------------------------------------------+
bool Refresh(string symbol)
  {
   long tmp_long=0;

   double            m_tick_value;                 // symbol tick value
   double            m_tick_value_profit;          // symbol tick value profit
   double            m_tick_value_loss;            // symbol tick value loss
   double            m_tick_size;                  // symbol tick size
   double            m_contract_size;              // symbol contract size
   double            m_lots_min;                   // symbol lots min
   double            m_lots_max;                   // symbol lots max
   double            m_lots_step;                  // symbol lots step
   double            m_lots_limit;                 // symbol lots limit
   double            m_swap_long;                  // symbol swap long
   double            m_swap_short;                 // symbol swap short
   double            m_margin_initial;             // symbol margin initial
   double            m_margin_maintenance;         // symbol margin maintenance
   bool              m_margin_hedged_use_leg;      // calculate hedged margin using larger leg
   double            m_margin_hedged;              // symbol margin hedged
   int               m_trade_time_flags;           // symbol trade time flags
   int               m_trade_fill_flags;           // symbol trade fill flags
   ENUM_SYMBOL_TRADE_EXECUTION m_trade_execution;  // symbol trade execution
   ENUM_SYMBOL_CALC_MODE m_trade_calcmode;         // symbol trade calcmode
   ENUM_SYMBOL_TRADE_MODE m_trade_mode;            // symbol trade mode
   ENUM_SYMBOL_SWAP_MODE m_swap_mode;              // symbol swap mode
   ENUM_DAY_OF_WEEK  m_swap3;                      // symbol swap3
   int               m_digits;                     // symbol digits
   int               m_order_mode;                 // symbol valid orders
   double            m_point;                      // symbol point
//---

   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,m_point))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE,m_tick_value))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE_PROFIT,m_tick_value_profit))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE_LOSS,m_tick_value_loss))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE,m_tick_size))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE,m_contract_size))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,m_lots_min))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,m_lots_max))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,m_lots_step))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_LIMIT,m_lots_limit))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG,m_swap_long))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT,m_swap_short))
      return(false);
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,tmp_long))
      return(false);
   m_digits=(int)tmp_long;
   if(!SymbolInfoInteger(symbol,SYMBOL_ORDER_MODE,tmp_long))
      return(false);
   m_order_mode=(int)tmp_long;
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_EXEMODE,tmp_long))
      return(false);
   m_trade_execution=(ENUM_SYMBOL_TRADE_EXECUTION)tmp_long;
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE,tmp_long))
      return(false);
   m_trade_calcmode=(ENUM_SYMBOL_CALC_MODE)tmp_long;
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_MODE,tmp_long))
      return(false);
   m_trade_mode=(ENUM_SYMBOL_TRADE_MODE)tmp_long;
   if(!SymbolInfoInteger(symbol,SYMBOL_SWAP_MODE,tmp_long))
      return(false);
   m_swap_mode=(ENUM_SYMBOL_SWAP_MODE)tmp_long;
   if(!SymbolInfoInteger(symbol,SYMBOL_SWAP_ROLLOVER3DAYS,tmp_long))
      return(false);
   m_swap3=(ENUM_DAY_OF_WEEK)tmp_long;
   if(!SymbolInfoDouble(symbol,SYMBOL_MARGIN_INITIAL,m_margin_initial))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_MARGIN_MAINTENANCE,m_margin_maintenance))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_MARGIN_HEDGED,m_margin_hedged))
      return(false);
   if(!SymbolInfoInteger(symbol,SYMBOL_MARGIN_HEDGED_USE_LEG,tmp_long))
      return(false);
   m_margin_hedged_use_leg=(bool)tmp_long;
   if(!SymbolInfoInteger(symbol,SYMBOL_EXPIRATION_MODE,tmp_long))
      return(false);
   m_trade_time_flags=(int)tmp_long;
   if(!SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE,tmp_long))
      return(false);
   m_trade_fill_flags=(int)tmp_long;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
