#!/bin/bash
clear

###############################
#
# Parametros:
#  - Lista Dominios y URL
#
#  Tareas:
#  - Se debera generar la estructura de directorio pedida con 1 solo comando con las tecnicas enseñadas en clases
#  - Generar los archivos de logs requeridos.
#
###############################

LISTA=$1
LOG_FILE="/var/log/status_url.log"

# Crear la estructura de directorios
mkdir -p {OK,cliente,servidor}

ANT_IFS=$IFS
IFS=$'\n'

# Leer cada línea de la lista de dominios
for LINEA in $(cat $LISTA); do
  # Extraer el dominio y la URL separados por espacio o tabulación
  DOMINIO=$(echo "$LINEA" | awk '{print $1}')
  URL=$(echo "$LINEA" | awk '{print $2}')
  
  # Verificamos que en la linea leida, exista una URL valida, para que no arroje errores al momento de ejecutar el script
  if [[ ! -z "$URL" && "$URL" =~ ^https?:// ]]; then #Para validamos decimos que $URL NO debe estar vacia, y que debe comenzar con http o https ://

    # Aca, obtenemos el codigo de estado de HTTP, para esto necesitamos que 'curl' nos transfiera de la URL dada, los encabezados (-I)	  #Que descarte todo lo que no nos importa (-o /dev/null) y que nos muestre solo el codigo http (-w '{%http_code}\n') y se guarde en    #La variable 'STATUS_CODE' 
    STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}\n' -s "$URL")
    
    # Fecha y hora actual en formato yyyymmdd_hhmmss
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    
    # Registrar en el archivo /var/log/status_url.log
    echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" | sudo tee -a "$LOG_FILE"
    
    # Determinar la carpeta según el código de estado
    if [ $STATUS_CODE -eq 200 ]; then
      DIRECTORY="OK"
    elif [ $STATUS_CODE -ge 400 ] && [ $STATUS_CODE -lt 500 ]; then
      DIRECTORY="cliente"
    elif [ $STATUS_CODE -ge 500 ] && [ $STATUS_CODE -lt 600 ]; then
      DIRECTORY="servidor"
    else
      DIRECTORY="otros"
    fi
    
    # Crear el archivo log correspondiente en la carpeta adecuada
    echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" | sudo tee -a "$DIRECTORY/${DOMINIO}.log"
  else
    echo "Línea no válida: $LINEA"
  fi
done

IFS=$ANT_IFS
