(define 
    (problem instance1)
    (:domain hvac)
    (:objects r1  -room k1 k2 k3 k4 -request)
    (:init
(= (ck ) 0)
(= (tk ) 0)
(= (delta ) 5)
        (= (time_requested r1 k1) 10)
        (= (temp_requested r1 k1) 20)
        
        (= (time_requested r1 k2) 20)
        (= (temp_requested r1 k2) 13)

        (= (time_requested r1 k3) 30)
        (= (temp_requested r1 k3) 20)
        
        (= (time_requested r1 k4) 40)
        (= (temp_requested r1 k4) 13)


        
        (= (temp r1) 15)
        (= (air_flow r1) 0)
        (= (temp_sa r1) 10)



        (= (time) 0)
        (= (comfort) 2)


    )
    ;; the goal encodes the horizon of control. 
    (:goal 
        (and  (satisfied k1)(satisfied k2)(satisfied k3)(satisfied k4))
    )
)
