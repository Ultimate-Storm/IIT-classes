import Data.HashMap.Strict as H
import Data.List (intercalate)

show' :: Show a => [a] -> String
show' = intercalate " " . Prelude.map show

-- Initial types

type ForthState = (IStack, CStack, Dictionary)

type IStack = [Integer]
initialIStack = []

type CStack = [[String]]
initialCStack = []

-- Type for the symbol dictionary

type Dictionary = H.HashMap String [Entry]

data Entry =
     Prim ([Integer] -> [Integer])
   | Def [String]
   | Num Integer
   | Unknown String
   | Boolean Bool

instance Show Entry where
  show (Prim f)    = "Prim"
  show (Def s)     = show s
  show (Num i)     = show i
  show (Unknown s) = "Unknown: " ++ s


-- Dictionary helpers

wrap2 f (x:y:xs) = (f x y):xs
wrap2 f _ = error "Value stack underflow!"

wrap2a f (x:y:xs) = (f y x):xs
wrap2a f _ = error "Value stack underflow!"

dup xx =  [head xx] ++ xx
drop1 (x:xs) = xs
swap (x:y:xs) = [y] ++ [x] ++ xs
rot (x:y:z:xs) = [z] ++ [x] ++ [y] ++ xs

notf (x:xs)
  | x == -1 = 0:xs
  | x == 0 = -1:xs
  | otherwise = error "You didn't use boolean values!"

compbool f (x:y:xs)
  | x == -1 && y == -1 = if((f) True True) then -1:xs else 0:xs
  | x == -1 && y == 0 = if((f) True False) then -1:xs else 0:xs
  | x == 0 && y == -1 = if((f) False True) then -1:xs else 0:xs
  |x == 0 && y == 0 = if((f) False False) then -1:xs else 0:xs
  | otherwise = error "You didn't use boolean values!"


comp f (x:y:xs) =
  if((f) y x)
    then -1:xs
    else 0:xs

dlookup :: String -> Dictionary -> Entry
dlookup word dict =
  case H.lookup word dict of
    Nothing -> case reads word of
                 [(i,"")] -> Num i
                 _        -> Unknown word
    Just x  -> head x

dinsert :: String -> Entry -> Dictionary -> Dictionary
dinsert key val dict =
   case H.lookup key dict of
      Nothing -> H.insert key [val] dict
      Just x  -> H.insert key (val:x) dict

-- Initial Dictionary

dictionary = dinsert "+" (Prim $ wrap2 (+))
              (dinsert "dup" (Prim $ dup)
              (dinsert "drop" (Prim $ drop1)
              (dinsert "swap" (Prim $ swap)
              (dinsert "rot" (Prim $ rot)
              (dinsert "-" (Prim $ wrap2a (-))
              (dinsert "*" (Prim $ wrap2 (*))
              (dinsert "/" (Prim $ wrap2a (quot))
              (dinsert "<" (Prim $ comp (<))
              (dinsert ">" (Prim $ comp (>))
              (dinsert "==" (Prim $ comp (==))
              (dinsert "<=" (Prim $ comp (<=))
              (dinsert ">=" (Prim $ comp (>=))
              (dinsert "&&" (Prim $ compbool (&&))
              (dinsert "||" (Prim $ compbool (||))
              (dinsert "not" (Prim $ notf) H.empty ) )))) ) ) ) ) ) ) ))))

getTrueStmt [] = []
getTrueStmt (x:xs) =
  if(x == "else")
    then []
    else x:(getTrueStmt xs)

getFalseStmt [] = []
getFalseStmt (x:xs) =
  if(x == "else")
    then xs
    else getFalseStmt xs

getThenStmt [] = []
getThenStmt (x:xs) =
  if(x == "then")
    then xs
    else getThenStmt xs

-- The Evaluator

eval :: [String] -> ForthState -> IO ForthState
eval []    (istack, [],     dict) = return (istack, [], dict)
eval words (istack, cstack, dict) =
  case dlookup (head words) dict of
    Num i        -> eval xs (i:istack, cstack, dict)
    Prim f       -> eval xs (f istack, cstack, dict)
    Def d         -> eval (d++xs) (istack, cstack, dict)

    Unknown "."  -> do { putStrLn $ show (head istack);
                             eval xs (tail istack, cstack, dict) }
    Unknown ".S"  -> do { putStrLn $ show' (reverse istack);
                             eval xs (istack, cstack, dict) }
    Unknown ":" ->   return (istack, cstack, dinsert (head (tail words)) (Def (tail (tail words))) dict)
    Unknown ";" ->   eval xs (istack, cstack, dict)
    Unknown "if" ->  do{if((head istack) == -1)
                          then eval ((getTrueStmt xs)++(getThenStmt xs)) ((drop1 istack), cstack, dict)
                          else eval (getFalseStmt xs) ((drop1 istack), cstack, dict)}
    Unknown "then" -> eval xs (istack, cstack, dict)
    Unknown "begin" -> eval xs (istack, xs:cstack, dict)
    Unknown "exit" -> return (istack, [], dict)
    Unknown "again" -> eval (head cstack) (istack, cstack, dict)

  where xs = tail words

repl :: ForthState -> IO ForthState
repl state =
  do putStr "> " ;
     input <- getLine
     nustate <- eval (words input) state
     repl nustate

main = do
  putStrLn "Welcome to your forth interpreter!"
  repl (initialIStack, initialCStack, dictionary)
