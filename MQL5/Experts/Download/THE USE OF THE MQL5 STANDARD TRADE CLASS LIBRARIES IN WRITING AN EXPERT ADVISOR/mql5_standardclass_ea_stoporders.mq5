//+------------------------------------------------------------------+
//|                             mql5_standardclass_ea_stoporders.mq5 |
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
//--- The SymbolInfo Class
#include <Trade\SymbolInfo.mqh>
//--- The OrderInfo Class
#include <Trade\OrderInfo.mqh>
//+------------------------------------------------------------------+
//|  Âõîäíûå ïàðàìåòðû                                               |
//+------------------------------------------------------------------+
input int      StopLoss=30;      // Stop Loss
input int      TakeProfit=60;    // Take Profit
input int      ADX_Period=14;    // Ïåðèîä ADX
input int      MA_Period=15;     // Ïåðèîä Moving Average
input ulong    EA_Magic=99977;   // Magic Number ñîâåòíèêà
input double   Adx_Min=25.0;     // Ìèíèìàëüíîå çíà÷åíèå ADX
input double   Lot=0.1;          // Êîëè÷åñòâî ëîòîâ äëÿ òîðãîâëè
input ulong    dev=100;          // Ïðîñêàëüçûâàíèå 
//+------------------------------------------------------------------+
//|  Äðóãèå ïîëåçíûå ïàðàìåòðû                                       |
//+------------------------------------------------------------------+
int adxHandle; //--- õýíäë íàøåãî èíäèêàòîðà ADX
int maHandle;  //--- õýíäë íàøåãî èíäèêàòîðà Moving Average
double plsDI[],minDI[],adxVal[]; //--- äèíàìè÷åñêèå ìàññèâû äëÿ õðàíåíèÿ çíà÷åíèé +DI, -DI è ADX êàæäîãî áàðà
double maVal[]; //--- äèíàìè÷åñêèé ìàññèâ äëÿ õðàíåíèÿ çíà÷åíèé èíäèêàòîðà Moving Average äëÿ êàæäîãî áàðà
double p_close; //--- ïåðåìåííàÿ äëÿ õðàíåíèÿ òåêóùèõ çíà÷åíèé öåíû çàêðûòèÿ áàðà
int STP,TKP;    //--- áóäóò èñïîëüçîâàòüñÿ äëÿ Stop Loss, Take Profit
double TPC;     //--- áóäåò èñïîëüçîâàí äëÿ êîíòðîëÿ ìàðæè

//--- Define the MQL5 MqlRates Structure we will use for our trade
MqlRates mrate[];     // To be used to store the prices, volumes and spread of each bar

//+------------------------------------------------------------------+
//|  CREATE CLASS OBJECTS                                            |
//+------------------------------------------------------------------+
//--- The CTrade Class Object
CTrade mytrade;
//--- The CPositionInfo Class Object
CPositionInfo myposition;
//--- The CSymbolInfo Class Object
CSymbolInfo mysymbol;
//--- The COrderInfo Class Object
COrderInfo myorder;
//+------------------------------------------------------------------+
//| Ïîëüçîâàòåëüñêèå ôóíêöèè                                         |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|  Ïðîâåðÿåò óñëîâèÿ íà ïîêóïêó                                    |
//+------------------------------------------------------------------+
bool checkBuy()
  {
   bool dobuy=false;
   if((maVal[0]>maVal[1]) && (maVal[1]>maVal[2]) && (p_close>maVal[1]))
     {
      //--- MA ðàñòåò è öåíà çàêðûòèÿ ïðåäûäóùåãî áàðà âûøå MA
      if((adxVal[1]>Adx_Min) && (plsDI[1]>minDI[1]))
        {
         //--- çíà÷åíèå ADX áîëüøå, ÷åì ìèíèìàëüíî òðåáóåìîå, è +DI áîëüøå, ÷åì -DI
         dobuy=true;
        }
     }
   return(dobuy);
  }
