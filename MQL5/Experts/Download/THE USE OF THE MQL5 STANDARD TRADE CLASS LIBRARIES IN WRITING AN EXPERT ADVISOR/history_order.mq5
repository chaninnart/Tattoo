//+------------------------------------------------------------------+
//|  Include ALL classes that will be used                           |
//+------------------------------------------------------------------+
//--- The Trade Class
#include <Trade\HistoryOrderInfo.mqh>
//+------------------------------------------------------------------+
//|  CREATE CLASS OBJECT                                             |
//+------------------------------------------------------------------+
//--- The HistoryOrderInfo Class Object
CHistoryOrderInfo myhistory;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Get all orders in History and get their details
   int buystop=0;
   int sellstop=0;
   int buylimit=0;
   int selllimit=0;
   int buystoplimit=0;
   int sellstoplimit=0;
   int buy=0;
   int sell=0;

   int s_started=0;
   int s_placed=0;
   int s_cancelled=0;
   int s_partial=0;
   int s_filled=0;
   int s_rejected=0;
   int s_expired=0;

   ulong o_ticket;
// Get all history records
   if(HistorySelect(0,TimeCurrent())) // get all history orders
     {
      // Get total orders in history
      for(int j=HistoryOrdersTotal(); j>0; j--)
        {
         // select order by ticket
         o_ticket=HistoryOrderGetTicket(j);
         if(o_ticket>0)
           {
            // Set order Ticket to work with
            myhistory.Ticket(o_ticket);
            Print("Order index ",j," Order Ticket is: ",myhistory.Ticket()," !");
            Print("Order index ",j," Order Setup Time is: ",TimeToString(myhistory.TimeSetup())," !");
            Print("Order index ",j," Order Open Price is: ",myhistory.PriceOpen()," !");
            Print("Order index ",j," Order Symbol is: ",myhistory.Symbol() ," !");
            Print("Order index ",j," Order Type is: ", myhistory.Type() ," !");
            Print("Order index ",j," Order Type Description is: ",myhistory.TypeDescription()," !");
            Print("Order index ",j," Order Magic is: ",myhistory.Magic()," !");
            Print("Order index ",j," Order Time Done is: ",myhistory.TimeDone()," !");
            Print("Order index ",j," Order Initial Volume is: ",myhistory.VolumeInitial()," !");
            //
            //
            if(myhistory.Type() == ORDER_TYPE_BUY_STOP) buystop++;
            if(myhistory.Type() == ORDER_TYPE_SELL_STOP) sellstop++;
            if(myhistory.Type() == ORDER_TYPE_BUY) buy++;
            if(myhistory.Type() == ORDER_TYPE_SELL) sell++;
            if(myhistory.Type() == ORDER_TYPE_BUY_LIMIT) buylimit++;
            if(myhistory.Type() == ORDER_TYPE_SELL_LIMIT) selllimit++;
            if(myhistory.Type() == ORDER_TYPE_BUY_STOP_LIMIT) buystoplimit++;
            if(myhistory.Type() == ORDER_TYPE_SELL_STOP_LIMIT) sellstoplimit++;

            if(myhistory.State() == ORDER_STATE_STARTED) s_started++;
            if(myhistory.State() == ORDER_STATE_PLACED) s_placed++;
            if(myhistory.State() == ORDER_STATE_CANCELED) s_cancelled++;
            if(myhistory.State() == ORDER_STATE_PARTIAL) s_partial++;
            if(myhistory.State() == ORDER_STATE_FILLED) s_filled++;
            if(myhistory.State() == ORDER_STATE_REJECTED) s_rejected++;
            if(myhistory.State() == ORDER_STATE_EXPIRED) s_expired++;
           }
        }
     }
// Print summary
   Print("Buy Stop Pending Orders : ",buystop);
   Print("Sell Stop Pending Orders: ",sellstop);
   Print("Buy Orders : ",buy);
   Print("Sell Orders: ",sell);
   Print("Total Orders in History is :",HistoryOrdersTotal()," !");
   
   Print("Orders type summary");
   Print("Market Buy Orders: ",buy);
   Print("Market Sell Orders: ",sell);
   Print("Pending Buy Stop: ",buystop);
   Print("Pending Sell Stop: ",sellstop);
   Print("Pending Buy Limit: ",buylimit);
   Print("Pending Sell Limit: ",selllimit);
   Print("Pending Buy Stop Limit: ",buystoplimit);
   Print("Pending Sell Stop Limit: ",sellstoplimit);
   Print("Total orders:",HistoryOrdersTotal()," !");

   Print("Orders state summary");
   Print("Checked, but not yet accepted by broker: ",s_started);
   Print("Accepted: ",s_placed);
   Print("Canceled by client: ",s_cancelled);
   Print("Partially executed: ",s_partial);
   Print("Fully executed: ",s_filled);
   Print("Rejected: ",s_rejected);
   Print("Expired: ",s_expired);
  }