# Test helper: render a plot and return its path
local({
  out <- tempfile("fontalign-test-", fileext = ".png")
  writeLines(out, "last_test_artifact")
})
