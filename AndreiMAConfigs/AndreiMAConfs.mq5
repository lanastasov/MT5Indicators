//+------------------------------------------------------------------+
//|                                                   AndreiOneMA.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property version   "1.1"
#property indicator_chart_window
#include "OneEMAEnums.mqh"

#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_width1 2
#property indicator_label1 "AndreiOneMA"

input string Info_1  =" == Andrei Florin Config Settings == ";
input TRADING_TIMEFRAMES AC1_TradingTF = TRADING_H4; // Signal Time Frame
input TREND_TIMEFRAMES AC1_TrendTF = TREND_W1;       // Trend Time Frame
input Andrei_MA_MODES AC1_MAType = A_SMA;            // MA Mode
input string Info_2  =" == Text Placement Properties == ";
input bool showConfigs  =true; // Show Configs Text
input ENUM_BASE_CORNER text_corner = CORNER_LEFT_UPPER; // Text Corner
input int text_x_pos = 5; // X POSITION
input int text_y_pos = 20; // Y POSITION
input color text_color = clrBlue; // Y Color

int andrei_period;
double Andrei_MA[];
int    Andrei_MA_Handle;
string obj_name = "AndreiOneMA";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {  
   SetIndexBuffer(0,Andrei_MA,INDICATOR_DATA);
   andrei_period = GetPeriod(AC1_TrendTF, AC1_TradingTF);
   ENUM_MA_METHOD ma_types = MODE_SMA;
   switch(AC1_MAType) {
      case 0 : ma_types = MODE_SMA; break;
      case 1 : ma_types =  MODE_EMA; break;
   }
   Andrei_MA_Handle=iMA(Symbol(), Period(), andrei_period, 0, ma_types, PRICE_CLOSE);
  }
 
//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
    ObjectDelete(0, obj_name);

   ChartRedraw(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   int start=prev_calculated;
   if(start>0) start--;
   if(start<rates_total)
     {
      CopyBuffer(Andrei_MA_Handle, 0, 0, rates_total - start, Andrei_MA);
      //----
      if(showConfigs){
         string text_output = GetMAType(AC1_MAType) + "(" + (string)andrei_period + ") || "  + "Trading TimeFrame: " + GetTradingTF(AC1_TradingTF) + " ||  Trend TimeFame: " + GetTrendTF(AC1_TrendTF );
         
         ResetLastError();
         if(!ObjectDelete(0, obj_name)){
            Print(__FUNCTION__, ": Failed to delete old object ",GetLastError());
            return(0);
         }
         
         ResetLastError();
         if(!ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0,0)){
            Print(__FUNCTION__, ": Failed to create arrow object ",GetLastError());
            return(0);
         }
         ObjectSetString(0, obj_name, OBJPROP_TEXT, text_output);
         ObjectSetInteger(0, obj_name, OBJPROP_CORNER, text_corner);
         ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, text_x_pos);
         ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, text_y_pos);
         ObjectSetInteger(0, obj_name, OBJPROP_COLOR, text_color);
      }
      //----
     }
   
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+

int GetPeriod(int Trend_TF, int Trade_TF)
{
   if(Trade_TF == 100) return (int)(Trend_TF/0.25); //m15 entry
   else 
   if(Trade_TF == 1000) return (int)(Trend_TF/0.5); // m30 entry
   else return (int)(Trend_TF/Trade_TF);            // hours based entries
}
//+------------------------------------------------------------------+
string GetTrendTF(int tr)
{
   switch(tr) {
      case 1: return "H1"; break;
      case 4: return "H4"; break;
      case 6: return "H6"; break;
      case 8: return "H8"; break;
      case 12: return "H12"; break;
      case 24: return "D1"; break;
      case 48: return "D2"; break;
      case 96: return "D4"; break;
      case 120: return "W1"; break;
      case 240: return "W2"; break;
      case 480: return "M1"; break;
      case 960: return "M2"; break;
      case 1440: return "M3"; break;
      default: return "Error"; break;
   }
}
//+------------------------------------------------------------------+
string GetTradingTF(int tr)
{
   switch(tr) {
      case 100: return "M15"; break;
      case 1000: return "M30"; break;
      case 1: return "H1"; break;
      case 2: return "H2"; break;
      case 4: return "H4"; break;
      case 24: return "D1"; break;
      default: return "Error"; break;
   }
}
//+------------------------------------------------------------------+
string GetMAType(int tr)
{
   switch(tr) {
      case 0: return "SMA"; break;
      case 1: return "EMA"; break;
      default: return "Error"; break;
   }
}