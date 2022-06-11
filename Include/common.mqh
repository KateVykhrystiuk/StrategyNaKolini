//+------------------------------------------------------------------+
//|                                                       common.mqh |
//|                                                Serhii Liubchenko |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Serhii Liubchenko"
#property link      "https://www.mql5.com"
#property strict

#include <LotSize.mqh>
#include <StopLoss.mqh>


int orderID;
double takeProfit;
double stopLoss;
double previousStopLoss = 0;
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+


/*bool CheckIfOpenOrdersByMagicNumber(int magicNumber) {
   int openOrders = OrdersTotal();
   for(int i = 0; i < openOrders; i++) {
      if (OrderSelect(i,SELECT_BY_POS) == true) {
         if (OrderMagicNumber() == magicNumber) return true;

      }
   }
   return false;
}*/

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CalculateEntryDirection()
  {
// Показники Stochastic RSI K i D
   double K = iCustom(NULL,0,"Stochastic-RSI",3,3,14,14,PRICE_CLOSE,0,0);
   double D = iCustom(NULL,0,"Stochastic-RSI",3,3,14,14,PRICE_CLOSE,1,0);

// Показники Stochastic RSI K i D попередньої свічки
   double K1 = iCustom(NULL,0,"Stochastic-RSI",3,3,14,14,PRICE_CLOSE,0,1);
   double D1 = iCustom(NULL,0,"Stochastic-RSI",3,3,14,14,PRICE_CLOSE,1,1);

//Показники Stochastic RSI K i D перед попередньої свічки
   double K2 = iCustom(NULL,0,"Stochastic-RSI",3,3,14,14,PRICE_CLOSE,0,2);
   double D2 = iCustom(NULL,0,"Stochastic-RSI",3,3,14,14,PRICE_CLOSE,1,2);

//Показник МА з довжиною 100
   double MA = iMA(NULL,0,100,0,MODE_SMA,PRICE_CLOSE,0);

//K i D безпосередньо перед перетином
   bool beforeCrossing = K2 > D2;
//K i D відразу після перетину
   bool afterCrossing = K1 < D1;
//друга свічка після перетину. точка входу
   bool entryPointSell = (K < D) && (MathAbs(K - D) >= 4) && (MathAbs(K - D) > MathAbs(K1 - D1));
   bool entryPointBuy = (K > D) && (MathAbs(K - D) >= 4) && (MathAbs(K - D) > MathAbs(K1 - D1));

   string orderDirection;

   if(K2 > 80 && Ask < MA && entryPointSell)
     {
      if(beforeCrossing && afterCrossing && entryPointSell)
        {
         orderDirection = "sell";
        }
     }
   else
      if(D2 < 20 && Bid > MA && entryPointBuy)
        {
         if(!beforeCrossing && !afterCrossing && entryPointBuy)
           {
            orderDirection = "buy";
           }
        }
      else
        {
         orderDirection = "чекай";
        }

   return orderDirection;
  }

string direction = CalculateEntryDirection();

//---------------------------------------------------------------------

datetime NewCandleTime = TimeCurrent();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandle()
  {
   if(NewCandleTime == iTime(Symbol(), 0, 0))
      return false;
   else
     {
      NewCandleTime = iTime(Symbol(), 0, 0);
      return true;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//double stopLoss = stopLossLevel(direction);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TakeProfit(double entryPrice, double stopLoss)
  {
   return 0.55;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendOrder()
  {
   double entryPrice;
   int tradeOperation;
   string direction = CalculateEntryDirection();
   double lotSize;

   if(direction == "buy")
     {
      entryPrice = Ask;
      tradeOperation = OP_BUY;
      stopLoss = StopLossLevel(direction);
      takeProfit = Ask + (Ask - stopLoss) * 1.5;
      lotSize = LotSize(2.0,entryPrice,stopLoss);

      orderID = OrderSend(NULL,tradeOperation,lotSize,entryPrice,10,stopLoss,takeProfit,NULL);

      if(orderID < 0)
         Print("Ордер відхилено. Код помилки: " + GetLastError());
     }
   else
      if(direction == "sell")
        {
         entryPrice = Bid;
         tradeOperation = OP_SELL;
         stopLoss = StopLossLevel(direction);
         takeProfit = Bid - (stopLoss - Bid) * 1.5;
         lotSize = LotSize(2.0,entryPrice,stopLoss);

         orderID = OrderSend(NULL,tradeOperation,lotSize,entryPrice,10,0,takeProfit,NULL);

         if(orderID < 0)
            Print("Ордер відхилено. Код помилки: " + GetLastError());
        }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyOrder()
  {
   double orderOpenPrice = 0;
   
   if(OrderSelect(orderID,SELECT_BY_TICKET)==true)
   {
      orderOpenPrice = OrderOpenPrice();
   }
  
   if(orderID > 0 && orderOpenPrice > takeProfit)
     {
      
      double modifiedStopLoss = stopLoss + NormalizeDouble(Ask - Bid,5);
      
      if(modifiedStopLoss > previousStopLoss) {
      
         previousStopLoss = modifiedStopLoss;
         int orderModify = OrderModify(orderID,orderOpenPrice,modifiedStopLoss,takeProfit,0,Blue);
         
         if(orderModify < 0)
            Print("Зміну стоп-лосу відхилено (modify). Код помилки: " + GetLastError());
      
      }

      

      
//----------------------------------------------------------------------------------
      /*int orderClose = OrderClose(orderID,1,stopLoss,3, Red);

      if(orderClose < 0)
         Print("Закриття угоди відхилено (stop loss). Код помилки: " + GetLastError());*/
     }


   else
      if(orderID > 0 && direction == "buy")
        {

         /*stopLoss = stopLoss + MarketInfo(Symbol(), MODE_SPREAD);

         int orderModify = OrderModify(orderID,OrderOpenPrice(),stopLoss,takeProfit,0,Blue);


         if(orderModify < 0)
            Print("Зміну стоп-лосу відхилено (modify). Код помилки: " + GetLastError());
         Print("Ask " + Ask + " Bid " + Bid);

         int orderClose = OrderClose(orderID,1,Bid,3, Red);



         if(orderClose < 0)
            Print("Закриття угоди відхилено (stop loss). Код помилки: " + GetLastError());*/
        }


  }

//+------------------------------------------------------------------+
