//+------------------------------------------------------------------+
//|                                                    LogicHere.mq4 |
//|                                                       Chaninnart |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chaninnart"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern int MagicNumber=5652534;
extern double Lots =0.1;
extern double StopLoss=50;
extern double TakeProfit=50;
extern int TrailingStop=50;
extern int Slippage=3;
//+------------------------------------------------------------------+
//    expert start function
//+------------------------------------------------------------------+
int start()
{
  double MyPoint=Point;
  if(Digits==3 || Digits==5) MyPoint=Point*10;
  
  double TheStopLoss=0;
  double TheTakeProfit=0;
  if( TotalOrdersCount()==0 ) 
  {
     int result=0;
     if((iADX(NULL,PERIOD_M30,8,PRICE_OPEN,MODE_MAIN,0)>25)&&(iMA(NULL,PERIOD_M5,48,0,MODE_SMA,PRICE_OPEN,0)>Ask)) // Here is your open buy rule
     {
        result=OrderSend(Symbol(),OP_BUY,AdvancedMM(),Ask,Slippage,0,0,"EA Generator www.ForexEAdvisor.com",MagicNumber,0,Blue);
        if(result ==0){drawGreenUpArrowOnScreen(0);}
        if(result>0)
        {
         TheStopLoss=0;
         TheTakeProfit=0;
         if(TakeProfit>0) TheTakeProfit=Ask+TakeProfit*MyPoint;
         if(StopLoss>0) TheStopLoss=Ask-StopLoss*MyPoint;
         OrderSelect(result,SELECT_BY_TICKET);
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),0,Green);
        }
        return(0);
     }
  }
  
  for(int cnt=0;cnt<OrdersTotal();cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber 
         )  
        {
         if(OrderType()==OP_BUY)  
           {
              if((Low[0]<Low[1])&&(Low[0]<Low[2])&&(Low[0]<Low[3])&&(Low[0]<Low[4])) //here is your close buy rule
              {
                   OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
 drawYellowDownArrowOnScreen(0);
              }
            if(TrailingStop>0)  
              {                 
               if(Bid-OrderOpenPrice()>MyPoint*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-MyPoint*TrailingStop)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*MyPoint,OrderTakeProfit(),0,Green);
                     return(0);
                    }
                 }
              }
           }
         else 
           {
            if(TrailingStop>0)  
              {                 
               if((OrderOpenPrice()-Ask)>(MyPoint*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+MyPoint*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+MyPoint*TrailingStop,OrderTakeProfit(),0,Red);
                     return(0);
                    }
                 }
              }
           }
        }
     }
   return(0);
}

int TotalOrdersCount()
{
  int result=0;
  for(int i=0;i<OrdersTotal();i++)
  {
     OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber()==MagicNumber) result++;

   }
  return (result);
}
double AdvancedMM()
{
 int i;
 double AdvancedMMLots = 0;
 bool profit1=false;
 int SystemHistoryOrders=0;
  for( i=0;i<OrdersHistoryTotal();i++)
  {  OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY);
     if (OrderMagicNumber()==MagicNumber) SystemHistoryOrders++;
  }
 bool profit2=false;
 int LO=0;
 if(SystemHistoryOrders<2) return(Lots);
 for( i=OrdersHistoryTotal()-1;i>=0;i--)
  {
     if(OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY))
     if (OrderMagicNumber()==MagicNumber) 
     {
        if(OrderProfit()>=0 && profit1) return(Lots);
        if( LO==0)
        {  if(OrderProfit()>=0) profit1=true;
           if(OrderProfit()<0)  return(OrderLots());
           LO=1;
        }
        if(OrderProfit()>=0 && profit2) return(AdvancedMMLots);
        if(OrderProfit()>=0) profit2=true;
        if(OrderProfit()<0 ) 
        {   profit1=false;
            profit2=false;
            AdvancedMMLots+=OrderLots();
        }
     }
  }
 return(AdvancedMMLots);
}

void drawYellowDownArrowOnScreen(int index){ 
   int bar;
   bar=Bars;
   string name2 = "Dn"+string(bar);
   ObjectCreate(name2,OBJ_ARROW, 0, Time[index], High[index]+10*Point); 
   ObjectSet(name2, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name2, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
   ObjectSet(name2, OBJPROP_COLOR,Yellow);   
}
void drawGreenUpArrowOnScreen(int index){ 
   int bar;
   bar=Bars;
   string name2 = "Dn"+string(bar);
   ObjectCreate(name2,OBJ_ARROW, 0, Time[index], Low[index]-10*Point); 
   ObjectSet(name2, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name2, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
   ObjectSet(name2, OBJPROP_COLOR,Green);   
}