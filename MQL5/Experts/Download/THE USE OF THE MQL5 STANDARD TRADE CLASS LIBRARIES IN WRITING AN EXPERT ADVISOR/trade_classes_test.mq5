//+------------------------------------------------------------------+
//|                                           Trade_classes_test.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|  Include ALL classes that will be used                           |
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>     //--- CPositionInfo
#include <Trade\AccountInfo.mqh>      //--- CAccountInfî
#include <Trade\SymbolInfo.mqh>       //--- CSymbolInfo
#include <Trade\HistoryOrderInfo.mqh> //--- ÑHistoryOrderInfo
#include <Trade\OrderInfo.mqh>        //--- ÑOrderInfo
#include <Trade\DealInfo.mqh>         //--- ÑDealInfo
#include <Trade\Trade.mqh>            //--- CTrade
//+------------------------------------------------------------------+
//| Test of CAccountInfo class methods                               |
//+------------------------------------------------------------------+
void Test_CAccountInfo()
  {
//--- CAccountInfo class object
   CAccountInfo myaccount;

//--- returns account number, for example, 7770
   long accountno=myaccount.Login();
   Print("Login: ",accountno);

//--- returns "Demo trading account", "Real trading account" or "Contest trading account"
   string  acc_trading_mode=myaccount.TradeModeDescription();
   Print("Account trading mode: ",acc_trading_mode);

//--- returns leverage
   long acct_leverage=myaccount.Leverage();
   Print("Account leverage: ",acct_leverage);

   if(myaccount.TradeAllowed())
     {
      //--- trade allowed
      Print("Trade is allowed");
     }
   else
     {
      //--- trade not allowed
      Print("Trade is not allowed");
     }
   if(myaccount.TradeExpert())
     {
      //--- trade by Expert Advisors is allowed
      Print("Trade by Expert Advisors is allowed");
     }
   else
     {
      //--- trade by Expert Advisors is not allowed
      Print("Trade by Expert Advisors is not allowed");
     }

//--- get account balance in deposit currency
   double acc_balance=myaccount.Balance();
   Print("Account balance in deposit currency",acc_balance);

//--- get account profit in deposit currency
   double acc_profit=myaccount.Profit();
   Print("Account profit in deposit currency:",acc_profit);

//--- get account free margin
   double acc_free_margin=myaccount.FreeMargin();
   Print("Account free margin:",acc_free_margin);

//--- get account currency
   string acc_currency=myaccount.Currency();
   Print("Account currency:",acc_currency);

//--- get operation profit
   double operation_profit=myaccount.OrderProfitCheck(_Symbol,ORDER_TYPE_BUY,1.0,1.2950,1.3235);
   Print("Profit for buy of EURUSD 1.2950/1.3235: ",operation_profit);

//--- get margin, required for trade operation
   double margin_req=myaccount.MarginCheck(_Symbol,ORDER_TYPE_BUY,1.0,SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   Print("Margin, required for trade operation:",margin_req);

//--- get free margin, left after trade operation
   double f_margin=myaccount.FreeMarginCheck(_Symbol,ORDER_TYPE_BUY,1.0,SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   Print("Free margin, left after trade operation: ",f_margin);

//--- get maximum trade volume
   double max_lot=myaccount.MaxLotCheck(_Symbol,ORDER_TYPE_BUY,SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   Print("Maximum trade volume: ",max_lot);
  }
//+------------------------------------------------------------------+
//| Testing of CSymbolInfo class methods                             |
//+------------------------------------------------------------------+
void Test_CSymbolInfo()
  {
//--- CSymbolInfo class object
   CSymbolInfo mysymbol;

//--- set symbol name 
   mysymbol.Name(_Symbol);
//--- refresh symbol data
   mysymbol.Refresh();

//--- refresh rates using corresponding method of CSymbolInfo class
   if(!mysymbol.RefreshRates())
     {
      //--- error
      Print("Error in RefreshRates");
     }
   else
     {
      Print("Rates updates");
     }

//--- is synchronized
   if(!mysymbol.IsSynchronized())
     {
      Print("Symbol data is not synchonized with server");
     }
   else
     {
      Print("Symbol data is synchonized with server");
     }

   ulong max_vol=mysymbol.VolumeHigh();
   Print("Maximum volume: ",max_vol);

   ulong min_vol=mysymbol.VolumeLow();
   Print("Minimum volume: ",min_vol);

   datetime qtime=mysymbol.Time();
   Print("Time: ",qtime);

   int spread=mysymbol.Spread();
   Print("Spread: ",spread);

   int stp_level=mysymbol.StopsLevel();
   Print("Stop Level: ",stp_level);

   int frz_level=mysymbol.FreezeLevel();
   Print("Freeze Level: ",frz_level);

   double bid=mysymbol.Bid();
   Print("Bid price: ",bid);

   double max_bid=mysymbol.BidHigh();
   Print("Max. Bid price: ",max_bid);

   double min_bid=mysymbol.BidLow();
   Print("Min. Bid price: ",min_bid);

   double ask=mysymbol.Ask();
   Print("Ask price: ",ask);

   double max_ask=mysymbol.AskHigh();
   Print("Max. Ask price: ",max_ask);

   double min_ask=mysymbol.AskLow();
   Print("Min. Ask price: ",min_ask);

//--- returns "USD" for USDJPY or USDCAD
   string base_currency=mysymbol.CurrencyBase();
   Print("Symbol base currency: ",base_currency);

   double contract_size=mysymbol.ContractSize();
   Print("Contract size: ",contract_size);
   
   int s_digits=mysymbol.Digits();
   Print("Digits: ",s_digits);

   double s_point=mysymbol.Point();
   Print("Point: ",s_point);

   double min_lot =  mysymbol.LotsMin();
   Print("Min. lot: ",min_lot);
   
   double max_lot =  mysymbol.LotsMax();
   Print("Max. lot: ",max_lot);

   double lot_step=  mysymbol.LotsStep();
   Print("Lot step: ",lot_step);

//--- a normalized current Ask price
   double n_price=mysymbol.NormalizePrice(mysymbol.Ask());
   Print("Normalized current Ask price: ",n_price);
      
   if(mysymbol.Select())
     {
      // symbol selected successfully
     }
   else
     {
      // symbol is not selected
     }

   if(!mysymbol.Select())
     {
      //-- Symbol is not selected, add it to Market Watch
      mysymbol.Select(true);
     }
   else
     {
      //--- Symbol already has been selected
      //--- Remove it from Market Watch
      mysymbol.Select(false);
     }

   double init_margin=mysymbol.MarginInitial();
   Print("Initial margin: ",init_margin);
    
   if(mysymbol.TradeMode()==SYMBOL_TRADE_MODE_FULL)
     {
      // There isn't any trade restrictions
     }

   Print("Trade mode description: ",mysymbol.TradeModeDescription());
  }
//+------------------------------------------------------------------+
//| Testing of CHistoryOrderInfo class methods                       |
//+------------------------------------------------------------------+
void Test_CHistoryOrderInfo()
  {
//--- CHistoryOrderInfo class object
   CHistoryOrderInfo myhistory;

//--- get all orders in history for the specified time period
   if(HistorySelect(0,TimeCurrent())) //--- get all orders in history
     {
      //--- get total orders in history
      int tot_hist_orders=HistoryOrdersTotal();

      ulong h_ticket; //--- order ticket

      for(int j=0; j<tot_hist_orders; j++)
        {

         h_ticket=HistoryOrderGetTicket(j);

         Print("");
         Print("Order ",j+1," of ",tot_hist_orders);

         if(h_ticket>0)
           {
            //--- first that we do - get order ticket
            myhistory.Ticket(h_ticket);
            ulong ticket=myhistory.Ticket();
            Print("Order ticket: ",ticket);

            datetime os_time=myhistory.TimeSetup();
            Print("Order setting date: ",os_time);

            Print("Order type: ",myhistory.TypeDescription());

            if(myhistory.Type()==ORDER_TYPE_BUY)
              {
               //--- buy order
               Print("Buy order");
              }
            else
            if(myhistory.Type()==ORDER_TYPE_SELL)
              {
               //--- sell order
               Print("Sell order");
              }

            if(myhistory.State()==ORDER_STATE_REJECTED)
              {
               //--- order rejected
               Print("Order has been rejected, it hasn't been placed");
              }
            //--- Order time
            datetime ot_done=myhistory.TimeDone();
            Print("Order execution time: ",ot_done);

            long o_magic=myhistory.Magic();
            Print("Magic: ",ot_done);

            long o_posid=myhistory.PositionId();
            Print("Position ID: ",o_posid);

            double o_price=myhistory.PriceOpen();
            Print("Open price: ",o_price);

            string o_symbol=myhistory.Symbol();
            Print("Symbol: ",o_symbol);

           }
        }

     }
  }
//+------------------------------------------------------------------+
//| Testing of COrderInfo class methods                              |
//+------------------------------------------------------------------+
void Test_COrderInfo()
  {
//--- COrderInfo class object
   COrderInfo myorder;

//--- Select all orders in history for the specified time period
   if(HistorySelect(0,TimeCurrent())) //--- all orders
     {
      //--- get total amount of orders
      int o_total=OrdersTotal();

      for(int j=0; j<o_total; j++)
        {
         //--- select order using the Select method of COrderInfî,
         if(myorder.Select(OrderGetTicket(j)))
           {
            //--- order has been selected successfully, we can work with it

            ulong o_ticket=myorder.Ticket();
            Print("Order ticket: ",o_ticket);

            datetime o_setup=myorder.TimeSetup();
            Print("Order setting time: ",o_setup);

            string o_typedescr=myorder.TypeDescription();
            Print("Order type: ",o_typedescr);

            if(myorder.Type()==ORDER_TYPE_BUY_LIMIT)
              {
               //--- this is Buy Limit order, etc
               Print("This is Buy Limit order");
              }

            if(myorder.State()==ORDER_STATE_STARTED)
              {
               //--- Order checked, but not yet accepted by broker
               Print("Order checked, but not yet accepted by broker");
              }

            datetime ot_done=myorder.TimeDone();
            Print("Order execution time: ",ot_done);

            long o_magic=myorder.Magic();
            Print("Magic: ",o_magic);

            long o_posid=myorder.PositionId();
            Print("Position ID: ",o_posid);

            double o_price=myorder.PriceOpen();
            Print("Order open price: ",o_price);

            double  s_loss=myorder.StopLoss();
            Print("Stop Loss price: ",s_loss);

            double t_profit=myorder.TakeProfit();
            Print("Take Profit price: ",t_profit);

            double cur_price=myorder.PriceCurrent();
            Print("Current price: ",cur_price);

            string o_symbol=myorder.Symbol();
            Print("Order symbol: ",o_symbol);

            //--- save order state
            myorder.StoreState();

            if(myorder.CheckState()==true)
              {
               //--- status or parameters hasn't changed
               Print("Order status or parameters hasn't changed.");
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Testing of CDealInfo class methods                               |
//+------------------------------------------------------------------+
void Test_CDealInfo()
  {
//--- CDealInfo class object
   CDealInfo mydeal;

   if(HistorySelect(0,TimeCurrent()))
     {
      //--- get total deals in history
      int tot_deals=HistoryDealsTotal();

      for(int j=0; j<tot_deals; j++)
        {
         Print("");
         Print("Deal : ",j+1," of ",tot_deals);
         mydeal.Ticket(HistoryDealGetTicket(j));

         ulong dealticket=mydeal.Ticket();
         Print("Deal ticket: ",dealticket);

         long deal_order_no=mydeal.Order();
         Print("Order ticket, of the deal: ",deal_order_no);

         datetime d_time=mydeal.Time();
         Print("Deal execution time: ",d_time);

         string deal_typedescr=mydeal.TypeDescription();
         Print("Order type: ",deal_typedescr);

         if(mydeal.Type()==DEAL_TYPE_BUY)
           {
            //--- Deal of BUY type
           }

         string deal_entrydescr=mydeal.EntryDescription();
         Print("Deal entry direction: ",deal_entrydescr);

         if(mydeal.Entry()==DEAL_ENTRY_IN)
           {
            //--- Deal entry IN (open)
           }

         long d_magic=mydeal.Magic();
         Print("Magic: ",d_magic);

         long d_post_id=mydeal.PositionId();
         Print("Position ID: ",d_post_id);

         double d_price=mydeal.Price();
         Print("Order price: ",d_price);

         double d_vol=mydeal.Volume();
         Print("Deal volume: ",d_vol);

         string d_symbol=mydeal.Symbol();
         Print("Deal symbol: ",d_symbol);
        }
     }
  }
//+------------------------------------------------------------------+
//| Testing of CCPositionInfo class methods                          |
//+------------------------------------------------------------------+
void Test_CPositionInfo()
  {
//--- CPositionInfo class object
   CPositionInfo myposition;

   int pos_total=PositionsTotal();
   Print("Total opened positions: ",pos_total);

   for(int j=0; j<pos_total; j++)
     {
      if(myposition.Select(PositionGetSymbol(j)))
        {
         Print("");
         Print("Position ",j+1," of ",pos_total);

         //--- position has been selected, now it's available
         datetime pos_time=myposition.Time();
         Print("Position time: ",pos_time);

         string pos_typedescr=myposition.TypeDescription();
         Print("Position type: ",pos_time);

         if(myposition.Type()==POSITION_TYPE_BUY)
           {
            //--- the long (buy) position
           }

         long pos_magic=myposition.Magic();
         Print("Magic number: ",pos_magic);

         double pos_vol=myposition.Volume(); //--- Lots
         Print("Positon volume: ",pos_vol);

         double pos_op_price=myposition.PriceOpen();
         Print("Position open price: ",pos_op_price);

         double pos_stoploss=myposition.StopLoss();
         Print("Position Stop Loss price: ",pos_stoploss);

         double pos_takeprofit=myposition.TakeProfit();
         Print("Position Take Profit price: ",pos_takeprofit);

         //--- save current state of the position
         myposition.StoreState();

         if(!myposition.CheckState())
           {
            //--- position state hasn't changed
           }
         string pos_symbol=myposition.Symbol();
         Print("Position symbol: ",pos_symbol);
        }
     }
  }
//+------------------------------------------------------------------+
//| Testing of CTrade class methods                                  |
//+------------------------------------------------------------------+
void Test_CTrade()
  {
   CTrade mytrade;            //--- CTrade class object
   CSymbolInfo mysymbol;      //--- CSymbolInfo class object
   CPositionInfo myposition;  //--- CPositionInfo class object

//--- set symbol name for CSymbolInfo class object
   mysymbol.Name(_Symbol);
   mysymbol.RefreshRates();

   ulong Magic_No=12345;
   mytrade.SetExpertMagicNumber(Magic_No);

   ulong Deviation=100;
//--- Deviation must be set
   mytrade.SetDeviationInPoints(Deviation);

//--- set parameters
   double Lots=0.1;
   double SL = 0;
   double TP = 0;
   int Stoploss=400;
   int Takeprofit=550;

//--- las bid price, obtained with CSymbolInfo class object
   double Oprice=mysymbol.Bid()-_Point*550;

//--- place pending order (Sell stop)
   mytrade.OrderOpen(_Symbol,ORDER_TYPE_SELL_STOP,Lots,Oprice,Oprice,SL,TP,ORDER_TIME_GTC,0);

//--- Example of order modify

//--- Proceed all orders in history and get all pending orders
   for(int j=0; j<OrdersTotal(); j++)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         //--- last bid price, obtained with CSymbolInfo class
         double Oprice1=mysymbol.Bid()-_Point*150;

         SL=NormalizeDouble(Oprice1+_Point*Stoploss,_Digits);
         TP=NormalizeDouble(Oprice1-_Point*Takeprofit,_Digits);
         //--- modify pending Sell Stop order
         mytrade.OrderModify(o_ticket,Oprice1,SL,TP,ORDER_TIME_GTC,0);
        }
     }

//--- Proceed all orders and get amount of pending order
   int o_total=OrdersTotal();
   Print("Total orders: ",o_total);

   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      Print("");
      Print("Order ",j+1," of ",o_total);
      Print("Order ticket: ",o_ticket);
      if(o_ticket>0)
        {
         //--- delete Sell Stop pending order
         if(!mytrade.OrderDelete(o_ticket))
            Print(mytrade.ResultRetcodeDescription());
        }
     }

//--- example of open buy position
//--- get the prices using CSymbolInfo class method
   Lots=0.1;
//--- Stoploss must be declared above
   SL=mysymbol.Ask()-Stoploss*_Point;
//--- Takeprofit must be declared above
   TP=mysymbol.Ask()+Takeprofit*_Point;
//--- last ask price, obtained via CSymbolInfo class object
   Oprice=mysymbol.Ask();
//--- open buy position
   mytrade.PositionOpen(_Symbol,ORDER_TYPE_BUY,Lots,Oprice,SL,TP,"Test Buy");

//--- show parameters after trade operation
   mytrade.PrintRequest();
//--- print result
   mytrade.PrintResult();

   ulong dl_ticket=mytrade.ResultDeal();
   Print("Deal ticket as a result of the request for trade operation: ",dl_ticket);

   ulong o_ticket=mytrade.ResultOrder();
   Print("Deal ticket as a result of the request for pending order: ",o_ticket);

   double o_volume=mytrade.ResultVolume();
   Print("Volume of trade operation: ",o_volume);

   double r_price=mytrade.ResultPrice();
   Print("Price, confirmed by broker: ",r_price);

   double rq_bid=mytrade.ResultBid();
   Print("Current Bid price: ",rq_bid);

   double rq_ask=mytrade.ResultAsk();
   Print("Current Ask price: ",rq_ask);

//--- example of modify position
   int newStoploss=250;
   int newTakeprofit=500;

   if(myposition.Select(_Symbol))
     {
      //--- newStoploss variable must be declared above
      double SL1=double(mysymbol.Ask()-newStoploss*_Point);
      //--- newTakeprofit variable must be declared above
      double TP1=double(mysymbol.Ask()+newTakeprofit*_Point);
      //--- modify the position
      mytrade.PositionModify(_Symbol,SL1,TP1);
     }

   Sleep(3000);

//--- example of position closing
   if(myposition.Select(_Symbol))
     {
      //--- close opened position on the symbol
      //--- slippage has been set before
      mytrade.PositionClose(_Symbol);
      Sleep(3000);

      //--- trade operation has finished, get result code
      uint return_code=mytrade.ResultRetcode();
      string ret_message=mytrade.ResultRetcodeDescription();
      //--- show it
      Print("Result code: ",return_code," Description: ",ret_message);
     }

  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- testing of CSymbolInfo class methods
   Test_CSymbolInfo();
//--- testing of CHistoryOrderInfo class methods
   Test_CHistoryOrderInfo();
//--- testing of COrderInfo class methods
   Test_COrderInfo();
//--- testing of CDealInfo class methods
   Test_CDealInfo();
//--- testing of CPositionInfo class methods
   Test_CPositionInfo();
//--- testing of CTrade class methods
   Test_CTrade();
  }
//+------------------------------------------------------------------+