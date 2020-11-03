;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname |Final-Project (How To Code Simple Data)|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

;; CONSTANTS:
;; =============

(define WIDTH 350)
(define HEIGHT 600)
(define BACKGROUND (rectangle WIDTH HEIGHT "solid" "midnight blue"))

(define SPEED  10) ;; PIXELS PER TICK
(define BSPEED 15) ;; PIXELS PER TICK
(define SSPEED  5) ;; PIXELS PER TICK

(define TANK (above (rectangle 10 15 "solid" "black")
                    (rectangle 30 10 "solid" "black")
                    (rectangle 40 15 "solid" "black")
                    (beside
                     (circle 5 "solid" "black")
                     (circle 5 "solid" "black")
                     (circle 5 "solid" "black")
                     (circle 5 "solid" "black"))))


(define BULLET (ellipse 10 25 "solid" "red"))

(define SPACESHIP (above (rectangle 5 10 "solid" "green") 
                         (ellipse 50 20 "solid" "green") ))

(define SHIP-WIDTH  25) ;; SPACESHIP WIDTH / 2    ;; to detect the bullet hit 
(define SHIP-HEIGHT 15) ;; SPACESHIP HEIGHT / 2   ;; to detect the bullet hit
(define TANK-HEIGHT (- HEIGHT 25)) ;; the distance between the top of the screen and the tiles of the tank

;--------------------------------------------------------------------------------------------------------------------------------

;; DATA DEFINITIONS:
;; =====================


(define-struct tank (x dir))
;; Tank is (make-tank Natural String)                                                                                             ;; Tank 
;; interp. x is the x-position of TANK
;;         dir is the direction of TANK

(define t0 (make-tank 0 "left"))    ;at the left bottom and moving left (stopped)
(define t1 (make-tank 5 "left"))    ;moving normally
(define t2 (make-tank WIDTH "right")) ;at the right bottom and moving right (stopped)

#;
(define (fn-for-tank t)
  (...(tank-x t)
      (tank-dir t)))



(define-struct bullet(x y))
;; Bullet is (make-bullet Natural Natural)                                                                                        ;; Bullet
;; interp. x, y are x-y position of BULLET

(define b0 (make-bullet 5 5))
(define b1 (make-bullet 3 3))
(define b2 (make-bullet 0 0))
(define b3 (make-bullet 5 -25)) ;out of the screen

#;
(define (fn-for-bullet b)
  (...(bullet-x b)
      (bullet-y b)))


;; ListOfBullet is one of                                                                                                         ;; List Of Bullet
;; - empty
;; - (cons Bullet ListOfBullet)

(define l0 empty)
(define l1 (cons b1 empty))
(define l2 (list b1 b2))

#;
(define (fn-for-LOB l)
  (cond[(empty? l) (...)]
       [else
        (... (fn-for-Bullet (first l))
             (fn-for-LOB (rest l)) )]))


(define-struct ship (x y dir))
;; Ship is (make-ship Natural Natural String)                                                                                     ;; Ship
;; interp. x, y are the x y position of SPACESHIP
;;         dir is the ship x-direction

(define s0 (make-ship 3 3 "left") )
(define s1 (make-ship 0 HEIGHT "right")) ; END OF THE SCREEN (GAME OVER)
(define s2 (make-ship 3 HEIGHT "left"))  ; END OF THE SCREEN (GAME OVER)

#;
(define (fn-for-ship s)
  (... (ship-x   s)
       (ship-y   s)
       (ship-dir s)))


;; ListOfShips is one of:                                                                                                         ;; List Of Ship
;; - empty
;; - (cons Ship ListOfShip)

(define ls0 empty)
(define ls1 (cons s0 empty))
(define ls2 (list s0 s1))

#;
(define (fn-for-LOS l)
  (cond [(empty? l ) (...)]
        [else
         (... (fn-for-ship (first l))
              (fn-for-LOS  (rest l))) ]))



(define-struct scene (t LOB LOS))
;; scene is (make-scene Tank ListOfBullet ListOfShip)                                                                               ;; Scene
;; interp. t is the tank, LOB is lis of bullets , LOS is list of ships

(define sc1 (make-scene (make-tank 0 "right") empty empty)) ;; beginnig scene
(define sc2 (make-scene t1 l1 ls1))
(define sc3 (make-scene t1 l1 (list (make-ship 123 123 "right"))))

