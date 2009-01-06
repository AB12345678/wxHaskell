-----------------------------------------------------------------------------------------
{-| Module      :  ParseC
    Copyright   :  (c) Daan Leijen 2003
    License     :  BSD-style

    Maintainer  :  wxhaskell-devel@lists.sourceforge.net
    Stability   :  provisional
    Portability :  portable

    Basic Types
-}
-----------------------------------------------------------------------------------------
module Types( trace, traceIgnore, traceWarning, traceError
            , errorMsg, errorMsgDecl
            , Decl(..), Arg(..), Type(..), Strategy(..), CBaseType(..), argName
            , Def(..), DefType(..)
            ) where

import System.IO.Unsafe ( unsafePerformIO )


{-----------------------------------------------------------------------------------------
  Tracing
-----------------------------------------------------------------------------------------}
trace s x
  = seq (unsafePerformIO (putStrLn s)) x

traceIgnore msg decl x
  = trace ("ignore: " ++ fill 12 msg ++ ": " ++ declName decl) x
  where
    fill n s  | length s >= 12  = s
              | otherwise       = s ++ replicate (12 - length s) ' '

traceWarning msg decl x
  = trace ("****************************************************\n" ++
           "warning : " ++ msg ++ ": " ++ declName decl) x

traceError msg decl x
  = trace ("****************************************************\n" ++
           "error : " ++ msg ++ ": " ++ declName decl) x


errorMsg str
  = error ("error: " ++ str)

errorMsgDecl decl str
  = errorMsg (str ++ " in " ++ declName decl ++ ": " ++ show decl)

{-----------------------------------------------------------------------------------------
  (Eiffel) Definitions
-----------------------------------------------------------------------------------------}
data Def  = Def{ defName  :: String
               , defValue :: Int
               , defType  :: DefType
               }
          deriving Show

data DefType  = DefInt    -- normal integer
              | DefMask   -- bit mask
              deriving Show

{-----------------------------------------------------------------------------------------
  (C) Declarations
-----------------------------------------------------------------------------------------}
data Decl = Decl{ declName :: String
                , declRet  :: Type
                , declArgs :: [Arg]
                , declComment :: String
                }
          deriving Show

data Arg  = Arg{ argNames :: [String]
               , argType :: Type
               }
          deriving Show

argName :: Arg -> String
argName arg
  = concat (argNames arg)

data Type = Int CBaseType
          | Int64
          | Word8
          | Word32
          | Void
          | Char
          | Double
          | Float
          | Ptr Type
          | ByteString Strategy
          | ByteStringOut Strategy
          | ByteStringLen
          -- typedefs
          | EventId
          | Id
          -- temporary types
          | StringLen
          | StringOut CBaseType
          | PointOut CBaseType
          | SizeOut CBaseType
          | VectorOut CBaseType
          | RectOut CBaseType
          | ArrayLen
          | ArrayStringOut CBaseType
          | ArrayIntOut CBaseType
          | ArrayObjectOut String CBaseType
          -- derived types
          | Object String
          | String CBaseType
          | ArrayInt    CBaseType
          | ArrayString CBaseType
          | ArrayObject String CBaseType
          | Bool
          | Point CBaseType
          | Size CBaseType
          | Vector CBaseType
          | Rect CBaseType
          | RefObject String    -- for "GetFont" etc. returns the font via an indirect reference!
          | Fun String          -- function pointers
          | ColorRGB CBaseType
          deriving (Eq,Show)

data Strategy   = Lazy | Strict
                deriving (Eq,Show)

data CBaseType  = CVoid | CInt | CLong | CDouble | CChar | TimeT | SizeT | CObject
                deriving (Eq,Show)
