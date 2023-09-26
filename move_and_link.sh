#!/bin/bash

# Gerar log da excução do script
exec 2>&1 >/config/shell/logs_move_and_link.txt

# Defina os diretórios de origem e destino como parâmetros
source_dir="/media/frigate/recordings"
dest_dir="/media/archive/recordings"

# Defina a idade máxima dos arquivos a serem movidos (em dias) como parâmetro
max_age=3
echo "Idade minima configurada: ($max_age)dias"

# Defina o limite de espaço livre em gigabytes (2GB neste caso)
limite=2

# Verifica o espaço livre no diretório
espaco_livre=$(df -BG "$dest_dir" | awk 'NR==2 {gsub("G","",$4); print $4}')

# Converte o limite para gigabytes
limite_gb=$limite

# Verifica se o espaço livre no diretório é menor que o limite
if [ "$espaco_livre" -lt "$limite_gb" ]; then
    echo "Espaço livre insuficiente no diretório. Iniciando a exclusão de arquivos antigos..."

    # Encontra e exclui os arquivos mais antigos no diretório, exclui sublinks e verificar se a pasta está vazia e a deleta
    find "$dest_dir" -type f -printf '%T+ %p\n' | sort | head -n 10 | while read -r data_arquivo arquivo; do
        echo "Excluindo $arquivo"
        rm -f "$arquivo" "${arquivo//"${dest_dir}"/"${source_dir}"}"
    done

    echo "Exclusão concluída."
else
    echo "Espaço livre adequado no diretório ($espaco_livre GB). Nenhuma ação necessária."
fi

# Encontre arquivos com mais de $max_age dias no diretório de origem
find "$source_dir" -type f -mtime +$max_age -print0 | while IFS= read -r -d $'\0' file; do
    # Extraia o caminho relativo do arquivo do diretório de origem
    relative_path="${file#$source_dir/}"

    # Cria o diretório de destino se ele não existir
    dest_file="$dest_dir/$relative_path"
    dest_directory="$(dirname "$dest_file")"
    mkdir -p "$dest_directory"

    # Move o arquivo para o diretório de destino
    mv "$file" "$dest_file"
    echo "Movendo arquivo: ($file)."

    # Crie um link simbólico no diretório de origem
    ln -s "$dest_file" "$file"
    echo "Criando simbólico ($dest_file)
done

