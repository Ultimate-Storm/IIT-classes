;; You will need to rewrite this.  This code is just for show.
(ns l_system_lab.student)

(defn remove-empties
  [v]
  (filter #(not= [] %) v))

;;
(defn get-xy-scale
  "Get the scaling factor for the coordinates."
  ([v]  {:scale (/ 480 (max (- (apply max (apply map max (map #(take-nth 2 %) (map rest v)))) (apply min (apply map min (map #(take-nth 2 %) (map rest v))))) (- (apply max (apply map max (map #(take-nth 2 %) (map rest (map rest v))))) (apply min (apply map min (map #(take-nth 2 %) (map rest (map rest v))))))))
         :min-x (apply min (apply map min (map #(take-nth 2 %) (map rest v))))
         :min-y (apply min (apply map min (map #(take-nth 2 %) (map rest (map rest v))))) })
  ([v min-x min-y max-x max-y]
     {:scale (/ 480 (max (- max-x min-x) (- max-y min-y)))
      :min-x min-x
      :min-y min-y})
)

;; You will need to rewrite this.  This code is just for show.
(defn scale-turtle
  "Normalizes a list of [:line ... ] vectors."
  ([v] (scale-turtle v (get-xy-scale (remove-empties v)) []))
  ([v scale out]
    ;;(map + (map * (map - (map first (map rest v)) (:min-x scale)) (:scale scale)) 10)
    ;;(loop [i 1
    ;;       vv v]
    ;;  (if (< i 5)
    ;;    (cond (odd? i) (recur (inc i) (map + (map * (map - (map first (map #(nth % i) vv)) (:min-x scale)) (:scale scale)) 10))
    ;;          :else (recur (inc i)((map + (map * (map - (map first (map #(nth % i) vv)) (:min-y scale)) (:scale scale)) 10)))
    ;;    )
    ;;  )
    )
  )


(defn transform [init-pat rules]
  (cond (empty? init-pat) []
        (contains? rules (first init-pat))
          (-> (conj (vector (get (assoc init-pat 0 (rules (first init-pat))) 0 )) (transform (vec (rest init-pat)) rules)) flatten vec)
        :else (-> (conj (vector (get init-pat 0)) (transform (vec (rest init-pat)) rules)) flatten vec)
  )
)

;; # Some fractals to start out with.  Add some of your own!
