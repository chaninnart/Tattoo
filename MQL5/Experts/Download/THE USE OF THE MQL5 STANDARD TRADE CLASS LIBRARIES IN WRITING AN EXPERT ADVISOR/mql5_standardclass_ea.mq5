//+------------------------------------------------------------------+
//|                                        mql5_standardclass_ea.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|  Include ALL classes that will be used                           |
//+------------------------------------------------------------------+
//--- The Trade Class
#include <Trade\Trade.mqh>
//--- The PositionInfo Class
#include <Trade\PositionInfo.mqh>
//--- The AccountInfo Class
#include <Trade\AccountInfo.mqh>
//--- The SymbolInfo Class
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//|  INPUT PARAMETERS                                              |
//+------------------------------------------------------------------+
input int      StopLoss=100;     // Stop Loss
input int      TakeProfit=240;   // Take Profit
input int      ADX_Period=15;    // ADX Period
input int      MA_Period=15;     // Moving Average Period
input ulong    EA_Magic=99977;   // EA Magic Number
input double   Adx_Min=24.0;     // Minimum ADX Value
input double   Lot=0.1;          // Lots to Trade
input ulong    dev=100;          // Deviation 
input long     Trail_point=32;   // Points to increase TP/SL
input int      Min_Bars = 20;    // Minimum bars required for Expert Advisor to trade
input double   TradePct = 25;    // Percentage of Account Free Margin to trade
//+------------------------------------------------------------------+
//|  OTHER USEFUL PARAMETERS                                         |
//+------------------------------------------------------------------+
int adxHandle;                     // handle for our ADX indicator
int maHandle;                    // handle for our Moving Average indicator
double plsDI[],minDI[],adxVal[]; // Dynamic arrays to hold the values of +DI, -DI and ADX values for each bars
double maVal[];                  // Dynamic array to hold the values of Moving Average for each bars
double p_close;                    // Variable to store the close value of a bar
int STP, TKP;                   // To be used for Stop Loss, Take Profit 
double TPC;                        // To be used for Trade percent
//+------------------------------------------------------------------+
//|  CREATE CLASS OBJECTS                                            |
//+------------------------------------------------------------------+
//--- The Trade Class Object
CTrade mytrade;
//--- The PositionInfo Class Object
CPositionInfo myposition;
//--- The AccountInfo Class Object
CAccountInfo myaccount;
//--- The SymbolInfo Class Object
CSymbolInfo mysymbol;
//+------------------------------------------------------------------+
//| Ïîëüçîâàòåëüñêèå ôóíêöèè                                         |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|  Checks if our Expert Advisor can go ahead and perform trading   |
//+------------------------------------------------------------------+
bool checkTrading()
{
  bool can_trade = false;
  // check if terminal is syncronized with server, etc
  if (myaccount.TradeAllowed() && myaccount.TradeExpert() && mysymbol.IsSynchronized())
  {
    // do we have enough bars?
    int mbars = Bars(_Symbol,_Period);
    if(mbars >Min_Bars)
    {
      can_trade = true;
    }
  }
  return(can_trade);
}
//+------------------------------------------------------------------+
//|  Confirms if margin is enough to open an order
//+------------------------------------------------------------------+
bool ConfirmMargin(ENUM_ORDER_TYPE otype,double price)
  {
   bool confirm = false;
   double lot_price = myaccount.MarginCheck(_Symbol,otype,Lot,price); // Lot price/ Margin    
   double act_f_mag = myaccount.FreeMargin();                        // Account free margin 
   // Check if margin required is okay based on setting
   if(MathFloor(act_f_mag*TPC)>MathFloor(lot_price))
     {
      confirm =true;
     }
    return(confirm);
  }