#;
(define (fn-for-scene sc)
  (... (fn-for-tank (scene-t sc))
       (fn-for-LOB  (scene-LOB sc))
       (fn-for-LOS  (scene-LOS sc)) ))


;;--------------------------------------------------------------------------------------------------------------------------------

;; FUNCTIONS:
;; ================


;; scene -> scene                                                                                                                    ;; (main sc)
;; start main with (main sc1)

(define (main sc)
  (big-bang sc
    (on-tick   next-scene )      ;; Scene -> Scene
    (to-draw   render-scene)     ;; Scene -> Image
    (on-key    key-handle)       ;; Scene KeyEvent -> Scene
    (stop-when game-over? last-scene)))     ;; scene -> boolen 




;; Scene -> Scene                                                                                                                    ;; (next-scene sc)
;; produces the next scene

;; (define (next-scene sc) sc) ;stub
;; <scene Template>

(define (next-scene sc)
  (make-scene (next-tank  (scene-t sc))
              (next-LOB   (check-bullets  (scene-LOB sc) (scene-LOS sc)) )

              (add-ships
               (next-LOS
                (check-ships (scene-LOS sc) (scene-LOB sc)) ))))
                  
;; tank -> tank                                                                                                                      ;; (next-tank t)
;; increase the tank-x by SPEED when tank-dir is "right". (refer to CONSTANTS for SPEED)
;; decrease the tank-x by SPEED when tank-dir is "left" . (refer to CONSTANTS for SPEED)
(check-expect (next-tank (make-tank 0 "right"))(make-tank (+ 0 SPEED) "right"))
(check-expect (next-tank (make-tank WIDTH "left")) (make-tank (- WIDTH SPEED) "left"))

;; (define (next-tank t) t) ;stub
;; < Tank's Template >

(define (next-tank t)
  (if (string=? (tank-dir t) "left" )
      (next-left-tank t)
      (next-right-tank t)))

;; Tank -> Tank                                                                                                                      ;; (next-left-tank t)
;; decreases the tank-x by SPEED and do nothing when tank-x = 0 (refer to CONSTANTS for SPEED)
(check-expect (next-left-tank (make-tank 15 "left")) (make-tank (- 15 SPEED) "left"))
(check-expect (next-left-tank (make-tank 0 "left")) (make-tank 0 "left"))

;;(define (next-left-tank t) t) ;stub
;; < Tank's Template >

(define (next-left-tank t)
  (if (<= (tank-x t) 0)
      (make-tank (tank-x t) (tank-dir t))
      (make-tank (- (tank-x t) SPEED) (tank-dir t))))

;; Tank -> Tank                                                                                                                      ;; (next-right-tank t)
;; increases the tank-x by SPEED and do nothing when tank-x = WIDTH (refer to CONSTANTS for SPEED and WIDTH)
(check-expect (next-right-tank (make-tank 15 "right")) (make-tank (+ 15 SPEED) "right"))
(check-expect (next-right-tank (make-tank WIDTH "right")) (make-tank WIDTH "right"))

;;(define (next-right-tank t) t) ;stub
;; < Tank's Template >

(define (next-right-tank t)
  (if (>= (tank-x t) WIDTH)
      (make-tank (tank-x t) (tank-dir t))
      (make-tank (+ (tank-x t) SPEED) (tank-dir t))))

;; ListOfBullet -> ListOfBullet                                                                                                      ;; (next-LOB l)
;; produces the next state of all bullets in the given LOB 
(check-expect(next-LOB empty) empty)
(check-expect(next-LOB (list (make-bullet 5 100))) (list (make-bullet 5 (- 100 BSPEED))))
(check-expect(next-LOB (list (make-bullet 9 (- (+ 5 HEIGHT))))) empty)

;;(define (next-LOB l) l) ;stub
;; < LOB's Template >

(define (next-LOB l)
  (cond[(empty? l) empty]
       [else
        (remove-exceeded
         (cons (next-bullet (first l))
               (next-LOB    (rest  l)) ))]))

;; Bullet -> Bullet                                                                                                                  ;; (next-bullet b)
;; decrease the bullet-y of the given bullet by BSPEED
(check-expect(next-bullet (make-bullet 0 100)) (make-bullet 0 (- 100 BSPEED)))

