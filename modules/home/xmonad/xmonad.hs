import XMonad
import XMonad.Actions.Volume
import XMonad.Actions.ToggleFullFloat (toggleFullFloat)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.FadeInactive (fadeInactiveLogHook)
import XMonad.Hooks.ManageDocks (docks)
import XMonad.Hooks.ManageHelpers (doFullFloat)
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.Gaps
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing (spacingRaw, Border(Border))
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.Loggers
import XMonad.Util.SpawnOnce (spawnOnce)

import qualified Codec.Binary.UTF8.String as UTF8
import qualified DBus
import qualified DBus.Client as DBus
import qualified XMonad.StackSet as W

import System.Exit (exitSuccess)
import Graphics.X11.ExtraTypes.XF86

myModMask = mod4Mask
myTerminal = "kitty"

appLauncher  = "rofi -modi drun,ssh,window -show drun -show-icons"
screenLocker = "betterlockscreen -l dim"
powerMenu = "wlogout"

main :: IO ()
main = mkDBusClient >>= main'

main' :: DBus.Client -> IO ()
main' dbus
  = xmonad
  $ ewmhFullscreen
  $ docks
  $ ewmh
  $ myConfig dbus

myLogHook = fadeInactiveLogHook 0.9

mkDBusClient :: IO DBus.Client
mkDBusClient = do
  dbus <- DBus.connectSession
  DBus.requestName dbus (DBus.busName_ "org.xmonad.log") opts
  return dbus
  where
    opts = [ DBus.nameAllowReplacement, DBus.nameReplaceExisting, DBus.nameDoNotQueue ]

dbusOutput :: DBus.Client -> String -> IO ()
dbusOutput dbus str =
  let opath  = DBus.objectPath_ "/org/xmonad/Log"
      iname  = DBus.interfaceName_ "org.xmonad.Log"
      mname  = DBus.memberName_ "Update"
      signal = DBus.signal opath iname mname
      body   = [ DBus.toVariant $ UTF8.decodeString str ]
  in  DBus.emit dbus $ signal { DBus.signalBody = body }

polybarHook :: DBus.Client -> PP
polybarHook dbus =
  let wrapper c s | s /= "NSP" = wrap ("%{F" <> c <> "} ") " %{F-}" s
                  | otherwise  = mempty
      blue   = "#2E9AFE"
      gray   = "#7F7F7F"
      orange = "#ea4300"
      purple = "#9058c7"
      red    = "#722222"
  in  def { ppOutput          = dbusOutput dbus
          , ppCurrent         = wrapper blue
          , ppVisible         = wrapper gray
          , ppUrgent          = wrapper orange
          , ppHidden          = wrapper gray
          , ppHiddenNoWindows = wrapper red
          , ppTitle           = wrapper purple . shorten 90
          }

myPolybarLogHook dbus = myLogHook <+> dynamicLogWithPP (polybarHook dbus)

myConfig dbus = def
  { modMask         = myModMask
  , terminal        = myTerminal
  , layoutHook      = myLayout
  , logHook         = myPolybarLogHook dbus
  , manageHook      = myManageHook
  }
  `additionalKeys`
  [ ((mod,           xK_c),                     kill)
  , ((mod,           xK_e),                     chrome)
  , ((mod,           xK_f),                     withFocused toggleFullFloat)
  , ((mod,           xK_equal),                 togglePolybar)
  , ((mod .|. shift, xK_l),                     spawn screenLocker)
  , ((mod,           xK_o),                     spawn appLauncher)
  , ((mod,           xK_p),                     spawn powerMenu)
  , ((mod,           xK_q),                     quit)
  , ((mod,           xK_v),                     spawn "code")
  , ((mod,           xK_w),                     spawn "brave")
  , ((0,             xF86XK_AudioMute),         audioMute)
  , ((0,             xF86XK_AudioLowerVolume),  audioLower)
  , ((0,             xF86XK_AudioRaiseVolume),  audioRaise)
  , ((0,             xF86XK_MonBrightnessUp),   brightUp)
  , ((0,             xF86XK_MonBrightnessDown), brightDown)
  ]
  ++
  [((mod .|. controlMask, k), windows $ (W.greedyView i) . (W.shift i))
    | (i, k) <- zip (workspaces def) [xK_1 .. xK_9]
  ]
  where
    mod           = myModMask
    shift         = shiftMask
    quit          = io exitSuccess
    chrome        = spawn "google-chrome-stable"
    togglePolybar = spawn "polybar-msg cmd toggle"
    audioMute     = spawn "polybar-msg action \"#pipewire.hook.1\""
    audioLower    = spawn "polybar-msg action \"#pipewire.hook.2\""
    audioRaise    = spawn "polybar-msg action \"#pipewire.hook.3\""
    brightDown    = spawn "brightnessctl set 5%-"
    brightUp      = spawn "brightnessctl set +5%"

myLayout
  = gaps [(L,10), (R,10), (U,60), (D,10)]
  $ spacingRaw True (Border 5 5 5 5) True (Border 5 5 5 5) True
  $ smartBorders
  $ tiled ||| Mirror tiled ||| Full
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    delta   = 3/100
    ratio   = 1/2

myManageHook :: ManageHook
myManageHook = composeAll
  [ className =? "Wlogout" --> doFullFloat ]
