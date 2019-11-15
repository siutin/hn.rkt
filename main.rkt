#lang racket

(require net/http-client)

(define-values (status headers in)
  (http-sendrecv 
    "hacker-news.firebaseio.com"
    "/v0/topstories.json"
    #:ssl? #t
    #:method "GET"))

(displayln status)
(displayln headers)
(displayln (port->string in))
(close-input-port in)