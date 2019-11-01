library(dplyr)
library(neo4r)

con <- neo4j_api$new(
  url = "http://localhost:7474",
  user = "neo4j",
  password = "test"
  )

cql_pairings <-  'MATCH (o:OBJECT)-[:isType]-(:TYPE {type: "schema:DataCatalog"})
  MATCH (o1:OBJECT)-[:isType]-(:TYPE {type: "schema:DataCatalog"})
  MATCH (n:OBJECT)-[:isType]-(:TYPE {type:"schema:CodeRepository"})
  WITH o, o1, n
  MATCH p=(o)-[]-(:ANNOTATION)-[]-(n)-[]-(:ANNOTATION)-[]-(o1)
  WHERE id(o) < id(o1)
  WITH o, o1, n
  RETURN n.name, o.name, o1.name, o.keywords, o1.keywords'

aa <- call_neo4j(cql_pairings, con)

# This gives us a tibble:
keywords <- list(aa["o.keywords"] %>% unlist %>% strsplit(","),
                 aa["o1.keywords"] %>% unlist %>% strsplit(","))

keys <- c(keywords[[1]], keywords[[2]]) %>% unlist %>% unique()

key_mat <- matrix(ncol = length(keys),
                  nrow = length(keys),
                  data = 0,
                dimnames = list(keys, keys))

for(i in 1:length(keywords[[1]])) {
  match_one <- match(keywords[[1]][[i]], keys)
  match_two <- match(keywords[[2]][[i]], keys)
  key_mat[match_one, match_two] <- key_mat[match_one, match_two] + 1
  cat(i, "\n")
}

bb <- key_mat %>%
  as.data.frame() %>%
  tibble::rownames_to_column() %>%
  tidyr::gather(key = "key", value = "value", -rowname) %>%
  mutate(key = stringr::str_replace_all(key, "\\.", " "),
         rowname = stringr::str_replace_all(rowname, "\\.", " ")) %>%
  mutate(key = stringr::str_replace_all(key, "(^\\s*)|(\\s*$)", ""),
         rowname = stringr::str_replace_all(rowname, "(^\\s*)|(\\s*$)", "")) %>%
  filter(value > 0)

bad <- bb[,1] > bb[,2]

bb[bad,1:2] <- bb[bad,2:1]

assertthat::assert_that(all(bb[,1] <= bb[,2]),
  msg = "Some sort of sorting error.")

cc <- bb %>%
  group_by(rowname, key) %>%
  summarise(links = sum(value))

readr::write_csv(cc, "term_pairings.csv")
