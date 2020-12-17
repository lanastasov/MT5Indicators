//+------------------------------------------------------------------+
//|                                            OneEMAENUMS mqh File  |
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+

enum TREND_TIMEFRAMES
{
   TREND_H1 = 1, // H1 Trend
   TREND_H4 = 4, // H4 Trend
   TREND_H6 = 6, // H6 Trend
   TREND_H8 = 8, // H8 Trend
   TREND_H12 = 12, // H12 Trend
   TREND_D1 = 24, // D1 Trend
   TREND_D2 = 48, // D2 Trend
   TREND_D4 = 96, // D4 Trend
   TREND_W1 = 120, // W1 Trend
   TREND_W2 = 240, // W2 Trend
   TREND_MN1 = 480, // M1 Trend
   TREND_MN2 = 960, // M2 Trend
   TREND_MN3 = 1440 // M3 Trend
};

enum TRADING_TIMEFRAMES
{
   TRADING_M15 = 100, //   M15 Entries
   TRADING_M30 = 1000, //   M30 Entries
   TRADING_H1 = 1,    // H1 Entries
   TRADING_H2 = 2,    // H2 Entries
   TRADING_H4 = 4,    // H4 Entries
   TRADING_D1 = 24    // D1 Entries
};

enum Andrei_MA_MODES
{
   A_SMA = 0, // SMA
   A_EMA = 1 // EMA
};
