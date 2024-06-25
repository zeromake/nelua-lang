#ifdef _WIN32
  #include <windows.h>
    #include <profileapi.h>
#endif

#include <time.h>
#include <stdint.h>
#include <stdbool.h>
#include <errno.h>
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

static int performance_sleep(lua_State *L) {
  lua_Number secs = luaL_optnumber(L, 1, 0.0f);
  if (secs <= 0) {
    return 0;
  }
#if defined(_WIN32)
  uint64_t us = (uint64_t)(secs * 1000000);
  unsigned int ms = (unsigned int)((us + 999) / 1000);
  if((ms > 0)) {
    Sleep((unsigned long)ms);
  }
#else
  if(secs > 0) {
    double n = 1;
    double m = modf((double)secs, &n);
    struct timespec ts = {(time_t)floor(secs), (long)(m * 1000000000.0)};
    {
      bool stop = false;
      int res = 0;
      do {
        errno = 0;
        res = nanosleep((&ts), (&ts));
        stop = res == 0 || errno != EINTR;
      } while(!stop);
    }
  }
#endif
  return 0;
}

#ifdef _WIN32

typedef struct TimeOffset {
    uint64_t frequency;
    uint64_t offset;
} TimeOffset;


static TimeOffset _timeOffset;


static void _InitTime(void)
{
    QueryPerformanceFrequency((LARGE_INTEGER*) &_timeOffset.frequency);
}

static uint64_t _GetTimeValue(void)
{
    uint64_t value;
    QueryPerformanceCounter((LARGE_INTEGER*) &value);
    return value;
}
#elif defined(__APPLE__)

#include <mach/mach_time.h>

typedef struct TimeOffset {
    uint64_t frequency;
    uint64_t offset;
} TimeOffset;

static TimeOffset _timeOffset;

static void _InitTime(void)
{
  mach_timebase_info_data_t info;
  mach_timebase_info(&info);
  _timeOffset.frequency = (info.denom * 1e9) / info.numer;
}

static uint64_t _GetTimeValue(void)
{
  return mach_absolute_time();
}

#else
#include <unistd.h>
#include <sys/time.h>

typedef struct TimeOffset {
  uint64_t frequency;
  uint64_t clock;
  uint64_t offset;
} TimeOffset;


static TimeOffset _timeOffset;

static void _InitTime()
{
    _timeOffset.clock = CLOCK_REALTIME;
    _timeOffset.frequency = 1000000000;
#if defined(_POSIX_MONOTONIC_CLOCK)
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) == 0)
        _timeOffset.clock = CLOCK_MONOTONIC;
#endif
}

static uint64_t _GetTimeValue()
{
  struct timespec ts;
  clock_gettime(_timeOffset.clock, &ts);
  return (uint64_t) ts.tv_sec * _timeOffset.frequency + (uint64_t) ts.tv_nsec;
}

#endif

static void frequencyInitTimer() {
  _InitTime();
  _timeOffset.offset = _GetTimeValue();
}

static int performance_counter(lua_State *L) {
  uint64_t t = _GetTimeValue();
  lua_pushnumber(L, t);
  return 1;
}

static int performance_frequency(lua_State *L) {
  double t = _timeOffset.frequency;
  lua_pushnumber(L, t);
  return 1;
}

static int performance_now(lua_State *L) {
  double t = (double)(_GetTimeValue() - _timeOffset.offset) / _timeOffset.frequency;
  lua_pushnumber(L, t);
  return 1;
}

static const luaL_Reg performancelib[] = {
  {"counter",   performance_counter},
  {"frequency", performance_frequency},
  {"now",       performance_now},
  {"sleep",     performance_sleep},
  {NULL, NULL}
};

LUAMOD_API int luaopen_performance(lua_State *L) {
  luaL_newlib(L, performancelib);
  frequencyInitTimer();
  return 1;
}