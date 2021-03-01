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
//+-----------------------------------+
input string Info  =" == + Hello  + == ";
input bool ShowTimeStudies = true; // Show Time Studies
input int CandleCount = 5; // candles around high/low
//
input bool ShowTimes = false; //  Show Time labels
input color timeColor = clrBlue;  // time label color
//
input bool ShowPrices = false; // Show Price Labels
input color priceColor = clrBlue;
//
input bool ShowFractals = false; // Show Fractal Arrows
input color arrowColor = clrBlue;
//
input bool ShowHHLL = true; //  Show HH and LL
input color hhllColor = clrBlue;  // time HH and LL
//
input int Labeldistance=2;
//shiftMultiplier 100000 for binary.com
input int shiftMultiplier = 100000; // multiplier

// ---

//--- 10 pixels upper from high price
int ExtArrowShift=10; //Arrow Shift
int PipFactor = 1*shiftMultiplier; //pip factor 200000

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
// Determine pip factor
   if(Digits() == 3 || Digits() == 5)
      PipFactor = 10*shiftMultiplier;
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
   ObjectsDeleteAll(0, "AMFractHHHL", -1, -1);
   int obj_total = ObjectsTotal(0, -1, -1);
   for(int i=0; i < obj_total; i++)
     {
      ObjectDelete(0, "AMFractHHHL" + string(i) + "-High-Time");
      ObjectDelete(0, "AMFractHHHL" + string(i) + "-Low-Time");
      ObjectDelete(0, "AMFractHHHL" + string(i) + "-High-Price");
      ObjectDelete(0, "AMFractHHHL" + string(i) + "-Low-Price");
      ObjectDelete(0, "AMFractHHHL" + string(i) + "-High-Arrow");
      ObjectDelete(0, "AMFractHHHL" + string(i) + "-Low-Arrow");
     }
   Comment("");
   ChartRedraw(0);
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
   if(rates_total < CandleCount*2 + 1)
      return(0);

   int start;

//--- clean up arrays
   if(prev_calculated < (CandleCount*2 + 1) + CandleCount)
     {
      start = CandleCount;
      ArrayInitialize(ExtUpperBuffer,EMPTY_VALUE);
      ArrayInitialize(ExtLowerBuffer,EMPTY_VALUE);
     }
   else
      start = rates_total - (CandleCount*2 + 1);
   
   int limit =  rates_total - CandleCount*2;
   
   if(start > limit) return(0);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();

   PriceTimeStudies(
      date_time,
      "AMFractHHHL",
      start,
      limit,
      timeColor,
      priceColor,
      arrowColor,
      hhllColor,
      CandleCount,
      ShowPrices,
      ShowTimes,
      ShowFractals,
      ShowHHLL,
      high,
      low,
      time
   );
   
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }

//+------------------------------------------------------------------+

//+----------------------------------------------------------------------------------------------+
//| PriceTimeStudies:                                                                            |
//+----------------------------------------------------------------------------------------------+
void PriceTimeStudies(
   datetime  date_time,
   string obj_name,
   int start,
   int limit,
   color timeColr,
   color priceColr,
   color arrowColr,
   color hhllColr,
   int candleCount,
   bool showPriceLabels,
   bool showTimeLabels,
   bool showFractalArrow,
   bool showHHLL,
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
   
   for(int i=limit; i>=start; i--) // int i=start; i<limit && !IsStopped(); i++
     {
      // Set names
      nameHigh = obj_name + (string)i + "-High";
      nameLow  = obj_name + (string)i + "-Low";
      // get candle i time, etract sub string HH:MM
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
         // Buffer updates
         ExtUpperBuffer[i]=price_high;
         string status = "";
         double currentHigh = price_high, previousHigh;
         // Plots
         if(showTimeLabels)
            plotText(chart_id, nameHigh+ "-Time", time_1, time_show, price_high, timeColr, angle_high);
         if(showPriceLabels)
            plotPrices(chart_id, nameHigh + "-Price", time_1, price_high, priceColr);
         if(showFractalArrow)
            plotArrow(chart_id, nameHigh + "-Arrow", time_1, price_high, OBJ_ARROW_DOWN, ANCHOR_BOTTOM, arrowColr);
         if(showHHLL)
           {
            for(int c=start; c<=limit; c++)
              {
               if(ExtUpperBuffer[c] != EMPTY_VALUE && ExtUpperBuffer[c] != currentHigh)
                 {
                  previousHigh = ExtUpperBuffer[c];
                  status = (currentHigh > previousHigh) ? "HH" : "LH";
                  //status = "ph: " + (string)previousHigh;
                  double shifted = currentHigh + (Labeldistance * Point() * PipFactor);
                  plotText(chart_id, nameHigh+ "-Highs", time_1, status, shifted, hhllColor, 0);
                  break;
                 }
              }
           }
        }
      else
         ExtUpperBuffer[i]=EMPTY_VALUE;

      // low fractal
      if(this_low == price_low)
        {
        //Buffer update
         ExtLowerBuffer[i]=this_low;
         string status = "";
         double currentLow = this_low, previousLow;
         //plots
         if(showTimeLabels)
            plotText(chart_id, nameLow+ "-Time", time_1, time_show, price_low, timeColr, angle_low);
         if(showPriceLabels)
            plotPrices(chart_id, nameLow + "-Price", time_1, price_low, priceColr);
         if(showFractalArrow)
            plotArrow(chart_id, nameHigh + "-Arrow", time_1, price_low, OBJ_ARROW_UP, ANCHOR_TOP, arrowColr);
         if(showHHLL)
           {
            for(int c=start; c<=limit; c++)
              {
               if(ExtLowerBuffer[c] != EMPTY_VALUE && ExtLowerBuffer[c] != currentLow)
                 {
                  previousLow = ExtLowerBuffer[c];
                  status = (currentLow > previousLow) ? "HL" : "LL";
                  //status = "pl: " + (string)previousLow;
                  double shifted = currentLow - (Labeldistance * Point() * PipFactor);
                  plotText(chart_id, nameHigh+ "-Lows", time_1, status, shifted, hhllColor, 0);
                  break;
                 }
              }
           }
        }
      else
         ExtLowerBuffer[i]=EMPTY_VALUE;
     }
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
void plotText(int obj_id, string obj_name, datetime obj_time, string obj_txt, double obj_price, color obj_clr, int obj_angle)
  {
   if(ObjectFind(obj_id, obj_name) == -1)
     {
      ObjectCreate(obj_id, obj_name, OBJ_TEXT, 0, obj_time, obj_price);
      ObjectSetString(obj_id, obj_name, OBJPROP_TEXT, obj_txt);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, obj_clr);
      ObjectSetDouble(obj_id, obj_name, OBJPROP_ANGLE, obj_angle);
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
