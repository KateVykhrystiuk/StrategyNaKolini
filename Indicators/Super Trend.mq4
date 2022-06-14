#property link          "https://www.earnforex.com/metatrader-indicators/supertrend/"
#property version       "1.02"
#property strict
#property copyright     "EarnForex.com - 2019-2021"
#property description   "This indicator shows the trend using the ATR" 
#property description   "and an ATR multiplier."
#property description   " "
#property description   "WARNING : You use this software at your own risk."
#property description   "The creator of these plugins cannot be held responsible for damage or loss."
#property description   " "
#property description   "Find More on EarnForex.com"


#property indicator_chart_window
#property indicator_color1 clrGreen
#property indicator_color2 clrRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_buffers 3

double TrendUp[], TrendDown[], TrendResult[];
int changeOfTrend;

/*
TrendResult Buffer 2 Contains The Overall Trend
It is +1 if trending UP
It is -1 if trending DOWN
*/

input string IndicatorName="SPRTRND";  //Objects Prefix (used to draw objects)
extern double ATRMultiplier=2.0;       //ATR Multiplier
extern int ATRPeriod=100;              //ATR Period
extern int ATRMaxBars=1000;            //ATR Max Bars (Max 10.000)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
  {
//---- indicators
   IndicatorSetString(INDICATOR_SHORTNAME,IndicatorName);

   SetIndexBuffer(0, TrendUp);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(0, "Trend Up");
   
   SetIndexBuffer(1, TrendDown);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(1, "Trend Down");
   
   SetIndexBuffer(2, TrendResult);
   SetIndexStyle(2, DRAW_NONE);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[]){

   int limit, i, flag, flagh, trend[10000];
   double up[10000], dn[10000], medianPrice, atr;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
   limit=Bars-counted_bars;
   if(Bars<ATRMaxBars+2+ATRPeriod) ATRMaxBars=Bars-2-ATRPeriod;
   if(ATRMaxBars<=0){
      Print("Need more historical data to calculate the Supertrend");
      return 0;
   }
   //Print(limit);
   //Print(Bars);
   
//----
   for (i = ATRMaxBars; i >= 0; i--) {
      //Print(Bars," ",i);
      TrendUp[i] = EMPTY_VALUE;
      TrendDown[i] = EMPTY_VALUE;
      TrendResult[i] = EMPTY_VALUE;
      atr = iATR(NULL, 0, ATRPeriod, i);
      //Print("atr: "+atr[i]);
      medianPrice = (High[i]+Low[i])/2;
      //Print("medianPrice: "+medianPrice[i]);
      up[i]=medianPrice+(ATRMultiplier*atr);
      //Print("up: "+up[i]);
      dn[i]=medianPrice-(ATRMultiplier*atr);
      //Print("dn: "+dn[i]);
      trend[i]=1;
   
      
      if (Close[i]>up[i+1]) {
         trend[i]=1;
         if (trend[i+1] == -1) changeOfTrend = 1;
         //Print("trend: "+trend[i]);
         
      }
      else if (Close[i]<dn[i+1]) {
         trend[i]=-1;
         if (trend[i+1] == 1) changeOfTrend = 1;
         //Print("trend: "+trend[i]);
      }
      else if (trend[i+1]==1) {
         trend[i]=1;
         changeOfTrend = 0;       
      }
      else if (trend[i+1]==-1) {
         trend[i]=-1;
         changeOfTrend = 0;
      }

      if (trend[i]<0 && trend[i+1]>0) {
         flag=1;
         //Print("flag: "+flag);
      }
      else {
         flag=0;
         //Print("flagh: "+flag);
      }
      
      if (trend[i]>0 && trend[i+1]<0) {
         flagh=1;
         //Print("flagh: "+flagh);
      }
      else {
         flagh=0;
         //Print("flagh: "+flagh);
      }
      
      if (trend[i]>0 && dn[i]<dn[i+1])
         dn[i]=dn[i+1];
      
      if (trend[i]<0 && up[i]>up[i+1])
         up[i]=up[i+1];
      
      if (flag==1)
         up[i]=medianPrice+(ATRMultiplier*atr);
         
      if (flagh==1)
         dn[i]=medianPrice-(ATRMultiplier*atr);
         
      //-- Draw the indicator
      if (trend[i]==1) {
         TrendUp[i]=dn[i];
         if (changeOfTrend == 1) {
            TrendUp[i+1] = TrendDown[i+1];
            changeOfTrend = 0;
         }
      }
      else if (trend[i]==-1) {
         TrendDown[i]=up[i];
         if (changeOfTrend == 1) {
            TrendDown[i+1] = TrendUp[i+1];
            changeOfTrend = 0;
         }
      }
      TrendResult[i]=trend[i];
   }
   WindowRedraw();
      
//----
   return(0);
  }
//+------------------------------------------------------------------+