# docker-spa-base

Image de base pour les Single Page Applications via Apache/NGINX.

Fonctionallités:

- Configuration serveur web pour SPA: réécriture d'url pour rediriger vers `index.html`
- Configuration des upstreams via variables d'environnement
- Possibilité d'ajouter des fichiers de configuration `*.conf` dans `/opt/apache-config/`
- Auto discovery des secrets dans  `/run/secrets`  et accessibles via variables d'environnement: préfix configurable via variable d'environnement  `app_name`
- Auto remplacement des variables d'environnement (préfixé de `CONFIG_`) dans les fichiers `main*.js`

# Getting started

## Exemple d'utilisation dans un Dockerfile

```
FROM govpf/node:14 AS dist
WORKDIR /code
COPY . .
RUN yarn install --frozen-lockfile
RUN yarn build

FROM govpf/spa-base:apache
COPY --from=dist /code/dist/ /var/www/html
```

## Exemple de configuration via `docker run`

```
echo "/api/
docker run --name my_app -d \
		   -e SERVER_NAME=my-app.com \
		   -e CONFIG_REMOTE_API=http://localhost:8000 \
		   -e UPSTREAMS="/api/;http://localhost:8080/ /api2/;http://localhost:9000/" \
```

.... I sleep ...

# Définition des fichiers normatifs par défaut

| Nom du fichier | A quoi sert ce fichier ? |
| ------------------ | ----------------------------------------------------------------------------------------------------------------- |
| CODE_OF_CONDUCT.md | Ce fichier définit des normes d'engagement dans la communauté. |
| CONTRIBUTING.md | Ce fichier indique comment vous pouvez contribuer. |
| SECURITY.md | Ce fichier donne des instructions sur la façon de signaler de manière responsable une vulnérabilité de sécurité. |
| SUPPORT.md | Ce fichier permet aux contributeurs de savoir comment obtenir de l'aide. |
