FROM openjdk:8-jdk-alpine as builder

ARG MICRO_NAME=microservicio-usuario

# In addition to installing the Amazon corretto, we also install
# fontconfig. The folks who manage the docker hub's
# official image library have found that font management
# is a common usecase, and painpoint, and have
# recommended that Java images include font support.
#
# See:
#  https://github.com/docker-library/official-images/blob/master/test/tests/java-uimanager-font/container.java

# The logic and code related to Fingerprint is contributed by @tianon in a Github PR's Conversation
# Comment = https://github.com/docker-library/official-images/pull/7459#issuecomment-592242757
# PR = https://github.com/docker-library/official-images/pull/7459




#Ruta de la imagen
WORKDIR /app/$MICRO_NAME

#Copiamos el pom.xml padre y el pom.xml del microservicio.
COPY ./pom.xml /app
#Copiamos la carpeta hijo
COPY ./$MICRO_NAME/.mvn               ./.mvn
COPY ./$MICRO_NAME/mvnw               .
COPY ./$MICRO_NAME/pom.xml            .


#Arranca la compilación del microservicio padre y salta los test.
RUN ./mvnw clean package -Dmaven.test.skip  -Dmaven.main.skip -Dspring-boot.repackage.skip && rm -r ./target/

#Copiamos el resto de archivos del microservicio
COPY ./$MICRO_NAME/src ./src



#Instalamos las dependencias de maven y creamos el jar
RUN ./mvnw package -DskipTests


#Copiamos el jar

#Copiamos el jar a la imagen docker. Ruta maquina local: ruta imagen docker
#COPY ./target/microservicio-usuario-0.0.1-SNAPSHOT.jar .


FROM openjdk:8-jdk-alpine

WORKDIR /app

COPY --from=builder /app/microservicio-usuario/target/microservicio-usuario-0.0.1-SNAPSHOT.jar .


ENV PORT 8083
EXPOSE $PORT



# docker run -p 8980:8083  --rm  -it id_imagen = segunda opcion para ejecutar el contenedor y ejecutar el jar automatica
# docker run -p 8980:8083  --rm  -it id_imagen /bin/sh = Arranca el contenedor y lo deja en ejecución en el puerto 8980. Pàra ejecutar el jar manualmente en el contenedor uso de linea de comandos: java -jar microservicio-usuario-0.0.1-SNAPSHOT.jar
#Uso con /bin/sh la ejecucion del jar se realiza con el comando java -jar en la consola de linux  java -jar microservicio-usuario-0.0.1-SNAPSHOT.jar
# Para salir de la consola de linux se utiliza el comando (exit) o (Ctrl + C)
CMD ["java","-jar","microservicio-usuario-0.0.1-SNAPSHOT.jar"]



#Inmutables la imagen no se puede modificar una vez creada la ejecucion es automatica
#ENTRYPOINT ["java","-jar","microservicio-usuario-0.0.1-SNAPSHOT.jar"]


