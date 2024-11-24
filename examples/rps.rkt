#lang racket

(require "../turnstyle.rkt")

; state hold the score in favor of player 0
(define (update score m0 m1)
  (define (beats? a b)
    (match (list a b)
      [(list 'rock 'scissors) #t]
      [(list 'scissors 'paper) #t]
      [(list 'paper 'rock) #t]
      [else #f]))
  (define score-change
    (cond
      [(equal? m0 m1)  0]
      [(beats? m0 m1)  1]
      [(beats? m1 m0) -1]))
  (+ score score-change))

; renders the state from the point of view of the player.
; this might hide information from one or both players.
(define (render-score score player-idx)
  (if (equal? 0 player-idx)
      score
      (- score)))

(define (display-score turn-idx relative-score)
  (printf "After turn ~v, your score is ~v~n" turn-idx relative-score))

(define (get-move)
  (display "> ")
  (read-line))

(define (parse-move move)
  (match (string-downcase move)
    [(or "r" "rock") 'rock]
    [(or "p" "paper") 'paper]
    [(or "s" "scissors") 'scissors]
    [else (invalid-move "Not a valid move. Try r, p, or s.")]))
  

(start-turnstyle-from-command-line-args!
 #:init-state 0
 #:apply-commands update
 #:render-state-for-client render-score
 #:display-rendered-state display-score
 #:get-command get-move
 #:parse-command parse-move
 #:display-system-message displayln)
