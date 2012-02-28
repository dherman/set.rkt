#lang racket/base
(provide (all-defined-out))

(define-syntax-rule (hash-intersection hash hashes for/xxx)
  (let ([rest hashes])
    (for/xxx ([(key value) hash]
              #:when (andmap (lambda (h)
                               (hash-ref h key (lambda () #f)))
                             rest))
      (values key #t))))

(define-syntax-rule (hash-difference hash hashes for/xxx)
  (let ([rest hashes])
    (for/xxx ([(key value) hash]
              #:when (not (ormap (lambda (h)
                                   (hash-ref h key (lambda () #f)))
                                 rest)))
      (values key #t))))

(define ((hash-partition empty) hash hashes)
  (for/fold ([diff empty]
             [intersection empty])
            ([(key value) hash])
    (if (ormap (lambda (h)
                 (hash-ref h key (lambda () #f)))
               hashes)
        (values diff (hash-set intersection key #t))
        (values (hash-set diff key #t) intersection))))

(define (union1 hash1 hash2)
  (for/fold ([result hash1])
            ([(key value) hash2])
    (hash-set result key #t)))

(define ((xor1 empty) hash1 hash2)
  (for/fold ([result (for/fold ([init empty])
                               ([(key value) hash1]
                                #:when (not (hash-ref hash2 key (lambda () #f))))
                       (hash-set init key #t))])
            ([(key value) hash2]
             #:when (not (hash-ref hash1 key (lambda () #f))))
    (hash-set result key #t)))

(define (<=?1 hash1 hash2)
  (let/ec return
    (for ([(key value) hash1]
          #:when (not (hash-ref hash2 key (lambda () #f))))
      (return #f))
    #t))

(define (=?1 hash1 hash2)
  (let/ec return
    (for ([(key value) hash1]
          #:when (not (hash-ref hash2 key (lambda () #f))))
      (return #f))
    (for ([(key value) hash2]
          #:when (not (hash-ref hash1 key (lambda () #f))))
      (return #f))
    #t))

(define (write-hash prefix hash [port (current-output-port)] [write? #t])
  (display "#<" port)
  (display prefix port)
  (display ":" port)
  (for ([(key value) hash]
        [i (in-naturals)])
    (when (> i 0)
      (display " " port))
    (if write? (write key port) (display key port)))
  (display ">" port))
