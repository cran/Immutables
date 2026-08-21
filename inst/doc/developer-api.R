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
sum_monoid <- measure_monoid(
  f = `+`,
  i = 0,
  measure = function(el) el
)

## -----------------------------------------------------------------------------
set.seed(42)
task_times <- runif(20, min = 1, max = 10) |>
  round(digits = 1) |>
  as_flexseq()

x <- add_monoids(task_times, list(sum = sum_monoid))

print(x, show_custom_monoids = TRUE)

## ----fig.height=4, fig.width=10-----------------------------------------------
plot_structure(x, node_label = function(node) {
  if(node$type == "Element") sprintf("%.1f\nΣ=%.1f", node$element, node$measures$sum)
  else sprintf("Σ=%.1f", node$measures$sum)
})

## -----------------------------------------------------------------------------
key_sum <- measure_monoid(`+`, 0L, function(entry) as.integer(entry$key))

os <- as_ordered_sequence(c("alice", "bob", "carol"), keys = c(10, 20, 30))
os <- add_monoids(os, list(key_sum = key_sum))

print(os, show_custom_monoids = TRUE)

## -----------------------------------------------------------------------------
loc <- locate_by_predicate(x, function(v) v > 25, "sum", include_metadata = TRUE)
str(loc)

## -----------------------------------------------------------------------------
s <- split_by_predicate(x, function(v) v > 25, "sum")
s$left
s$right

## -----------------------------------------------------------------------------
sa <- split_around_by_predicate(x, function(v) v > 25, "sum")
sa$left
sa$value
sa$right

## -----------------------------------------------------------------------------
split_at(x, index = 5)

## -----------------------------------------------------------------------------
sequence <- "ACGCGCTCGCGCATAGTCGCGCCTG"
query <- "CGCGC" # goal: find indices where query occurs

## -----------------------------------------------------------------------------
max_seq <- measure_monoid(max, i = -Inf, measure = function(entry) entry$key)

subseqs <- ordered_sequence()
subseqs <- add_monoids(subseqs, list(max_seq = max_seq))

## -----------------------------------------------------------------------------
for(i in 1:nchar(sequence)) {
  subseq <- substr(sequence, i, i + 10)
  subseqs <- insert(subseqs, i, key = subseq)
}

subseqs

## -----------------------------------------------------------------------------
first_split <- split_by_predicate(subseqs, function(m) query <= m, "max_seq")
first_split$left
first_split$right

## -----------------------------------------------------------------------------
if(length(first_split$right) > 0) {
  right_measures = get_measures(first_split$right, "max_seq")
  first_measure = right_measures[[1]]

  if(startsWith(first_measure, query)) {
    second_split <- split_by_predicate(
      first_split$right,
      function(m) query < m & !startsWith(m, query),
      "max_seq"
    )
    matches <- second_split$left
  }
}

matches

## -----------------------------------------------------------------------------
positions <- fapply(matches, function(value, key) value) |> unlist()
positions

## -----------------------------------------------------------------------------
validate_tree(x)
validate_name_state(flexseq(a = 1, b = 2, c = 3))

