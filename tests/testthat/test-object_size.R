context("Object_size")

# Compatibility with base ---------------------------------------------------

test_that("size scales correctly with length (accounting for vector pool)", {
  expect_same(numeric())
  expect_same(1)
  expect_same(2)
  expect_same(1:10 + 0)
  expect_same(1:1000 + 0)
})

test_that("size correct for length one vectors", {
  expect_same(1)
  expect_same(1L)
  expect_same("abc")
  expect_same(paste(rep("banaana", 100), collapse = ""))
  expect_same(charToRaw("a"))
  expect_same(5 + 1i)
})

test_that("size of list computed recursively", {
  expect_same(list())
  expect_same(as.list(1))
  expect_same(as.list(1:2))
  expect_same(as.list(1:3))

  expect_same(list(list(list(list(list())))))
})

test_that("size of symbols same as base", {
  expect_same(quote(x))
  expect_same(quote(asfsadfasdfasdfds))
})

test_that("size of pairlists same as base", {
  expect_same(pairlist())
  expect_same(pairlist(1))
  expect_same(pairlist(1, 2, 3))
})

test_that("size of attributes included in object size", {
  expect_same(c(x = 1))
  expect_same(list(x = 1))
  expect_same(c(x = "y"))
})

test_that("duplicated CHARSXPS only counted once", {
  expect_same("x")
  expect_same(c("x", "y", "x"))
  expect_same(c("banana", "banana", "banana"))
})

# Improved behaviour for shared components ------------------------------------
test_that("shared components only counted once", {
  x <- 1:1e3
  z <- list(x, x, x)

  expect_equal(object_size(z), object_size(x) + object_size(vector("list", 3)))
})

test_that("size of closures same as base", {
  f <- function() NULL
  attributes(f) <- NULL # zap srcrefs
  environment(f) <- emptyenv()
  expect_same(f)
})

# Environment sizes -----------------------------------------------------------
test_that("terminal environments have size zero", {
  expect_equal(as.numeric(object_size(globalenv())), 0)
  expect_equal(as.numeric(object_size(baseenv())), 0)
  expect_equal(as.numeric(object_size(emptyenv())), 0)

  expect_equal(as.numeric(object_size(asNamespace("stats"))), 0)
})

test_that("environment size computed recursively", {
  e <- new.env(parent = emptyenv())
  e_size <- object_size(e)

  f <- new.env(parent = e)
  object_size(f)
  expect_equal(object_size(f), 2 * object_size(e))
})

test_that("size of function includes environment", {
  f <- function() {
    y <- 1:1e3
    a ~ b
  }
  g <- function() {
    y <- 1:1e3
    function() 10
  }

  expect_true(object_size(f()) > object_size(1:1e3))
  expect_true(object_size(g()) > object_size(1:1e3))
})

test_that("size doesn't include parents of current environment", {
  x <- 1:1e4 + 0
  embedded <- (function() {
    g <- function() {
      x <- 1:1e3
      a ~ b
    }
    object_size(g())
  })()

  expect_true(embedded < object_size(x))

})

test_that("support dots in closure environments", {
  fn <- (function(...) function() NULL)(foo)
  expect_error(object_size(fn), NA)
})