//+------------------------------------------------------------------+
//|  Ïðîâåðÿåò óñëîâèÿ íà ïðîäàæó                                    |
//+------------------------------------------------------------------+
bool checkSell()
  {
   bool dosell=false;
   if((maVal[0]<maVal[1]) && (maVal[1]<maVal[2]) && (p_close<maVal[1]))
     {
      //--- MA ïàäàåò è öåíà çàêðûòèÿ ïðåäûäóùåãî áàðà íèæå MA
      if((adxVal[1]>Adx_Min) && (minDI[1]>plsDI[1]))
        {
         //--- çíà÷åíèå ADX áîëüøå, ÷åì ìèíèìàëüíî òðåáóåìîå, è -DI áîëüøå, ÷åì +DI
         dosell=true;
        }
     }
   return(dosell);
  }
//+------------------------------------------------------------------+
//|  Count Total Orders for this expert/symbol                             |
//+------------------------------------------------------------------+
int CountOrders()
  {
   int mark=0;

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(myorder.Select(OrderGetTicket(i)))
        {
         if(myorder.Magic()==EA_Magic && myorder.Symbol()==_Symbol) mark++;
        }
     }
   return(mark);
  }
//+------------------------------------------------------------------+
//| Checks and Deletes a pending order                                |
//+------------------------------------------------------------------+
bool DeletePending()
  {
   bool marker=false;
//--- check all pending orders
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(myorder.Select(OrderGetTicket(i)))
        {
         if(myorder.Magic()==EA_Magic && myorder.Symbol()==_Symbol)
           {
            //--- check if order has stayed more than two bars time
            if(myorder.TimeSetup()<mrate[2].time)
              {
               //--- delete this pending order and check if we deleted this order successfully?
                if(mytrade.OrderDelete(myorder.Ticket())) //Request successfully completed 
                  {
                    Alert("A pending order with ticket #", myorder.Ticket(), " has been successfully deleted!!");
                    marker=true;
                  }
                 else
                  {
                    Alert("The pending order # ",myorder.Ticket(),
                             " delete request could not be completed - error: ",mytrade.ResultRetcodeDescription());
                  }

              }
           }
        }
     }
   return(marker);
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- óñòàíîâêà íàèìåíîâàíèÿ ñèìâîëà äëÿ îáúåêòà êëàññà CSymbolInfo
   mysymbol.Name(_Symbol);
//--- óñòàíîâêà èäåíòèôèêàòîðà ýêñïåðòà (Expert Magic No) â îáúåêòå êëàññà CTrade
   mytrade.SetExpertMagicNumber(EA_Magic);
//--- óñòàíîâêà ìàêñèìàëüíî äîïóñòèìîãî ïðîñêàëüçûâàíèÿ â îáúåêòå êëàññà CTrade
   mytrade.SetDeviationInPoints(dev);
//--- ïîëó÷àåì õýíäë èíäèêàòîðà ADX
   adxHandle=iADX(NULL,0,ADX_Period);
//--- ïîëó÷àåì õýíäë èíäèêàòîðà Moving Average
   maHandle=iMA(_Symbol,Period(),MA_Period,0,MODE_EMA,PRICE_CLOSE);
//--- åñëè õýíäëû íåâåðíûå
   if(adxHandle<0 || maHandle<0)
     {
      Alert("Îøèáêà ñîçäàíèÿ õýíëîâ èíäèêàòîðîâ MA è ADX - îøèáêà: ",GetLastError(),"!!");
      return(1);
     }
