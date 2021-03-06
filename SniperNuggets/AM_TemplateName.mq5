//+------------------------------------------------------------------+
//|                                               AM_TemplateName.mq5|
//|                               Copyright © 2021, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Aurthur Musendame"
#property description "Text that you want shown on your chart"
#property version   "1.0"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
int    NumberOfDays = 5;
input string Info  =" == == Template Name == == ";
input bool showTName  = true; // Show Template Name 
input string TName  = "Template Name"; // Template Name 
input color TNameColor = clrYellow; // Template Name Color
input int TNameSize = 20; // Template Name Size
input ENUM_BASE_CORNER TNameCorner = CORNER_RIGHT_LOWER; // Template Name Text Corner
input ENUM_ANCHOR_POINT TNameAnchor = ANCHOR_RIGHT_LOWER; // Template Name Anchor
input int TName_x_pos = 10; // TName X POSITION
input int TName_y_pos = 10; //  TName Y POSITION


//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME,"AM_TemplateName");
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
   ObjectDelete(0, "TName");
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

   if(showTName) WriteTemplateName("TName", TName, TNameColor, TNameSize, TNameCorner, TNameAnchor, TName_x_pos, TName_y_pos);

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
 
 
//+----------------------------------------------------------------------------------------------+
//| WriteTemplateName: WaterMark                                                                 |
//+----------------------------------------------------------------------------------------------+

void WriteTemplateName(
   string name, 
   string text, 
   color clr, 
   int font_size, 
   ENUM_BASE_CORNER corner, 
   ENUM_ANCHOR_POINT anchor, 
   int x, 
   int y
)
{
   ObjectCreate(0 , name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0 ,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(0 ,name,OBJPROP_YDISTANCE,y); 
   ObjectSetInteger(0 ,name,OBJPROP_CORNER,corner); 
   ObjectSetString(0 ,name,OBJPROP_TEXT,text); 
   ObjectSetString(0 ,name,OBJPROP_FONT, "Arial"); 
   ObjectSetInteger(0 ,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(0 ,name,OBJPROP_ANCHOR,anchor); 
   ObjectSetInteger(0 ,name,OBJPROP_COLOR,clr); 
   ObjectSetInteger(0 ,name,OBJPROP_BACK, true); 
   ObjectSetInteger(0 ,name,OBJPROP_ZORDER, 0);   
}