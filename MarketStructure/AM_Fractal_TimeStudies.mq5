//+------------------------------------------------------------------+
//|                                                  AM_TimeStudies.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "Highs and Lows Price Time Studies"
#property version   "1.1"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

#define RESET 0

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info  =" == + Time Study Parameters  + == ";
input bool ShowTimeStudies = true; // Show Time Studies
input int HistoryLookBack = 1000; // Look Back Candle Count (0 for all)
input int CandleCount = 5; // candles around high/low
//
input bool ShowTimes = true; //  Show Time labels
input color timeColor = clrBlue;  // time label color
//
input bool ShowPrices = false; // Show Price Labels
input color priceColor = clrBlue;
//
input bool ShowFractals = false; // Show Fractal Arrows
input color arrowColor = clrBlue;


//+-----------------------------------+

// data starting point
int min_rates_total, new_rates_total;

//+------------------------------------------------------------------+
//| initialization function                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "AM_TimeStudies");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "AMFractal", -1, -1); // this must delete everything but its not working
   int obj_total = ObjectsTotal(0, -1, -1);
   for(int i=0; i < obj_total; i++)
     {
      ObjectDelete(0, "AMFractal" + string(i) + "-High-Time");
      ObjectDelete(0, "AMFractal" + string(i) + "-Low-Time");
      ObjectDelete(0, "AMFractal" + string(i) + "-High-Price");
      ObjectDelete(0, "AMFractal" + string(i) + "-Low-Price");
      ObjectDelete(0, "AMFractal" + string(i) + "-High-Arrow");
      ObjectDelete(0, "AMFractal" + string(i) + "-Low-Arrow");
     }
   Comment("");
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| iteration function                                    |
//+------------------------------------------------------------------+
int OnCalculate(
   const int       rates_total,
   const int       prev_calculated,
   const datetime  &time[],
   const double    &open[],
   const double    &high[],
   const double    &low[],
   const double    &close[],
   const long      &tick_volume[],
   const long      &volume[],
   const int       &spread[]
)
  {

   if(HistoryLookBack == 0)
      new_rates_total = rates_total;
   else
      new_rates_total = HistoryLookBack;

   if(new_rates_total < CandleCount*2 + 1)
      return(0);

   int start = CandleCount;

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();

   if(ShowTimeStudies)
      PriceTimeStudies(
         date_time,
         "AMFractal",
         start,
         new_rates_total,
         timeColor,
         priceColor,
         arrowColor,
         CandleCount,
         ShowPrices,
         ShowTimes,
         ShowFractals,
         high,
         low,
         time
      );

   ChartRedraw(0);
   return(new_rates_total);
  }
//+------------------------------------------ END ITERATION FUNCTION

//+----------------------------------------------------------------------------------------------+
//| PriceTimeStudies:                                                                            |
//+----------------------------------------------------------------------------------------------+
bool PriceTimeStudies(
   datetime  date_time,
   string obj_name,
   int start,
   int look_back,
   color timeColr,
   color priceColr,
   color arrowColr,
   int candleCount,
   bool showPriceLabels,
   bool showTimeLabels,
   bool showFractalArrow,
   const double &high[],
   const double &low[],
   const datetime  &time[]
)
  {

   datetime time_1;
   double price_high, price_low, this_high, this_low;
   int chart_id = 0, bar_far_right_position, num_elements;
   string nameHigh, nameLow, time_show;
   int angle_high = 75; //  45,
   int angle_low = -45; // -45,


   for(int i = start; i < look_back - candleCount*2 - candleCount - 1 && !IsStopped(); i++)
     {
      // Set names
      nameHigh = obj_name + (string)i + "-High";
      nameLow  = obj_name + (string)i + "-Low";
      // get candle i time, etract sub string HH:MM
      int timeSize = ArraySize(time);
      if(i >= timeSize) return(false);
      time_1    =  time[i]; // iTime(NULL, 0, i); // time[i]
      time_show = StringSubstr((string)time_1, 10, 20);
      // get current high and low
      this_high = iHigh(NULL, 0, i);
      this_low  = iLow(NULL, 0, i);

      // Candle range Low and high ::   [bar_far_left_position, ..., i , ..., bar_far_right_position]
      num_elements = candleCount*2 + 1;
      bar_far_right_position = i - candleCount;
      price_high = high[iHighest(Symbol(), Period(), MODE_HIGH, num_elements, bar_far_right_position)];
      price_low  = low[iLowest(Symbol(), Period(), MODE_LOW, num_elements, bar_far_right_position)];

      // high fractal
      if(this_high == price_high)
        {
            if(showTimeLabels){  
               ResetLastError();
               if(!plotTimes(chart_id, nameHigh+ "-Time", time_1, time_show, price_high, timeColr, angle_high)){
                  Print(__FUNCTION__, ": Failed to plot time tag ",GetLastError());
                  return(false);
               }
            }
               
            if(showPriceLabels){  
               ResetLastError();
               if(!plotPrices(chart_id, nameHigh + "-Price", time_1, price_high, priceColr)){
                  Print(__FUNCTION__, ": Failed to plot price tag",GetLastError());
                  return(false);
               }
            }
               
            if(showFractalArrow){  
               ResetLastError();
               if(!plotArrow(chart_id, nameHigh + "-Arrow", time_1, price_high, OBJ_ARROW_DOWN, ANCHOR_BOTTOM, arrowColr)){
                  Print(__FUNCTION__, ": Failed to plot arrow ",GetLastError());
                  return(false);
               }
            }
        }

      // low fractal
      if(this_low == price_low)
        {
            if(showTimeLabels){  
               ResetLastError();
               if(!plotTimes(chart_id, nameLow+ "-Time", time_1, time_show, price_low, timeColr, angle_low)){
                  Print(__FUNCTION__, ": Failed to plot time tag ",GetLastError());
                  return(false);
               }
            }
               
            if(showPriceLabels){  
               ResetLastError();
               if(!plotPrices(chart_id, nameLow + "-Price", time_1, price_low, priceColr)){
                  Print(__FUNCTION__, ": Failed to plot price tag ",GetLastError());
                  return(false);
               }
            }
               
            if(showFractalArrow){  
               ResetLastError();
               if(!plotArrow(chart_id, nameHigh + "-Arrow", time_1, price_low, OBJ_ARROW_UP, ANCHOR_TOP, arrowColr)){
                  Print(__FUNCTION__, ": Failed to plot arrow ",GetLastError());
                  return(false);
               }
            }
            
        }
     }
    return(true);
  }

