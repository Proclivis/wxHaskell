{--------------------------------------------------------------------------------
  A utility to view images
--------------------------------------------------------------------------------}
module Main where

import Char( toLower )
import Graphics.UI.WXH

defaultWidth,defaultHeight :: Int
defaultWidth  = 300
defaultHeight = 300

main
  = run imageViewer

imageViewer
  = do -- variable that holds the current bitmap
       vbitmap <- varCreate Nothing

       -- create file menu: we use standard Id's but could also use any other identifier, like 1 or 27.
       fm <- menuCreate "" 0
       menuAppend fm wxID_OPEN "&Open..\tCtrl+O"  "Open image" False
       menuAppend fm wxID_CLOSE "&Close\tCtrl+C"  "Close image" False
       menuAppendSeparator fm
       menuAppend fm wxID_ABOUT "&About.." "About ImageViewer" False {- not checkable -}
       menuAppend fm wxID_EXIT "&Quit\tCtrl+Q"    "Quit the viewer"  False

       -- disable close
       menuEnable fm wxID_CLOSE False

       -- create menu bar
       m  <- menuBarCreate 0
       menuBarAppend m fm "&File"

       -- create top frame
       f  <- frameCreateTopFrame "Image Viewer"
       windowSetClientSize f (sz defaultWidth defaultHeight)

       -- coolness: set a custom icon
       frameSetIconFromFile f "ImageViewer.ico"

       -- put a scrolled window inside the frame to paint the image on
       -- note that 'wxNO_FULL_REPAINT_ON_RESIZE'  is needed to prevent flicker on resize.
       s <- scrolledWindowCreate f idAny rectNull (wxHSCROLL + wxVSCROLL + wxNO_FULL_REPAINT_ON_RESIZE + wxCLIP_CHILDREN)

       -- set paint event handler:
       windowOnPaint s False {- double buffer? -} (onPaint vbitmap)

       -- connect menu
       frameSetMenuBar f m
       evtHandlerOnMenuCommand f wxID_OPEN  (onOpen f vbitmap fm s)
       evtHandlerOnMenuCommand f wxID_CLOSE (onClose f vbitmap fm s)
       evtHandlerOnMenuCommand f wxID_ABOUT (onAbout f)
       evtHandlerOnMenuCommand f wxID_EXIT  (onQuit f)
       windowAddOnDelete f (close f vbitmap)
       -- show it
       windowShow f
       windowRaise f

       return ()
  where
    onAbout f
      = infoDialog f "About 'Image Viewer'" "This is a wxHaskell demo"

    onQuit f
      = do windowClose f True {- force close -}
           return ()

    onOpen f vbitmap fm s
      = do mbfname <- fileOpenDialog f True True "Open image" imageFiles "" ""
           case mbfname of
             Nothing
               -> return ()
             Just fname
               -> do bm <- bitmapCreateFromFile fname  -- can fail with exception
                     close f vbitmap
                     varSet vbitmap (Just bm)
                     menuEnable fm wxID_CLOSE True
                     -- and than reset the scrollbars and resize around the picture
                     w <- bitmapGetWidth bm
                     h <- bitmapGetHeight bm
                     oldsz <- windowGetClientSize f
                     let newsz = (sizeMin (sz w h) oldsz)
                     windowSetClientSize f newsz
                     scrolledWindowSetScrollbars s 1 1 w h 0 0 False
                     -- and repaint explicitly (to delete previous stuff)
                     withClientDC s (\dc -> onPaint vbitmap dc (rectFromSize newsz) [])
                  `catch` (\err -> return ())
      where
        imageFiles
           = [("Image files",["*.bmp","*.jpg","*.gif","*.png"])
             ,("Portable Network Graphics (*.png)",["*.png"])
             ,("BMP files (*.bmp)",["*.bmp"])
             ,("JPG files (*.jpg)",["*.jpg"])
             ,("GIF files (*.gif)",["*.gif"])
             ]


    onClose f vbitmap fm s
      = do close f vbitmap
           menuEnable fm wxID_CLOSE False
           -- explicitly delete the old bitmap
           withClientDC s dcClear
           -- and than reset the scrollbars
           scrolledWindowSetScrollbars s 1 1 0 0 0 0 False

    close f vbitmap
      = do mbBitmap <- varSwap vbitmap Nothing
           case mbBitmap of
             Nothing -> return ()
             Just bm -> bitmapDelete bm

    onPaint vbitmap dc viewRect updateAreas
      = do -- clear the canvas
           dcClear dc
           mbBitmap <- varGet vbitmap
           case mbBitmap of
             Nothing -> return ()
             Just bm -> do dcDrawBitmap dc bm pointZero False {- use mask? -}
                           return ()