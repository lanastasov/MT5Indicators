//+------------------------------------------------------------------+
//|                                                        Pivots.mqh|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#include "co_initiators.mqh"
#include "enums.mqh"

//+------------------------------------------------------------------+
//| Pivot_Points                                                     |
//+------------------------------------------------------------------+
double main_pivot, day_range, period_close, period_high, period_low, period_open,
       R1, R2, R3, R4, R38, R61, R78, R100, R138, R161, R200, 
       S1, S2, S3, S4, S38, S61, S78, S100, S138, S161, S200, 
       M0, M1, M2, M3, M4, M5;
datetime starting_time, ending_time;
ENUM_TIMEFRAMES pivot_tf;
string tf_text;

void Pivot_Points(
  datetime date_time, 
  string name, 
  PIVOT_METHODS p_Method, 
  PIVOT_TIMEFRAME p_TimeFrame, 
  bool use_fibs, 
  bool use_camarilla, 
  bool show_SR_Pivots, 
  color SPivotColor, 
  color RPivotColor, 
  ENUM_LINE_STYLE SR_PivotsLineStyle,
  bool show_MidPivots, 
  color MidPivots_Color, 
  ENUM_LINE_STYLE MidPivots_LineStyle  
)
{
  starting_time = iTime(Symbol(), PERIOD_D1, 0);
  ending_time = starting_time + 24*3600-1;
  switch(p_TimeFrame)
  {
    case 1: pivot_tf = PERIOD_MN1; tf_text = "Monthly"; break;
    case 2: pivot_tf = PERIOD_W1; tf_text = "Weekly"; break;
    case 3: pivot_tf = PERIOD_D1; tf_text = "Daily"; break;
  }

  period_close= iClose(Symbol(), pivot_tf, 1);
  period_open = iOpen(Symbol(), pivot_tf, 1);
  period_high = iHigh(Symbol(), pivot_tf, 1);
  period_low  = iLow(Symbol(), pivot_tf, 1);

  switch(p_Method)
  {
    case 1: main_pivot = (period_high + period_low + period_close)/3; break;
    case 2: main_pivot = (period_high + period_low + period_close + period_close)/4; break;
    case 3: main_pivot = (period_high + period_low + period_close + period_open)/4; break;
    case 4: main_pivot = (period_high + period_low + period_open + period_open)/4; break;
    case 5: main_pivot = (period_high + period_low + period_open)/3; break;
  }

  day_range = period_high - period_low;

  if(use_camarilla)
  {
    // -- Camarilla Pivots
    R1 = period_close + day_range*(1.1/12);
    R2 = period_close + day_range*(1.1/6);
    R3 = period_close + day_range*(1.1/4);
    R4 = period_close + day_range*(1.1/2);
    S1 = period_close - day_range*(1.1/12);
    S2 = period_close - day_range*(1.1/6);
    S3 = period_close - day_range*(1.1/4);
    S4 = period_close - day_range*(1.1/2);
    main_pivot = (R1 - S1)/2;
    SetPivotLine( "R1", starting_time, R1, ending_time, R1, RPivotColor, "R1 " + DoubleToString(R1,5), SR_PivotsLineStyle);
    SetPivotLine( "R2", starting_time, R2, ending_time, R2, RPivotColor, "R2 " + DoubleToString(R2,5), SR_PivotsLineStyle);
    SetPivotLine( "R3", starting_time, R3, ending_time, R3, RPivotColor, "R3 " + DoubleToString(R3,5), SR_PivotsLineStyle);
    SetPivotLine( "R4", starting_time, R4, ending_time, R4, RPivotColor, "R4 " + DoubleToString(R4,5), SR_PivotsLineStyle);
    SetPivotLine( "Pivot", starting_time, main_pivot, ending_time, main_pivot, RPivotColor, "Pivot " + DoubleToString(main_pivot,5), SR_PivotsLineStyle);
    SetPivotLine( "S1", starting_time, S1, ending_time, S1, SPivotColor, "S1 " + DoubleToString(S1,5), SR_PivotsLineStyle);
    SetPivotLine( "S2", starting_time, S2, ending_time, S2, SPivotColor, "S2 " + DoubleToString(S2,5), SR_PivotsLineStyle);
    SetPivotLine( "S3", starting_time, S3, ending_time, S3, SPivotColor, "S3 " + DoubleToString(S3,5), SR_PivotsLineStyle);
    SetPivotLine( "S4", starting_time, S4, ending_time, S4, SPivotColor, "S4 " + DoubleToString(S4,5), SR_PivotsLineStyle);
  }
  else
  {
    if(use_fibs)
    {
      // -- Fibonachi Pivots
      R38  = day_range*0.382 + main_pivot;
      R61  = day_range*0.618 + main_pivot;
      R78  = day_range*0.786 + main_pivot;
      R100 = day_range*1.00 + main_pivot;
      R138 = day_range*1.382 + main_pivot;
      R161 = day_range*1.618 + main_pivot;
      R200 = day_range*2.00 + main_pivot;

      S38  = main_pivot - day_range*0.382;
      S61  = main_pivot - day_range*0.618;
      S78  = main_pivot - day_range*0.786;
      S100 = main_pivot - day_range*1.00;
      S138 = main_pivot - day_range*1.382;
      S161 = main_pivot - day_range*1.618;
      S200 = main_pivot - day_range*2.00;

      SetPivotLine( "R38", starting_time, R38, ending_time, R38, RPivotColor, "R38 " + DoubleToString(R38,5), SR_PivotsLineStyle);
      SetPivotLine( "R61", starting_time, R61, ending_time, R61, RPivotColor, "R61 " + DoubleToString(R61,5), SR_PivotsLineStyle);
      SetPivotLine( "R78", starting_time, R78, ending_time, R78, RPivotColor, "R78 " + DoubleToString(R78,5), SR_PivotsLineStyle);
      SetPivotLine( "R100", starting_time, R100, ending_time, R100, RPivotColor, "R100 " + DoubleToString(R100,5), SR_PivotsLineStyle);
      SetPivotLine( "R138", starting_time, R138, ending_time, R138, RPivotColor, "R138 " + DoubleToString(R138,5), SR_PivotsLineStyle);
      SetPivotLine( "R161", starting_time, R161, ending_time, R161, RPivotColor, "R161 " + DoubleToString(R161,5), SR_PivotsLineStyle);
      SetPivotLine( "R200", starting_time, R200, ending_time, R200, RPivotColor, "R200 " + DoubleToString(R200,5), SR_PivotsLineStyle);

      SetPivotLine( "Pivot", starting_time, main_pivot, ending_time, main_pivot, RPivotColor, "Pivot " + DoubleToString(main_pivot,5), SR_PivotsLineStyle);

      SetPivotLine( "S38", starting_time, S38, ending_time, S38, SPivotColor, "S38 " + DoubleToString(S38,5), SR_PivotsLineStyle);
      SetPivotLine( "S61", starting_time, S61, ending_time, S61, SPivotColor, "S61 " + DoubleToString(S61,5), SR_PivotsLineStyle);
      SetPivotLine( "S78", starting_time, S78, ending_time, S78, SPivotColor, "S78 " + DoubleToString(S78,5), SR_PivotsLineStyle);
      SetPivotLine( "S100", starting_time, S100, ending_time, S100, SPivotColor, "S100 " + DoubleToString(S100,5), SR_PivotsLineStyle);
      SetPivotLine( "S138", starting_time, S138, ending_time, S138, SPivotColor, "S138 " + DoubleToString(S138,5), SR_PivotsLineStyle);
      SetPivotLine( "S161", starting_time, S161, ending_time, S161, SPivotColor, "S161 " + DoubleToString(S161,5), SR_PivotsLineStyle);
      SetPivotLine( "S200", starting_time, S200, ending_time, S200, SPivotColor, "S200 " + DoubleToString(S200,5), SR_PivotsLineStyle);
    }
    else
    {
      // -- Standard Pivots
      R1 = 2*main_pivot - period_low;
      R2 = main_pivot + (period_high - period_low);
      R3 = R2 + (period_high - period_low);
      S1 = 2*main_pivot - period_high;
      S2 = main_pivot - (period_high - period_low);
      S3 = S2 - (period_high - period_low);

      SetPivotLine( "Pivot", starting_time, main_pivot, ending_time, main_pivot, RPivotColor, "Pivot " + DoubleToString(main_pivot,5), SR_PivotsLineStyle);

      if(show_SR_Pivots)
      {
        //-- SR
        SetPivotLine( "R1", starting_time, R1, ending_time, R1, RPivotColor, "R1 " + DoubleToString(R1,5), SR_PivotsLineStyle);
        SetPivotLine( "R2", starting_time, R2, ending_time, R2, RPivotColor, "R2 " + DoubleToString(R2,5), SR_PivotsLineStyle);
        SetPivotLine( "R3", starting_time, R3, ending_time, R3, RPivotColor, "R3 " + DoubleToString(R3,5), SR_PivotsLineStyle);
        SetPivotLine( "S1", starting_time, S1, ending_time, S1, SPivotColor, "S1 " + DoubleToString(S1,5), SR_PivotsLineStyle);
        SetPivotLine( "S2", starting_time, S2, ending_time, S2, SPivotColor, "S2 " + DoubleToString(S2,5), SR_PivotsLineStyle);
        SetPivotLine( "S3", starting_time, S3, ending_time, S3, SPivotColor, "S3 " + DoubleToString(S3,5), SR_PivotsLineStyle);
      }
      if(show_MidPivots)
      {
        //-- Mid
        M0 = (S2 + S3)*0.5;
        M1 = (S2 + S1)*0.5;       
        M2 = (main_pivot + S1)*0.5;
        M3 = (main_pivot + R1)*0.5;
        M4 = (R1 + R2)*0.5;
        M5 = (R2 + R3)*0.5;
        SetPivotLine( "M0", starting_time, M0, ending_time, M0, MidPivots_Color, "M0 " + DoubleToString(M0,5), MidPivots_LineStyle);
        SetPivotLine( "M1", starting_time, M1, ending_time, M1, MidPivots_Color, "M1 " + DoubleToString(M1,5), MidPivots_LineStyle);
        SetPivotLine( "M2", starting_time, M2, ending_time, M2, MidPivots_Color, "M2 " + DoubleToString(M2,5), MidPivots_LineStyle);
        SetPivotLine( "M3", starting_time, M3, ending_time, M3, MidPivots_Color, "M3 " + DoubleToString(M3,5), MidPivots_LineStyle);
        SetPivotLine( "M4", starting_time, M4, ending_time, M4, MidPivots_Color, "M4 " + DoubleToString(M4,5), MidPivots_LineStyle);
        SetPivotLine( "M5", starting_time, M5, ending_time, M5, MidPivots_Color, "M5 " + DoubleToString(M5,5), MidPivots_LineStyle);
      }
    }
  }
}

