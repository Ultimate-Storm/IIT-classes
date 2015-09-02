--gets max level of hydra heads
maxlevel hydra = aux hydra (length hydra)
  where aux _ 0 = 0
        aux [] _ = 0
        aux (0:xs) i = aux xs (i-1)
        aux (x:xs) i = i

--Prints what the hydra looks like after chopping highest level head
chop(0:xs) = (0:chop(xs))
chop (x:xs) =
    if 1 + length xs == 1
      then [x-1]
      else (x-1 : length xs + head xs: tail xs)

--Calculates number of chops needed to defeat the hydra
numOfChops hydra j=
  if maxlevel hydra == 0
    then j
    else numOfChops (chop hydra) j+1
