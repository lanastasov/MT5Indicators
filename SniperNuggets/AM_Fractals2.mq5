//+------------------------------------------------------------------+
//|                                                  AM_Fractals.mq5 |
//|                                Copyright 2020, Aurthur Musendame |
//|                          credits to Metaquotes Fractal indicator |
//+------------------------------------------------------------------+
#property copyright "2021, Aurthur Musendame"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_color1  Gray
#property indicator_color2  Gray
#property indicator_label1  "Fractal Up"
#property indicator_label2  "Fractal Down"
//--- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
//--- 10 pixels upper from high price
int    ExtArrowShift=-10;

//--- User Input Controllable Settings
enum FACTAL_CHOICE
{
   TIMESTUDY = 1,  // TIME STUDIES
   STANDARD = 2,  // STANDARD FRACTAL
};

enum FRACTAL_CANDLES
{
   ONE = 1,  // ONE CANDLE
   TWO = 2,  // TWO CANDLES
   THREE = 3,  // THREE CANDLES
   FOUR = 4,  // FOUR CANDLES
   FIVE = 5,  // FIVE CANDLES
};

input FACTAL_CHOICE fractalChoice = TIMESTUDY;
input FRACTAL_CANDLES fractalCandles = FIVE;
input color timeColor = clrBlue;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowerBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//--- arrow shifts when drawing
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ExtArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ExtArrowShift);
//--- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//|  Fractals on 5 bars                                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  if(rates_total<5)
    return(0);

  int start;

    //--- clean up arrays
    if(prev_calculated<7)
    {
      start=2;
      ArrayInitialize(ExtUpperBuffer,EMPTY_VALUE);
      ArrayInitialize(ExtLowerBuffer,EMPTY_VALUE);
    }
    else
      start=rates_total-5;

    datetime time_1;
    double price_high, price_low;
    int chart_id = 0;
    string nameHigh, nameLow, time_show;
    string obj_name = "TimePrice-";


    //--- main cycle of calculations
    for(int i=start; i<rates_total-3 && !IsStopped(); i++)
    {
      // Set names
      nameHigh = obj_name + (string)i + "-High";
      nameLow  = obj_name + (string)i + "-Low";
      // get candle i time, etract sub string HH:MM
      time_1    = iTime(Symbol(), Period(), i); // time[i] is giving an error
      time_show = StringSubstr((string)time_1, 10, 16);
      // get candle high and low
      price_high = iHigh(Symbol(), Period(), i);
      price_low  = iLow(Symbol(), Period(), i);

      if (fractalCandles == 1) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>=high[i-1])
          {
            ExtUpperBuffer[i]=high[i];
            plotTimes(chart_id, nameHigh, time_1, time_show, price_high, timeColor);
          } else {
            ExtUpperBuffer[i]=EMPTY_VALUE;
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<=low[i-1])
          {
            ExtLowerBuffer[i]=low[i];
            plotTimes(chart_id, nameLow, time_1, time_show, price_low, timeColor);
          } else {
            ExtLowerBuffer[i]=EMPTY_VALUE;
          }
      } 
      if (fractalCandles == 2) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>=high[i-1] && high[i]>=high[i-2])
          {
            ExtUpperBuffer[i]=high[i];
            plotTimes(chart_id, nameHigh, time_1, time_show, price_high, timeColor);
          } else {
            ExtUpperBuffer[i]=EMPTY_VALUE;
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<=low[i-1] && low[i]<=low[i-2])
          {
            ExtLowerBuffer[i]=low[i];
            plotTimes(chart_id, nameLow, time_1, time_show, price_low, timeColor);
          } else {
            ExtLowerBuffer[i]=EMPTY_VALUE;
          }
      } 
      if (fractalCandles == 3) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>high[i+3] && high[i]>=high[i-1] && high[i]>=high[i-2] && high[i]>=high[i-3])
          {
            ExtUpperBuffer[i]=high[i];
            plotTimes(chart_id, nameHigh, time_1, time_show, price_high, timeColor);
          } else {
            ExtUpperBuffer[i]=EMPTY_VALUE;
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<low[i+3] && low[i]<=low[i-1] && low[i]<=low[i-2] && low[i]<=low[i-3])
          {
            ExtLowerBuffer[i]=low[i];
            plotTimes(chart_id, nameLow, time_1, time_show, price_low, timeColor);
          } else {
            ExtLowerBuffer[i]=EMPTY_VALUE;
          }
      } 
      if (fractalCandles == 4) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>high[i+3] && high[i]>high[i+4] && high[i]>=high[i-1] && high[i]>=high[i-2] && high[i]>=high[i-3] && high[i]>=high[i-4])
          {
            ExtUpperBuffer[i]=high[i];
            plotTimes(chart_id, nameHigh, time_1, time_show, price_high, timeColor);
          } else {
            ExtUpperBuffer[i]=EMPTY_VALUE;
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<low[i+3] && low[i]<low[i+4] && low[i]<=low[i-1] && low[i]<=low[i-2] && low[i]<=low[i-3] && low[i]<=low[i-4])
          {
            ExtLowerBuffer[i]=low[i];
            plotTimes(chart_id, nameLow, time_1, time_show, price_low, timeColor);
          } else {
            ExtLowerBuffer[i]=EMPTY_VALUE;
          }
      } 
      if (fractalCandles == 5) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>high[i+3] && high[i]>high[i+4] && high[i]>high[i+5] && high[i]>=high[i-1] && high[i]>=high[i-2] && high[i]>=high[i-3] && high[i]>=high[i-4] && high[i]>=high[i-5])
          {
            ExtUpperBuffer[i]=high[i];
            plotTimes(chart_id, nameHigh, time_1, time_show, price_high, timeColor);
          } else {
            ExtUpperBuffer[i]=EMPTY_VALUE;
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<low[i+3] && low[i]<low[i+4] && low[i]<low[i+5] && low[i]<=low[i-1] && low[i]<=low[i-2] && low[i]<=low[i-3] && low[i]<=low[i-4] && low[i]<=low[i-5])
          {
            ExtLowerBuffer[i]=low[i];
            plotTimes(chart_id, nameLow, time_1, time_show, price_low, timeColor);
          } else {
            ExtLowerBuffer[i]=EMPTY_VALUE;
          }
      } 
      //
  }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
}

//+------------------------------------------------------------------+

void plotTimes(int obj_id, string obj_name, datetime obj_time, string obj_txt, double obj_price, color obj_clr){
  if(ObjectFind(obj_id, obj_name) == -1)
    {
        ObjectCreate(obj_id, obj_name, OBJ_TEXT, 0, obj_time, obj_price);
        ObjectSetString(obj_id, obj_name, OBJPROP_TEXT, obj_txt);
        ObjectSetInteger(obj_id, obj_name, OBJPROP_FONTSIZE, 8);
        ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, obj_clr);
    }
}