//+------------------------------------------------------------------+
//|                                                     StopLoss.mqh |
//|                                                Serhii Liubchenko |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Serhii Liubchenko"
#property link      "https://www.mql5.com"
#property strict

#include <common.mqh>

//string direction = CalculateEntryDirection();
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
double StopLossLevel(string direction)
  {

    if(direction == "buy") {
      double candleExtremum = Low[0];
      for(int i = 1; i < 5; i++)
        {
         if(candleExtremum > Low[i])
           {
            candleExtremum = Low[i];
           }
        }
        //Print("стоп лос" + candleExtremum);
        return candleExtremum;
    } else if(direction == "sell") {
        double candleExtremum = High[0];
        for(int i = 1; i < 5; i++)
        {
        if(candleExtremum < High[i])
            {
            candleExtremum = High[i];
            }
        }
        //Print("стоп лос" + candleExtremum);
        return candleExtremum;
    } else {
      return false;
    }
}