//+------------------------------------------------------------------+
int TimeDayOfWeek(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }

//+------------------------------------------------------------------+
datetime decDateTradeDay(datetime date_time)
  {
   MqlDateTime times;
   TimeToStruct(date_time, times);
   int time_years  = times.year;
   int time_months = times.mon;
   int time_days   = times.day;
   int time_hours  = times.hour;
   int time_mins   = times.min;

   time_days--;
   if(time_days == 0)
     {
      time_months--;

      if(!time_months)
        {
         time_years--;
         time_months = 12;
        }

      if(time_months == 1 || time_months == 3 || time_months == 5 || time_months == 7 || time_months == 8 || time_months == 10 || time_months == 12)
         time_days = 31;
      if(time_months == 2)
         if(!MathMod(time_years, 4))
            time_days = 29;
         else
            time_days = 28;
      if(time_months == 4 || time_months == 6 || time_months == 9 || time_months == 11)
         time_days = 30;
     }

   string text;
   StringConcatenate(text, time_years, ".", time_months, ".", time_days, " ", time_hours, ":", time_mins);
   return(StringToTime(text));
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool plotTimes(int obj_id, string obj_name, datetime obj_time, string obj_txt, double obj_price, color obj_clr, int obj_angle)
  {
   ResetLastError();
   if(!ObjectDelete(obj_id, obj_name)){
      Print(__FUNCTION__, ": Failed to delete old object ",GetLastError());
      return(false);
   }
//--
   ResetLastError();
   if(!ObjectCreate(obj_id, obj_name, OBJ_TEXT, 0, obj_time, obj_price)){
      Print(__FUNCTION__, ": Failed to delete old object ",GetLastError());
      return(false);
   }  
   ObjectSetString(obj_id, obj_name, OBJPROP_TEXT, obj_txt);
   ObjectSetInteger(obj_id, obj_name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, obj_clr);
   ObjectSetDouble(obj_id, obj_name, OBJPROP_ANGLE, obj_angle);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool plotPrices(int obj_id, string obj_name, datetime obj_time, double obj_price, color obj_clr)
  {
   ResetLastError();
   if(!ObjectDelete(obj_id, obj_name)){
      Print(__FUNCTION__, ": Failed to delete old object ",GetLastError());
      return(false);
   }
//--
   ResetLastError();
   if(!ObjectCreate(obj_id, obj_name, OBJ_ARROW_LEFT_PRICE, 0, obj_time, obj_price)){
      Print(__FUNCTION__,  ": Failed to create arrow object ",GetLastError());
      return(false);
   }
   ObjectSetInteger(obj_id,  obj_name, OBJPROP_COLOR, obj_clr);
   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool plotArrow(int obj_id, string obj_name, datetime obj_time, double obj_price, ENUM_OBJECT obj_arrow, ENUM_ARROW_ANCHOR obj_anchor, color obj_clr)
  {
   ResetLastError();
   if(!ObjectDelete(obj_id, obj_name)){
      Print(__FUNCTION__, ": Failed to delete old object ",GetLastError());
      return(false);
   }
//--
   ResetLastError();
   if(!ObjectCreate(obj_id, obj_name, obj_arrow, 0, obj_time, obj_price)){
      Print(__FUNCTION__, ": Failed to create arrow object ",GetLastError());
      return(false);
   }
   ObjectSetInteger(obj_id, obj_name, OBJPROP_ANCHOR, obj_anchor);
   ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, obj_clr);
   ObjectSetInteger(obj_id, obj_name, OBJPROP_WIDTH, 3);
   return(true);
  }
//+------------------------------------------------------------------+