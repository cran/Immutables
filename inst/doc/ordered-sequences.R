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
key_at(xs, 2)                          # key at position 2
key_at(xs, 1) == min_key(xs)           # first position holds the minimum key
key_at(xs, length(xs)) == max_key(xs)  # last position holds the maximum key
key_at(xs, 10)                         # NULL when out of bounds

front <- pop_front(xs)                 # positional pop carries the key too
front$value
front$key

## -----------------------------------------------------------------------------
nearest_key(xs, 2.4)                    # between 2 and 3 -> closer key (2)
nearest_key(xs, 0)                      # below all -> min_key (1)
nearest_key(xs, 2.5, ties = "both")     # exactly between 2 and 3 -> c(2, 3)

k <- nearest_key(xs, 2.4)               # locate, then act with the keyed helpers
pop_key(xs, k)$value

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

## -----------------------------------------------------------------------------
set.seed(100)
n_patients <- 200
patients <- data.frame(treated = sample(c(TRUE, FALSE),
                                        n_patients,
                                        prob = c(0.1, 0.9),
                                        replace = TRUE),
                       score = runif(n_patients))

# row numbers act as identifiers
treated_rows <- which(patients$treated)
treated_scores <- patients$score[patients$treated]

untreated_rows <- which(!patients$treated)
untreated_scores <- patients$score[!patients$treated]

matches <- flexseq()

treated_seq <- as_ordered_sequence(treated_rows, keys = treated_scores)
untreated_seq <- as_ordered_sequence(untreated_rows, keys = untreated_scores)

## -----------------------------------------------------------------------------
while(length(treated_seq) > 0) {
  # no untreated patients left to match against
  if (length(untreated_seq) == 0L) break

  # pop the first (lowest-score) treated patient
  front_el <- pop_front(treated_seq)
  treated_seq <- front_el$remaining

  treated_pt_score <- front_el$key
  treated_pt_row   <- front_el$value

  # find and remove the nearest-score untreated patient
  match_key <- nearest_key(untreated_seq, treated_pt_score)
  match_el  <- pop_key(untreated_seq, match_key)
  untreated_seq <- match_el$remaining

  untreated_pt_score <- match_el$key
  untreated_pt_row   <- match_el$value

  match_row <- data.frame(treated_pt_row,
                          treated_pt_score,
                          untreated_pt_row,
                          untreated_pt_score)

  matches <- push_back(matches, match_row)
}

match_df <- do.call(rbind, as.list(matches))
head(match_df)

