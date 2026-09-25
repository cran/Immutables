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
x <- flexseq(1, 2, 3)
x

x2 <- as_flexseq(letters[1:5])
x2

## -----------------------------------------------------------------------------
x <- flexseq(a = 1, b = 2, c = 3)
x
x[c("c", "b")]

x$b <- NULL # delete b
x

## -----------------------------------------------------------------------------
x <- as_flexseq(letters[1:6])

x[[3]]

x[c(1, 3, 5)]

## -----------------------------------------------------------------------------
x <- as_flexseq(4:6)

x <- x |>
  push_back(100) |>
  push_front(50)

x

xpopped <- pop_front(x)

xpopped$value
xpopped$remaining

## -----------------------------------------------------------------------------
x <- flexseq("a", "b", "c", "d")

peek_at(x, 10)  # NULL, no error

out <- pop_at(x, 2)
out$value
out$remaining

insert_at(x, 3, c("x", "y"))

## -----------------------------------------------------------------------------
x <- as_flexseq(4:6)
x2 <- as_flexseq(8:10)

c(x, x2)

x <- as_flexseq(1:3)
fapply(x, function(el) el * 10)

## -----------------------------------------------------------------------------
x <- flexseq("a", "b", "c", "d")

loop(for (el in x) {
  print(el)
})

## -----------------------------------------------------------------------------
x <- flexseq(a = 1, b = 2, c = 3)
loop(for (el in x) print(el))

## -----------------------------------------------------------------------------
x <- flexseq(a = 1, b = 2, c = 3)

as.list(x)
unlist(x)
length(x)

## -----------------------------------------------------------------------------
set.seed(100)
steps <- 1000
p_arrival <- 0.9
mean_service <- 1 # service times ~ rpois(1, mean_service) + 1 (real mean 2)

qa <- flexseq(); free_a <- 0
qb <- flexseq(); free_b <- 0
waits <- flexseq()

for(t in seq_len(steps)) {
  # process new arrivals into the shorter queue
  if(runif(1) < p_arrival) {
    request <- list(arrival = t)
    if(length(qa) <= length(qb)) qa <- push_back(qa, request)
    else                         qb <- push_back(qb, request)
  }

  # if qa is free, process the front request and record total wait time
  if(free_a <= t && length(qa) > 0) {
    nxt <- pop_front(qa)
    qa <- nxt$remaining    # overwrite queue with remaining portion
    request <- nxt$value
    waits <- push_back(waits, t - request$arrival)
    free_a <- t + rpois(1, mean_service) + 1
  }

  # if qb is free, process the front request and record total wait time
  if(free_b <= t && length(qb) > 0) {
    nxt <- pop_front(qb)
    qb <- nxt$remaining    # overwrite queue with remaining portion
    request <- nxt$value
    waits <- push_back(waits, t - request$arrival)
    free_b <- t + rpois(1, mean_service) + 1
  }
}

mean(unlist(waits))

