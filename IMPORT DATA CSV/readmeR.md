# Chargement de Données dans MongoDB à partir de Fichiers CSV en R

Ce projet fournit un script R pour lire des fichiers CSV, les nettoyer et les charger dans une base de données MongoDB. Le script utilise les packages `readr`, `tidyr` et `mongolite`.

## Prérequis

Assurez-vous d'avoir les éléments suivants installés sur votre machine :

- R (version 3.6 ou supérieure)
- Les packages R suivants :
  - `readr`
  - `tidyr`
  - `remotes`

## Installation

1. **Installer les packages nécessaires :**

    ```r
    install.packages(c("readr", "tidyr", "remotes"))
    remotes::install_github("jeroen/mongolite")
    ```

## Utilisation

1. **Script R pour charger les données dans MongoDB :**

    ```r
    # Charger les packages nécessaires
    library(readr)
    library(tidyr)
    library(mongolite)

    # Chemins vers les fichiers CSV
    airports_file <- "path/to/airports.csv"
    planes_file <- "path/to/planes.csv"
    flights_file <- "path/to/flights.csv"
    weather_file <- "path/to/weather.csv"

    # Lire les fichiers CSV dans des dataframes
    airports_df <- read_csv(airports_file)
    planes_df <- read_csv(planes_file)
    flights_df <- read_csv(flights_file)
    weather_df <- read_csv(weather_file)

    # Vérifiez que le nom de la colonne est correct dans le DataFrame
    if ("year,month,day,dep_time,sched_dep_time,dep_delay,arr_time,sched_arr_time,arr_delay,carrier,flight,tailnum,origin,dest,air_time,distance,hour,minute,time_hour" %in% colnames(flights_df)) {
      # Diviser la colonne en plusieurs colonnes
      flights_df <- separate(flights_df, 
                             col = "year,month,day,dep_time,sched_dep_time,dep_delay,arr_time,sched_arr_time,arr_delay,carrier,flight,tailnum,origin,dest,air_time,distance,hour,minute,time_hour", 
                             into = c("year", "month", "day", "dep_time", "sched_dep_time", "dep_delay", "arr_time", "sched_arr_time", "arr_delay", "carrier", "flight", "tailnum", "origin", "dest", "air_time", "distance", "hour", "minute", "time_hour"), 
                             sep = ",")
    }

    # Nettoyer les données si nécessaire
    airports_df <- drop_na(airports_df)
    planes_df <- drop_na(planes_df)
    flights_df <- drop_na(flights_df)
    weather_df <- drop_na(weather_df)

    # Connexion à MongoDB
    mongo_url <- "mongodb+srv://project:KcuXIlF8eZkIjtgC@cluster0.yyhqpxq.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
    conn <- mongo(url = mongo_url)

    # Sélectionner la base de données et collection
    db <- conn$plane_db

    # Charger les dataframes dans MongoDB
    db$airports$insert(airports_df)
    db$planes$insert(planes_df)
    db$flights$insert(flights_df)
    db$weather$insert(weather_df)

    # Fermer la connexion à MongoDB
    conn$disconnect()

    print("Chargement des données dans MongoDB terminé.")
    ```

## Contributeurs

- Maxime ROCHETEAU
