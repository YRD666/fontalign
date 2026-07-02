## Reporting issues

Please open an issue with:

* Output of `fontalign::fontalign_check_system()`.
* A minimal reproducible example (plot code + labels + target device).
* The rendered output paths (PDF and PNG if applicable).

## Submitting changes

* Branch off `main`.
* Add a NEWS.md entry under the development version.
* Make sure `devtools::check()` and `devtools::test()` pass.
* Add a vdiffr snapshot if behaviour changes are visual.
