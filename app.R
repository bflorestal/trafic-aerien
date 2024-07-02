library(shiny)
library(mongolite)

# Fonction pour se connecter à MongoDB et récupérer les collections
get_collections <- function() {
  # URL de connexion
  url <- "mongodb+srv://project:KcuXIlF8eZkIjtgC@cluster0.yyhqpxq.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
  
  # Connexion à MongoDB
  client <- tryCatch({
    mongo(url = url, db = "plane_db")
  }, error = function(e) {
    stop("Échec de la connexion à MongoDB : ", e$message)
  })
  
  # Récupérer les noms des collections
  collections <- tryCatch({
    client$run('{"listCollections": 1}')
  }, error = function(e) {
    stop("Échec de la récupération des collections : ", e$message)
  })
  
  client$disconnect()
  
  return(collections)
}

# Interface utilisateur
ui <- fluidPage(
  titlePanel("Affichage des Collections MongoDB"),
  sidebarLayout(
    sidebarPanel(
      h2("Collections MongoDB"),
      p("Cette application affiche les collections de la base de données MongoDB.")
    ),
    mainPanel(
      h2("Liste des Collections"),
      tableOutput("collectionsTable")
    )
  )
)

# Serveur
server <- function(input, output) {
  output$collectionsTable <- renderTable({
    tryCatch({
      collections <- get_collections()
      data.frame(Collection = collections)
    }, error = function(e) {
      data.frame(Collection = paste("Erreur : ", e$message))
    })
  })
}

# Lancer l'application
shinyApp(ui = ui, server = server)
