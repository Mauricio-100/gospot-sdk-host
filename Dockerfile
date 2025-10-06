# Utiliser Node.js Alpine léger
FROM node:22-alpine

# Installer les dépendances nécessaires
RUN apk add --no-cache bash curl tar python3 py3-pip

# Créer le répertoire pour le SDK
RUN mkdir -p /gospot-sdk

# Définir le répertoire de travail
WORKDIR /gospot-sdk

# Télécharger et extraire le SDK
ADD https://github.com/Mauricio-100/gospot-sdk-host/raw/main/public/gospot-sdk-1.0.0.tar.gz /tmp/gospot-sdk-1.0.0.tar.gz
RUN tar -xzvf /tmp/gospot-sdk-1.0.0.tar.gz -C /gospot-sdk \
    && rm /tmp/gospot-sdk-1.0.0.tar.gz

# Rendre les scripts exécutables
RUN chmod +x /gospot-sdk/sdk/scripts/*.sh

# Exposer un port pour HTTP (Render utilise 10000 par défaut pour web services)
EXPOSE 10000

# Commande par défaut : lancer un serveur HTTP simple pour servir le SDK
CMD ["python3", "-m", "http.server", "10000", "--directory", "/gospot-sdk"]