;; (define (next-bullet b) b) ;stub
;; < Bullet's Template >

(define (next-bullet b)
  (make-bullet (bullet-x b) (- (bullet-y b) BSPEED) ))

;; ListOfBullet -> ListOfBullet                                                                                                      ;; (remove-exceeded LOB)
;; remove all the bullets their bullet-y < 0
(check-expect(remove-exceeded (list (make-bullet 0 0)
                                    (make-bullet 0 -1)
                                    (make-bullet 25 25))) (list (make-bullet 0 0)
                                                                (make-bullet 25 25)))

 
;;(define (remove-exceeded LOB) LOB) ;stub
;; < LOB's Template >

(define (remove-exceeded l)
  (cond[(empty? l) empty]
       [else
        (if   (remove?   (first l))
              (remove-exceeded (rest l))
              (cons (first l) (remove-exceeded (rest l)))) ]))

;; Bullet -> Boolean                                                                                                                 ;; (remove? b)
;; produces true when bullet-y of the given bullet < 0
(check-expect (remove? (make-bullet 0 8)) false)
(check-expect (remove? (make-bullet 65 -1)) true)


;; (define (remove? b) false) ;stub
;; < Bullet's Template >

(define (remove? b)
  (< (bullet-y b) 0 ))

;; ListOfShip -> ListOfShip                                                                                                          ;; (next-LOS ls)
;; produces the next state of all Ships in the given LOS and adds new ships

;; (define (next-LOS ls) ls) ;stub
;; < LOS' Template >

(define (next-LOS l)
  (cond [(empty? l ) l]
        [else
         (cons (next-ship  (first l))
               (next-LOS (rest l))) ]))

;; Ship -> Ship                                                                                                                      ;; (next-ship s)
;; increase ship-y by SSPEED (refer to CONSTANTS for SSPEED)
;; inc. the ship-x by SSPEED and (- SSPEED) when ship-dir is "right" and "left" respectively

(check-expect(next-ship (make-ship 3 3 "right")) (make-ship (+ 3 SSPEED)(+ 3 SSPEED) "right"))
(check-expect(next-ship (make-ship (+ 10 WIDTH) 8 "right")) (make-ship (- (+ 10 WIDTH) SSPEED)(+ 8 SSPEED) "left" ))
(check-expect(next-ship (make-ship 0 8 "left" )) (make-ship (+ 0 SSPEED)(+ 8 SSPEED) "right" ))


;; (define (next-ship s) s) ;sub
;; < Ship's Template >

(define (next-ship s)
  (cond [(to-left? s)
         (make-ship (- (ship-x s) SSPEED) (+ (ship-y s) SSPEED) "left") ]

        [else
         (make-ship (+ (ship-x s) SSPEED) (+ (ship-y s) SSPEED) "right")]
        ))

;; Ship -> Boolean                                                                                                                   ;; (to-left? s)
;; true when ship-dir = "left" or ship-dir = "right" and ship-x >= WIDTH

;;(define (to-left? s) true) ;stub
;; < Ship's Template >

(define (to-left? s)
  (or  (and (<  (ship-x s) WIDTH) (> (ship-x s) 0) (string=?  (ship-dir s) "left"))
       (and (>= (ship-x s) WIDTH) (string=? (ship-dir s) "right"))))

;; LOS -> LOS                                                                                                                       ;; (add-ships ls)
;; adds random number of ships to the given LOS

(define (add-ships ls)
  (new-ships ls (random 30)))

;; LOS Natural -> LOS                                                                                                                 ;; (new-ships ls n)
;; adds one ship to the given LOS if the given Natural is five or two ships when it is 10


;; (define (new-ships ls n) ls) ;stub
;; < LOS' Template >

(define (new-ships l n)
  (cond [(=  5 n) (cons (make-ship (random WIDTH) 0 "right") l) ]
        [(= 10 n) (cons (make-ship (random WIDTH) 0 "right") (cons (make-ship (random WIDTH) 0 "right") l)) ]
        [else l]))



;; LOS LOB -> LOS                                                                                                                    ;; (check-ships ls l)
;; remove all the ships that have been hit by bullets
(check-expect(check-ships (list (make-ship 15 15 "left")
                                (make-ship 30 30 "left")) (list (make-bullet 39 15 )
                                                                (make-bullet 10 10 )))
             empty)
