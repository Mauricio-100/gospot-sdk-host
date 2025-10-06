# -----------------------------
# Dockerfile pour GoSpot SDK
# -----------------------------
FROM node:22-alpine

# Définir le répertoire de travail
WORKDIR /gospot-sdk-host

# Installer les dépendances nécessaires (bash, curl, etc.)
RUN apk add --no-cache bash curl tar

# Télécharger le tarball du SDK depuis GitHub
ADD https://github.com/Mauricio-100/gospot-sdk-host/raw/main/public/gospot-sdk-1.0.0.tar.gz /tmp/gospot-sdk-1.0.0.tar.gz

# Décompresser le SDK dans le répertoire de travail
RUN tar -xzvf /tmp/gospot-sdk-1.0.0.tar.gz -C /gospot-sdk \
    && rm /tmp/gospot-sdk-1.0.0.tar.gz

# Installer globalement Node.js packages si nécessaires
# RUN npm install -g <package1> <package2> ...

# Définir le point d'entrée pour exécuter le SDK ou un script
WORKDIR /gospot-sdk
CMD ["bash"]
