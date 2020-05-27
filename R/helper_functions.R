validate_name <- function(player_name) {
  known_names <- c(
    "keith",
    "dustin",
    "devon",
    "hanson"
  )
  player_name %in% known_names
}

record_transaction <- function(player, dollars, ledger, transaction = c("buyin", "cashout", "deposit", "withdrawal"), transaction_date = NULL) {
  stopifnot(validate_name(player))
  stopifnot(dollars > 0)
  transaction <- match.arg(transaction)

  # handle default date
  if (is.null(transaction_date)) {
    dt <- lubridate::today()
  } else {
    # TODO: validate date
    dt <- transaction_date
  }

  # handle sign of transaciton dependent on type
  amt <- ifelse(transaction %in% c("cashout", "deposit"), dollars, -dollars)

  # replace with write to gsheet
  dplyr::bind_rows(
    ledger,
    dplyr::tibble(name = player, date = dt, transaction = transaction, amount = amt)
  )
}

get_money_on_table <- function(ledger) {
  buyins_cashouts <- ledger %>%
    # ignore venmo
    filter(transaction %in% c("buyin", "cashout")) %>%
    magrittr::use_series(amount)

  # buyins are positive, cashouts are negative with respect to the table
  sum(buyins_cashouts * -1)
}

# handle chips as a % of money on the table
value_chips <- function(chips_on_table, money_on_table, chips=4000) {
  chips * money_on_table / chips_on_table
}

chips_to_dollars <- function(player_chips, money_on_table) {
  total_chips <- sum(player_chips$chips)
  player_chips %>%
    mutate(dollars = round(value_chips(total_chips, money_on_table, chips), 2))
}

# handle value of a chip at any moment
calculate_buyin <- function(chips_on_table, money_on_table, buyin=1.00) {
  chips_on_table * buyin / money_on_table
}

player_balance <- function(ledger) {
  ledger %>%
    group_by(name) %>%
    summarise(balance = sum(amount))
}
