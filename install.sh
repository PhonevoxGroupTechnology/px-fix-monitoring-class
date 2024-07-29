#!/bin/bash

CURRDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"



# LOGGING
datahora=$(date +%Y%m%d%H%M%S%3N)

LOG_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOGFILE_PATH="."
LOGFILE_NAME="pvx-autossh" # Nome (prefixo) pro arquivo de log. "<logfile_name>-0000-11-22.log"
LOGFILE="$LOGFILE_NAME-$(date '+%Y-%m-%d').log"
if ! [ -f "$LOGFILE" ]; then # checa se o arquivo de log já existe
        echo -e "[$LOG_TIMESTAMP] Iniciando novo logfile" > $LOGFILE_PATH/$LOGFILE
fi

log () {
    if [ -z $2 ]; then
        local muted=false
    else
        local muted=true
    fi
    echo -e "[$LOG_TIMESTAMP] $1" >> $LOGFILE_PATH/$LOGFILE
    if ! $muted; then
        echo -e "[$LOG_TIMESTAMP] $1" # Comentando pra não atrapalhar nas funções.
    fi
}

# Função de ajuda para exibir a mensagem de ajuda
show_help() {
    echo 'Em resumo, ao alterar o "ASTSPOOLDIR" em "/etc/asterisk/asterisk.conf", a configuração não é tão bem-repassada assim pro sistema, causando alguns pontos quebrarem. Até o momento (30/11/23), o único local relevante que percebi erros foram para baixar as gravações, onde as mais recentes apareciam como "Recording missing.". Diante deste problema, a intenção DESTE script é corrigir ESTE E APENAS ESTE problema, referente ao RECORDING MISSING. Ao rodar este script, o mesmo fará a substituição do arquivo "/var/www/html/modules/monitoring/libs/paloSantoMonitoring.class.php" por um novo arquivo de mesmo nome, com alterações pequenas em suas funções, removendo a parte em que o local da gravação $file é comparado com "DEFAULT_ASTERISK_RECORDING_BASEDIR", ou, $basedir.'
    echo 'Função relevantes envolvidas: "resolveRecordingPath", que utiliza "_rutaAbsolutaGrabacion", '
    echo 'Linha específica relevante: $result['fullpath'] = $this->_rutaAbsolutaGrabacion($recordingfile);'
    exit 0
}

if [[ -f /var/www/html/modules/monitoring/libs/paloSantoMonitoring.class.php ]]; then
    echo "PROGRESS: O '.class.php' existe"

    # // Fazendo backup antes de alterar
    echo "PROGRESS: fazendo backup"
    cp "/var/www/html/modules/monitoring/libs/paloSantoMonitoring.class.php" "/var/www/html/modules/monitoring/libs/paloSantoMonitoring.class.php.backup-$datahora"

    # @ Adrian 05/01/24 15:38
    # Não sei pq eu fiz isso, mas não funciona. Vou optar por só mover um arquivo pra lá mesmo
    # # // Alterando a linha problemática pra comparar com nada, ao invés de comparar com "/var/spool/asterisk/monitor"
    # echo "PROGRESS: sed'zando a linha problemática"
    # sed -i "s/define ('DEFAULT_ASTERISK_RECORDING_BASEDIR', '\/var\/spool\/asterisk\/monitor');/define ('DEFAULT_ASTERISK_RECORDING_BASEDIR', '');/" /var/www/html/modules/monitoring/libs/paloSantoMonitoring.class.php
    rm -rf /var/www/html/modules/monitoring/libs/paloSantoMonitoring.class.php
    mv -fv $CURRDIR/files/paloSantoMonitoring.class.php /var/www/html/modules/monitoring/libs/

    echo "SUCCESS: \"paloSantoMonitoring.class.php\" substituido, as gravações serão buscadas relativamente à astspooldir a partir de agora (alteração retroativa)"
    exit 0
else
    echo "FATAL: O seu .class.php de monitor não existe, abortando aqui."
    exit 1
fi