void SetPivotLine(
  string name, 
  datetime start_time,
  double price_1,
  datetime end_time, 
  double price_2,
  color line_color,
  string decsription,
  ENUM_LINE_STYLE line_style
)
{
  line.Create(0, name, 0, start_time, price_1, end_time, price_1);
  line.Color(line_color);
  line.Description(decsription);
  line.SetInteger(OBJPROP_STYLE, line_style);
  line.SetString(OBJPROP_TEXT, decsription);
}

void Delete_Pivots()
{
  ObjectDelete(0, "R1");
  ObjectDelete(0, "R2");
  ObjectDelete(0, "R3");
  ObjectDelete(0, "R4");
  ObjectDelete(0, "R38");
  ObjectDelete(0, "R61");
  ObjectDelete(0, "R78");
  ObjectDelete(0, "R100");
  ObjectDelete(0, "R138");
  ObjectDelete(0, "R161");
  ObjectDelete(0, "R200");
  ObjectDelete(0, "S1");
  ObjectDelete(0, "S2");
  ObjectDelete(0, "S3");
  ObjectDelete(0, "S4");
  ObjectDelete(0, "S38");
  ObjectDelete(0, "S61");
  ObjectDelete(0, "S78");
  ObjectDelete(0, "S100");
  ObjectDelete(0, "S138");
  ObjectDelete(0, "S161");
  ObjectDelete(0, "S200");
  ObjectDelete(0, "M0");
  ObjectDelete(0, "M1");
  ObjectDelete(0, "M2");
  ObjectDelete(0, "M3");
  ObjectDelete(0, "M4");
  ObjectDelete(0, "M5");
  ObjectDelete(0, "Pivot");
}