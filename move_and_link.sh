#!/bin/bash

# Gerar log da execução do script
exec >> /config/shell/logs_move_and_link.txt 2>&1

# Obtém a data e hora local
data_hora_local=$(date)
echo "Data e hora local: $data_hora_local"

# Defina os diretórios de origem e destino como parâmetros
source_dir="/media/frigate/recordings"
dest_dir="/media/archive/recordings"

# Defina a idade máxima dos arquivos a serem movidos (em dias) como parâmetro
max_age=3
echo "Idade mínima configurada: ($max_age) dias"

# Defina o limite de espaço livre em gigabytes (2GB neste caso)
limite=2

# Verifica o espaço livre no diretório de destino
espaco_livre=$(df -BG "$dest_dir" | awk 'NR==2 {gsub("G","",$4); print $4}')

# Converte o limite para gigabytes
limite_gb=$limite

# Verifica se o espaço livre no diretório de destino é menor que o limite
if [ "$espaco_livre" -lt "$limite_gb" ]; then
    echo "Espaço livre insuficiente no diretório de destino. Iniciando a exclusão de arquivos antigos..."

    # Encontra e exclui os arquivos mais antigos no diretório de destino, exclui sublinks e verifica se a pasta está vazia e a deleta
    find "$dest_dir" -type f -printf '%T+ %p\n' | sort | head -n 10 | while read -r data_arquivo arquivo; do
        echo "Excluindo $arquivo"
        rm -f "$arquivo" "${arquivo//"${dest_dir}"/"${source_dir}"}"
    done

    echo "Exclusão concluída."
else
    echo "Espaço livre adequado no diretório de destino ($espaco_livre GB). Nenhuma ação necessária."
fi

# Inicializa o contador de arquivos movidos
contador=0

# Encontra arquivos com mais de $max_age dias no diretório de origem
find "$source_dir" -type f -mtime +$max_age -print0 | while IFS= read -r -d $'\0' file; do
    # Extraia o caminho relativo do arquivo do diretório de origem
    relative_path="${file#$source_dir/}"

    # Cria o diretório de destino se ele não existir
    dest_file="$dest_dir/$relative_path"
    dest_directory="$(dirname "$dest_file")"
    mkdir -p "$dest_directory"

    # Move o arquivo para o diretório de destino e cria um link simbólico no diretório de origem
    if mv "$file" "$dest_file"; then
        ln -s "$dest_file" "$file"
        echo "Arquivo movido e link criado: $file"
        contador=$((contador+1))
    else
        echo "Erro ao mover o arquivo: $file"
    fi
done

echo "Total de arquivos movidos e links simbólicos criados: $contador"
