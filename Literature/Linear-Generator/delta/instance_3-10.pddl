
(define (problem instance_1_2_40_900_70)
  (:domain generator_linear_duration_mt)
  (:objects
    gen_1 - generator
	tank_1 tank_2 tank_3 - tank
  )

  (:init
(= (ck ) 0)
(= (tk ) 0)
(= (delta ) 10)
        (= (uptime gen_1) 0.0)
	(= (fuelLevel gen_1) 940)
	(= (capacity gen_1) 1000)
	(not_online gen_1)
	(= (refuel_running gen_1 tank_1) 0)
	(= (refuel_running gen_1 tank_2) 0)
	(= (refuel_running gen_1 tank_3) 0)
	(= (generator_running gen_1) 0)
	(available tank_1)
	(available tank_2)
	(available tank_3)
	(= (generator_duration) 1000)
	(= (refuel_duration) 10)
  )

  (:goal
    (and 
	(= (generator_running gen_1) 1000) (not (block))
    )
  )
)