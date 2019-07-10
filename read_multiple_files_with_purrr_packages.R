# read multiple file with purrr package
path_way_num <- length(list.files("data", "mtcars_.*csv"))
path_way_file <- list.files("data", "mtcars_.*csv")
mtcars_file_path <- "data"

list(as.list(rep(mtcars_file_path, path_way_num)), as.list(rep("/", path_way_num)), 
     as.list(path_way_file)) %>% 
  purrr::pmap_chr(paste0) %>% 
  map(read_csv, col_types = cols()) %>% 
  list(., path_way_file) %>% 
  pmap(function(x, path_way_file) {
    x %>% mutate(`path_way_file` = path_way_file)
  }) %>% 
  reduce(bind_rows)
