#lang racket

(require "client.rkt"
         "server.rkt")

(provide start-turnstyle-from-command-line-args!
         start-turnstyle!
         invalid-move)

(struct cli-opts (mode server port) #:transparent)

(define (parse-cli)
  (define connect-addr #f)
  (define port #f)
  (command-line 
   #:once-each
   [("-p" "--port") p "Port"
                    (set! port (string->number p))]
   #:args host
   (set! connect-addr (if (empty? host) #f (car host))))
  (define mode (if connect-addr 'client 'server))
  (cli-opts mode connect-addr port))

(define start-turnstyle-from-command-line-args!
  (make-keyword-procedure
   (lambda (kws kw-args . args)
     (define opts (parse-cli))
     (keyword-apply
      start-turnstyle!
      kws
      kw-args
      (cli-opts-mode opts)
      (cli-opts-server opts)
      (cli-opts-port opts)
      args))))

(define (start-turnstyle!
         mode
         server
         port
         #:init-state init-state
         #:apply-commands apply-commands
         #:render-state-for-client render-state-for-player
         #:display-rendered-state display-state-message
         #:get-command get-move
         #:parse-command validate-move
         #:display-system-message display-system-message)
  (cond
    [(equal? mode 'client)
     (start-turnstyle-client!
      port
      display-state-message
      get-move
      validate-move
      display-system-message)]
    [(equal? mode 'server)
     (start-turnstyle-server!
      port
      init-state
      apply-commands
      render-state-for-player
      display-system-message)]))
