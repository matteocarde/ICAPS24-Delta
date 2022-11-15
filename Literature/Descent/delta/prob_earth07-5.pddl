;; Enrico Scala (enricos83@gmail.com) and Miquel Ramirez (miquel.ramirez@gmail.com)
(define (problem descent_prob)
	(:domain descent)
	(:init
(= (ck ) 0)
(= (tk ) 0)
(= (delta ) 5)
		(= d_final 700)
		(= d_margin 10)
		(= v_margin 10)
		(= v 0)
		(= d 0)
		(= g 9.8)
		(= M 10000)
		(= M_min 5000)
		(= q 50)
		(= ISP 311)  
				;(not_thrusting)  
		(stop)
		;;(not (landed))
		;;(not (crashed))
	)
	
	(:goal (and (landed) (not (crashed))))
	(:metric minimize(total-time))
)
	
