# Charger les bibliothèques nécessaires
install.packages("rsconnect")
library(rsconnect)

# Configurer le compte shinyapps.io
rsconnect::setAccountInfo(name='ipssi-projectr', 
                          token='2B39748E9D28ABFF95E67225B3F10027', 
                          secret='qKwtZvKMeqcR+4fcgwtWfDJnsclvSdDp/P2zrbsJ')

# Déployer l'application
rsconnect::deployApp('/Users/thoms/Desktop/IPSSI/M2/Langage_R/trafic-aerien/')
