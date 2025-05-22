habsuit_bs <- function(
    bc_fl_mm,
    salinity,
    do) {
  lo_surv <- function(salinity, bc_fl_mm) {
    25.02 + -2.14 * salinity + 0.04 * bc_fl_mm
  }

  prop_surv <- function(surv) {
    exp(surv) / (1 + exp(surv))
  }

  do_threshold <- function(do) {
    as.integer(do >= 3)
  }

  prop_surv(
    lo_surv(salinity = salinity, bc_fl_mm = bc_fl_mm)
  ) *
    do_threshold(do)
}
