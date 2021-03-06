//+------------------------------------------------------------------+
//|                                              OrderConditions.mqh |
//|                                                Serhii Liubchenko |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Serhii Liubchenko"
#property link      "https://www.mql5.com"
#property strict
//---

int lengthSMA = 250;
int volumeSMALength = 20;
int distanceKD = 3;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IdentifyRangeMove()
  {
// отримуємо значення об'ємів і МА за попередній період
   double volumeValue = iCustom(Symbol(),0,"Volume MA",volumeSMALength,1,0);
   double smaValue = iCustom(Symbol(),0,"Volume MA",volumeSMALength,1,2);

   if(volumeValue < smaValue)
     {
      return true; // ідентифікуємо бічний рух
     }
   else
     {
      return false;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool identifyTrend()
  {
   double superTrendValue = iCustom(Symbol(),0,"Super Trend","SPRTRND",2,100,5000,0,0);

   if(superTrendValue > Bid)
     {
      return true; // продаємо
     }
   else
     {
      return false;  //купуємо
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderConditions()
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
   double MA = iMA(NULL,0,lengthSMA,0,MODE_SMA,PRICE_CLOSE,0);

//K i D безпосередньо перед перетином
   bool beforeCrossing = K2 > D2;
//K i D відразу після перетину
   bool afterCrossing = K1 < D1;
//друга свічка після перетину. точка входу
   bool entryPointSell = (K < D) && (MathAbs(K - D) >= distanceKD) && (MathAbs(K - D) > MathAbs(K1 - D1));
   bool entryPointBuy = (K > D) && (MathAbs(K - D) >= distanceKD) && (MathAbs(K - D) > MathAbs(K1 - D1));

   string orderDirection;

   if(K2 > 80 && Ask < MA && entryPointSell && identifyTrend())
     {
      if(beforeCrossing && afterCrossing && entryPointSell)
        {
         orderDirection = "sell";
        }
     }
   else
      if(D2 < 20 && Bid > MA && entryPointBuy && !identifyTrend())
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

//+------------------------------------------------------------------+
