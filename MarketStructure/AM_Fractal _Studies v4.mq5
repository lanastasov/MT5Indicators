//+------------------------------------------------------------------+
//|                                                     AM_MS_TP.mq5 |
//|                                Copyright 2020, Aurthur Musendame |
//|                          Credits to MetaQuotes Fractal Indicator |
//+------------------------------------------------------------------+
#property copyright "2020, Aurthur. Musendame"
// #property link      "http://www.xxxxx.com"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_type1   DRAW_NONE
#property indicator_type2   DRAW_NONE
#property indicator_type3   DRAW_NONE
#property indicator_type4   DRAW_NONE
#property indicator_color1  Gray
#property indicator_color2  Gray
#property indicator_color3  Gray
#property indicator_color4  Gray
#property indicator_label1  "Fractal Up"
#property indicator_label2  "Fractal Down"
#property indicator_label3  "Signal Fractal Up"
#property indicator_label4  "Signal Fractal Down"

//--- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
double SignalUpperBuffer[];
double SignalLowerBuffer[];

//+-----------------------------------+
input string Info  =" == + Market Structure Studies  + == ";
input bool     ShowMSStudies = false; // Show Time Studies
input int      CandleCount = 5; // Candles around high/low Fractal
//
//
input bool ShowTimes = false; //  Show Time labels
input color TimeHighColor = clrRed;  // Time high label color
input color TimeLowColor = clrGreen;  // Time low label color
//
input bool ShowPrices = false; // Show Price Labels
input color PriceHighColor = clrRed; // Price high color
input color PriceLowColor = clrGreen; // Price low color
//
input bool ShowFractals = false; // Show Fractal Arrows
input color ArrowHighColor = clrRed; // Fractal high color
input color ArrowLowColor = clrGreen; // Fractal low color
//
input bool ShowHHLL = false; //  Show HHs, HLs, LHs and LLs
input color HHHLColor = clrRed;  // HH/HL color
input color LHLLColor = clrGreen;  // LH/LL color
//
input bool ShowSMS = false; // Show shift in market structure text
input bool ShowBMS = false;  // Show break in market structure text
//
input bool ShowBMSLine = false; // Show BMS Line
input color BMSLineHighColor = clrRed;  // Upside BMS Line color
input color BMSLineLowColor = clrGreen;  // Downside BSM Line color
//
input bool ShowRecentPurges = false; // show Most Recent Liquidty Runs
input color RecentBSLRColor = clrRed;  // Recent Buy Side Liquidity Run color
input color RecentSSLRColor = clrGreen;  // Recent Sell Side Liquidity Run color
// Layer a Scond fractal as a signal fractal
input bool ShowSignalFractal = true; // Show Signal Fractal BMS
input int  SignalCandleCount = 2; // Candles around high/low Fractal
input color SignalLineHighColor = clrRed;  // Upside Signal Line color
input color SignalLineLowColor = clrGreen;  // Downside Signal Line color
//
input int LabelDistance=2;
// ShiftMultiplier 100000 for binary.com
input int ShiftMultiplier = 100000; // multiplier

// ---

//--- 10 pixels upper from high price
int ExtArrowShift=10; //Arrow Shift
int PipFactor = 1*ShiftMultiplier; //pip factor 200000

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
// Determine pip factor
   if(Digits() == 3 || Digits() == 5)
      PipFactor = 10*ShiftMultiplier;
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,SignalUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,SignalLowerBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
   PlotIndexSetInteger(2,PLOT_ARROW,217);
   PlotIndexSetInteger(3,PLOT_ARROW,218);
//--- arrow shifts when drawing
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ExtArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ExtArrowShift);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,ExtArrowShift);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,-ExtArrowShift);
//--- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "MS_Fractal", -1, -1);
   ObjectsDeleteAll(0, "Si_Fractal", -1, -1);
   int obj_total = ObjectsTotal(0, -1, -1);
   for(int i=0; i < obj_total; i++)
     {
      ObjectDelete(0, "MS_Fractal" + string(i) + "-High-Time");
      ObjectDelete(0, "MS_Fractal" + string(i) + "-Low-Time");
      ObjectDelete(0, "MS_Fractal" + string(i) + "-High-Price");
      ObjectDelete(0, "MS_Fractal" + string(i) + "-Low-Price");
      ObjectDelete(0, "MS_Fractal" + string(i) + "-High-Arrow");
      ObjectDelete(0, "MS_Fractal" + string(i) + "-Low-Arrow");
     }
   Comment("");
   ChartRedraw(0);
   Comment("");
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|  Fractals on CandleCount bars                                    |
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
  
   if(rates_total < CandleCount*2 + 1 || rates_total < SignalCandleCount*2 + 1 )
      return(0);

   int start, s_start;

