//+------------------------------------------------------------------+
//|                                            AM_HOD_LOD_Fractal.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "AM High Of Day, Low Of Day Fractal with -- Time Price Studies --"
#property version   "1.1"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

#define RESET 0

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info  =" == Look Back Days == ";
input int    NumberOfDays = 20;
input bool   ShowHODLOD = true;
input bool   ShowPrice =true;
input bool   ShowTime =false;
input bool   ShowArrow =false;
input color  hodColor =clrRed;
input color  lodColor =clrGreen;


//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+
//| initialization function                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
   IndicatorSetString(INDICATOR_SHORTNAME, "AMHodLod");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i = 0; i < NumberOfDays; i++)
     {
      ObjectDelete(0, "HodLod" + string(i) + "HOD-Price");
      ObjectDelete(0, "HodLod" + string(i) + "HOD-Time");
      ObjectDelete(0, "HodLod" + string(i) + "HOD-Arrow");
      ObjectDelete(0, "HodLod" + string(i) + "LOD-Price");
      ObjectDelete(0, "HodLod" + string(i) + "LOD-Time");
      ObjectDelete(0, "HodLod" + string(i) + "LOD-Arrow");
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

   if(rates_total < min_rates_total)
      return (RESET);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();

   if(ShowHODLOD)
      plotHODLOD(date_time, "HodLod", NumberOfDays, ShowPrice, ShowTime, ShowArrow, hodColor, lodColor, high, low);

   ChartRedraw(0);
   return(rates_total);
  } //+------------------------------------------ END ITERATION FUNCTION

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
  }


//+------------------------------------------------------------------+
//| plotHODLOD:                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool plotHODLOD(
   datetime date_time,
   string object_name,
   int days_look_back,
   bool showPrice,
   bool showTime,
   bool showArrow,
   color hod_color,
   color lod_color,
   const double &High[],
   const double &Low[])
  {

   datetime candle_time, time_beg_of_day, time_end_of_day;
   double candle_high, candle_low, hi_price, lo_price, day_range;
   int bar_last_position, bar_first_position, num_elements;
   int chart_id = 0;
   int angle_high = 75; //  45,
   int angle_low = -45; // -45,
   string time_show, nameHod, nameLod;

   for(int i = 0; i < days_look_back; i++)
     {     
      nameHod = object_name + (string)i + "HOD";
      nameLod = object_name + (string)i + "LOD";
      
      // days hi and lo
      hi_price     = iHigh(Symbol(), PERIOD_D1, i);
      lo_price     = iLow(Symbol(), PERIOD_D1, i);
      
      // time start and end of day
      time_beg_of_day  = iTime(Symbol(), PERIOD_D1, i);
      time_end_of_day  =  time_beg_of_day + 60*60*24;
 
      // first and last bar position of the day
      bar_last_position = iBarShift(NULL, PERIOD_M1, time_beg_of_day);
      bar_first_position   = iBarShift(NULL, PERIOD_M1, time_end_of_day);

      num_elements  = bar_last_position - bar_first_position;
      
      day_range = GetPips(hi_price, lo_price);

      // in this day loop through the 1 min time frame and detect hod/lod
      for(int c = 0; c < num_elements+1; c++)
        {
         candle_high = iHigh(NULL, PERIOD_M1, c + bar_first_position);
         candle_low  = iLow(NULL, PERIOD_M1, c + bar_first_position);
         candle_time = iTime(NULL, PERIOD_M1, c + bar_first_position);
         time_show  = StringSubstr((string)candle_time, 10, 20);

         // high fractal
         if(candle_high == hi_price)
           {
            if(showTime){  
               ResetLastError();
               if(!plotTimes(chart_id, nameHod+ "-Time", candle_time, time_show, hi_price, hodColor, angle_high)){
                  Print(__FUNCTION__, ": Failed to plot time tag ",GetLastError());
                  return(false);
               }
            }
               
            if(showPrice){  
               ResetLastError();
               if(!plotPrices(chart_id, nameHod + "-Price", candle_time, hi_price, hodColor)){
                  Print(__FUNCTION__, ": Failed to plot price tag",GetLastError());
                  return(false);
               }
            }
               
            if(showArrow){  
               ResetLastError();
               if(!plotArrow(chart_id, nameHod + "-Arrow", candle_time, hi_price, OBJ_ARROW_DOWN, ANCHOR_BOTTOM, hodColor)){
                  Print(__FUNCTION__, ": Failed to plot arrow ",GetLastError());
                  return(false);
               }
            }
               
           }

         // low fractal
         if(candle_low == lo_price)
           {
            if(showTime){  
               ResetLastError();
               if(!plotTimes(chart_id, nameLod+ "-Time", candle_time, time_show, lo_price, lodColor, angle_low)){
                  Print(__FUNCTION__, ": Failed to plot time tag ",GetLastError());
                  return(false);
               }
            }
               
            if(showPrice){  
               ResetLastError();
               if(!plotPrices(chart_id, nameLod + "-Price", candle_time, lo_price, lodColor)){
                  Print(__FUNCTION__, ": Failed to plot price tag ",GetLastError());
                  return(false);
               }
            }
               
            if(showArrow){  
               ResetLastError();
               if(!plotArrow(chart_id, nameLod + "-Arrow", candle_time, lo_price, OBJ_ARROW_UP, ANCHOR_TOP, lodColor)){
                  Print(__FUNCTION__, ": Failed to plot arrow ",GetLastError());
                  return(false);
               }
            }
               
           }

        }
      // end of drawings

      date_time = decDateTradeDay(date_time);
      MqlDateTime times;
      TimeToStruct(date_time, times);

      while(times.day_of_week > 5)
        {
         date_time = decDateTradeDay(date_time);
         TimeToStruct(date_time, times);
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
double GetPips(double price_high, double price_low)
  {
   return MathRound((MathAbs(price_high - price_low)/Point()))/10.0;
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
      Print(__FUNCTION__,
            ": Failed to delete old object ",GetLastError());
      return(false);
   }
//--
   ResetLastError();
   if(!ObjectCreate(obj_id, obj_name, OBJ_TEXT, 0, obj_time, obj_price)){
      Print(__FUNCTION__,
            ": Failed to create arrow object ",GetLastError());
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
      Print(__FUNCTION__,
            ": Failed to delete old object ",GetLastError());
      return(false);
   }
//--
   ResetLastError();
   if(!ObjectCreate(obj_id, obj_name, OBJ_ARROW_LEFT_PRICE, 0, obj_time, obj_price)){
      Print(__FUNCTION__,
            ": Failed to create arrow object ",GetLastError());
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
      Print(__FUNCTION__,
            ": Failed to delete old object ",GetLastError());
      return(false);
   }
//--
   ResetLastError();
   if(!ObjectCreate(obj_id, obj_name, obj_arrow, 0, obj_time, obj_price)){
      Print(__FUNCTION__,
            ": Failed to create arrow object ",GetLastError());
      return(false);
   }
   ObjectSetInteger(obj_id, obj_name, OBJPROP_ANCHOR, obj_anchor);
   ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, obj_clr);
   ObjectSetInteger(obj_id, obj_name, OBJPROP_WIDTH, 3);
   return(true);
  }
//+------------------------------------------------------------------+
