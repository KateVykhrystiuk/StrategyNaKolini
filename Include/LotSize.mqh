//+------------------------------------------------------------------+
//|                                                      LotSize.mqh |
//|                                                Serhii Liubchenko |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Serhii Liubchenko"
#property link      "https://www.mql5.com"
#property strict

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPipValue()
  {
   if(_Digits >=4)
     {
      return 0.0001;
     }
   else
     {
      return 0.01;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateLotSize(double SL, double MaxRiskPerTrade)           // Calculate the position size.
  {
   double lotSize = 0;
// We get the value of a tick.
   double nTickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
// If the digits are 3 or 5, we normalize multiplying by 10.
   if((Digits == 3) || (Digits == 5))
     {
      nTickValue = nTickValue * 10;
     }
// We apply the formula to calculate the position size and assign the value to the variable.
   lotSize = (AccountBalance() * MaxRiskPerTrade / 100) / (SL * nTickValue);
   return lotSize;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LotSize(double maxRiskPrc, double entryPrice, double stopLoss)
  {

   
   double maxLossInPips = MathAbs(entryPrice - stopLoss)/GetPipValue();
   //Print("втрата в піпсах: " + maxLossInPips);
   return CalculateLotSize(maxLossInPips, maxRiskPrc);
  }
//+------------------------------------------------------------------+
