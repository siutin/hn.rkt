#lang racket

(require net/http-client)
(require json)
(require racket/gui)

(define frame (new frame%
                   [label "Hacker News"]
                   [width 1024]
                   [height 600]))
(send frame show #t)

(define (add-frame-list titles)
  (new list-box%
        (label #f)
        (parent frame)
        (choices titles)
        (style (list 'single
                      'column-headers))
        (columns (list "List"))))

(let ([hc (http-conn)])
  (http-conn-open!
    hc
    "hacker-news.firebaseio.com"
    #:ssl? #t
    #:port 443
    #:auto-reconnect? #t)

  (define (hw/base/api-get url)
    (define-values (status headers in)
        (http-conn-sendrecv!
          hc
          (format "https://hacker-news.firebaseio.com/~a" url)
          #:method "GET"))
    (let ([s (string->jsexpr (port->string in))])
      (close-input-port in)
      s))

  (define (hw/api/topstories)
    (hw/base/api-get "/v0/topstories.json"))

  (define (hw/api/item id)
    (hw/base/api-get (format "/v0/item/~a.json" id)))

  (define (hw/index)
    (map
        (lambda (item-id)
              (future (lambda () (hw/api/item item-id))))
        (hw/api/topstories)))

  (begin
    (let* ([futures (take (hw/index) 5)]
           [titles '()])
      (for/async ([f futures])
        (let ([item (touch f)])
          (set! titles (append titles (list (hash-ref item 'title))))))

      (displayln titles)
      (add-frame-list titles))))

