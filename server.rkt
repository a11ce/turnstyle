#lang racket

(provide start-turnstyle-server!)


(struct player-conn (idx in out))

(define (send conn datum)
  (define out (player-conn-out conn))
  (writeln datum out)
  (flush-output out))

(define (recv-commands player-conns)
  ; TODO async
  (for/list ([conn player-conns])
    (define command (read (player-conn-in conn)))
    command))

(define (annotate-state-message message turn-idx)
  `(turn ,turn-idx ,message))

(define (start-turnstyle-server!
         port
         init-state apply-commands render-state display-system-message
         [n-players 2])
  (define listener (tcp-listen port 5 #t))
  (display-system-message (format "Listening on port ~v" port))
  (define player-conns
    (for/list ([player-idx n-players])
      (define-values (in out) (tcp-accept listener))
      (display-system-message
       (format "Player ~v connected" player-idx))
      (player-conn player-idx in out)))
  (display-system-message "Starting game")
  (for/list ([conn player-conns])
    (send conn `(game-start ,(player-conn-idx conn))))
  
  (let game-loop ([state init-state]
                  [turn-count 0])
    (define commands (recv-commands player-conns))
    (define next-state (apply apply-commands state commands))
    (for/list ([conn player-conns])
      (define message (render-state next-state (player-conn-idx conn)))
      (send conn
            (annotate-state-message message turn-count)))
    (display-system-message (format "Turn ~v complete" turn-count))
    (game-loop next-state (add1 turn-count))))
