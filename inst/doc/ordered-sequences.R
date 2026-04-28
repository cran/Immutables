## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
if(requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(".", quiet = TRUE)
} else if(requireNamespace("Immutables", quietly = TRUE)) {
  library(Immutables)
} else {
  stop("Need either installed 'Immutables' or the 'pkgload' package to render this vignette.")
}

## -----------------------------------------------------------------------------
xs <- ordered_sequence("a1", "b1", "b2", "c1", keys = c(1, 2, 2, 3))
xs

## -----------------------------------------------------------------------------
xs2 <- as_ordered_sequence(c(3, 1, 2, 1), keys = letters[1:4])
xs2

## -----------------------------------------------------------------------------
seq <- as_ordered_sequence(1:3, keys = letters[1:3])
seq2 <- insert(seq, 10, key = "b")
seq2

## -----------------------------------------------------------------------------
one <- pop_key(seq, key = "b")
one$value
one$key
one$remaining

all_two <- pop_all_key(seq, "b")
all_two$elements
all_two$remaining

## -----------------------------------------------------------------------------
count_key(seq, key = "b")
peek_key(seq, key = "b")
peek_all_key(seq, key = "b")

## -----------------------------------------------------------------------------
elements_between(seq, from_key = "b", to_key ="c", include_from = TRUE, include_to = TRUE)
count_between(seq, from_key = "b", to_key = "c", include_from = TRUE, include_to = TRUE)

# exclude "b" keys
elements_between(seq, from_key = "b", to_key ="c", include_from = FALSE, include_to = TRUE)

## -----------------------------------------------------------------------------
seq <- as_ordered_sequence(1:4, keys = c("b", "d", "d", "f"))

lower_bound(seq, key = "d") |> str()
upper_bound(seq, key = "d") |> str()

## -----------------------------------------------------------------------------
lower_bound(seq, key = "a") |> str()

upper_bound(seq, key = "g") |> str()

## -----------------------------------------------------------------------------
upper_bound(seq, key = "d")$index - lower_bound(seq, key = "d")$index
count_key(seq, key = "d")

## -----------------------------------------------------------------------------
min_key(xs)
max_key(xs)
min_key(ordered_sequence())  # NULL when empty

## -----------------------------------------------------------------------------
empty_os <- ordered_sequence()
length(empty_os)
peek_key(empty_os, 1)
count_between(empty_os, 1, 5)

## -----------------------------------------------------------------------------
xs_named <- as_ordered_sequence(
  setNames(list("alice", "bob", "carol"), c("a", "b", "c")),
  keys = c(3, 1, 2)
)
xs_named

xs_named[["b"]]
xs_named[c("a", "c")]
xs_named[1]            # positional read also works

try(xs_named$a <- "!!")  # replacement blocked

## -----------------------------------------------------------------------------
xs_t <- ordered_sequence("alice", "bob", "carol", keys = c(3, 1, 2))
fapply(xs_t, function(value, key) toupper(value))

## -----------------------------------------------------------------------------
loop(for (v in xs_t) print(v))

## -----------------------------------------------------------------------------
a <- as_ordered_sequence(c("a1", "a2", "a3"), keys = c(1, 3, 5))
b <- as_ordered_sequence(c("b1", "b2", "b3"), keys = c(2, 3, 6))
merge(a, b)

