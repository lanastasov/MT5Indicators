//+------------------------------------------------------------------+
//|                                                    AM_TrueDay.mq5|
//|                               Copyright © 2021, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Aurthur Musendame"
#property description "True Trading Day"
#property version   "1.1"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#include <ChartObjects/ChartObjectsLines.mqh>
CChartObjectTrend line;

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info  =" == True Day Parameters == ";
input int    NumberOfDays = 5;
input bool ShowTrueDay = true;
input string TrueDayStartTime = "02:00";
input string TrueDayEndTime = "19:00";
input color TrueDayStartColor = clrGreen;
input color TrueDayEndColor = clrRed;
input ENUM_LINE_STYLE TrueDayLineStyle = STYLE_DASHDOTDOT;
//+-----------------------------------+

// data starting point
int min_rates_total;
// custome period seperators
double textprice, newtextprice,
       max_price, min_price;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME,"AM_TrueDay");
    IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
    //--- find the highest and lowest values of the chart then calculate textposition == GetChartHighPrice
    textprice  = GetChartHighPrice();  
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
   for(int i = 0; i < NumberOfDays; i++)
     {
      ObjectDelete(0, "TrueDay" + string(i));
      ObjectDelete(0, "TrueDay" + string(i) + "Start");
      ObjectDelete(0, "TrueDay" + string(i) + "End");
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
   if(rates_total < min_rates_total) return (RESET);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();   
      
  if(ShowTrueDay) DrawTrueDay(date_time, "TrueDay", NumberOfDays, TrueDayStartTime, TrueDayEndTime, TrueDayStartColor, TrueDayEndColor, TrueDayLineStyle);
   
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
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      // Custom Periods Aligh to Chart Height
      textprice = GetChartHighPrice();      
      int total_trends_ = ObjectsTotal(0, 0, OBJ_TREND);
      for (int i = 0; i <= total_trends_; i++){
        string _name = ObjectName(0, i , 0 , OBJ_TREND);
        if (StringSubstr(_name, 0, 3) == "CPL"){
          long t1 = ObjectGetInteger(0, _name, OBJPROP_TIME, 1);
           ObjectMove(0, _name, 1, t1, textprice);
        }
        // TrueDay CustomPeriods
        if (StringSubstr(_name, 0, 7) == "TrueDay"){
          long t1 = ObjectGetInteger(0, _name, OBJPROP_TIME, 1);
           ObjectMove(0, _name, 1, t1, textprice);
        }
      }
      newtextprice = textprice;    
      ChartRedraw();    
   }
 }
 

//+------------------------------------------------------------------------+
//| DrawTrueDay: Draws Custom period Seperators that show true day         |
//+------------------------------------------------------------------------+
bool DrawTrueDay(
  datetime date_time,  
  string obj_name, 
  int days_look_back,
  string startTime, 
  string endTime, 
  color startColor, 
  color endColor,
  ENUM_LINE_STYLE truedayLineStyle
  )
{
  for(int i = 0; i < days_look_back; i++)
  {
    string name = obj_name + string(i);
    datetime time_start  = StringToTime(TimeToString(date_time, TIME_DATE) + " " + startTime);
    datetime time_end  = StringToTime(TimeToString(date_time, TIME_DATE) + " " + endTime);
    textprice = GetChartHighPrice();
    // TrueDay Start
    int _day = TimeDayOfWeek(date_time);
    if(_day > 0 && _day < 6){  
      ResetLastError();
      if(!drawVLine(0, name + "Start", "TrueDaySart", time_start, textprice, truedayLineStyle, startColor)){
         Print(__FUNCTION__,
               ": Failed to draw line",GetLastError());
         return(false);
      }
      // TrueDay End 
      ResetLastError();
      if(!drawVLine(0, name + "End", "TrueDayEnd", time_end, textprice, truedayLineStyle, endColor)){
         Print(__FUNCTION__,
               ": Failed to draw line",GetLastError());
         return(false);
      }
   }
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
//|                                                  OjectDrawers.mqh|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+

int TimeDayOfWeek(datetime date)
  {
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.day_of_week);
  }    

//+------------------------------------------------------------------+
int ChartHeightInPixelsGet(const long chart_ID=0,const int sub_window=0)
  {
  long result=-1;
  ResetLastError();
  if(!ChartGetInteger(chart_ID,CHART_HEIGHT_IN_PIXELS,sub_window,result))
  {
    Print(__FUNCTION__+", Error Code = ",GetLastError());
  }
  if((int)result == 0) result = -1;
  return((int)result);
  }

//+------------------------------------------------------------------+
double GetChartHighPrice()
  {
    max_price=ChartGetDouble(0,CHART_PRICE_MAX);
    min_price=ChartGetDouble(0,CHART_PRICE_MIN);   
    return(max_price-((max_price-min_price) * (0/ChartHeightInPixelsGet(0, 0)))); 
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
bool drawVLine(int obj_id, string obj_name, string obj_description, datetime obj_time, double obj_price, ENUM_LINE_STYLE line_style, color obj_clr)
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
   if(!line.Create(obj_id, obj_name, 0, obj_time, Point(), obj_time, obj_price)){
      Print(__FUNCTION__,
            ": Failed to create line object ",GetLastError());
      return(false);
   }
   line.Color(obj_clr);
   line.Description(obj_description);
   line.SetInteger(OBJPROP_STYLE, line_style);
   line.SetString(OBJPROP_TEXT, obj_description);
   
   return(true);
  }
//+------------------------------------------------------------------+