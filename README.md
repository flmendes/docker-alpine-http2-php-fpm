# Container para PHP 7 com PHP-FPM

Container construido com base na distro Alpine Linux.

Os seguintes pacotes são instalados via APK:
- nginx com suporte http2
- php 7
- php-fpm
- supervisor

### Como usar
Cria o container.
```sh
$ docker build --rm --no-cache -t nginx-http2 .
```
Cria executa o container e seta um volume.
```sh
$ docker run -d --name nginx-http2 -p 443:443 -v "$PWD"/public:/var/www/web nginx-http2
```
Inicia o container.
```sh
$ docker start nginx-http2
```
Acessa o bash do container.
```sh
$ docker exec -it nginx-http2 bash
```
Para o container.
```sh
$ docker stop nginx-http2
```
Remove o container.
```sh
$ docker rm -f nginx-http2
```
### TODOS
 - Fazer uso da imagem nginx:alpine
