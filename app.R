if (!require("shiny")) install.packages("shiny")
if (!require("DT")) install.packages("DT")

library(shiny)
library(DT)

# Source le fichier de connexion MongoDB
source("mongodb_connection.R")

collections <- c("airports", "flights", "planes", "weather")

# UI de l'application Shiny
ui <- fluidPage(
  titlePanel("Données du trafic aérien"),
  sidebarLayout(
    sidebarPanel(
      selectInput("collection", "Choisissez une collection :",
                  choices = collections),
      actionButton("refresh", "Rafraîchir les données")
    ),
    mainPanel(
      DTOutput("table")
    )
  )
)

# Serveur de l'application Shiny
server <- function(input, output) {

  # Fonction pour charger les données en fonction de la collection choisie
  load_data <- reactive({
    if(input$collection == "airports") {
      data <- get_collection("airports")
    } else if(input$collection == "flights") {
      data <- get_collection("flights")
    } else if(input$collection == "planes") {
      data <- get_collection("planes")
    } else if(input$collection == "weather") {
      data <- get_collection("weather")
    }
    print(paste("Chargement de la collection :", input$collection)) # Debugging
    print(head(data)) # Debugging
    if (nrow(data) == 0) {
      showNotification("Aucune donnée trouvée dans la collection sélectionnée.",
                       type = "warning")
    }
    data
  })

  # Affichez les données dans un tableau
  output$table <- renderDT({
    input$refresh  # Actualise les données lorsqu'on clique sur le bouton
    datatable(load_data(), options = list(pageLength = 10))
  })
}

shinyApp(ui = ui, server = server)
