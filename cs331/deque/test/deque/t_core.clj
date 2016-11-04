(ns deque.t-core
  (:use midje.sweet)
  (:use [deque.core])
  (:import [deque.core Deque] ))

(facts "about this lab"
  (fact "the student never started it."
        (+ 1 2)  => 3))

(facts "deque size changes"
       (fact "all push/pop functions change size"
           (let [x (Deque. '(1 2 3) '(4 5 6) 6)]
             
             (push-front x 7) => (Deque. '(7 1 2 3) '(4 5 6) 7)
             (push-back x 7) => (Deque. '(1 2 3) '(7 4 5 6) 7)
             (pop-front x) => (Deque. '(2 3) '(4 5 6) 5)
             (pop-back x) => (Deque. '(1 2 3) '(5 6) 5)
           ) 
        )

       (fact "Size cannot go negative"
             (let [x (Deque. '() '() 0)]
              (pop-front x) => (Deque. '() '() 0)
              (pop-back x) => (Deque. '() '() 0)
             )
       )
)

(facts "flip functions"
    (fact "flip functions perform correctly"
    (flip-front (Deque. '() '(2 3 4) 3)) => (Deque. '(4 3 2) '() 3)
    (flip-back (Deque. '(2 3 4) '() 3)) => (Deque. '() '(4 3 2) 3)
    (flip-front (Deque. '(1 2) '(2 3 4) 5)) => (Deque. '(1 2) '(2 3 4) 5)
    (flip-back (Deque. '(2 3 4) '(4 5) 5)) => (Deque. '(2 3 4) '(4 5) 5)
    )
)
(facts "front function"
    (fact "front and back perform correctly"
    (front (Deque. '(1 2 3) '(4 5) 5)) => 1
    (front (Deque. '() '(4 5) 2)) => 5
    (back (Deque. '(1 2 3) '(4 5) 5)) => 4
    (back (Deque. '(1 2 3) '() 3)) => 3      
    )
)
