//+------------------------------------------------------------------+
//|                                                           ADR.mqh|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#include "co_initiators.mqh"

double yest_hi, yest_lo, today_open, yest_range, yest_range_pips, 
       adr, adr_pips, adr_5_days, adr_10_days, adr_20_days, adr_high, adr_low,
       highest_price, lowest_price, range_today, range_today_pips,
       last_high, last_low, now_high, now_low, now_range, to_low_adr, to_high_adr, now_close;
datetime current_bar_time, adr_start, adr_end;
int now_bars,bar_now_index, bar_started_index, n_elements;
string debug_post, adr_post, reached = "N0";
bool adr_reached = false, last_reached = false;
bool DEBUG_CODE = false;
//+------------------------------------------------------------------+
//| ADR_Maker                                                              |
//+------------------------------------------------------------------+

void ADR_Maker(
    datetime date_time,
    string name,
    color m_color,
    int line_thickness,
    ENUM_LINE_STYLE line_style,
    bool use_custom,
    int custom_days,
    bool draw_markers,
    const double &high[],
    const double &low[]
  )
  {
    yest_hi = iHigh(Symbol(), PERIOD_D1, 1);
    yest_lo = iLow(Symbol(), PERIOD_D1, 1);
    today_open = iOpen(Symbol(),PERIOD_D1,0);

    yest_range = daily_range(yest_hi, yest_lo);
    yest_range_pips = yest_range/Point()/10;
    debug_post += "Yest Range: " + (string)yest_range_pips;

    if(use_custom) 
    {
      adr = x_days_range(custom_days)/custom_days; 
      adr_pips = adr/Point()/10.0;
      debug_post += "\nADR Custom: " + (string)adr_pips + " ("  + (string)custom_days + " Days)";
      adr_post += "ADR: " + DoubleToString(MathRound(adr_pips),2) + " ("  + (string)custom_days + " Days)";
    }
    else
    {
      adr_5_days=x_days_range(5)/5;
      adr_10_days = x_days_range(10)/10;
      adr_20_days = x_days_range(20)/20;
      adr=(yest_range+adr_5_days+adr_10_days+adr_20_days)/4;
      adr_pips=adr/Point()/10.0;
      debug_post += "\nADR Default: " + (string)adr_pips;
      adr_post += "ADR: " + DoubleToString(MathRound(adr_pips),2);
    }
    adr_post += "   |   3xADR: " + DoubleToString(MathRound(adr_pips*3),2);

    adr_high = today_open + adr;
    adr_low  = today_open - adr;

    current_bar_time=iTime(Symbol(),Period(),0);
    adr_start=iTime(Symbol(), PERIOD_D1, 0);
    adr_end=adr_start + 24*3600-1;

    now_bars = Bars(Symbol(), Period(), adr_start, current_bar_time) - 1;

    bar_started_index=iBarShift(NULL,0,adr_start);
    bar_now_index = iBarShift(NULL, 0, current_bar_time);

    n_elements  = bar_started_index - bar_now_index;

    highest_price  = high[iHighest(Symbol(), Period(), MODE_HIGH, n_elements, bar_now_index)];
    lowest_price  = low[iLowest(Symbol(), Period(), MODE_LOW, n_elements, bar_now_index)];

    range_today = highest_price - lowest_price;
    range_today_pips = range_today/Point()/10;
    debug_post += "\nToday Range: " + (string)range_today_pips;
    adr_post += "\nToday: " + DoubleToString(MathRound(range_today_pips),2);
    adr_post += "  |  Yesterday: " + DoubleToString(MathRound(yest_range_pips),2);

    last_low = today_open;
    last_high = today_open;
    now_high = today_open;
    now_low = today_open;
    now_range = now_high - now_low;
    now_close = iOpen(Symbol(),Period(),0);
    to_low_adr = now_close - adr_low;
    to_high_adr = adr_high - now_close;

    for(int bar = now_bars; bar >= 0; bar--)
    {
      if (current_bar_time >= adr_start && current_bar_time < adr_end) 
      {
        //--- inner for
        for (int k= 0; k<3; k++) {
            double price=0;
            switch (k) 
            {
                case 0: price = iLow(Symbol(), Period(), bar); break;
                case 1: price = iHigh(Symbol(), Period(), bar); break;
                case 2: price = iClose(Symbol(), Period(), bar); break;
            }

            now_high = MathMax(last_high, price);
            now_low = MathMin(last_low, price);
         
            now_range = now_high - now_low;
            adr_reached = now_range >= adr - Point()/2;

            // adr-high
            if (!last_reached && !adr_reached) 
            {
               adr_high= now_low + adr;
            }
            else
            if (!last_reached && adr_reached && price>=last_high) 
            {
               adr_high= now_low + adr;
            }
            else
            if (!last_reached && adr_reached && price<last_high) 
            {
               adr_high = last_high;
            }
            else {
               adr_high= adr_high;
            }

            // adr-low
            if (!last_reached && !adr_reached) 
            {
               adr_low = now_high - adr;
            }
            else
            if (!last_reached && adr_reached && price >= last_low) 
            {
               adr_low= now_low;
            }
            else
            if (!last_reached && adr_reached && price<last_low) 
            {
               adr_low= last_high - adr;
            }
            else 
            {
               adr_low= adr_low;
            }

            last_high = now_high;
            last_low = now_low;
            last_reached = adr_reached;

            double now_bar_close = iClose(Symbol(), Period(), bar);
            to_high_adr = adr_high - now_bar_close;
            to_low_adr = now_bar_close - adr_low;
         
        }
        //--- end inner for
      }
    }
    //---    
    if(adr_reached)
    {
      m_color = clrRed;
      line_thickness+=1;
      line_style = STYLE_SOLID;
      reached = "Yes";
    }
    //---
    to_high_adr = to_high_adr/Point()/10;
    to_low_adr = to_low_adr/Point()/10;
    debug_post += "\nTo adr low: " + (string)to_low_adr;
    debug_post += "\nTo adr high: " + (string)to_high_adr;
    debug_post += "\nADR HIGH: " + (string)adr_high;
    debug_post += "\nADR LOW: " + (string)adr_low;
    debug_post += "\nReached?:  " + reached;
    //---
    adr_post += "\nto adr low:  " + DoubleToString(MathRound(to_low_adr),2);
    adr_post += "  |  to adr high:  " + DoubleToString(MathRound(to_high_adr),2);
    adr_post += "\nADR High:  " + DoubleToString(adr_high,5);
    adr_post += "  |  ADR Low:  " + DoubleToString(adr_low,5);
    adr_post += "  |  Reached?:  " + reached;
    //---

    // -- Weekly Range
    double awr, lwr,lwr_pips, awr_4_weeks, awr_8_weeks, awr_16_weeks;
    lwr = daily_range(iHigh(Symbol(), PERIOD_W1, 1), iLow(Symbol(), PERIOD_W1, 1));
    lwr_pips = lwr/Point()/10 ;      
    awr_4_weeks = x_weeks_range(4)/4;
    awr_8_weeks = x_weeks_range(8)/8;
    awr_16_weeks = x_weeks_range(16)/16;
    awr=(lwr+awr_4_weeks+awr_8_weeks+awr_16_weeks)/4/Point()/10;
    adr_post += "\n======================";
    adr_post += "\nAWR:  " + DoubleToString(awr,2);
    adr_post += "   ||   LWR:  " + DoubleToString(lwr_pips,2);

    // --
    if(adr!=0)
    {
      if(DEBUG_CODE) Comment(debug_post); else Comment(adr_post);
      if(draw_markers)
      {
        SetMarkers(name + "High", adr_start,  adr_end, adr_high,  m_color, line_style, line_thickness, "ADR High: " + DoubleToString(adr_high, 5));
        SetMarkers(name + "Low", adr_start,  adr_end, adr_low,  m_color, line_style, line_thickness, "ADR Low: " + DoubleToString(adr_low, 5));
        //SetADRStartLine( name + "Start", adr_start, m_color);
      } 
    }
    else
    {
      Comment("Please Refresh your Chart !!");
    }  
    adr_post = ""; 
    debug_post = "";
    //--
  }
