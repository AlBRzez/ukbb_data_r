source("functions.R")

## Get data --------------------------------------------------------------------
data_path <- "path to data folder"
ukbb <- open_dataset(paste0(data_path, "/current_melt.arrow"), format = "ipc")
codings <- readr::read_tsv(paste0(data_path, "/Codings.tsv"))
diction <- readr::read_tsv(paste0(data_path, "/Data_Dictionary_Showcase.tsv"))

## In case you have a file with the subjects id's you want
ukbb_id <- "read path to file"
ids <- ukbb_id$subject_id #depends on your data structure

###############
test1 <- get_ukbb_data(ukbb, diction, subjs_id = c(1000083, 1000139, 1000261))
otest1 <- order_data(test1, diction, codings)

test2 <- get_ukbb_data(ukbb, diction, categories = c(196), subjs_id = c(1000083, 1000139, 1000261))
otest2 <- order_data(test2, diction, codings)

test3 <- get_ukbb_data(ukbb, diction, #subjs_id = c(1000083, 1000139, 1000261), 
                       fields_id = c(31, 21003, 54, 26521), 
                       subjs_id = ids[1:500],
                       instances = c(2, 3))
otest3 <- order_data(test3, diction, codings)

test4 <- get_ukbb_data(ukbb, diction, subjs_id = ids[1:500], 
                       fields_id = c(31, 21003, 54, 26521), categories = c(196), instances = 2)
otest4 <- order_data(test4, diction, codings)

### Benchmark test of differents ways to filte ---------------------------------

# library(rbenchmark)

# benchmark("sign" = {
#   sa <- 
#     ukbb |> 
#     filter(FieldID == 31 | FieldID == 21003 | FieldID == 54 | FieldID == 26521) |> 
#     filter(SubjectID %in% ids) |> 
#     collect()
# },
# "in" = {
#   sa <- 
#     ukbb |> 
#     filter(FieldID %in% c(31, 21003, 54, 26521)) |> 
#     filter(SubjectID %in% ids) |> 
#     collect()
# },
# replications = 100,
# columns = c("test", "replications", "elapsed",
#             "relative", "user.self", "sys.self"))

#### Output
# test replications elapsed relative user.self sys.self
# 2   in          100 479.154    1.000  3496.178  421.895
# 1 sign          100 492.255    1.027  4005.571  435.558

