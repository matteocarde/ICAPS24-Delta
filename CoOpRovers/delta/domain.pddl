(define (domain robots)

  (:requirements :fluents :durative-actions :duration-inequalities :adl :typing :time)
  (:types
    robot room obj
  )

  (:predicates
    (atRobot ?r - robot ?l - room)
    (atObject ?o - obj ?l - room)
    (allowed ?r - robot ?l - room)
    (holding ?r - robot ?o - obj)
    (handsFull ?r - robot)
    (ismoving ?r - robot ?a - room ?b - room)
    (inMovement ?r - robot)
    (ischarging ?r - robot)
    (link ?a - room ?b - room)
    (alwaysfalse)
  )
  (:functions
    (speed ?r - robot)
    (dischargeRate ?r - robot)
    (battery ?r - robot)
    (distance ?a - room ?b - room)
    (distanceRun ?r - robot ?a - room ?b - room)
    (d ?r - robot)
    (tk ?r - robot)
    (ck)
    (deltaMovement ?r - robot)
    (deltaCharging ?r - robot)
  )

  (:action startMoving
    :parameters (?r - robot ?a - room ?b - room)
    :precondition (and
      (= (ck) (tk ?r))
      (link ?a ?b)
      (not (inMovement ?r))
      (atRobot ?r ?a)
      (allowed ?r ?b)
      (handsFull ?r)
    )
    :effect (and
      (not (atRobot ?r ?a))
      (ismoving ?r ?a ?b)
      (inMovement ?r)
      (assign (distanceRun ?r ?a ?b) 0)
      (assign (d ?r) (deltaMovement ?r))
    )
  )

  (:process moving
    :parameters (?r - robot ?a - room ?b - room)
    :precondition (and
      (link ?a ?b)
      (ismoving ?r ?a ?b)
      (inMovement ?r)
      (< (distanceRun ?r ?a ?b) (distance ?a ?b))
      (>= (battery ?r) 20)
    )
    :effect (and
      (increase
        (distanceRun ?r ?a ?b)
        (* (speed ?r) #t))
    )
  )

  (:event endMoving
    :parameters (?r - robot ?a - room ?b - room)
    :precondition (and
      (link ?a ?b)
      (ismoving ?r ?a ?b)
      (inMovement ?r)
      (>= (battery ?r) 20)
      (>= (distanceRun ?r ?a ?b) (distance ?a ?b))
    )
    :effect (and
      (atRobot ?r ?b)
      (not (ismoving ?r ?a ?b))
      (not (inMovement ?r))
    )
  )

  (:action startCharging
    :parameters (?r - robot)
    :precondition (and
      (= (ck) (tk ?r))
      (>= (battery ?r) 20)
      (inMovement ?r)
    )
    :effect (and
      (not (inMovement ?r))
      (ischarging ?r)
      (assign (d ?r) (deltaCharging ?r))
    )
  )

  (:process charging
    :parameters (?r - robot)
    :precondition (and
      (ischarging ?r)
      (< (battery ?r) 100)
    )
    :effect (and
      (increase (battery ?r) (* #t 1))
    )
  )

  (:process discharging
    :parameters (?r - robot)
    :precondition (and
      (handsFull ?r)
      (not (ischarging ?r))
      (>= (battery ?r) 0)
    )
    :effect (and
      (decrease
        (battery ?r)
        (* #t (* (speed ?r) (dischargeRate ?r))))
    )
  )

  (:action stopCharging
    :parameters (?r - robot)
    :precondition (and
      (= (ck) (tk ?r))
      (ischarging ?r)
    )
    :effect (and
      (not (ischarging ?r))
      (inMovement ?r)
      (assign (d ?r) (deltaMovement ?r))
    )
  )

  (:action pick
    :parameters (?o - obj ?r - robot ?l - room)
    :precondition (and
      (= (ck) (tk ?r))
      (>= (battery ?r) 20)
      (atRobot ?r ?l)
      (atObject ?o ?l)
      (not (handsFull ?r))
    )
    :effect (and
      (holding ?r ?o)
      (not (atObject ?o ?l))
      (handsFull ?r)
    )
  )

  (:action drop
    :parameters (?o - obj ?r - robot ?l - room)
    :precondition (and
      (= (ck) (tk ?r))
      (>= (battery ?r) 20)
      (atRobot ?r ?l)
      (holding ?r ?o)
    )
    :effect (and
      (not (holding ?r ?o))
      (atObject ?o ?l)
      (not (handsFull ?r))
    )
  )

  (:event tic
    :parameters (?r - robot)
    :precondition (and
      (> (d ?r) 0)
      (= (ck) (+ (tk ?r) 3))
    )
    :effect (and
      (assign (tk ?r) (- (+ (ck) (d ?r)) 3))
    )
  )

  (:process ticking
    :parameters ()
    :precondition (and (not (alwaysfalse)))
    :effect (and
      (increase (ck) (* #t 1.0))
    )
  )

)