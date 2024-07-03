if (!require("shiny")) install.packages("shiny")
if (!require("DT")) install.packages("DT")
if (!require("bslib")) install.packages("bslib")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("leaflet")) install.packages("leaflet")

library(shiny)
library(DT)
library(bslib)
library(ggplot2)
library(leaflet)

# Source le fichier de connexion MongoDB
source("mongodb_connection.R")

collections <- c("airports", "flights", "planes", "weather")

# UI de l'application Shiny avec bslib
ui <- page_navbar(
  title = "Données du trafic aérien",
  theme = bs_theme(bootswatch = "flatly"),

  # Page Tableaux
  nav_panel(
    title = "Tableaux",
    fluidPage(
      titlePanel("Données des collections"),
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
  ),

  # Page Graphiques
  nav_panel(
    title = "Graphiques",
    fluidPage(
      titlePanel("Graphiques des collections"),
      sidebarLayout(
        sidebarPanel(
          selectInput("graph_collection", "Choisissez une collection :",
                      choices = collections),
          actionButton("plot", "Afficher le graphique")
        ),
        mainPanel(
          plotOutput("plot")
        )
      )
    )
  ),

  # Page Carte des Aéroports
  nav_panel(
    title = "Carte",
    fluidPage(
      titlePanel("Carte des aéroports"),
      sidebarLayout(
        sidebarPanel(
          actionButton("show_map", "Afficher la carte")
        ),
        mainPanel(
          leafletOutput("map", height = "600px")
        )
      )
    )
  )
)

server <- function(input, output, session) {

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
    if (nrow(data) == 0) {
      showNotification("Aucune donnée trouvée dans la collection sélectionnée.",
                       type = "warning")
    }
    data
  })

  # Affichage des données dans un tableau
  output$table <- renderDT({
    input$refresh  # Actualise les données lorsqu'on clique sur le bouton
    datatable(load_data(), options = list(pageLength = 10))
  })

  # Graphiques en fonction de la collection choisie
  output$plot <- renderPlot({
    input$plot  # Actualise le graphique lorsqu'on clique sur le bouton
    data <- NULL

    if (input$graph_collection == "airports") {
      data <- get_collection("airports")
      ggplot(data, aes(x = reorder(name, -lat), y = lat)) +
        geom_bar(stat = "identity") +
        labs(title = "Nombre de vols par aéroport",
             x = "Aéroport",
             y = "Latitude") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1))

    } else if (input$graph_collection == "flights") {
      data <- get_collection("flights")
      ggplot(data, aes(x = dep_delay)) +
        geom_histogram(binwidth = 5, fill = "blue", color = "black") +
        labs(title = "Histogramme des retards au départ",
             x = "Retard au départ (minutes)",
             y = "Nombre de vols")

    } else if (input$graph_collection == "planes") {
      data <- get_collection("planes")
      ggplot(data, aes(x = manufacturer)) +
        geom_bar(fill = "blue") +
        labs(title = "Nombre d'avions par fabricant",
             x = "Fabricant",
             y = "Nombre d'avions") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1))

    } else if (input$graph_collection == "weather") {
      data <- get_collection("weather")
      ggplot(data, aes(x = time_hour, y = temp)) +
        geom_line(color = "blue") +
        labs(title = "Température au fil du temps",
             x = "Temps",
             y = "Température (F)")
    }
  })

  # Carte avec les aéroports
  output$map <- renderLeaflet({
    data_airports <- get_collection("airports")
    leaflet(data_airports) %>%
      addTiles() %>%
      addMarkers(~lon, ~lat, popup = ~name)
  })
}

shinyApp(ui = ui, server = server)
