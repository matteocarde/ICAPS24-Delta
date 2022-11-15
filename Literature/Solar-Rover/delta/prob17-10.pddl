(define (problem run-generator2)
(:domain generator)
(:objects GB - generalBattery b1 b2 b3 - battery)
(:init
(= (ck ) 0)
(= (tk ) 0)
(= (delta ) 10)
   (= (roverenergy) 0)
   (night)
   (datatosend)
   (gboff GB)
   (= (SoC b1) 40)
   (off b1)
   (off b2)
   (= (SoC b2) 80)
   (off b3)
   (= (SoC b3) 100)
   (= (sunexposure_time) 850.0)
   (= (time) 0.0)  
)
(:goal (datasent))
(:metric minimize ( total-time ))
)