//+------------------------------------------------------------------+

double daily_range(double hi,double lo)
  {
   return hi - lo;
  }
//+------------------------------------------------------------------+

double x_days_range(int x_days)
  {
   int days_counter=0;
   double sum= 0;
   for(int i = 1; i <= x_days; i++)
     {
      double hi = iHigh(Symbol(), PERIOD_D1, i);
      double lo = iLow(Symbol(), PERIOD_D1, i);
      datetime date_time=iTime(Symbol(),Period(),i);
      int day_of_week=TimeDayOfWeek(date_time);
      if(day_of_week>0 && day_of_week<6)
        {
         sum+=daily_range(hi,lo);
         days_counter++;
         if(days_counter>=x_days) break;
        }
     }
   return sum;
  }

//+------------------------------------------------------------------+

double x_weeks_range(int x_weeks)
  {
   int weeks_counter=0;
   double sum= 0;
   for(int i = 1; i <= x_weeks; i++)
     {
      double hi = iHigh(Symbol(), PERIOD_W1, i);
      double lo = iLow(Symbol(), PERIOD_W1, i);
      sum+=daily_range(hi,lo);
      weeks_counter++;
      if(weeks_counter>=x_weeks) break;
     }
   return sum;
  }

//+------------------------------------------------------------------+
void SetMarkers(
  string name,
  datetime starting_adr_time, 
  datetime ending_adr_time,
  double price_high,
  color colr,
  ENUM_LINE_STYLE lyn,
  int lwidth,
  string marker_text
)
{
  line.Create(0, name , 0, starting_adr_time, price_high, ending_adr_time, price_high);
  line.Color(colr);
  line.SetInteger(OBJPROP_STYLE, lyn);
  line.SetInteger(OBJPROP_WIDTH, lwidth);
  line.Description(marker_text);
}

//+------------------------------------------------------------------+

void SetADRStartLine(
  string name,
  datetime starting_adr_time,
  color colr
)
{
  vline.Create(0, name, 0, starting_adr_time);
  vline.Color(colr);
  vline.SetInteger(OBJPROP_STYLE, STYLE_DASHDOTDOT);  
}