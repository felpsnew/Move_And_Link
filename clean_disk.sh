#!/bin/bash

# Diretório a ser verificado
source_dir="/media/frigate/recordings"
dest_dir="/media/archive/recordings"

# Encontra e exclui links simbólicos inválidos
find "$source_dir" -type l ! -exec test -e {} \; -exec rm -f {} \;

echo "Links simbólicos inválidos do Frigate excluídos."

# Encontra e exclui pastas vazias no diretório
find "$source_dir" -type d -empty -delete

echo "Pastas vazias do Frigate excluídas."

# Encontra e exclui pastas vazias no diretório
find "$dest_dir" -type d -empty -delete

echo "Pastas vazias do Archive excluídas."