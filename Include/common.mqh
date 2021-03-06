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
#include <OrderConditions.mqh>

int orderID;
int previousOrderID;
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
   string direction = OrderConditions();
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

      //Print("orderID " + orderID + " previousOrderID " + previousOrderID);
      if(orderID != previousOrderID)
        {

         previousOrderID = orderID;

         previousStopLoss = 0;
        }

      if(modifiedStopLoss > previousStopLoss)
        {

         previousStopLoss = modifiedStopLoss;
         // Print("modifiedSL " + modifiedStopLoss + " previousSL " + previousStopLoss);
         int orderModify = OrderModify(orderID,orderOpenPrice,modifiedStopLoss,takeProfit,0,Blue);

         if(orderModify < 0)
            Print("Зміну стоп-лосу відхилено (modify). Код помилки: " + GetLastError());

        }
     }
     else if(orderID > 0 && orderOpenPrice < takeProfit)
     {
      
      /*if (identifyTrend()) {
        int orderModify = OrderModify(orderID,orderOpenPrice,modifiedStopLoss,Bid,0,Blue);

         if(orderModify < 0)
            Print("Зміну стоп-лосу відхилено (modify). Код помилки: " + GetLastError());
      }*/


     }


  }

//+------------------------------------------------------------------+