;; (define (check-ships ls l) ls ) ;stub
;; < LOS' Template >

(define (check-ships ls lb)
  (cond [(or (empty? ls) (empty? lb)) ls]
        [else
         (if  (hit?  (first ls) lb)
              (check-ships   (rest ls) lb)
              (cons (first ls) (check-ships (rest ls) lb))) ]))


;; Ship ListOfBullet -> Boolean                                                                                                      ;; (hit? s lb)
;; true if one of bulle in the given LOB hit the given ship


;; (define (hit? s lb) true) ;stub
;; < LOB's Template >

(define (hit? s l)
  (cond[(empty? l) false]
       [else
        (or  (one-hit? s (first l))
             (hit? s (rest l)) )]))

;; Ship Bullet -> Boolean                                                                                                            ;; (one-hit? s b)
;; true if the given bullet hit the given ship

;; (define (one-hit? s b) true)
;; < Bullet's Template >

(define (one-hit? s b)
  (and  (and (>= (bullet-x b) (- (ship-x s) SHIP-WIDTH)) (<= (bullet-x b) (+ (ship-x s) SHIP-WIDTH)) )
        (and (>= (bullet-y b) (- (ship-y s) SHIP-HEIGHT)) (<= (bullet-y b) (+ (ship-y s) SHIP-HEIGHT)) )))



;; LOB LOS-> LOB                                                                                                                  ;; (check-bullet lb ls)
;; remove all the Bullets that have hit ships in the given LOS

(check-expect(check-bullets (list (make-bullet 10 10 )
                                  (make-bullet 39 15 )) (list (make-ship 15 15 "left")
                                                              (make-ship 30 30 "left")))
             empty)
;; (define (check-bullets lb ls) lb ) ;stub
;; < LOS' Template >

(define (check-bullets lb ls)
  (cond [(or (empty? ls) (empty? lb)) lb]
        [else
         (if  (hit-bullet?  (first lb) ls)
              (check-bullets (rest lb) ls)
              (cons (first lb) (check-bullets (rest lb) ls))) ]))


;; Bullet ListOfShip -> Boolean                                                                                                      ;; (hit-bullet? b ls)
;; true if the given bullet hit one of ships in the given LOS

(check-expect(hit-bullet? (make-bullet 15 15) (list (make-ship 15 15 "right"))) true )
(check-expect(hit-bullet? (make-bullet 15 15) (list (make-ship 10 10 "right"))) true )
(check-expect(hit-bullet? (make-bullet 15 15) (list (make-ship 150 150 "right"))) false )

;; (define (hit-bullet? b ls) true) ;stub
;; < LOS' Template >

(define (hit-bullet? b ls)
  (cond [(empty? ls ) false]
        [else
         (or  (one-hit? (first ls) b)
              (hit-bullet?  b (rest ls))) ]))

;; Scene -> Image                                                                                                                    ;; (render-scene sc)
;; render the whole scene
(check-expect(render-scene (make-scene  (make-tank 15 "right")
                                        (list (make-bullet 15 15))
                                        (list (make-ship 90 90 "right")))) (place-image TANK 15 TANK-HEIGHT
                                                                                        (place-image BULLET 15 15
                                                                                                     (place-image SPACESHIP 90 90 BACKGROUND))))

;; (define (render-scene sc) BACKGROUND) ;stub
;; < scene's Template >

(define (render-scene sc)
  (render-tank (scene-t sc)
               (render-LOB  (scene-LOB sc)
                            (render-LOS  (scene-LOS sc) BACKGROUND) )))

;; Tank Image -> Image                                                                                                               ;; (render-tank t i)
;; render the given tank on the given image
(check-expect(render-tank (make-tank 50 "left") BACKGROUND)
             (place-image TANK 50 TANK-HEIGHT BACKGROUND))

;; (define (render-tank t i) i) ;stub
;; < Tank's Template >

(define (render-tank t i)
  (place-image TANK  (tank-x t) TANK-HEIGHT i))

;; LOB Image -> Image                                                                                                                ;; (render-LOB lb i)
;; render all the bullets in the given LOB on the given Image
(check-expect(render-LOB (list (make-bullet 50 60) (make-bullet 20 20)) BACKGROUND)
             (place-image BULLET 50 60
                          (place-image BULLET 20 20 BACKGROUND)))

