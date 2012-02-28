#lang scribble/doc

@require[(for-syntax racket/base)
         racket/runtime-path
         planet/scribble
         scribble/manual
         scribble/basic
         scribble/eval]

@require[(for-label racket/base
                    (this-package-in set)
                    (this-package-in seteq))]

@define-runtime-path[here (build-path 'same)]

@define[the-eval
        (let ([the-eval (make-base-eval)])
          (parameterize ([current-directory here])
            (the-eval `(require (file ,(path->string (build-path here "main.ss")))))
            the-eval))]

@title[#:tag "top"]{@bold{Set}: Purely Functional Sets}

by Dave Herman (@tt{dherman at ccs dot neu dot edu})

This library provides two implementations of functional sets
backed by hash tables: one comparing elements for equality using
@scheme[equal?], the other using @scheme[eq?].

The data structures of this library are immutable. They are
implemented on top of Racket's immutable hash tables, and
therefore should have @italic{O}(1) running time for extending and
@italic{O}(@italic{log} @italic{n}) running time for lookup.

This library was inspired by
@link["http://srfi.schemers.org/srfi-1/srfi-1.html"]{SRFI-1}
and @link["http://www.haskell.org/ghc/"]{GHC}'s
@link["http://www.haskell.org/ghc/docs/latest/html/libraries/containers/Data-Set.html"]{@tt{Data.Set}} library.

@table-of-contents[]

@section[#:tag "started"]{Getting started}

The easiest way to use this library is to install its main module,
which exports all bindings in the two individual modules:

@defmodule/this-package[]

@examples[#:eval the-eval
          (define heroes (list->seteq '(rocky bullwinkle)))
          (define villains (list->seteq '(boris natasha)))
          (for ([x (seteq-union heroes villains)])
            (printf "~a~n" x))]

@section[#:tag "set"]{Sets using @scheme[equal?]}

@defmodule/this-package[set]

@defproc[(set? [x any]) boolean?]{Determines whether @scheme[x] is a set.}

@defproc[(list->set [ls list?]) set?]{
Produces a set containing the elements in @scheme[ls].
If @scheme[ls] contains duplicates (as determined by @scheme[equal?]),
the resulting set contains only the rightmost of the duplicate elements.}

@defproc[(set->list [s set?]) list?]{
Produces a list containing the elements in @scheme[s].
No guarantees are made about the order of the elements in the list.}

@defthing[empty-set set?]{An empty set.}

@defproc[(set-empty? [s set?]) boolean?]{Determines whether @scheme[s] is empty.}

@deftogether[(
@defproc[(set-intersection [sets set?] ...+) set?]
@defproc[(set-intersections [sets (nelistof set?)]) set?]
)]{Produces the set intersection of @scheme[sets].}

@deftogether[(
@defproc[(set-difference [sets set?] ...+) set?]
@defproc[(set-differences [sets (nelistof set?)]) set?]
)]{Produces the left-associative set difference of @scheme[sets].}

@deftogether[(
@defproc[(set-union [sets set?] ...) set?]
@defproc[(set-unions [sets? (listof set?)]) set?]
)]{Produces the set union of @scheme[sets].}

@deftogether[(
@defproc[(set-xor [sets set?] ...+) set?]
@defproc[(set-xors [sets (nelistof set?)]) set?]
)]{
Produces the exclusive union of @scheme[sets].
This operation is associative and extends to the @italic{n}-ary case
by producing a set of elements that appear in an odd number of
@scheme[sets].}

@deftogether[(
@defproc[(set-partition [sets set?] ...+) (values set? set?)]
@defproc[(set-partitions [sets (nelistof set?)]) (values set? set?)]
)]{
Equivalent to
@schemeblock[(values (set-differences sets)
                     (set-intersection (car sets) (unions (cdr sets))))]
but implemented more efficiently.

Note that this is @bold{not necessarily the same thing} as
@schemeblock[(values (set-differences sets)
                     (set-intersections sets)) #, '(code:comment "not the same thing!")]}

@defproc[(set-adjoin [s set?] [elts any] ...) set?]{Produces a set containing the elements of @scheme[s] and @scheme[elts].}

@defproc[(set-add [x any] [s set?]) set?]{Produces a set containing @scheme[x] and the elements of @scheme[s].}

@defproc[(set-contains? [s set?] [x any]) boolean?]{Determines whether the set @scheme[s] contains the element @scheme[x].}

@defproc[(set-count [s set?]) exact-nonnegative-integer?]{Produces the number of elements in @scheme[s].}

@deftogether[(
@defform[(for/set (for-clause ...) body ...+)]
@defform[(for*/set (for-clause ...) body ...+)]
)]{
Like @scheme[for/list] and @scheme[for*/list], respectively,
but the result is a set. The expressions in the @scheme[body] forms
must produce a single value, which is included in the resulting set.}

@defproc[(in-set [s set?]) sequence?]{
Produces a sequence that iterates over the elements of @scheme[s].

Sets themselves have the @scheme[prop:sequence] property and can therefore
be used as sequences.}

@defproc[(set=? [s1 set?] [s2 set?]) boolean?]{
Determines whether @scheme[s1] and @scheme[s2] contain exactly the same elements,
using @scheme[equal?] to compare elements.}

@defproc[(subset? [s1 set?] [s2 set?]) boolean?]{
Determines whether all elements of @scheme[s1] are contained in @scheme[s2]
(i.e., whether @scheme[s1] is an improper subset of @scheme[s2]),
using @scheme[equal?] to compare elements.}

@section[#:tag "seteq"]{Sets using @scheme[eq?]}

@defmodule/this-package[seteq]

@defproc[(seteq? [x any]) boolean?]{Determines whether @scheme[x] is a set.}

@defproc[(list->seteq [ls list?]) seteq?]{
Produces a set containing the elements in @scheme[ls].
If @scheme[ls] contains duplicates (as determined by @scheme[eq?]),
the resulting set contains only the rightmost of the duplicate elements.}

@defproc[(seteq->list [s seteq?]) list?]{
Produces a list containing the elements in @scheme[s].
No guarantees are made about the order of the elements in the list.}

@defthing[empty-seteq seteq?]{An empty set.}

@defproc[(seteq-empty? [s seteq?]) boolean?]{Determines whether @scheme[s] is empty.}

@deftogether[(
@defproc[(seteq-intersection [sets seteq?] ...+) seteq?]
@defproc[(seteq-intersections [sets (nelistof seteq?)]) seteq?]
)]{Produces the set intersection of @scheme[sets].}

@deftogether[(
@defproc[(seteq-difference [sets seteq?] ...+) seteq?]
@defproc[(seteq-differences [sets (nelistof seteq?)]) seteq?]
)]{Produces the left-associative set difference of @scheme[sets].}

@deftogether[(
@defproc[(seteq-union [sets seteq?] ...) seteq?]
@defproc[(seteq-unions [sets? (listof seteq?)]) seteq?]
)]{Produces the set union of @scheme[sets].}

@deftogether[(
@defproc[(seteq-xor [sets seteq?] ...+) seteq?]
@defproc[(seteq-xors [sets (nelistof seteq?)]) seteq?]
)]{
Produces the exclusive union of @scheme[sets].
This operation is associative and extends to the @italic{n}-ary case
by producing a set of elements that appear in an odd number of
@scheme[sets].}

@deftogether[(
@defproc[(seteq-partition [sets seteq?] ...+) (values seteq? seteq?)]
@defproc[(seteq-partitions [sets (nelistof seteq?)]) (values seteq? seteq?)]
)]{
Equivalent to
@schemeblock[(values (seteq-differences sets)
                     (seteq-intersection (car sets) (unions (cdr sets))))]
but implemented more efficiently.

Note that this is @bold{not necessarily the same thing} as
@schemeblock[(values (seteq-differences sets)
                     (seteq-intersections sets)) #, '(code:comment "not the same thing!")]}

@defproc[(seteq-adjoin [s seteq?] [elts any] ...) seteq?]{Produces a set containing the elements of @scheme[s] and @scheme[elts].}

@defproc[(seteq-add [x any] [s seteq?]) seteq?]{Produces a set containing @scheme[x] and the elements of @scheme[s].}

@defproc[(seteq-contains? [s seteq?] [x any]) boolean?]{Determines whether the set @scheme[s] contains the element @scheme[x].}

@defproc[(seteq-count [s seteq?]) exact-nonnegative-integer?]{Produces the number of elements in @scheme[s].}

@deftogether[(
@defform[(for/seteq (for-clause ...) body ...+)]
@defform[(for*/seteq (for-clause ...) body ...+)]
)]{
Like @scheme[for/list] and @scheme[for*/list], respectively,
but the result is a set. The expressions in the @scheme[body] forms
must produce a single value, which is included in the resulting set.}

@defproc[(in-seteq [s seteq?]) sequence?]{
Produces a sequence that iterates over the elements of @scheme[s].

Sets themselves have the @scheme[prop:sequence] property and can therefore
be used as sequences.}

@defproc[(seteq=? [s1 seteq?] [s2 seteq?]) boolean?]{
Determines whether @scheme[s1] and @scheme[s2] contain exactly the same elements,
using @scheme[eq?] to compare elements.}

@defproc[(subseteq? [s1 seteq?] [s2 seteq?]) boolean?]{
Determines whether all elements of @scheme[s1] are contained in @scheme[s2]
(i.e., whether @scheme[s1] is an improper subset of @scheme[s2]),
using @scheme[eq?] to compare elements.}

