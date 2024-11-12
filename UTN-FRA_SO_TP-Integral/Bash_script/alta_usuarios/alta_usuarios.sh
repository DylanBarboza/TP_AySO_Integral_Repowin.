#!/bin/bash
clear

###############################
#
# Parametros:
#  - Lista de Usuarios a crear
#  - Usuario del cual se obtendra la clave
#
#  Tareas:
#  - Crear los usuarios segun la lista recibida en los grupos descriptos
#  - Los usuarios deberan de tener la misma clave que la del usuario pasado por parametro
#
###############################

LISTA=$1 

ANT_IFS=$IFS
IFS=$'\n'
for LINEA in `cat $LISTA |  grep -v ^#`
do
	
	#Separamos en usuarios, grupos y areas de trabajo
	USUARIO=$(echo  $LINEA |awk -F ',' '{print $1}')
	GRUPO=$(echo  $LINEA |awk -F ',' '{print $2}')
	WORK=$(echo  $LINEA |awk -F ',' '{print $3}')
	
	#Creamos grupos y luego los usuarios en su respectivo grupo
	sudo groupadd $GRUPO
	sudo useradd -m -s /bin/bash -g $GRUPO $USUARIO

	#Creamos la zona de trabajo, y le definimos su usuario y grupo dueño
	sudo mkdir -p $WORK
	sudo chown $USUARIO:$GRUPO $WORK

	echo "Se creo el usuario $USUARIO del grupo $GRUPO y con work area en $WORK"

done
IFS=$ANT_IFS