//--- Áóäåì ïîääåðæèâàòü áðîêåðîâ ñ 5/3 çíàêàìè
   STP = StopLoss;
   TKP = TakeProfit;
   if(_Digits==5 || _Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Îñâîáîæäàåì õýäëû íàøèõ èíäèêàòîðîâ
   IndicatorRelease(adxHandle);
   IndicatorRelease(maHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
/*
     Óáåäèìñÿ â òîì, ÷òî çíà÷åíèÿ íàøèõ ìàññèâîâ äëÿ êîòèðîâîê, 
     çíà÷åíèé èíäèêàòîðà ADX è MA óêàçàíû êàê òàéìñåðèè
*/
//--- ìàññèâ êîòèðîâîê
   ArraySetAsSeries(mrate,true);
//--- ìàññèâ çíà÷åíèé ADX
   ArraySetAsSeries(adxVal,true);
//--- ìàññèâ çíà÷åíèé MA
   ArraySetAsSeries(maVal,true);
//--- ìàññèâ çíà÷åíèé -DI
   ArraySetAsSeries(minDI,true);
//--- ìàññèâ çíà÷åíèé +DI
   ArraySetAsSeries(plsDI,true);
//

//--- Ïîëó÷èì ïîñëåäíèå êîòèðîâêè, èñïîëüçóÿ ôóíêöèþ îáúåêò êëàññà CSymbolInfo
   if(!mysymbol.RefreshRates())
     {
      Alert("Îøèáêà îáíîâëåíèÿ êîòèðîâîê - îøèáêà:",GetLastError(),"!!");
      return;
     }

//--- Êîïèðóåì äàííûå ïî 4-ì ïîñëåäíèì áàðàì
   if(CopyRates(_Symbol,_Period,0,4,mrate)<0)
     {
      Alert("Îøèáêà êîïèðîâàíèÿ èñòîðè÷åñêèõ êîòèðîâîê - îøèáêà:",GetLastError(),"!!");
      return;
     }

//--- ñîâåòíèê äîëæåí ïðîâåðÿòü óñëîâèÿ òîðãîâëè òîëüêî ïðè ïîÿâëåíèè íîâîãî áàðà
//--- îáúÿâèì ñòàòè÷åñêóþ ïåðåìåííóþ òèïà datetime
   static datetime Prev_time;
//--- îáúÿâèì ìàññèâ èç îäíîãî ýëåìåíòà äëÿ õðàíåíèÿ âðåìåíè íà÷àëà òåêóùåãî áàðà (áàð 0)
   datetime Bar_time[1];
//--- êîïèðóåì âðåìÿ òåêóùåãî áàðà
   Bar_time[0]=mrate[0].time;
//--- åñëè îáà âðåìåíè ðàâíû, íîâûé áàð íå ïîÿâèëñÿ
   if(Prev_time==Bar_time[0])
     {
      return;
     }
//--- ñîõðàíèì âðåìÿ â ñòàòè÷åñêîé ïåðåìåííîé
   Prev_time=Bar_time[0];

//--- êîïèðóåì íîâûå çíà÷åíèÿ èíäèêàòîðîâ â ìàññèâû, èñïîëüçóÿ õýíäëû èíäèêàòîðîâ
   if(CopyBuffer(adxHandle,0,0,5,adxVal)<1 || CopyBuffer(adxHandle,1,0,5,plsDI)<1
      || CopyBuffer(adxHandle,2,0,5,minDI)<1)
     {
      Alert("Îøèáêà êîïèðîâàíèÿ áóôåðîâ èíäèêàòîðà ADX - îøèáêà:",GetLastError(),"!!");
      return;
     }
   if(CopyBuffer(maHandle,0,0,5,maVal)<1)
     {
      Alert("Îøèáêà êîïèðîâàíèÿ áóôåðà èíäèêàòîðà Moving Average - îøèáêà:",GetLastError());
      return;
     }
//--- îøèáîê íåò, ïðîäîëæàåì
//--- êîïèðóåì öåíó çàêðûòèÿ ïðåäûäóùåãî áàðà (áàðà, ïðåäøåñòâóþùåãî òåêóùåìó, ò.å. áàðà 1)

   p_close=mrate[1].close;  //--- öåíà çàêðûòèÿ áàðà 1

   // do we have more than 3 already placed pending orders
   if (CountOrders()>3) 
     {
        DeletePending(); 
        return;  
     }
     
   //--- åñòü ëè îòêðûòàÿ ïîçèöèÿ?
   bool Buy_opened=false,Sell_opened=false;
   if(myposition.Select(_Symbol)==true) //--- åñòü îòêðûòàÿ ïîçèöèÿ
     {
      if(myposition.PositionType()==POSITION_TYPE_BUY)
        {
         Buy_opened=true;  //--- äëèííàÿ (buy) ïîçèöèÿ
         return;           //--- âûõîäèì è æäåì íîâîãî áàðà
        }
      else if(myposition.PositionType()==POSITION_TYPE_SELL)
        {
         Sell_opened=true; //--- êîðîòêàÿ (sell) ïîçèöèÿ
         return;           //--- âûõîäèì è æäåì íîâîãî áàðà
        }

     }
/*
    Ïðîâåðêà óñëîâèé ïîêóïêè : MA ðàñòåò, 
    ïðåäûäóùàÿ öåíà çàêðûòèÿ áîëüøå åå, ADX > adxmin, +DI > -DI
*/
    if(checkBuy()==true)
        {
         Alert("Total Pending Orders now is :",CountOrders(),"!!");
         //--- any opened Buy position?
         if(Buy_opened)
           {
            Alert("We already have a Buy position!!!");
            return;    //--- Don't open a new Sell Position
           }
         //Buy price = bar 1 High + 2 pip + spread
         int sprd=mysymbol.Spread();
         double bprice =mrate[1].high + 10*_Point + sprd*_Point;
         double mprice=NormalizeDouble(bprice,_Digits);               //--- Buy price
         double stloss = NormalizeDouble(bprice - STP*_Point,_Digits); //--- Stop Loss
         double tprofit = NormalizeDouble(bprice+ TKP*_Point,_Digits); //--- Take Profit
         //--- open BuyStop order
         if(mytrade.BuyStop(Lot,mprice,_Symbol,stloss,tprofit))
         //if(mytrade.OrderOpen(_Symbol,ORDER_TYPE_BUY_STOP,Lot,0.0,bprice,stloss,tprofit,ORDER_TIME_GTC,0)) 
           {
            //--- Request is completed or order placed
            Alert("A BuyStop order has been successfully placed with Ticket#:",mytrade.ResultOrder(),"!!");
            return;
           }
         else
           {
            Alert("The BuyStop order request at vol:",mytrade.RequestVolume(), 
                    ", sl:", mytrade.RequestSL(),", tp:",mytrade.RequestTP(),
                  ", price:", mytrade.RequestPrice(), 
                    " could not be completed -error:",mytrade.ResultRetcodeDescription());
            return;
           }
        }

/*
    2. Ïðîâåðêà óñëîâèé íà ïðîäàæó : MA ïàäàåò, 
    ïðåäûäóùàÿ öåíà çàêðûòèÿ íèæå íàõîäèòñÿ åå, ADX > adxmin, -DI > +DI
*/
      if(checkSell()==true)
        {
         Alert("Total Pending Orders now is :",CountOrders(),"!!");
         //--- any opened Sell position?
         if(Sell_opened)
           {
            Alert("We already have a Sell position!!!");
            return;    //--- Wait for a new bar
           }
         //--- Sell price = bar 1 Low - 2 pip 
         double sprice=mrate[1].low-10*_Point;
         double slprice=NormalizeDouble(sprice,_Digits);            //--- Sell price
         double ssloss=NormalizeDouble(sprice+STP*_Point,_Digits);   //--- Stop Loss
         double stprofit=NormalizeDouble(sprice-TKP*_Point,_Digits); //--- Take Profit
         //--- Open SellStop Order
         if(mytrade.SellStop(Lot,slprice,_Symbol,ssloss,stprofit))
         //if(mytrade.OrderOpen(_Symbol,ORDER_TYPE_SELL_STOP,Lot,0.0,slprice,ssloss,stprofit,ORDER_TIME_GTC,0)) 
           {
            //--- Request is completed or order placed
            Alert("A SellStop order has been successfully placed with Ticket#:",mytrade.ResultOrder(),"!!");
            return;
           }
         else
           {
            Alert("The SellStop order request at Vol:",mytrade.RequestVolume(), 
                 ", sl:", mytrade.RequestSL(),", tp:",mytrade.RequestTP(), 
                   ", price:", mytrade.RequestPrice(), 
                   " could not be completed -error:",mytrade.ResultRetcodeDescription());
            return;
           }
        }
  }
//+------------------------------------------------------------------+