library(neo4r)

con <- neo4j_api$new(
  url = "http://localhost:7474",
  user = "neo4j",
  password = "test"
)

network <- 'MATCH (:TYPE {type:"schema:CodeRepository"})-[:isType]-(ocr:OBJECT)
MATCH (:TYPE {type:"schema:DataCatalog"})-[:isType]-(odca:OBJECT)
MATCH (:TYPE {type:"schema:DataCatalog"})-[:isType]-(odcb:OBJECT)
MATCH p = (odca)-[]-(:ANNOTATION)-[]-(ocr)-[]-(:ANNOTATION)-[]-(odcb)
WHERE odca <> odcb
WITH odca.name AS name,  odcb.name AS thing, count(odcb) AS links, COLLECT(ocr.name) AS repos
WHERE links > 1
RETURN name, thing, links, repos;'

aa <- network %>%
  call_neo4j(con) %>%
  jsonlite::fromJSON()
