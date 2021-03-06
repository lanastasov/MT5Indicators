//+------------------------------------------------------------------+
//|                                             AM_MWD_Open_Lines.mq5|
//|                               Copyright © 2021, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Aurthur Musendame"
#property description "Current Month Open Line an Rolling Weekly Open Lines"
#property version "1.1"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info_0 = " == Weekly Open Lines == ";
input int    NumberOfDays = 50;
input bool  WeeklyOpenLineShow = true;
input string WeeklyOpenLineTime = "00:00";
input color  WeeklyOpenLineColor = clrRed;
input string Info_1 =" == Current Month Open Line == ";
input bool   MonthOpenLineShow = true;
input color  MonthOpenLineColor = clrBlue;

//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME,"AM_MWD_Open_Lines");
    IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
   for(int i = 0; i < NumberOfDays; i++)
     {
      ObjectDelete(0, "MonthOpenLine");
      ObjectDelete(0, "WeeklyOpenLine");
      ObjectDelete(0, "WeeklyOpenLine" + string(i));
      Comment("");
      ChartRedraw(0);
   }
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
  
   if(rates_total < min_rates_total) return (RESET);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();   
      
  if(WeeklyOpenLineShow) DrawWeeklyOpenLines(date_time, "WeeklyOpenLine", NumberOfDays, WeeklyOpenLineTime, WeeklyOpenLineColor);
  if(MonthOpenLineShow) DrawMonthOpenLine("MonthOpenLine", MonthOpenLineColor);

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
 
 //+------------------------------------------------------------------------+
//| DrawWeeklyOpenLines: Draws Weekly Open Horizontal Line spanning 5 days |
//+------------------------------------------------------------------------+
bool DrawWeeklyOpenLines(
  datetime date_time,
  string object_name,
  int days_look_back,
  string time1,     
  color clr
  )
  {
    for(int i = 0; i < days_look_back; i++)
    {
   datetime time_1, time_2;
   double price_1;
   int bar_1_position;
   string name = object_name + string(i);      
   MqlDateTime times;
   TimeToStruct(date_time, times);

   time_1   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time1);
   time_2   = time_1 + 414100;

   bar_1_position = iBarShift(NULL, 0, time_1);
   price_1  = iOpen(Symbol(), Period(), bar_1_position);
   
   if(times.day_of_week == 1) 
     {
         ResetLastError();
         if(!plotOpenLine(0, name, time_1, time_2, price_1, price_1, clr)){
            Print(__FUNCTION__, ": Failed to weekly open line",GetLastError());
            return(false);
         }
     }

  date_time = decDateTradeDay(date_time);  

  while(times.day_of_week > 5)
  {
  date_time = decDateTradeDay(date_time);
  TimeToStruct(date_time, times);
  } 
  }
  return(true);
}

//+------------------------------------------------------------------------+
//| DrawMonthOpenLine: Draws Month Open Horizontal Line                    |
//+------------------------------------------------------------------------+
bool DrawMonthOpenLine(string name, color clr)
  {
   datetime time_1, time_2;
   double price_1;

   time_1   = iTime(NULL,PERIOD_MN1,0);
   time_2   = TimeCurrent() + 3600;
   price_1  = iOpen(Symbol(), PERIOD_MN1, 0);
     
   ResetLastError();
   if(!plotOpenLine(0, name, time_1, time_2, price_1, price_1, clr)){
      Print(__FUNCTION__, ": Failed to plot monthly open line ",GetLastError());
      return(false);
   }
   return(true); 
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

      if(time_months == 1 || time_months == 3 || time_months == 5 || time_months == 7 || time_months == 8 || time_months == 10 || time_months == 12) time_days = 31;
      if(time_months == 2) if(!MathMod(time_years, 4)) time_days = 29; else time_days = 28;
      if(time_months == 4 || time_months == 6 || time_months == 9 || time_months == 11) time_days = 30;
     }

   string text;
   StringConcatenate(text, time_years, ".", time_months, ".", time_days, " ", time_hours, ":" , time_mins);
   return(StringToTime(text));
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool plotOpenLine(int obj_id, string obj_name, datetime obj_time_1, datetime obj_time_2, double obj_price_1, double obj_price_2, color ZgColor)
  {
//--
   ResetLastError();
   if(!ObjectDelete(obj_id, obj_name)){
      Print(__FUNCTION__,
            ": Failed to delete old object ",GetLastError());
      return(false);
   }
//--
   ResetLastError();
   if(!ObjectCreate(obj_id, obj_name, OBJ_TREND, 0, obj_time_1, obj_price_1, obj_time_2, obj_price_2)){
      Print(__FUNCTION__,
            ": Failed to create arrow object ",GetLastError());
      return(false);
   }
   ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, ZgColor);
   ObjectSetInteger(obj_id, obj_name, OBJPROP_STYLE, STYLE_DASH);
//--
   return(true);
//--
  }
//+------------------------------------------------------------------+