#IMPORTANT: El nombre del contenedor es el host
#Comandos docker
#docker build . = Construye la imagen docker con el Dockerfile de la ruta actual (.) RAIZ
# docker image prune -a = Elimina todas las imagenes docker
#docker build -t micro-usuario  . -f .\microservicio-usuario\Dockerfile = Construye la imagen docker con el Dockerfile de la ruta especificada
#docker build -t nombrePersonalizado .  = Construye la imagen con un nombre personalizado
#docker run -p 8081:8080 -d id_imagen  = Arranca el contenedor y lo deja en ejecución en el puerto 8081
#docker ps = ver los contenedores que estan corriendo
#docker ps -a = ver los contenedores que estan detenidos
#docker stop id_contenedor = detiene el contenedor
#docker images = ver las imagenes que tenemos
#docker logs id_contenedor = ver los logs del contenedor
#docker build -t testdockerone . = construye la imagen con el tag testdockerone. -t es para darle un tag a la imagen
#Vuelve a construir la imagen con el tag mcsuser_container desde la dirtecion del Dockerfile
#docker run -p 8083:8083  mcsuser_container = Arranca el contenedor y lo deja en ejecución en el puerto 8083
#docker logs id_contenedor = ver los logs del contenedor
#docker attach ad35cb2b4073 = Otra forma de ver los logs del contenedor
#docker rm id_contenedor = Elimina el contenedor
#docker container prune = Elimina todos los contenedores detenidos
#docker rmi id_imagen = Elimina la imagen
#docker image prune = Elimina todas las imagenes que no estan en uso
# docker run -p 8980:8083 -d --rm id_imagen = Arranca el contenedor y lo deja en ejecución en el puerto 8980 y lo elimina al detenerse el contenedor
# docker run -p 8980:8083  --rm  -it id_imagen /bin/sh = Arranca el contenedor y lo deja en ejecución en el puerto 8980 y lo elimina al detenerse el contenedor y abre la consola del contenedor
#docker image inspect id_imagen = Muestra la informacion de la imagen
#docker container inspect id_contenedor = Muestra la informacion del contenedor
#docker run -p 8083:8083  --rm -d --name micro-container-usuario  micro-usuario:v1 = Arranca el contenedor y lo deja en ejecución en el puerto 8083 y lo elimina al detenerse el contenedor y le da un nombre al contenedor
#docker run -p 8980:8083  --rm  -it id_imagen /bin/sh = Arranca el contenedor y lo deja en ejecución en el puerto 8980. Pàra ejecutar el jar manualmente en el contenedor uso de linea de comandos: java -jar microservicio-usuario-0.0.1-SNAPSHOT.jar
# NETWORK DOCKER-------------------------------------------
#docker network ls = ver las redes que tenemos
#docker network create name_red = crear una red
#docker run -p 8083:8083 -d --rm --name micro-usuario --network spring id_imagen = Arranca el contenedor y lo deja en ejecución en el puerto 8083 y lo elimina al detenerse el contenedor y le da un nombre al contenedor y lo conecta a la red spring
#MySQL DOCKER---------------------------------------------
#docker pull mysql:8 = Descarga la imagen de mysql
#docker run -d -p 3307:3306 --name mysql8 --network spring - e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_DATABASE=cartest mysql:8 = Arranca el contenedor y lo deja en ejecución en el puerto 3307 y lo elimina al detenerse el contenedor y le da un nombre al contenedor y lo conecta a la red spring y le da un password al usuario root y crea una base de datos llamada cartest
#docker logs id_contenedor = ver los logs del contenedor
#docker stop id_contenedor = detiene el contenedor
#docker start id_contenedor = inicia el contenedor
#|NOTA: Cuando se tiene ejecutando el contenedor de la BBDD se debe campiar la confi en properties y  añadir el nuevo host de la BBDD que --------------|
#|fue asigando mediante mysql --name mysql:8, ejemplo:                                                                                                  |
#|spring.datasource.url=jdbc:mysql://mysql8:3306/cartest?useSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false                                    |
#|Recorda que cada cambio de condigo de tienen que volver a construir la imagen y volver a ejecutar el contenedor---------------------------------------|
# docker build -t micro-usuario:latest . -f .\microservicio-usuario\Dockerfile = Construye la imagen docker con el Dockerfile de la ruta especificada
#docker run -p 8083:8083 -d --rm --name micro-usuario --network spring id_imagen = Arranca el contenedor y lo deja en ejecución en el puerto 8082 y lo elimina al detenerse el contenedor y le da un nombre al contenedor y lo conecta a la red spring
#DOCKER VOLUME-------------------------------------------
# docker run -d -p 3307:3306 --name mysql8 --network spring -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_DATABASE=cartest -v data-mysql:/var/lib/mysql --restart=always mysql:8 = Arranca el contenedor y lo deja en ejecución en el puerto 3307 y lo elimina al detenerse el contenedor y le da un nombre al contenedor y lo conecta a la red spring y le da un password al usuario root y crea una base de datos llamada cartest y crea un volumen llamado data-mysql y lo monta en la ruta /var/lib/mysql y los datos de guandan en maquina local
#docker volume ls = ver los volumenes que tenemos
#Cliente de MySQL de linea de comando ------------------------------------
#docker run -it --rm  --network spring mysql:8 bash= Arranca el contenedor y lo deja en ejecución y lo elimina al detenerse el contenedor y lo conecta a la red spring y abre la consola del contenedor para trabajar con linea de comando
# docker run -it --rm  --network spring mysql:8 bash = Arranca el contenedor y lo deja en ejecución y lo elimina al detenerse el contenedor y lo conecta a la red spring y abre la consola del contenedor para trabajar con linea de comando y accede a la BBDD
#mysql -hmysql8 -uroot -p123456 = Accede a la BBDD
#Comados de MySQL-----------------------------------------------------------
#show databases; = muestra las BBDD
#use cartest; = selecciona la BBDD
#show tables; = muestra las tablas de la BBDD
#desc user;= muestra la estructura de la tabla user
#select * from user; = muestra los registros de la tabla user
#exit = salir de la BBDD
#exit = salir del contenedor
#ARG AND ENV DOCKER-------------------------------------------
#docker run -p 8080:8089 --env PORT=8089  -d --rm --name micro-usuario --network spring bf99 = Arranca el contenedor y lo deja en ejecución en el puerto 8080 y lo elimina al detenerse el contenedor y le da un nombre al contenedor y lo conecta a la red spring y le da un valor a la variable de entorno PORT
#NOTA: Otra alternativa es crear un archivo .env y poner la variable de entorno y luego en el Dockerfile poner ARG PORT
#Se modifica las varibles de properties.prorerties y se cambia el puerto por la variable de entorno
#Luego se vuelve a construir la imagen y se vuelve a ejecutar el contenedor, recorda que cada cambio de condigo de tienen que volver a construir la imagen y volver a ejecutar el contenedor
# docker build -t micro-usuario:latest . -f .\microservicio-usuario\Dockerfile = Construye la imagen docker con el Dockerfile de la ruta especificada
# docker run -p 8080:8083 --env PORT=8083  -d --rm --name micro-usuario --network spring id_imagen
#DOCKER COMPOSE-------------------------------------------
#docker-compose up -d = Arranca los contenedores y los deja en ejecución
#docker-compose down = Detiene los contenedores y los elimina
#docker-compose ps = Ver los contenedores que se estan ejecutando
#docker-compose logs -f = Ver los logs de los contenedores
#docker-compose logs -f micro-usuario = Ver los logs del contenedor micro-usuario
#docker-compose logs -f micro-usuario -f micro-usuario = Ver los logs de los contenedores micro-usuario y micro-usuario
#docker volume ls = ver los volumenes que tenemos
#docker-compose down -v = Detiene los contenedores y elimina los volumenes
#detener volumenes = docker volume prune
#docker-compose up -d --build = Construye las imagenes y arranca los contenedores y los deja en ejecución
#DOCKER HUB------------------------------
#Enviar uma una imagen al repository
#docker login = loguearse en docker hub
#docker logout = salir de docker hub
#1- OPCION)= docker build -t sifponia/micro-user .  -f .\microservicio-usuario\Dockerfile = Construye la imagen docker con el Dockerfile de la ruta especificada
#2- OPCION)= docker tag kubernate_micro-usuario sifponia/micro-user  = OPCINAL Construye la imagen docker con el Dockerfile de la ruta especificada esto se utiliza cuando gtenemos la imagen creada en local para crear un clon de la imagen y subirla al repository
#2- OPCION)= docker tag kubernate_micro-car sifponia/micro-car = OPCIONAL  Construye la imagen docker con el Dockerfile de la ruta especificada esto se utiliza cuando gtenemos la imagen creada en local para crear un clon de la imagen y subirla al repository
#3- OPCION)= docker push sifponia/micro-user = Sube la imagen al repository
#4- OPCION)= docker pull sifponia/micro-user:latest = Descarga la imagen del repository
#NOTA: dEBEMOS USAR ESTA FORMA YA QUE NO DISPONEMOS DE DOCKER-COMPOSE EN EL SERVIDOR
#5)- OPCION)= docker run -p 8083:8083 --env PORT=8083    -d --rm --name micro-usuario --network spring sifponia/micro-user = Arranca el contenedor y lo deja en ejecución en el puerto 8080 y lo elimina al detenerse el contenedor y le da un nombre al contenedor y lo conecta a la red spring y le da un valor a la variable de entorno PORT
#6) docker run -p 8082:8082  -d --rm --name micro-car --network spring sifponia/micro-car = Arranca el contenedor y lo deja en ejecución en el puerto 8080 y lo elimina al detenerse el contenedor y le da un nombre al contenedor y lo conecta a la red spring y le da un valor a la variable de entorno PORT
