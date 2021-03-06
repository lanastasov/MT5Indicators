//+------------------------------------------------------------------+
//|                                                 AM_ADR_Marker.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "Average Daily Range Marker"
#property version   "1.0"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#include "adr.mqh"
#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
int    NumberOfDays = 5;
input string Info  =" == == ADR Marker == == ";
input bool showADR  = true; // Show ADR 
input color adrmColor = clrBlue; // Markers Color
input int adrm_LThickness = 1; // Markers Line Thickness
input ENUM_LINE_STYLE adr_line_style = STYLE_DASHDOTDOT;
input bool useCustomRange  = false; // Use  Custom Range Days 
input int adr_past_days = 5; // Range Days for ADR Calc\
input bool DrawMarkers  = false; // Draw ADR Markers


//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME,"AM_ADR_Marker");
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
    ObjectDelete(0, "ADRMHigh");
    ObjectDelete(0, "ADRMLow");
    ObjectDelete(0, "ADRMStart");
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
  
  ///=============Testing Ideas
  ///=============ENDOF Testing Ideas
  
  
   if(rates_total < min_rates_total) return (RESET);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();   
      
   if(showADR) ADR_Maker(date_time, "ADRM", adrmColor, adrm_LThickness, adr_line_style, useCustomRange, adr_past_days, DrawMarkers, high, low);

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
 int TimeDayOfWeek(datetime date)
  {
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.day_of_week);
  }    
