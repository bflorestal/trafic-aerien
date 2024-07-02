# Chargement de Données dans MongoDB à partir de Fichiers CSV en Python

Ce projet fournit un script Python pour lire des fichiers CSV, les nettoyer et les charger dans une base de données MongoDB. Le script utilise les packages `pandas` et `pymongo`.

## Prérequis

Assurez-vous d'avoir les éléments suivants installés sur votre machine :

- Python (version 3.6 ou supérieure)
- Les packages Python suivants :
  - `pandas`
  - `pymongo`

## Installation

1. **Installer les packages nécessaires :**

    ```sh
    pip install pandas pymongo
    ```

## Utilisation

1. **Script Python pour charger les données dans MongoDB :**

    ```python
    import pandas as pd
    from pymongo import MongoClient

    # Chemins vers les fichiers CSV
    airports_file = "/content/data-csv/airports.csv"
    planes_file = "/content/data-csv/planes.csv"
    flights_file = "/content/data-csv/flights.csv"
    weather_file = "/content/data-csv/weather.csv"

    # Lire les fichiers CSV dans des dataframes
    airports_df = pd.read_csv(airports_file)
    planes_df = pd.read_csv(planes_file)
    flights_df = pd.read_csv(flights_file)
    weather_df = pd.read_csv(weather_file)

    # Afficher les premières lignes de planes_df pour vérifier les noms de colonnes
    print(planes_df.head())

    # Vérifiez que le nom de la colonne est correct dans le DataFrame
    if 'year,month,day,dep_time,sched_dep_time,dep_delay,arr_time,sched_arr_time,arr_delay,carrier,flight,tailnum,origin,dest,air_time,distance,hour,minute,time_hour' in planes_df.columns:
        # Diviser la colonne en plusieurs colonnes
        planes_df[['year', 'month', 'day', 'dep_time', 'sched_dep_time', 'dep_delay', 'arr_time', 'sched_arr_time', 'arr_delay', 'carrier', 'flight', 'tailnum', 'origin', 'dest', 'air_time', 'distance', 'hour', 'minute', 'time_hour']] = planes_df['year,month,day,dep_time,sched_dep_time,dep_delay,arr_time,sched_arr_time,arr_delay,carrier,flight,tailnum,origin,dest,air_time,distance,hour,minute,time_hour'].str.split(',', expand=True)
        # Supprimer la colonne initiale
        planes_df.drop(columns=['year,month,day,dep_time,sched_dep_time,dep_delay,arr_time,sched_arr_time,arr_delay,carrier,flight,tailnum,origin,dest,air_time,distance,hour,minute,time_hour'], inplace=True)

    # Nettoyer les données si nécessaire
    airports_df = airports_df.dropna()
    planes_df = planes_df.dropna()
    flights_df = flights_df.dropna()
    weather_df = weather_df.dropna()

    # Vérifier les types de données dans les dataframes
    print(airports_df.dtypes)
    print(planes_df.dtypes)
    print(flights_df.dtypes)
    print(weather_df.dtypes)

    # Connexion à MongoDB
    client = MongoClient("mongodb+srv://project:KcuXIlF8eZkIjtgC@cluster0.yyhqpxq.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")

    # Sélectionner la base de données
    db = client.get_database("plane_db")

    # Charger les dataframes dans MongoDB
    db.airports.insert_many(airports_df.to_dict(orient='records'))
    db.planes.insert_many(planes_df.to_dict(orient='records'))
    db.flights.insert_many(flights_df.to_dict(orient='records'))
    db.weather.insert_many(weather_df.to_dict(orient='records'))

    # Fermer la connexion à MongoDB
    client.close()

    print("Chargement des données dans MongoDB terminé.")
    ```

## Contributeurs

- Maxime ROCHETEAU