//--- clean up arrays
   if(prev_calculated < (CandleCount*2 + 1) + CandleCount || prev_calculated < (SignalCandleCount*2 + 1) + SignalCandleCount)
     {
      start = CandleCount;
      s_start = SignalCandleCount;
      ArrayInitialize(ExtUpperBuffer,EMPTY_VALUE);
      ArrayInitialize(ExtLowerBuffer,EMPTY_VALUE);
      ArrayInitialize(SignalUpperBuffer,EMPTY_VALUE);
      ArrayInitialize(SignalLowerBuffer,EMPTY_VALUE);
     }
   else
   {   
      start = rates_total - (CandleCount*2 + 1);
      s_start = rates_total - (SignalCandleCount*2 + 1);
   }

   int limit =  rates_total - CandleCount*2;
   int s_limit =  rates_total - SignalCandleCount*2;
   
   if(start > limit || s_start > s_limit)
      return(0);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();

   if(ShowSignalFractal)
      SignalFractal(date_time, "Si_Fractal", s_start, s_limit, high, low, time);

   if(ShowMSStudies)
      PriceTimeStudies(date_time, "MS_Fractal", start, limit, high, low, time);

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
   color ColorHHHL = (ShowHHLL) ? HHHLColor : clrNONE;
   color ColorLHLL = (ShowHHLL) ? HHHLColor : clrNONE;

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
      num_elements = CandleCount*2 + 1;
      bar_far_right_position = i - CandleCount;
      price_high = high[iHighest(Symbol(), Period(), MODE_HIGH, num_elements, bar_far_right_position)];
      price_low  = low[iLowest(Symbol(), Period(), MODE_LOW, num_elements, bar_far_right_position)];

      // high fractal
      double currentHigh=0.0, previousHigh=0.0, formerPreviousHigh=0.0;
      int currentHighPosition, previousHighPostion, formerPreviousHighPosition;
      if(this_high == price_high)
        {
         // Buffer updates
         ExtUpperBuffer[i]=price_high;
         string status = "";
         currentHigh = price_high;
         currentHighPosition = i;

         // Plots
         if(ShowTimes)
            plotText(chart_id, nameHigh+ "-Time", time_1, time_show, price_high, TimeHighColor, angle_high);
         if(ShowPrices)
            plotPrices(chart_id, nameHigh + "-Price", time_1, price_high, PriceHighColor);
         if(ShowFractals)
            plotArrow(chart_id, nameHigh + "-Arrow", time_1, price_high, OBJ_ARROW_DOWN, ANCHOR_BOTTOM, ArrowHighColor);
         //
         for(int c=start; c<=limit; c++)
           {
            if(ExtUpperBuffer[c] != EMPTY_VALUE && ExtUpperBuffer[c] != currentHigh)
              {
               previousHigh = ExtUpperBuffer[c];
               previousHighPostion = c;
               status = (currentHigh > previousHigh) ? "HH" : "LH";
               break;
              }
           }
         // get former previous high
         for(int c=start; c<=limit; c++)
           {
            if(ExtUpperBuffer[c] != EMPTY_VALUE && ExtUpperBuffer[c] != currentHigh && ExtUpperBuffer[c] != previousHigh)
              {
               formerPreviousHigh = ExtUpperBuffer[c];
               formerPreviousHighPosition = c;
               int ph = (previousHigh > formerPreviousHigh) ? 0 : 1; // "HH" : "LH";
               int ch = (currentHigh > previousHigh) ? 0 : 1; // "HH" : "LH";
               bool bms = false;
               bool sms = false;
               if(ph==0 && ch==1)  // HH to LH
                 {
                  if(ShowSMS)
                     status += " (SMS)";
                  sms = true;
                 }
               if(ph==1 && ch==0) // LH to HH
                 {
                  if(ShowBMS)
                     status += " (BMS)";
                  bms = true;
                 }
               if(bms && ShowBMSLine)
                  plotTrendLine(0, nameHigh + "-bms", time[previousHighPostion], previousHigh, time[i], previousHigh, BMSLineHighColor);
               // status = "ph: " + (string)previousHigh + " fph: " + formerPreviousHigh;
               double shifted = currentHigh + (LabelDistance * Point() * PipFactor);
               plotText(chart_id, nameHigh+ "-Highs", time_1, status, shifted, ColorHHHL, 0);
               break;
              }
           }
        }
      // else ExtUpperBuffer[i]=EMPTY_VALUE;

      // low fractal
      double currentLow=0.0, previousLow=0.0, formerPreviousLow=0.0;
      int currentLowPosition, previousLowPostion, formerPreviousLowPosition;
      if(this_low == price_low)
        {
         //Buffer update
         ExtLowerBuffer[i]=this_low;
         string status = "";
         currentLow = this_low;
         currentLowPosition = i;
         //plots
         if(ShowTimes)
            plotText(chart_id, nameLow+ "-Time", time_1, time_show, price_low, TimeLowColor, angle_low);
         if(ShowPrices)
            plotPrices(chart_id, nameLow + "-Price", time_1, price_low, PriceLowColor);
         if(ShowFractals)
            plotArrow(chart_id, nameHigh + "-Arrow", time_1, price_low, OBJ_ARROW_UP, ANCHOR_TOP, ArrowLowColor);
         //
         for(int c=start; c<=limit; c++)
           {
            if(ExtLowerBuffer[c] != EMPTY_VALUE && ExtLowerBuffer[c] != currentLow)
              {
               previousLow = ExtLowerBuffer[c];
               previousLowPostion = c;
               status = (currentLow > previousLow) ? "HL" : "LL";
               //status = "pl: " + (string)previousLow;
               double shifted = currentLow - (LabelDistance * Point() * PipFactor);
               //plotText(chart_id, nameHigh+ "-Lows", time_1, status, shifted, dispClr, 0);
               break;
              }
           }

         // get former previous low
         for(int c=start; c<=limit; c++)
           {
            if(ExtLowerBuffer[c] != EMPTY_VALUE && ExtLowerBuffer[c] != currentLow && ExtLowerBuffer[c] != previousLow)
              {
               formerPreviousLow = ExtLowerBuffer[c];
               formerPreviousLowPosition = c;
               int pl = (previousLow > formerPreviousLow) ? 0 : 1; // "HL" : "LL";
               int cl = (currentLow > previousLow) ? 0 : 1; // "HL" : "LL";
               bool bms = false;
               bool sms = false;
               if(pl==0 && cl==1)  // HL to LL
                 {
                  if(ShowBMS)
                     status += " (BMS)";
                  bms = true;
                 }
               if(pl==1 && cl==0) // LL to HL
                 {
                  if(ShowSMS)
                     status += " (SMS)";
                  sms = true;
                 }
               if(bms && ShowBMSLine)
                  plotTrendLine(0, nameLow + "-bms", time[previousLowPostion], previousLow, time[i], previousLow, BMSLineLowColor);
               //status = "pl: " + (string)previousLow;
               double shifted = currentLow - (LabelDistance * Point() * PipFactor);
               plotText(chart_id, nameHigh+ "-Lows", time_1, status, shifted, ColorLHLL, 0);
               break;
              }
           }
        }
      // else ExtLowerBuffer[i]=EMPTY_VALUE;

      //+--------------------------------------------------------------------------------------------------------------------------------------------+
      // 
      if(ShowRecentPurges) LiquidyPurge(obj_name, time[currentLowPosition], currentLow, time[currentHighPosition], currentHigh, high[i], low[i], time[i]);

     }
  }

  
