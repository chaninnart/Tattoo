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
//| Custom Indicator Variable                                  |
//+------------------------------------------------------------------+
//1. Currency Strength

input int ccs_score_period = 10;  //Currency Score Period
struct cc_score_structure{string currency; double score; double slope; cc_score_structure(){currency="";score = 0.0;slope=0.0;}};
cc_score_structure aud ,cad,eur,gbp ,nzd ,usd,chf,jpy;
cc_score_structure cc_score [8]; //
string pairs[28] = {"AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD","CADCHF",	"CADJPY", "CHFJPY", "EURAUD",	"EURCAD", "EURCHF", "EURGBP",	"EURJPY", "EURNZD", "EURUSD",	"GBPAUD","GBPCAD","GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD","NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD", "USDCAD",   "USDCHF",	"USDJPY"};





//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){   
   //EventSetTimer(3);                //set Timer to proceed the OnTick while close market.
  
   //parameter initialization   
   aud.currency = "AUD";cad.currency = "CAD";eur.currency = "EUR";gbp.currency = "GBP"; nzd.currency = "NZD"; usd.currency = "USD";chf.currency = "CHF";jpy.currency = "JPY"; 
   
   
   int    ccs_handle0;   
   ccs_handle0 = iCustom(NULL,PERIOD_H1,"_Fluke_CCS2");

   
   double ccs_buffer0 [],ccs_buffer1[];
   ArraySetAsSeries(ccs_buffer0,true);
   ArraySetAsSeries(ccs_buffer1,true);
   CopyBuffer(ccs_handle0,0,0,10,ccs_buffer0);
   CopyBuffer(ccs_handle0,1,0,10,ccs_buffer1);
   
Comment(ccs_buffer0[0] +"\n"+ ccs_buffer0[1] +"\n"+ ccs_buffer1[0] +"\n"+ ccs_buffer1[1]);




   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+  
//void OnTimer(){OnTick();}
 
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
      getAllParameter();
      //getOrdersDetail();
      //getOrderSummary();
      //orderManagement(); 
      //openOrderStrategy();


  }
  
//+------------------------------------------------------------------+

void  getAllParameter(){ 
      get_CurrencyScore(ccs_score_period);   //bar back to cal slope  
}     







//---------------Parameter-----------------
void get_CurrencyScore(int ref_bar){
   

         
         /*aud.score = NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",ref_bar,0,0),8);
         cad.score = NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",ref_bar,1,0),8);
         eur.score = NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",ref_bar,2,0),8);
         gbp.score = NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",ref_bar,3,0),8);
         nzd.score = NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",ref_bar,4,0),8);
         usd.score = NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",ref_bar,5,0),8);
         chf.score = NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",ref_bar,6,0),8);
         jpy.score = NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",ref_bar,7,0),8);         
  
         aud.slope = aud.score - NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",50,0,0),3) ;
         cad.slope = cad.score - NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",50,1,0),3) ;
         eur.slope = eur.score - NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",50,2,0),3) ;
         gbp.slope = gbp.score - NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",50,3,0),3) ;
         nzd.slope = nzd.score - NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",50,4,0),3) ;
         usd.slope = usd.score - NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",50,5,0),3) ;
         chf.slope = chf.score - NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",50,6,0),3) ;
         jpy.slope = jpy.score - NormalizeDouble(iCustom(NULL,timeframe,"_Fluke_CCS",50,7,0),3) ;
         
         cc_score [0] = aud; cc_score [1] = cad; cc_score [2] = eur; cc_score [3] = gbp; 
         cc_score [4] = nzd; cc_score [5] = usd; cc_score [6] = chf; cc_score [7] = jpy; 
         
         Comment(aud.score + "\n" + cad.score + "\n" + eur.score + "\n" + gbp.score + "\n" 
                 + nzd.score + "\n" + usd.score + "\n" + chf.score + "\n" + jpy.score + "\n"); 
         */

}

