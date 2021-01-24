//+------------------------------------------------------------------+
//|  Include ALL classes that will be used                           |
//+------------------------------------------------------------------+
//--- The CDealInfo Class
#include <Trade\DealInfo.mqh>
//+------------------------------------------------------------------+
//|  Create class object                                             |
//+------------------------------------------------------------------+
//--- The CDealInfo Class Object
CDealInfo mydeal;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Get all deals in History and get their details
    int buy=0;
    int sell=0;
    int deal_in=0;
    int deal_out=0;
    ulong d_ticket;
    // Get all history records
    if (HistorySelect(0,TimeCurrent())) 
    {
      // Get total deals in history
      for (int j=HistoryDealsTotal(); j>0; j--)
      {
         // select deals by ticket
         if (d_ticket = HistoryDealGetTicket(j))
         {
          // Set Deal Ticket to work with
          mydeal.Ticket(d_ticket);
          Print("Deal index ", j ," Deal Ticket is: ", mydeal.Ticket() ," !");
          Print("Deal index ", j ," Deal Execution Time is: ", TimeToString(mydeal.Time()) ," !");
          Print("Deal index ", j ," Deal Price is: ", mydeal.Price() ," !");
          Print("Deal index ", j ," Deal Symbol is: ", mydeal.Symbol() ," !");
          Print("Deal index ", j ," Deal Type Description is: ", mydeal.TypeDescription() ," !");
          Print("Deal index ", j ," Deal Magic is: ", mydeal.Magic() ," !");
          Print("Deal index ", j ," Deal Time is: ", mydeal.Time() ," !");
          Print("Deal index ", j ," Deal Initial Volume is: ", mydeal.Volume() ," !");
          Print("Deal index ", j ," Deal Entry Type Description is: ", mydeal.EntryDescription() ," !");
          Print("Deal index ", j ," Deal Profit is: ", mydeal.Profit() ," !");
          //
          if (mydeal.Entry() == DEAL_ENTRY_IN) deal_in++;
          if (mydeal.Entry() == DEAL_ENTRY_OUT) deal_out++;
          if (mydeal.Type() == DEAL_TYPE_BUY) buy++;
          if (mydeal.Type() == DEAL_TYPE_SELL) sell++;
         }
      }
    }
    // Print Summary
    Print("Total Deals in History is :", HistoryDealsTotal(), " !");
    Print("Total Deal Entry IN is : ", deal_in);
    Print("Total Deal Entry OUT is: ", deal_out);
    Print("Total Buy Deal is : ", buy);
    Print("Total Sell Deal is: ", sell);
  }