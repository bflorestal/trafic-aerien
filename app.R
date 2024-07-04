# app.R

# Charger les packages
library(shiny)
library(DT)
library(bslib)
library(ggplot2)
library(leaflet)
library(dplyr)

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
          conditionalPanel(
            condition = "input.collection == 'airports'",
            selectInput("dst_filter", "Filtrer par DST :",
                        choices = c("All", "A", "U", "N"),
                        selected = "All")
          ),
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
  ),

  # Page Analyses
  nav_panel(
    title = "Analyses",
    fluidPage(
      titlePanel("Analyses spécifiques"),
      sidebarLayout(
        sidebarPanel(
          selectInput("analysis", "Choisissez une analyse :",
                      choices = c(
                        "Aéroport de départ le plus emprunté",
                        "10 destinations les plus prisées",
                        "10 destinations les moins prisées",
                        "10 avions qui ont le plus décollé",
                        "10 avions qui ont le moins décollé"
                      )),
          actionButton("run_analysis", "Afficher l'analyse")
        ),
        mainPanel(
          plotOutput("analysis_plot"),
          DTOutput("analysis_table")
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
      if (input$dst_filter != "All") {
        data <- data[data$dst == input$dst_filter, ]
      }
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
      airport_counts <- data %>% 
        dplyr::group_by(tzone) %>% 
        dplyr::summarise(count = n()) %>% 
        dplyr::arrange(desc(count))

      ggplot(airport_counts, aes(x = reorder(tzone, -count), y = count)) +
        geom_bar(stat = "identity", fill = "blue") +
        labs(title = "Nombre d'aéroports par fuseau horaire",
             x = "Fuseau horaire",
             y = "Nombre d'aéroports") +
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
      ggplot(data, aes(x = wind_speed, y = temp)) +
        geom_line(color = "blue") +
        labs(title = "Vitesse du vent au fil du temps",
             x = "Vitesse",
             y = "Température (F)")
    }
  })

  # Carte avec les aéroports
  output$map <- renderLeaflet({
    data_airports <- get_collection("airports")
    leaflet(data_airports) %>%
      addTiles() %>%
      addMarkers(~lon,
                 ~lat,
                 popup = ~name,
                 clusterOptions = markerClusterOptions())
  })

  # Analyses spécifiques
  output$analysis_plot <- renderPlot({
    input$run_analysis
    isolate({
      if (input$analysis == "Aéroport de départ le plus emprunté") {
        data <- get_collection("flights")
        top_airport <- data %>%
          group_by(origin) %>%
          summarise(count = n()) %>%
          arrange(desc(count)) %>%
          slice(1)
        ggplot(top_airport, aes(x = origin, y = count)) +
          geom_bar(stat = "identity", fill = "blue") +
          labs(title = "Aéroport de départ le plus emprunté",
               x = "Aéroport",
               y = "Nombre de vols")
      } else if (input$analysis == "10 destinations les plus prisées") {
        data <- get_collection("flights")
        top_destinations <- data %>%
          group_by(dest) %>%
          summarise(count = n()) %>%
          arrange(desc(count)) %>%
          slice(1:10)
        ggplot(top_destinations, aes(x = reorder(dest, -count), y = count)) +
          geom_bar(stat = "identity", fill = "blue") +
          labs(title = "10 destinations les plus prisées",
               x = "Destination",
               y = "Nombre de vols") +
          theme(axis.text.x = element_text(angle = 90, hjust = 1))
      } else if (input$analysis == "10 destinations les moins prisées") {
        data <- get_collection("flights")
        bottom_destinations <- data %>%
          group_by(dest) %>%
          summarise(count = n()) %>%
          arrange(count) %>%
          slice(1:10)
        ggplot(bottom_destinations, aes(x = reorder(dest, count), y = count)) +
          geom_bar(stat = "identity", fill = "blue") +
          labs(title = "10 destinations les moins prisées",
               x = "Destination",
               y = "Nombre de vols") +
          theme(axis.text.x = element_text(angle = 90, hjust = 1))
      } else if (input$analysis == "10 avions qui ont le plus décollé") {
        data <- get_collection("flights")
        top_planes <- data %>%
          group_by(tailnum) %>%
          summarise(count = n()) %>%
          arrange(desc(count)) %>%
          slice(1:10)
        ggplot(top_planes, aes(x = reorder(tailnum, -count), y = count)) +
          geom_bar(stat = "identity", fill = "blue") +
          labs(title = "10 avions qui ont le plus décollé",
               x = "Numéro de queue",
               y = "Nombre de décollages") +
          theme(axis.text.x = element_text(angle = 90, hjust = 1))
      } else if (input$analysis == "10 avions qui ont le moins décollé") {
        data <- get_collection("flights")
        bottom_planes <- data %>%
          group_by(tailnum) %>%
          summarise(count = n()) %>%
          arrange(count) %>%
          slice(1:10)
        ggplot(bottom_planes, aes(x = reorder(tailnum, count), y = count)) +
          geom_bar(stat = "identity", fill = "blue") +
          labs(title = "10 avions qui ont le moins décollé",
               x = "Numéro de queue",
               y = "Nombre de décollages") +
          theme(axis.text.x = element_text(angle = 90, hjust = 1))
      }
    })
  })

  output$analysis_table <- renderDT({
    input$run_analysis
    isolate({
      if (input$analysis == "Aéroport de départ le plus emprunté") {
        data <- get_collection("flights")
        top_airport <- data %>%
          group_by(origin) %>%
          summarise(count = n()) %>%
          arrange(desc(count)) %>%
          slice(1)
        datatable(top_airport, options = list(pageLength = 10))
      } else if (input$analysis == "10 destinations les plus prisées") {
        data <- get_collection("flights")
        top_destinations <- data %>%
          group_by(dest) %>%
          summarise(count = n()) %>%
          arrange(desc(count)) %>%
          slice(1:10)
        datatable(top_destinations, options = list(pageLength = 10))
      } else if (input$analysis == "10 destinations les moins prisées") {
        data <- get_collection("flights")
        bottom_destinations <- data %>%
          group_by(dest) %>%
          summarise(count = n()) %>%
          arrange(count) %>%
          slice(1:10)
        datatable(bottom_destinations, options = list(pageLength = 10))
      } else if (input$analysis == "10 avions qui ont le plus décollé") {
        data <- get_collection("flights")
        top_planes <- data %>%
          group_by(tailnum) %>%
          summarise(count = n()) %>%
          arrange(desc(count)) %>%
          slice(1:10)
        datatable(top_planes, options = list(pageLength = 10))
      } else if (input$analysis == "10 avions qui ont le moins décollé") {
        data <- get_collection("flights")
        bottom_planes <- data %>%
          group_by(tailnum) %>%
          summarise(count = n()) %>%
          arrange(count) %>%
          slice(1:10)
        datatable(bottom_planes, options = list(pageLength = 10))
      }
    })
  })
}

shinyApp(ui = ui, server = server)
