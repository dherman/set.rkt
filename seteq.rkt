#lang racket/base
(require racket/match
         "private/common.rkt")
(provide seteq? list->seteq seteq->list empty-seteq seteq-empty? seteq-count
         seteq-intersection seteq-difference seteq-partition seteq-union seteq-xor
         seteq-intersections seteq-differences seteq-partitions seteq-unions seteq-xors
         seteq-adjoin seteq-add seteq-contains?
         subseteq? seteq=?
         for/seteq for*/seteq
         in-seteq)

(define (in-seteq set)
  (in-hash-keys (seteq-elts set)))

(struct seteq (elts)
  #:property prop:custom-write (lambda (set port write?)
                                 (write-hash "seteq" (seteq-elts set) port write?))
  #:property prop:sequence in-seteq
  #:property prop:equal+hash
  (list (lambda (s1 s2 recur)
          (seteq=? s1 s2))
        (lambda (s equal-hash-code)
          (apply + (map eq-hash-code (seteq->list s))))
        (lambda (s secondary-equal-hash-code)
          (apply + (map eq-hash-code (seteq->list s))))))

(define (list->seteq ls)
  (seteq (for/hasheq ([x ls])
           (values x #t))))

(define (seteq->list set)
  (for/list ([(key value) (seteq-elts set)])
    key))

(define (seteq-intersection set . sets)
  (seteq (hash-intersection (seteq-elts set) (map seteq-elts sets) for/hasheq)))

(define (seteq-intersections sets)
  (seteq (hash-intersection (seteq-elts (car sets)) (map seteq-elts (cdr sets)) for/hasheq)))

(define (seteq-difference set . sets)
  (seteq (hash-difference (seteq-elts set) (map seteq-elts sets) for/hasheq)))

(define (seteq-differences sets)
  (seteq (hash-difference (seteq-elts (car sets)) (map seteq-elts (cdr sets)) for/hasheq)))

(define (seteq-partition set . sets)
  (let-values ([(diff intersection) ((hash-partition #hasheq()) (seteq-elts set) (map seteq-elts sets))])
    (values (seteq diff) (seteq intersection))))

(define (seteq-partitions sets)
  (let-values ([(diff intersection) ((hash-partition #hasheq()) (seteq-elts (car sets)) (map seteq-elts (cdr sets)))])
    (values (seteq diff) (seteq intersection))))

(define empty-seteq (seteq #hasheq()))

(define (seteq-empty? set)
  (zero? (hash-count (seteq-elts set))))

(define (seteq-count set)
  (hash-count (seteq-elts set)))

(define (seteq-unions sets)
  (seteq (foldr union1 #hasheq() (map seteq-elts sets))))

(define (seteq-union . sets)
  (seteq-unions sets))

(define (seteq-xor . sets)
  (seteq-xors sets))

(define (seteq-xors sets)
  (seteq (foldr (xor1 #hasheq()) #hasheq() (map seteq-elts sets))))

(define (seteq-adjoin set . elts)
  (seteq-union set (list->seteq elts)))

(define (seteq-add elt set)
  (seteq-adjoin set elt))

(define (seteq-contains? set elt)
  (hash-ref (seteq-elts set) elt (lambda () #f)))

(define-syntax-rule (for/seteq (for-clause ...) body0 body ...)
  (seteq (for/hash (for-clause ...)
           (values (let () body0 body ...) #t))))
  
(define-syntax-rule (for*/seteq (for-clause ...) body0 body ...)
  (seteq (for*/hash (for-clause ...)
           (values (let () body0 body ...) #t))))

(define (subseteq? . sets)
  (let loop ([hashes (map seteq-elts sets)])
    (match hashes
      [(cons hash1 (and hashes (cons hash2 _)))
       (and (<=?1 hash1 hash2) (loop hashes))]
      [_ #t])))

(define (seteq=? . sets)
  (let loop ([hashes (map seteq-elts sets)])
    (match hashes
      [(cons hash1 (and hashes (cons hash2 _)))
       (and (=?1 hash1 hash2) (loop hashes))]
      [_ #t])))
