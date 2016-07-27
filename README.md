# docker_ol6_wls (Doker for Oracle Linux 6 & Oracle Weblogic Server 11g-r10.3.6)

## Preparar

### Descargar  
JRockit 6  
http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-jrockit-2192437.html  
O  
Standar Java 6  
http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase6-419409.html  

-----
WLS r10.3.6(Generic)  
http://www.oracle.com/technetwork/middleware/weblogic/downloads/wls-main-097127.html  

-----


Colocar los archivos en el mismo directorio donde se ha hecho checkout del repositorio.

Acualizar las variables en el Dockerfile con los nombres de los instaladores
>ENV **JDK_INST**=jrockit-jdk1.6.0_45-R28.2.7-4.1.0-linux-x64.bin **WLS_INST**=wls1036_generic.jar


## Pruebas previas de comandos

Se puede usar una imagen de prueba antes de intentar construir nuestra propia imagen. Podemos usar oracle linux desde el shell e ir probando las instrucciones.

    docker run -t -i --name pepe oraclelinux:6 /bin/bash
    docker start -i pepe

## Consruir imagen (BUILD)
    
    #eliminar imagenes inconsistentes
    docker rmi -f $(docker images | grep "^<none>" | awk "{print $3}")
    #eliminar imagenes de prueba
    docker rm -f ol6wls
    #eliminar nuestra imagen previa
    docker rmi -f castokaribu/ol6_wls11g
    #construir desde el directorio actual (.). donde hemos hecho la clonacion del repositorio.
    docker build --no-cache -t castokaribu/ol6_wls11g .

## Instanciar
    
    docker run -d --name ol6wls -p 7001:7001 -p 7002:7002 castokaribu/ol6_wls11g

_Aquí le hemos asignado un nombre conocido para administrar luego, le decimos se ejecute como demonio y le asignamos las redirecciones de puertos necesarias._

## Despues de instanciar

    # Administrar el micro-servicio, nuestra instancia creada anteriormente cuando ejecutamos 'run -d --name ...'
    docker restart -i ol6wls
    docker start -i ol6wls
    docker stop -i ol6wls

    # Ver el log
    docker logs ol6wls

    # Acceder al shell
    docker exec -t -i ol6wls /bin/bash

## Revisar los puertos locales

    sudo nmap -sT -O localhost
    docker ps -l

## Para acceder

    WLS Console:    http://localhost:7001/console/
    WSDL Testing:   http://localhost:7001/wls_utc/

**_weblogic=weblogic1_**  
_Aqui accedemos con el puerto inseguro, para acceder con el puerto seguro usar el 7002._


### Futuras mejoras.
 - Crear un solo archivo de propiedades .ini/.properties donde se puedan colocar todas las variables de rutas a usar durante la instalación.
    - Se debe crear un script (sh) que cargue las variables en memoria.
    - Los archivos usados para la instalacion, silent-jr.xml, silent-wls.xml en lugar de valores deberian tener variables a modo de plantillas.
    - Crear script python que actue como parser y sustituya las variables en los archivos de instalación.
 - Crear volumenes para carpeta de logs y carpeta de autodeploy