//+----------------------------------------------------------------------------------------------+
//| SignalFractal:                                                                               |
//+----------------------------------------------------------------------------------------------+
void SignalFractal(
   datetime  s_date_time,
   string s_obj_name,
   int s_start,
   int s_limit,
   const double &high[],
   const double &low[],
   const datetime  &time[]
)
  {
   double s_price_high, s_price_low, s_this_high, s_this_low;
   int s_bar_far_right_position, s_num_elements;

   for(int i=s_limit; i>=s_start; i--) // int i=s_start; i<s_limit && !IsStopped(); i++
     {
      // get current high and low
      s_this_high = iHigh(NULL, 0, i);
      s_this_low  = iLow(NULL, 0, i);

      // Candle range Low and high ::   [bar_far_left_position, ..., i , ..., s_bar_far_right_position]
      s_num_elements = SignalCandleCount*2 + 1;
      s_bar_far_right_position = i - SignalCandleCount;
      s_price_high = high[iHighest(Symbol(), Period(), MODE_HIGH, s_num_elements, s_bar_far_right_position)];
      s_price_low  = low[iLowest(Symbol(), Period(), MODE_LOW, s_num_elements, s_bar_far_right_position)];

      // high fractal
      double currentHigh=0.0, previousHigh=0.0, formerPreviousHigh=0.0;
      int currentHighPosition, previousHighPostion, formerPreviousHighPosition;
      if(s_this_high == s_price_high)
        {
         // Buffer updates
         ExtUpperBuffer[i]=s_price_high;
         string status = "";
         currentHigh = s_price_high;
         currentHighPosition = i;

         for(int c=s_start; c<=s_limit; c++)
           {
            if(ExtUpperBuffer[c] != EMPTY_VALUE && ExtUpperBuffer[c] != currentHigh)
              {
               previousHigh = ExtUpperBuffer[c];
               previousHighPostion = c;
               break;
              }
           }
         // get former previous high
         for(int c=s_start; c<=s_limit; c++)
           {
            if(ExtUpperBuffer[c] != EMPTY_VALUE && ExtUpperBuffer[c] != currentHigh && ExtUpperBuffer[c] != previousHigh)
              {
               formerPreviousHigh = ExtUpperBuffer[c];
               formerPreviousHighPosition = c;
               int ph = (previousHigh > formerPreviousHigh) ? 0 : 1; // "HH" : "LH";
               int ch = (currentHigh > previousHigh) ? 0 : 1; // "HH" : "LH";
               bool bms = false;
               bool sms = false;
               if(ph==0 && ch==1)  // HH to LH
                 sms = true;
               if(ph==1 && ch==0) // LH to HH
                 bms = true;
               if(bms)
                  plotTrendLine(0, s_obj_name + (string)i + "-bms-sh", time[previousHighPostion], previousHigh, time[i], previousHigh, SignalLineHighColor);
               break;
              }
           }
        }
      // else ExtUpperBuffer[i]=EMPTY_VALUE;

      // low fractal
      double currentLow=0.0, previousLow=0.0, formerPreviousLow=0.0;
      int currentLowPosition, previousLowPostion, formerPreviousLowPosition;
      if(s_this_low == s_price_low)
        {
         //Buffer update
         ExtLowerBuffer[i]=s_this_low;
         currentLow = s_this_low;
         currentLowPosition = i;
         
         // get previous low
         for(int c=s_start; c<=s_limit; c++)
           {
            if(ExtLowerBuffer[c] != EMPTY_VALUE && ExtLowerBuffer[c] != currentLow)
              {
               previousLow = ExtLowerBuffer[c];
               previousLowPostion = c;
               break;
              }
           }

         // get former previous low
         for(int c=s_start; c<=s_limit; c++)
           {
            if(ExtLowerBuffer[c] != EMPTY_VALUE && ExtLowerBuffer[c] != currentLow && ExtLowerBuffer[c] != previousLow)
              {
               formerPreviousLow = ExtLowerBuffer[c];
               formerPreviousLowPosition = c;
               int pl = (previousLow > formerPreviousLow) ? 0 : 1; // "HL" : "LL";
               int cl = (currentLow > previousLow) ? 0 : 1; // "HL" : "LL";
               bool bms = false;
               bool sms = false;
               if(pl==0 && cl==1)  // HL to LL
                 bms = true;
               if(pl==1 && cl==0) // LL to HL
                 sms = true;
               if(bms)
                  plotTrendLine(0, s_obj_name + (string)i + "-bms-sl", time[previousLowPostion], previousLow, time[i], previousLow, SignalLineLowColor);
               break;
              }
           }
        }
     }
  }  
  

