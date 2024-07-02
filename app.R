# Charger la bibliothèque Shiny
library(shiny)

# Interface utilisateur
ui <- fluidPage(
  titlePanel("Analyse du Trafic Aérien"),
  sidebarLayout(
    sidebarPanel(
      h2("Section de Filtrage"),
      p("Ici, vous pouvez ajouter des contrôles pour filtrer les données.")
    ),
    mainPanel(
      h2("Section Principale"),
      p("Ici, vous pouvez ajouter des visualisations et des résultats d'analyses."),
      h3("Titre secondaire"),
      p("Texte descriptif ou contenu additionnel.")
    )
  )
)

# Serveur
server <- function(input, output) {
  # Aucun traitement pour l'instant, juste une structure vide
}

# Lancer l'application
shinyApp(ui = ui, server = server)
