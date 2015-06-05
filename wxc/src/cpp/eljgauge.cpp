#include "wrapper.h"

extern "C"
{

EWXWEXPORT(void*, wxGauge_Create) (void* _prt, int _id, int _rng, int _lft, int _top, int _wdt, int _hgt, int _stl)
{
	return (void*) new wxGauge ((wxWindow*)_prt, _id, _rng, wxPoint(_lft, _top), wxSize(_wdt, _hgt), _stl);
}
	
EWXWEXPORT(void, wxGauge_SetRange)(void* _obj, int r)
{
	((wxGauge*)_obj)->SetRange(r);
}
	
EWXWEXPORT(void, wxGauge_SetValue)(void* _obj, int pos)
{
	((wxGauge*)_obj)->SetValue(pos);
}
	
EWXWEXPORT(int, wxGauge_GetRange)(void* _obj)
{
	return ((wxGauge*)_obj)->GetRange();
}
	
EWXWEXPORT(int, wxGauge_GetValue)(void* _obj)
{
	return ((wxGauge*)_obj)->GetValue();
}
	
}
