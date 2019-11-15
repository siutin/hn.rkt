#lang racket

(require net/http-client)
(require json)

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
    (let ([items (map
                    (lambda (item-id)
                          (future (lambda () (hw/api/item item-id))))
                    (take (hw/api/topstories) 5))])
      (for/async ([item items])
        (displayln (touch item)))))
  (hw/index))