//+------------------------------------------------------------------+
//|  Checks for a Buy trade Condition                                |
//+------------------------------------------------------------------+
bool checkBuy()
{
  bool dobuy = false;
  if ((maVal[0]>maVal[1]) && (maVal[1]>maVal[2]) &&(p_close > maVal[1]))
  {
    // MA increases upwards and previous price closed above MA
    if ((adxVal[1]>Adx_Min)&& (plsDI[1]>minDI[1]))
    {
      // ADX is greater than minimum and +DI is greater tha -DI for ADX
      dobuy = true;
    }
  }
  return(dobuy);
}
//+------------------------------------------------------------------+
//|  Checks for a Sell trade Condition                               |
//+------------------------------------------------------------------+
bool checkSell()
{
  bool dosell = false;
  if ((maVal[0]<maVal[1]) && (maVal[1]<maVal[2]) &&(p_close < maVal[1]))
  {
    // MA decreases downwards and previuos price closed below MA
    if ((adxVal[1]>Adx_Min)&& (minDI[1]>plsDI[1]))
    {
      // ADX is greater than minimum and -DI is greater tha +DI for ADX
      dosell = true;
    }
  }
  return(dosell);
} 
//+------------------------------------------------------------------+
//|  Checks if an Open position can be closed                        |
//+------------------------------------------------------------------+
bool checkClosePos(string ptype, double Closeprice)
{
   bool mark = false;
   if (ptype=="BUY")
   {
      // Can we close this position
     if (Closeprice < maVal[1]) // Previous price close below MA
      {
         mark = true;
      }
   }
   if (ptype=="SELL")
   {
      // Can we close this position
      if (Closeprice > maVal[1]) // Previous price close above MA
      {
         mark = true;
      }
   }
   return(mark);
}
//+------------------------------------------------------------------+
//| Checks and closes an open position                               |
//+------------------------------------------------------------------+
bool ClosePosition(string ptype,double clp)
  {
   bool marker=false;
     
      if(myposition.Select(_Symbol)==true)
        {
         if(myposition.Magic()==EA_Magic && myposition.Symbol()==_Symbol)
           {
            //--- Check if we can close this position
            if(checkClosePos(ptype,clp)==true)
              {
               //--- close this position and check if we close position successfully?
               if(mytrade.PositionClose(_Symbol)) //--- Request successfully completed 
                 {
                  Alert("An opened position has been successfully closed!!");
                  marker=true;
                 }
               else
                 {
                  Alert("The position close request could not be completed - error: ",
                       mytrade.ResultRetcodeDescription());
                 }
              }
           }
        }
      return(marker);
     }
