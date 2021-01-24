#include <Trade\Trade.mqh>
CTrade trade;


void OnTimer(){
   OnTick();
}


void OnTick()
  {
      
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);

      double Balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double Equity = AccountInfoDouble(ACCOUNT_EQUITY);

  
    
      if((Equity >= Balance) ){
         trade.Buy(0.01,NULL,Ask,0,(Ask + 100 *_Point),NULL);
      }
  }




