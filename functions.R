library(arrow)
library(dplyr)
library(janitor)

get_ukbb_data <- function(arrow, diction, fields_id = c(), 
                          categories = c(), subjs_id = c(), instances = c()) {
  
  # Function to get the data. Variables:
  # arrow: object containing the arrow file
  # diction: ukbb data dictionary
  # fields_id: a vector containing the fields to filter. To get a whole category
  # it's better to use the "categories" variable
  # categories: a vector containing which categories to filter, in case we
  # want all the fields in a specific category
  # subjs_id: vector containing the "subject_id" of which subjects to get,
  # in case we want to get specific subjects
  # instances: a vector of the desired instances. If this variable is specified,
  # it will get the required fields for that instance and, in case you required a
  # field that only have one instance (i.e. field 31 - sex), it will retrieve that
  # one
  
  if(!is.null(categories)) {
    fid <- diction |> 
      filter(Category %in% categories) |> 
      pull(FieldID)
    fields_id <- c(fields_id, fid)
    
  }
  
  if(!is.null(fields_id)) {
    print("Filtering fields")
    intermediate <- 
      arrow |> 
      filter(FieldID %in% fields_id) 
  } else {
    intermediate <- arrow
  }
  
  if(!is.null(subjs_id)) {
    print("Filtering participants")
    intermediate <- 
      intermediate |> 
      filter(SubjectID %in% subjs_id) 
  }
  
  ukbb_df <- 
    intermediate |> 
    collect()
  
  
  if(!is.null(instances)) {
    print("Filtering instances")
    
    ones <-
      diction |>
      filter(Instances == 1) |>
      pull(FieldID)
    
    ukbb_df <- 
      ukbb_df |> 
      filter(
        case_when(
          FieldID %in% ones ~ InstanceID == InstanceID,
          TRUE ~ InstanceID %in% instances
        )
      )
  }
  
  return(ukbb_df)
}

order_data <- function(ukbb_df, diction, codings) {
  
  # Function to clean the data. Variables:
  # ukbb_df: output from the "get_ukbb_data" function
  # diction: ukbb data dictionary
  # codings: ukbb data codings
  
  clean_data <- 
    ukbb_df |> 
    left_join(diction |> 
                select(FieldID, Category, Field, ValueType, Coding)
    ) |> 
    left_join(
      codings,
      by = c("Coding" = "Coding", "FieldValue" = "Value")
    ) |> 
    mutate(
      value = ifelse(is.na(Meaning), FieldValue, Meaning)
    ) |> 
    clean_names()
  
  return(clean_data)
}
