if (!require("mongolite")) install.packages("mongolite")
library(mongolite)

collections <- c("airports", "flights", "planes", "weather")
url <- "mongodb+srv://project:KcuXIlF8eZkIjtgC@cluster0.yyhqpxq.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

# Fonction pour se connecter à MongoDB et récupérer les collections
get_collections <- function() {
  client <- tryCatch({
    mongo(db = "plane_db", url = url)
  }, error = function(e) {
    stop("Échec de la connexion à MongoDB : ", e$message)
  })

  collections <- tryCatch({
    client$run('{"listCollections": 1}')
  }, error = function(e) {
    stop("Échec de la récupération des collections : ", e$message)
  })

  client$disconnect()

  return(collections)
}

# Récupérer une collection spécifique
get_collection <- function(collection_name) {
  collection <- tryCatch({
    mongo(collection = collection_name,
          db = "plane_db",
          url = url)
  }, error = function(e) {
    stop("Échec de la connexion à MongoDB : ", e$message)
  })

  data <- tryCatch({
    collection$find()
  }, error = function(e) {
    stop("Échec de la récupération des données : ", e$message)
  })

  return(data)
}
