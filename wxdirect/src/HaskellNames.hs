-----------------------------------------------------------------------------------------
{-| Module      :  HaskellNames
    Copyright   :  (c) Daan Leijen 2003
    License     :  BSD-style

    Maintainer  :  daan@cs.uu.nl
    Stability   :  provisional
    Portability :  portable

    Utility module to create haskell compatible names.
-}
-----------------------------------------------------------------------------------------
module HaskellNames( haskellDeclName
                   , haskellName, haskellTypeName, haskellUnManagedTypeName
                   , haskellUnderscoreName, haskellArgName
                   , isManaged
                   , getPrologue
                   ) where

import qualified Set
import Char( toLower, toUpper, isLower, isUpper )
import Time( getClockTime )
import List( isPrefixOf )

{-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------}
managedObjects :: Set.Set String
managedObjects
  = Set.fromList ["wxColour"]

  {-
    [ "Bitmap"
    , "Brush"
    , "Colour"
    , "Cursor"
    , "DateTime"
    , "Icon"
    , "Font"
    , "FontData"
    , "ListItem"
    , "PageSetupData"
    , "Pen"
    , "PrintData"
    , "PrintDialogData"
    , "TreeItemId"
    ]
   -}

reservedVarNames :: Set.Set String
reservedVarNames
  = Set.fromList
    ["data"
    ,"int"
    ,"init"
    ,"module"
    ,"raise"
    ,"type"
    ]

reservedTypeNames :: Set.Set String
reservedTypeNames
  = Set.fromList
    [ "Object"
    , "Managed"
    , "Array"
    , "Date"
    , "Dir"
    , "DllLoader"
    , "Expr"
    , "File"
    , "Point"
    , "Size"
    , "String"
    , "Rect"
    ]


{-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------}
haskellDeclName name
  | isPrefixOf "wxDC_" name     = haskellName ("dc" ++ drop 5 name)
  | isPrefixOf "expEVT_" name   = ("wxEVT_" ++ drop 7 name) -- keep underscores
  | isPrefixOf "wxc" name       = haskellName name
  | isPrefixOf "wx" name        = haskellName (drop 2 name)
  | isPrefixOf "ELJ" name       = haskellName ("wxc" ++ drop 3 name)
  | isPrefixOf "DDE" name       = haskellName ("dde" ++ drop 3 name)
  | otherwise                   = haskellName name


haskellArgName name
  = haskellName (dropWhile (=='_') name)

haskellName name
  | Set.member suggested reservedVarNames  = "wx" ++ suggested
  | otherwise                              = suggested
  where
    suggested
      = case name of
          (c:cs)  -> toLower c : filter (/='_') cs
          []      -> "wx"

haskellUnderscoreName name
  | Set.member suggested reservedVarNames  = "wx" ++ suggested
  | otherwise                              = suggested
  where
    suggested
      = case name of
          ('W':'X':cs) -> "wx" ++ cs
          (c:cs)       -> toLower c : cs
          []           -> "wx"


haskellTypeName name
  | isPrefixOf "ELJ" name                   = haskellTypeName ("WXC" ++ drop 3 name)
  | Set.member suggested reservedTypeNames  = "Wx" ++ suggested
  | otherwise                               = suggested
  where
    suggested
      = case name of
          'W':'X':'C':cs -> "WXC" ++ cs
          'w':'x':'c':cs -> "WXC" ++ cs
          'w':'x':cs  -> firstUpper cs
          other       -> firstUpper name

    firstUpper name
      = case name of
          c:cs  | isLower c       -> toUpper c : cs
                | not (isUpper c) -> "Wx" ++ name
                | otherwise       -> name
          []    -> "Wx"

haskellUnManagedTypeName name
  | isManaged name  = haskellTypeName name ++ "Object"
  | otherwise       = haskellTypeName name

isManaged name
  = Set.member name managedObjects

{-----------------------------------------------------------------------------------------
 Haddock prologue
-----------------------------------------------------------------------------------------}
getPrologue moduleName content contains inputFiles
  = do time <- getClockTime
       return (prologue time)
  where
    prologue time
      = [line
        ,"{-| Module      :  " ++ moduleName
        ,"    Copyright   :  (c) Daan Leijen 2003"
        ,"    License     :  wxWindows"
        ,""
        ,"    Maintainer  :  daan@cs.uu.nl"
        ,"    Stability   :  provisional"
        ,"    Portability :  portable"
        ,""
        ,"Haskell " ++ content ++ " definitions for the wxWindow C library (@wxc.dll@)."
        ,""
        ,"Do not edit this file manually!"
        ,"This file is automatically generated by wxDirect on: "
        , ""
        ,"  * @" ++ show time ++ "@"
        ]
        ++
        (if (null inputFiles)
          then []
          else (["","From the files:"] ++ concatMap showFile inputFiles))
        ++
        [""
        ,"And contains " ++ contains
        ,"-}"
        ,line
        ]
      where
        line = replicate 80 '-'

        showFile fname
             = ["","  * @" ++ concatMap escapeSlash fname ++ "@"]

        escapeSlash c
             | c == '/'   = "\\/"
             | c == '\"'  = "\\\""
             | otherwise  = [c]