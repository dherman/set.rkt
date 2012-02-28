#lang racket/base
(require racket/match
         "private/common.rkt")
(provide set? list->set set->list empty-set set-empty? set-count
         set-intersection set-difference set-partition set-union set-xor
         set-intersections set-differences set-partitions set-unions set-xors
         set-adjoin set-add set-contains?
         subset? set=?
         for/set for*/set
         in-set)

(define (in-set set)
  (in-hash-keys (set-elts set)))

(struct set (elts)
  #:property prop:custom-write (lambda (set port write?)
                                 (write-hash "set" (set-elts set) port write?))
  #:property prop:sequence in-set
  #:property prop:equal+hash
  (list (lambda (s1 s2 recur)
          (set=? s1 s2))
        (lambda (s equal-hash-code)
          (apply + (map equal-hash-code (set->list s))))
        (lambda (s secondary-equal-hash-code)
          (apply + (map secondary-equal-hash-code (set->list s))))))

(define (list->set ls)
  (set (for/hash ([x ls])
         (values x #t))))

(define (set->list set)
  (for/list ([(key value) (set-elts set)])
    key))

(define (set-intersection set . sets)
  (set (hash-intersection (set-elts set) (map set-elts sets) for/hash)))

(define (set-intersections sets)
  (set (hash-intersection (set-elts (car sets)) (map set-elts (cdr sets)) for/hash)))

(define (set-difference set . sets)
  (set (hash-difference (set-elts set) (map set-elts sets) for/hash)))

(define (set-differences sets)
  (set (hash-difference (set-elts (car sets)) (map set-elts (cdr sets)) for/hash)))

(define (set-partition set . sets)
  (let-values ([(diff intersection) ((hash-partition #hash()) (set-elts set) (map set-elts sets))])
    (values (set diff) (set intersection))))

(define (set-partitions sets)
  (let-values ([(diff intersection) ((hash-partition #hash()) (set-elts (car sets)) (map set-elts (cdr sets)))])
    (values (set diff) (set intersection))))

(define empty-set (set #hash()))

(define (set-empty? set)
  (zero? (hash-count (set-elts set))))

(define (set-count set)
  (hash-count (set-elts set)))

(define (set-unions sets)
  (set (foldr union1 #hash() (map set-elts sets))))

(define (set-union . sets)
  (set-unions sets))

(define (set-xor . sets)
  (set-xors sets))

(define (set-xors sets)
  (set (foldr (xor1 #hash()) #hash() (map set-elts sets))))

(define (set-adjoin set . elts)
  (set-union set (list->set elts)))

(define (set-add elt set)
  (set-adjoin set elt))

(define (set-contains? set elt)
  (hash-ref (set-elts set) elt (lambda () #f)))

(define-syntax-rule (for/set (for-clause ...) body0 body ...)
  (set (for/hash (for-clause ...)
         (values (let () body0 body ...) #t))))
  
(define-syntax-rule (for*/set (for-clause ...) body0 body ...)
  (set (for*/hash (for-clause ...)
         (values (let () body0 body ...) #t))))

(define (subset? . sets)
  (let loop ([hashes (map set-elts sets)])
    (match hashes
      [(cons hash1 (and hashes (cons hash2 _)))
       (and (<=?1 hash1 hash2) (loop hashes))]
      [_ #t])))

(define (set=? . sets)
  (let loop ([hashes (map set-elts sets)])
    (match hashes
      [(cons hash1 (and hashes (cons hash2 _)))
       (and (=?1 hash1 hash2) (loop hashes))]
      [_ #t])))
