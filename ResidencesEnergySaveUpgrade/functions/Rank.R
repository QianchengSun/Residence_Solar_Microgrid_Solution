# Rank order --------------------------------
rank_order <- function(target_column, max_value, min_value){
  # Description:
  # rank_order is a function that automatically generate rank index value for upgrade options
  # The max_value and min_value represent for the expected payback year for the upgrade option, 
  
  # Note:
  # if the rank index (for example, rank = 1) is small, that means the best
  # if the rank index (for example, rank = 10) is big, that means the worst
  # if the rank index is 11, which means there are NA value in the target column for that specific row
  # if you want to automatically generate the rank index for the residential house, you could set yo the max value or min value as NA

  # Arguments:
  # Input:
  #   target_column: the target column that need to create rank index value
  #   max_value (the excepted max value): max value of the target column, if want to generate rank index value automatrically
  #             the max_value = NA will be input for this argument, otherwise, you can define the max_value for the range by manual, for example, max_value = 5
  #
  #   min_value (the excepted min value): min value of the target column, if want to generate rank index value automatrically
  #             the min_value = NA will be input for this argument, otherwise, you can define the min_value for the range by manual, for example, min_value = 5

  # Output:
  #   rank: rank index for the target column

  rank <- NA

  target_column_no_NA <- ifelse(is.na(target_column), target_column[c(which(!is.na(target_column)))], target_column)
  # Remove Inf value
  target_column_no_NA <- ifelse(target_column_no_NA == Inf, target_column_no_NA[c(which(target_column_no_NA != Inf))], target_column_no_NA)

  max_value <- ifelse(is.na(max_value),max(target_column_no_NA), max_value)
  min_value <- ifelse(is.na(min_value),max(target_column_no_NA), min_value)

  # Need to add expected max and min value to define the range for the K means
  target_column_no_NA <- target_column_no_NA[c(which(target_column_no_NA < max_value & target_column_no_NA > min_value))]

  point_value <- seq(min_value, max_value, by = (max_value - min_value) /10)

  # rank the target column
  for (i in 1:length(target_column)){
    # if NA value appeared, define the rank value as NA
    if (is.na(target_column[i])){
      rank[i] <- 11
    }else{
      if(target_column[i] <= point_value[1]){
        rank[i] <- 1
      }else if (target_column[i] >= point_value[1] & target_column[i] < point_value[2]){
        rank[i] <- 2
      }else if (target_column[i] >= point_value[2] & target_column[i] < point_value[3]){
        rank[i] <- 3
      }else if (target_column[i] >= point_value[3] & target_column[i] < point_value[4]){
        rank[i] <- 4
      }else if (target_column[i] >= point_value[4] & target_column[i] < point_value[5]){
        rank[i] <- 5
      }else if (target_column[i] >= point_value[5] & target_column[i] < point_value[6]){
        rank[i] <- 6
      }else if (target_column[i] >= point_value[6] & target_column[i] < point_value[7]){
        rank[i] <- 7
      }else if (target_column[i] >= point_value[7] & target_column[i] < point_value[8]){
        rank[i] <- 8
      }else if (target_column[i] >= point_value[8] & target_column[i] < point_value[9]){
        rank[i] <- 9
      }else{
        rank[i] <- 10
      }
    }
  }
  return (rank)
}
