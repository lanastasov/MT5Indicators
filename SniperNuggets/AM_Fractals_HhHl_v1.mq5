//+------------------------------------------------------------------+
//|                                                     Fractals.mq5 |
//|                   Copyright 2009-2020, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2020, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_NONE
#property indicator_type2   DRAW_NONE
#property indicator_color1  Gray
#property indicator_color2  Gray
#property indicator_label1  "Fractal Up"
#property indicator_label2  "Fractal Down"
//--- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
//--- 10 pixels upper from high price
int    ExtArrowShift=10;
int Labeldistance=2; 
//pip factor 200000 for binary.com
int PipFactor = 100000; //pip factor 200000

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
 // Determine pip factor
   if(Digits() == 3 || Digits() == 5)
      PipFactor = 10;
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
//| deinitialization function                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "amFract", -1, -1);
   Comment("");
   ChartRedraw(0);
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
   //--- main cycle of calculations
   
   for(int i=start; i<rates_total-3 && !IsStopped(); i++)
     {
      //--- Upper Fractal
      if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>=high[i-1] && high[i]>=high[i-2])
        {
         ExtUpperBuffer[i]=high[i];
         string status = "";
         double ch = high[i];
         for(int c=rates_total-3; c >= 0  ; c--)
           {
            if(ExtUpperBuffer[c] != EMPTY_VALUE && ExtUpperBuffer[c] != ch)
              {
               double ph = ExtUpperBuffer[c];
               status = (ch > ph) ? "HH" : "LH";
               double shifted = ch + (Labeldistance * Point() * PipFactor);
               plotTimes(0, "amFract"+(string)i, time[i],status, shifted, clrRed);
               break;
              }
           }
        }
      else
         ExtUpperBuffer[i]=EMPTY_VALUE;

      //--- Lower Fractal
      if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<=low[i-1] && low[i]<=low[i-2])
        {
         ExtLowerBuffer[i]=low[i];
         string status = "";
         double cl = low[i];
         for(int c=rates_total-3; c >= 0  ; c--)
           {
            if(ExtLowerBuffer[c] != EMPTY_VALUE && ExtLowerBuffer[c] !=cl)
              {
               double pl = ExtLowerBuffer[c];
               if(cl > pl)
                  status = "HL";
               else
                  status = "LL";
                  plotTimes(0, "amFract"+(string)i, time[i], status, low[i], clrGreen);
               break;
              }
           }
        }
      else
         ExtLowerBuffer[i]=EMPTY_VALUE;
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void plotTimes(int obj_id, string obj_name, datetime obj_time, string obj_txt, double obj_price, color obj_clr)
  {
   if(ObjectFind(obj_id, obj_name) == -1)
     {
      ObjectCreate(obj_id, obj_name, OBJ_TEXT, 0, obj_time, obj_price);
      ObjectSetString(obj_id, obj_name, OBJPROP_TEXT, obj_txt);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, obj_clr);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void plotPrices(int obj_id, string obj_name, datetime obj_time, double obj_price, color obj_clr)
  {
   if(ObjectFind(obj_id, obj_name) == -1)
     {
      ObjectCreate(obj_id, obj_name, OBJ_ARROW_LEFT_PRICE, 0, obj_time, obj_price);
      ObjectSetInteger(obj_id,  obj_name, OBJPROP_COLOR, obj_clr);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void plotArrow(int obj_id, string obj_name, datetime obj_time, double obj_price, ENUM_OBJECT obj_arrow, ENUM_ARROW_ANCHOR obj_anchor, color obj_clr)
  {
   if(ObjectFind(obj_id, obj_name) == -1)
     {
      ObjectCreate(obj_id, obj_name, obj_arrow, 0, obj_time, obj_price);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_ANCHOR, obj_anchor);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, obj_clr);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_WIDTH, 3);
     }
  }
//+------------------------------------------------------------------+
