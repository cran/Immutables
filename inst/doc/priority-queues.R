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
x <- priority_queue("task_a", "task_b", "task_c", priorities = c(3, 1, 2))
x

peek_min(x)
res <- pop_max(x)

res$value
res$priority
res$remaining

## -----------------------------------------------------------------------------
q <- as_priority_queue(letters[1:4], priorities = c(3, 1, 2, 1))
q

## -----------------------------------------------------------------------------
y <- priority_queue() |>
  insert("Jones", priority = "B") |>
  insert("Smith", priority = "A") |>
  insert("Adams", priority = "A")

peek_min(y)
peek_all_min(y)

res1 <- pop_min(y)
res1$value
res1$priority
res1$remaining

res2 <- pop_all_min(y)

res2$elements
res2$remaining

## -----------------------------------------------------------------------------
as.list(res2$elements) |> str()
as.list(res2$elements, drop_meta = TRUE) |> str()

## -----------------------------------------------------------------------------
empty_q <- priority_queue()
length(empty_q)
peek_min(empty_q)
pop_min(empty_q)

## -----------------------------------------------------------------------------
q <- priority_queue("a", "b", "c", priorities = c(3, 1, 2))
min_priority(q)
max_priority(q)
min_priority(priority_queue())  # NULL when empty

## -----------------------------------------------------------------------------
q <- priority_queue(a = "task-a", b = "task-b", priorities = c(2, 1)) |>
  insert("task-c", priority = 3, name = "c")

q[["b"]]
q[c("a", "c")]

try(q[1])         # positional indexing blocked
try(q$a <- "!!")  # replacement blocked

## -----------------------------------------------------------------------------
q <- priority_queue("alice", "bob", "carol", priorities = c(3, 1, 2))
fapply(q, function(value, priority) toupper(value))

## -----------------------------------------------------------------------------
q <- priority_queue("task_a", "task_b", "task_c", priorities = c(3, 1, 2))
loop(for (v in q) print(v))

## -----------------------------------------------------------------------------
a <- priority_queue("x", "y", priorities = c(5, 1))
b <- priority_queue("z", priorities = 3)
m <- merge(a, b)
length(m)
peek_min(m)
peek_max(m)

## -----------------------------------------------------------------------------
y <- priority_queue() |>
  insert("Jones", priority = "B") |>
  insert("Smith", priority = "A") |>
  insert("Adams", priority = "A")

as_flexseq(y)
as_flexseq(as.list(y))

## -----------------------------------------------------------------------------
set.seed(100)
n <- 2000
p <- 25
X <- matrix(rnorm(n * p), n, p)

# response depends on features 3 and 7 only
y <- 3.5 * X[, 3] - 4 * X[, 7] + rnorm(n)

## -----------------------------------------------------------------------------
# a model using no features, initially the "best"
model <- lm(y ~ 1)
best_features <- numeric(0)
best_aic <- AIC(model)

# store the initial model prioritized by its AIC
pq <- priority_queue()
pq <- insert(pq, best_features, priority = best_aic)

## -----------------------------------------------------------------------------
models_considered <- 1

while(length(pq) > 0 && models_considered < 200) {
  # pop the current best-performing set of features
  current_best <- pop_min(pq)

  # replace the queue with the remaining (unpopped) portion
  pq <- current_best$remaining

  # extract the current best features ($value) and AIC ($priority)
  current_best_features <- current_best$value
  current_best_aic <- current_best$priority

  # features we can add to the current best for potential improvement
  available_features <- setdiff(1:ncol(X), current_best_features)

  # add each unused feature one at a time
  for(available_feature in available_features) {
    # add it to the set of best-performing features so far
    selected_features <- c(current_best_features, available_feature)

    # build a model with that updated set
    model <- lm(y ~ X[ , selected_features, drop = FALSE])

    # add the features to the queue prioritized by the AIC they deliver
    pq <- insert(pq, selected_features, priority = AIC(model))

    # if the current model is better than the best so far, record it
    if(AIC(model) < best_aic) {
      best_features <- selected_features
      best_aic <- AIC(model)
    }

    models_considered <- models_considered + 1
  }
}

best_features

