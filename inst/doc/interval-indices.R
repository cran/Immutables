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
ix <- interval_index(
  "A", "B", "C",
  start = c(1, 2, 4),
  end = c(3, 4, 5)
)
ix

## -----------------------------------------------------------------------------
ix2 <- as_interval_index(c("phase1", "phase2", "phase3"), start = c(1, 3, 2), end = c(4, 5, 6))
ix2

## ----pointops-----------------------------------------------------------------
peek_point(ix, point = 2)
peek_all_point(ix, point = 2)

## -----------------------------------------------------------------------------
res <- pop_point(ix, 2)
res$value
res$start
res$end
res$remaining

## -----------------------------------------------------------------------------
# Entries whose start coordinate equals 2
peek_all_point(ix, point = 2, match_at = "start")

# Entries whose end coordinate equals 3 — the sweep-line retirement query
peek_all_point(ix, point = 3, match_at = "end")

# Either endpoint equals 3
peek_all_point(ix, point = 3, match_at = "either")

## -----------------------------------------------------------------------------
ix3 <- interval_index(
  "narrow", "wide", "right", "inner",
  start = c(2, 1, 4, 3),
  end   = c(3, 6, 5, 4)
)
ix3

## -----------------------------------------------------------------------------
# overlaps [2, 5]: any shared point
peek_all_overlaps(ix3, start = 2, end = 5)

# containing [3, 4]: index interval must enclose query
peek_all_containing(ix3, start = 3, end = 4)

# within [1, 5]: index interval must fit inside query
peek_all_within(ix3, start = 1, end = 5)

## -----------------------------------------------------------------------------
edge <- interval_index("E", start = 1, end = 3, default_query_bounds = "[)")

# right endpoint excluded by default
peek_point(edge, 3)

# override to closed bounds for this query
peek_point(edge, 3, bounds = "[]")

## -----------------------------------------------------------------------------
# [2, 2) contains nothing under half-open bounds
pt_open <- interval_index("X", start = 2, end = 2, default_query_bounds = "[)")
peek_point(pt_open, point = 2)

# [2, 2] contains exactly the point 2
pt_closed <- interval_index("X", start = 2, end = 2, default_query_bounds = "[]")
peek_point(pt_closed, point = 2)

## -----------------------------------------------------------------------------
ix4 <- insert(ix, "D", start = 2, end = 6)
ix4

## -----------------------------------------------------------------------------
min_endpoint(ix)
max_endpoint(ix)
min_endpoint(interval_index())

## -----------------------------------------------------------------------------
empty_ix <- interval_index()
length(empty_ix)
peek_point(empty_ix, point = 1)
pop_overlaps(empty_ix, start = 1, end = 5)

## -----------------------------------------------------------------------------
ix_named <- as_interval_index(
  setNames(list("alice", "bob", "carol"), c("a", "b", "c")),
  start = c(1, 3, 2),
  end = c(4, 5, 6)
)
ix_named

ix_named[["b"]]
ix_named[c("a", "c")]
ix_named[1]

try(ix_named$a <- "!!")

## -----------------------------------------------------------------------------
fapply(ix, function(value, start, end) paste0(value, "[", start, ",", end, "]"))

## -----------------------------------------------------------------------------
loop(for (v in ix) print(v))

## -----------------------------------------------------------------------------
a <- as_interval_index(c("A1", "A2"), start = c(1, 5), end = c(4, 8))
b <- as_interval_index(c("B1", "B2"), start = c(3, 7), end = c(6, 10))
m <- merge(a, b)
peek_all_point(m, 3)

