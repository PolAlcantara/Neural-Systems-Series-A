//+------------------------------------------------------------------+
//|                                                    Neural A1.m
//|                                                           Neural |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Neural"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
input int PeriodRSI=30,PeriodJaw=25,PeriodTeeth=15,PeriodLips=10,Lotes=4,NivelCap_RSI=70,NivelCcl_RSI=30,NivelVap_RSI=30,NivelVcl_RSI=70;
input int Magic_A1=6549; //Clave:A1. https://cryptii.com/text-decimal;
double RSI, Alligator_Jaw,Alligator_Lips,TimeWait,Compra,Venta;
int m=0, OperacionesA1;
datetime VelasR=LocalTime();
input double num_years = 4; // numero de años de la simulacion
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {


  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   OperacionesA1=OrdersInCurrentSymbol(Symbol(),Magic_A1);
   if(NewBar()==True)
   { 
      RSI=iRSI(Symbol(),NULL,PeriodRSI,PRICE_CLOSE,0);
      Alligator_Jaw=iAlligator(Symbol(),NULL,PeriodJaw,0,PeriodTeeth,0,PeriodLips,0,0,0,1,0);
      Alligator_Lips=iAlligator(Symbol(),NULL,PeriodJaw,0,PeriodTeeth,0,PeriodLips,0,0,0,3,0);
      
      if(OperacionesA1==0)
      {        
         //ABRIR COMPRAS
         if(RSI>NivelCap_RSI && Alligator_Jaw<Alligator_Lips)
         {  
            Compra=OrderSend(Symbol(),OP_BUY,Lotes,Ask,5,0,0,NULL,Magic_A1,0,Green);  
         }    
         //ABRIR VENTAS
         if(RSI<NivelVap_RSI && Alligator_Jaw>Alligator_Lips)
         {  
            Venta=OrderSend(Symbol(),OP_SELL,Lotes,Bid,5,0,0,NULL,Magic_A1,0,Pink);  
         }           
       } 
       
      //CERRAR OPERACIONES

      int cnt;
      for(cnt=0;cnt<=OrdersTotal();cnt++)
      {
         if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         {
            continue;
         }
         //CERRAR COMPRAS
         if(OrderType()==OP_BUY)
         {          
            if(RSI<NivelCcl_RSI && Alligator_Jaw>Alligator_Lips)
            {              
               Print("Order ticket=",OrderTicket());
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet))
               {
                 Print("Error de cierre de Compra ",GetLastError(),"Ticket: ",OrderTicket());
               }
            }
         }
         //CERRAR VENTAS
         if(OrderType()==OP_SELL)
         {           
            if(RSI>NivelVcl_RSI && Alligator_Jaw<Alligator_Lips)
            {              
               Print("Order ticket=",OrderTicket());
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet))
               {
                  Print("Error de cierre de Venta ",GetLastError(),"Ticket: ",OrderTicket());
               }
            }
         }
       }
    }
  }
  
//+------------------------------------------------------------------+
//| MODULOS DE FUNCIONES                                             |
//+------------------------------------------------------------------+

int OrdersInCurrentSymbol(string simbolo,int magic)
{
   int orders=0;
   int TotalOrdenes=OrdersTotal();
   for(int cnt=0;cnt<=(TotalOrdenes)+1;cnt++)
   {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))continue;
      if((OrderType()==OP_SELL || OrderType()==OP_BUY)  && OrderMagicNumber()==magic && OrderSymbol()==simbolo)
      {
         orders++;
      } 
   }
   return(orders);
}
bool NewBar()
  {
   static datetime time=0;
   if(time==0)
     {
      time=Time[0];
      return false;
     }
   if(time!=Time[0])
     {
      time=Time[0];
      return true;
     }
   return false;
  }
  
double OnTester()
{
   //---
   double ret=0;
   //---
   if (TesterStatistics(STAT_TRADES)!=0)
   {
      double profit= TesterStatistics(STAT_PROFIT);
      double drawdownmax = TesterStatistics(STAT_EQUITY_DD);
      double trades = TesterStatistics(STAT_TRADES);
      double perc_drawdown_max = TesterStatistics(STAT_EQUITYDD_PERCENT);
      Alert("Profit= ",profit,",DDMAX= ",drawdownmax,",trades=",trades,"%DDMAX",perc_drawdown_max); 
      double weight_trades = (trades/(num_years *150));
      if(weight_trades>1.5){weight_trades=1.5;}
      ret =weight_trades*(profit/drawdownmax)*((100-perc_drawdown_max)/100)*(1/num_years);    
   }
   return(ret);
}