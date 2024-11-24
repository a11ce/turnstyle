#lang racket

(provide start-turnstyle-client!
         invalid-move)

(struct invalid-move (reason))

(define current-system-messenger (make-parameter displayln))
(define (display-system-message message) ((current-system-messenger) message))
  
(struct server-conn (in out))

(define (send out datum)
  (writeln datum out)
  (flush-output out))

(define (tcp-connect-retry host port)
  (define (on-fail e)
    (display-system-message
     "[C] Connection failed. Maybe the server has not started? Retrying in 10s")
    (sleep 10)
    (tcp-connect-retry display-system-message host port))
  (with-handlers ([exn:fail:network? on-fail])
    (tcp-connect host port)))

(define (get-valid-move get-move validate-move)
  (let loop ()
    (define move (get-move))
    (define parse-result (validate-move move))
    (if (invalid-move? parse-result)
        (begin
          (display-system-message
           (format "[C] Invalid move. Reason: ~v"
                   (invalid-move-reason parse-result)))
          (loop))
        (begin
          (display-system-message (format "Move confirmed: ~v" parse-result))
          parse-result))))

(define (start-turnstyle-client! port display-state-message get-move
                                 validate-move
                                 [display-system-message displayln])
  (parameterize ([current-system-messenger display-system-message])
    (display-system-message "[C] Connecting to server...")
    (define-values (conn-in conn-out)
      (tcp-connect-retry "localhost" port))
    (display-system-message "[C] Connected to server...")
    (define start-message (read conn-in ))
    (match start-message
      [(list 'game-start n)
       (display-system-message
        (format "[S] Game started. You are player ~v" n))])
    (let client-loop ([turn-count 0])
      (send conn-out (get-valid-move get-move validate-move))
      (define response (read conn-in))
      (display-state-message (second response) (third response))
      (client-loop (add1 turn-count)))))