//+------------------------------------------------------------------+
//|   LiquidyPurge  / BMS/SMS fast Signal detection:                 |
//+------------------------------------------------------------------+
void LiquidyPurge(string obj_name, datetime time_low, double currentLow, datetime time_high, double currentHigh, double high_i, double low_i, datetime time_i)
  {
   //:: Breaks lower :: Most Recent Low Liqudity Purge
   if(currentLow != 0.0 && low_i < currentLow)
     {
      plotTrendLine(0, obj_name + (string)currentLow, time_low, currentLow, time_i, currentLow, RecentSSLRColor);
     }

   //:: Breaks ligher :: Most Recent High Liqudity Purge
   if(currentHigh != 0.0 && high_i > currentHigh)
     {
      plotTrendLine(0, obj_name + (string)currentHigh, time_high, currentHigh, time_i, currentHigh, RecentBSLRColor);
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void plotTrendLine(int obj_id, string obj_name, datetime t1, double p1, datetime t2, double p2, color tlColor)
  {
   if(ObjectFind(obj_id, obj_name) == -1)
     {
      ObjectCreate(obj_id, obj_name, OBJ_TREND, 0, t1, p1, t2, p2);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, tlColor);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_WIDTH, 2);
     }
  }
//+------------------------------------------------------------------+
