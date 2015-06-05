#include "wrapper.h"

#define LEN (CHAR_BIT * sizeof(int) - 1) / 3 + 2
extern "C"
{

EWXWEXPORT(wxCursor*,Cursor_CreateFromStock)(int _id)
{
	char str[LEN];
	snprintf(str, LEN, "%d", _id);
	return  new wxCursor(str);
}

EWXWEXPORT(wxCursor*,Cursor_CreateFromImage)(wxImage* image)
{
	return  new wxCursor(*image);
}

EWXWEXPORT(wxCursor*,Cursor_CreateLoad)(wxString* name,long type,int width,int height)
{
#if (wxVERSION_NUMBER >= 2900)
    wxBitmapType bm_type = (wxBitmapType) type;
#else
    long bm_type = type;
#endif
#if defined(__WXGTK__)
    return NULL;
#else
    return new wxCursor(*name, bm_type, width, height);
#endif
}

}