//+------------------------------------------------------------------+
//|  Checks if we can modify an open position                        |
//+------------------------------------------------------------------+
bool CheckModify(string otype,double cprc)
{
   bool check=false;
   if (otype=="BUY")
   {
      if ((maVal[2]<maVal[1]) && (maVal[1]<maVal[0]) && (cprc>maVal[1]) && (adxVal[1]>Adx_Min))
      {
         check=true;
      }
   }
   else if (otype=="SELL")
   {
      if ((maVal[2]>maVal[1]) && (maVal[1]>maVal[0]) && (cprc<maVal[1]) && (adxVal[1]>Adx_Min))
      {
         check=true;
      }
   }
   return(check);
} 
//+------------------------------------------------------------------+
//| Modifies an open position                                        |
//+------------------------------------------------------------------+
   void Modify(string ptype,double stpl,double tkpf)
     {
       //--- New Stop Loss, new Take profit, Bid price, Ask Price
      double ntp,nsl,pbid,pask;                  
      long tsp=Trail_point;
       //--- adjust for 5 & 3 digit prices
      if(_Digits==5 || _Digits==3) tsp=tsp*10;   
       //--- Stops Level
      long stplevel= mysymbol.StopsLevel();      
       //--- Trail point must not be less than stops level
      if(tsp<stplevel) tsp=stplevel;
      if(ptype=="BUY")
        {
          //--- current bid price
         pbid=mysymbol.Bid();           
         if(tkpf-pbid<=stplevel*_Point)
           {
            //--- distance to takeprofit less or equal to Stops level? increase takeprofit
            ntp = pbid + tsp*_Point;
            nsl = pbid - tsp*_Point;
           }
         else
           {
            //--- distance to takeprofit higher than Stops level? dont touch takeprofit
            ntp = tkpf;
            nsl = pbid - tsp*_Point;
           }
        }
      else //--- this is SELL
        {
          //--- current ask price
         pask=mysymbol.Ask();            
         if(pask-tkpf<=stplevel*_Point)
           {
            ntp = pask - tsp*_Point;
            nsl = pask + tsp*_Point;
           }
         else
           {
            ntp = tkpf;
            nsl = pask + tsp*_Point;
           }
        }
      //--- modify and check result
      if(mytrade.PositionModify(_Symbol,nsl,ntp))  
        {
          //--- Request successfully completed    
         Alert("An opened position has been successfully modified!!");
         return;
        }
      else
        {
         Alert("The position modify request could not be completed - error: ",
               mytrade.ResultRetcodeDescription());
         return;
        }

     }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
   int OnInit()
     {
       //--- set the symbol name for our SymbolInfo Object
         mysymbol.Name(_Symbol);
      // Set Expert Advisor Magic No using our Trade Class Object
         mytrade.SetExpertMagicNumber(EA_Magic);
      // Set Maximum Deviation using our Trade class object
         mytrade.SetDeviationInPoints(dev);
      //--- Get handle for ADX indicator
         adxHandle=iADX(NULL,0,ADX_Period);
      //--- Get the handle for Moving Average indicator
         maHandle=iMA(_Symbol,Period(),MA_Period,0,MODE_EMA,PRICE_CLOSE);
      //--- What if handle returns Invalid Handle
         if(adxHandle<0 || maHandle<0)
           {
            Alert("Error Creating Handles for MA, ADX indicators - error: ",GetLastError(),"!!");
            return(1);
           }
         STP = StopLoss;
         TKP = TakeProfit;
      //--- Let us handle brokers that offers 5 or 3 digit prices instead of 4
         if(_Digits==5 || _Digits==3)
           {
            STP = STP*10;
            TKP = TKP*10;
           }
         
      //--- Set trade percent
          TPC = TradePct;
          TPC = TPC/100;
      //---
      //---
      return(0);
     }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
   void OnDeinit(const int reason)
     {
      //--- Release our indicator handles
      IndicatorRelease(adxHandle);
      IndicatorRelease(maHandle);

     }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
   void OnTick()
     {
      //--- check if EA can trade
          if (checkTrading() == false) 
         {
            Alert("EA cannot trade because certain trade requirements are not meant");
            return;
         }
      //--- Define the MQL5 MqlRates Structure we will use for our trade
         MqlRates mrate[];          // To be used to store the prices, volumes and spread of each bar
      /*
           Let's make sure our arrays values for the Rates, ADX Values and MA values 
           is store serially similar to the timeseries array
      */
      // the rates arrays
         ArraySetAsSeries(mrate,true);
      // the ADX values arrays
         ArraySetAsSeries(adxVal,true);
      // the MA values arrays
         ArraySetAsSeries(maVal,true);
      // the minDI values array
         ArraySetAsSeries(minDI,true);
      // the plsDI values array
         ArraySetAsSeries(plsDI,true);

       //--- Get the last price quote using the SymbolInfo class object function
         if (!mysymbol.RefreshRates())
           {
            Alert("Error getting the latest price quote - error:",GetLastError(),"!!");
            return;
           }
      
      //--- Get the details of the latest 3 bars
         if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
           {
            Alert("Error copying rates/history data - error:",GetLastError(),"!!");
            return;
           }
      
      //--- EA should only check for new trade if we have a new bar
      // lets declare a static datetime variable
         static datetime Prev_time;
      // lest get the start time for the current bar (Bar 0)
         datetime Bar_time[1];
         //copy the current bar time
         Bar_time[0] = mrate[0].time;
      // We don't have a new bar when both times are the same
         if(Prev_time==Bar_time[0])
           {
            return;
           }
      //Save time into static varaiable, 
         Prev_time = Bar_time[0]; 

       //--- Copy the new values of our indicators to buffers (arrays) using the handle
         if(CopyBuffer(adxHandle,0,0,3,adxVal)<3 || CopyBuffer(adxHandle,1,0,3,plsDI)<3
            || CopyBuffer(adxHandle,2,0,3,minDI)<3)
           {
            Alert("Error copying ADX indicator Buffers - error:",GetLastError(),"!!");
            return;
           }
         if(CopyBuffer(maHandle,0,0,3,maVal)<3)
           {
            Alert("Error copying Moving Average indicator buffer - error:",GetLastError());
            return;
           }
      //--- we have no errors, so continue
      // Copy the bar close price for the previous bar prior to the current bar, that is Bar 1
      
         p_close=mrate[1].close;  // bar 1 close price
         
      //--- Do we have positions opened already?
        bool Buy_opened = false, Sell_opened=false; 
         if (myposition.Select(_Symbol) ==true)  // we have an opened position
          {
            if (myposition.Type()== POSITION_TYPE_BUY)
             {
                  Buy_opened = true;  //It is a Buy
                // Get Position StopLoss and Take Profit
                 double buysl = myposition.StopLoss();      // Buy position Stop Loss
                 double buytp = myposition.TakeProfit();    // Buy position Take Profit
                 // Check if we can close/modify position
                 if (ClosePosition("BUY",p_close)==true)
                   {
                      Buy_opened = false;   // position has been closed
                      return; // wait for new bar
                   }
                 else
                 {
                    if (CheckModify("BUY",p_close)==true) // We can modify position
                    {
                        Modify("BUY",buysl,buytp);
                        return; // wait for new bar
                    }
                 } 
             }
            else if(myposition.Type() == POSITION_TYPE_SELL)
             {
                  Sell_opened = true; // It is a Sell
                  // Get Position StopLoss and Take Profit
                  double sellsl = myposition.StopLoss();    // Sell position Stop Loss
                  double selltp = myposition.TakeProfit();  // Sell position Take Profit
                   if (ClosePosition("SELL",p_close)==true)
                   {
                     Sell_opened = false;  // position has been closed
                     return;   // wait for new bar
                   }
                   else
                   {
                       if (CheckModify("SELL",p_close)==true) // We can modify position
                       {
                           Modify("SELL",sellsl,selltp);
                           return;  //wait for new bar
                       }
                   } 
             }
          } 
      if(checkBuy()==true)
        {
         //--- any opened Buy position?
         if(Buy_opened)
           {
            Alert("We already have a Buy position!!!");
            return;    //--- Don't open a new Sell Position
           }

         double mprice=NormalizeDouble(mysymbol.Ask(),_Digits);                //--- latest ask price
         double stloss = NormalizeDouble(mysymbol.Ask() - STP*_Point,_Digits); //--- Stop Loss
         double tprofit = NormalizeDouble(mysymbol.Ask()+ TKP*_Point,_Digits); //--- Take Profit
         //--- check margin
         if(ConfirmMargin(ORDER_TYPE_BUY,mprice)==false)
           {
            Alert("You do not have enough money to place this trade based on your setting");
            return;
           }
         //--- open Buy position and check the result
         if(mytrade.Buy(Lot,_Symbol,mprice,stloss,tprofit))
         //if(mytrade.PositionOpen(_Symbol,ORDER_TYPE_BUY,Lot,mprice,stloss,tprofit)) 
           {
               //--- Request is completed or order placed
             Alert("A Buy order has been successfully placed with deal Ticket#:",
                  mytrade.ResultDeal(),"!!");
           }
         else
           {
            Alert("The Buy order request at vol:",mytrade.RequestVolume(), 
                  ", sl:", mytrade.RequestSL(),", tp:",mytrade.RequestTP(),
                  ", price:", mytrade.RequestPrice(), 
                     " could not be completed -error:",mytrade.ResultRetcodeDescription());
            return;
           }
        }
/*
    2. Or we can use the PositionOpen function, ADX > adxmin, -DI > +DI
*/
           if(checkSell()==true)
        {
         //--- any opened Sell position?
         if(Sell_opened)
           {
            Alert("We already have a Sell position!!!");
            return;    //--- Wait for a new bar
           }

         double sprice=NormalizeDouble(mysymbol.Bid(),_Digits);             //--- latest Bid price
         double ssloss=NormalizeDouble(mysymbol.Bid()+STP*_Point,_Digits);   //--- Stop Loss
         double stprofit=NormalizeDouble(mysymbol.Bid()-TKP*_Point,_Digits); //--- Take Profit
         //--- check margin
         if(ConfirmMargin(ORDER_TYPE_SELL,sprice)==false)
           {
            Alert("You do not have enough money to place this trade based on your setting");
            return;
           }
         //--- Open Sell position and check the result
         if(mytrade.Sell(Lot,_Symbol,sprice,ssloss,stprofit))
         //if(mytrade.PositionOpen(_Symbol,ORDER_TYPE_SELL,Lot,sprice,ssloss,stprofit))
           {
               //---Request is completed or order placed            
               Alert("A Sell order has been successfully placed with deal Ticket#:",mytrade.ResultDeal(),"!!");
           }
         else
           {
            Alert("The Sell order request at Vol:",mytrade.RequestVolume(), 
                    ", sl:", mytrade.RequestSL(),", tp:",mytrade.RequestTP(), 
                    ", price:", mytrade.RequestPrice(), 
                    " could not be completed -error:",mytrade.ResultRetcodeDescription());
            return;
           }

        }
     }
//+------------------------------------------------------------------+