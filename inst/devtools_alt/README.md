# devtools_alt/

These scripts are local-development helpers. They are **not** part of the
installed package and are excluded from the build via `.Rbuildignore`-able
naming (`^inst/devtools_alt`).

Typical workflow when you don't have `devtools` installed but want to
exercise the package sources directly:

```sh
Rscript inst/devtools_alt/run_tests.R
Rscript inst/devtools_alt/sanity_check.R
Rscript inst/devtools_alt/sanity_check2.R
```

In CI (GitHub Actions), use `devtools::check()` and
`devtools::test()` per `.github/workflows/R-CMD-check.yaml`.