;; (define (render-LOB l i) i) ;stub
;; < LOB's Template >

(define (render-LOB l i)
  (cond[(empty? l) i]
       [else
        (render-bullet (first l) (render-LOB (rest l) i)) ]))

;; Bullet Image -> Image                                                                                                             ;; (render-bullet b i)
;; render the given bullet on the given image
(check-expect(render-bullet (make-bullet 15 52) BACKGROUND)
             (place-image BULLET 15 52 BACKGROUND))

;; (define (render-bullet b i) i)
;; < Bullet's Template >

(define (render-bullet b i)
  (place-image BULLET (bullet-x b)
               (bullet-y b) i))



;; LOS Image -> Image                                                                                                                ;; (render-LOS ls i)
;; render all the ships in the given LOS on the given image
(check-expect(render-LOS (list (make-ship 15 15 "right")
                               (make-ship 15 99 "left" )) BACKGROUND) (place-image SPACESHIP 15 15
                                                                                   (place-image SPACESHIP 15 99
                                                                                                BACKGROUND)))

;; (define (render-LOS l i) i) ;stub
;; < LOS' Template >


(define (render-LOS l i)
  (cond [(empty? l ) i]
        [else
         (render-ship (first l) (render-LOS (rest l) i)) ]))


;; Ship Image -> Image                                                                                                             ;; (render-ship s i)
;; render the given Ship on the given image
(check-expect(render-ship (make-ship 15 52 "left") BACKGROUND)
             (place-image SPACESHIP  15 52 BACKGROUND))

;; (define (render-ship S i) i)
;; < Ship's Template >

(define (render-ship s i)
  (place-image SPACESHIP (ship-x s)
               (ship-y s) i))



;; Scene KeyEvent -> Scene                                                                                                           ;; (key-handle sc k)
;; handle the pressed keys
(check-expect(key-handle sc1 "left") (make-scene (make-tank (tank-x (scene-t sc1)) "left")
                                                 (scene-LOB sc1)
                                                 (scene-LOS sc1)))

(check-expect(key-handle sc1 "right") (make-scene (make-tank (tank-x (scene-t sc1)) "right")
                                                  (scene-LOB sc1)
                                                  (scene-LOS sc1)))

(check-expect(key-handle sc1 " ") (make-scene (scene-t sc1)
                                              (add-bullet sc1)
                                              (scene-LOS sc1)))

;; (define (key-handle sc k) sc) ; stub

(define (key-handle sc k)
  (cond [(key=? k " ") (make-scene (scene-t sc) (add-bullet sc) (scene-LOS sc))]
        [(key=? k "right") (make-scene (make-tank (tank-x (scene-t sc)) "right")
                                       (scene-LOB sc)
                                       (scene-LOS sc))]
        [(key=? k "left") (make-scene (make-tank (tank-x (scene-t sc)) "left")
                                      (scene-LOB sc)
                                      (scene-LOS sc))]
        [else sc]))

;; Scene -> LOB                                                                                                                      ;; (add-bullet s)
;; add one bullet to the given (scene-LOB) at (tank-x (scene-tank))
(check-expect(add-bullet sc1) (cons (make-bullet (tank-x (scene-t sc1)) TANK-HEIGHT) (scene-LOB sc1)))


(define (add-bullet sc)
  (cons (make-bullet (tank-x (scene-t sc)) TANK-HEIGHT)
        (scene-LOB sc)))


;; Scene -> Boolen                                                                                                                  ;; (game-over? g)
;; produces true when a Ship reach the end of the screen
(check-expect(game-over? sc1) false)
(check-expect(game-over? (make-scene (scene-t sc1) (scene-LOB sc1)
                                     (list (make-ship 15 HEIGHT "right")))) true)

;; (define (game-over? sc) true)

(define (game-over? sce)
  (ormap reached-border? (scene-LOS sce)))

;; Ship -> Boolean                                                                                                                   ;; (reached-border? s)
;; true when the given ship's height is >= HEIGHT (refer to CONSTANTS for HEIGHT)
(check-expect(reached-border? (make-ship 15 HEIGHT "left")) true)
(check-expect(reached-border? (make-ship 15 15 "right")) false)

;; (define (reached-border? s) true)
;; < Ship's Template >

(define (reached-border? s)
  (>= (ship-y s) HEIGHT))



(define (last-scene s)
  (render-scene s))