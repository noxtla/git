#!/bin/bash

echo "🚀 Iniciando configuración del entorno Git con convenciones y Gemini CLI..."

# --- SECCIÓN: Configuración de Git con Husky, Commitlint y Commitizen ---

# Instalar dependencias de desarrollo
echo "📦 Instalando husky, commitlint y commitizen..."
npm install --save-dev husky @commitlint/{config-conventional,cli} commitizen cz-conventional-changelog || { echo "Error: Falló la instalación de dependencias de Git." && exit 1; }

# Crear configuración commitlint
echo "📝 Creando commitlint.config.js..."
cat <<EOL > commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
};
EOL

# Agregar Commitizen config en package.json
echo "⚙️ Configurando Commitizen en package.json..."
npx json -I -f package.json -e 'this.config={"commitizen":{"path":"cz-conventional-changelog"}}' || { echo "Error: Falló la configuración de Commitizen en package.json." && exit 1; }

# Configurar Husky
echo "🔐 Configurando husky y hooks..."
npm pkg set scripts.prepare="husky install" || { echo "Error: Falló la configuración del script prepare de npm." && exit 1; }
npx husky install || { echo "Error: Falló la instalación de Husky." && exit 1; }
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"' || { echo "Error: Falló la adición del hook commit-msg de Husky." && exit 1; }

# Crear archivo .gitignore si no existe
if [ ! -f ".gitignore" ]; then
  echo "node_modules/" > .gitignore
  echo "Creado .gitignore."
else
  echo ".gitignore ya existe. Asegúrate de que 'node_modules/' esté incluido."
fi

echo "✅ Configuración de Git (Husky, Commitlint, Commitizen) completada."
echo ""
echo "---"

# --- SECCIÓN: Instalación y Configuración de Gemini CLI ---

echo "✨ Iniciando instalación y configuración de Gemini CLI..."

# Verificar e instalar Node.js y npm (usando nvm)
if ! command -v node &> /dev/null; then
  echo "Node.js no encontrado. Instalando NVM y Node.js (versión LTS)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Esto carga nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Esto carga nvm bash_completion
  nvm install --lts || { echo "Error: Falló la instalación de Node.js con nvm." && exit 1; }
  nvm use --lts || { echo "Error: Falló la selección de Node.js con nvm." && exit 1; }
  echo "Node.js y npm instalados y activados."
else
  echo "Node.js ya está instalado. Versión: $(node -v)"
fi

# Instalar Gemini CLI
echo "📦 Instalando @google/gemini-cli globalmente..."
npm install -g @google/gemini-cli || { echo "Error: Falló la instalación de Gemini CLI con npm. Asegúrate de tener permisos." && exit 1; }

# Solicitar clave API de Gemini
echo "🔑 Por favor, ingresa tu clave API de Gemini."
echo "Puedes obtenerla en https://aistudio.google.com/app/apikey o gestionarla en https://console.cloud.google.com/apis/credentials?project=gateway-r9gl0"
read -p "Ingresa tu GEMINI_API_KEY: " gemini_api_key

# Validar que la clave no esté vacía
if [ -z "$gemini_api_key" ]; then
  echo "⛔ Error: La clave API no puede estar vacía. No se configuró Gemini CLI."
else
  # Configurar GEMINI_API_KEY en .env en el directorio actual
  echo "📝 Configurando GEMINI_API_KEY en .env en el directorio actual ($(pwd))..."
  echo "GEMINI_API_KEY=\"$gemini_api_key\"" > .env
  echo ".env creado con tu clave API de Gemini."

  # Limpiar configuraciones previas de Gemini CLI
  echo "🧹 Limpiando configuraciones previas de Gemini CLI en ~/.gemini/..."
  rm -rf ~/.gemini/
  echo "Configuraciones previas limpiadas."

  echo "✅ Gemini CLI instalado y configurado con tu API Key."
  echo "Ahora puedes usar 'gemini' en tu terminal desde este directorio."
fi

echo ""
echo "---"
echo "🎉 Configuración completa del entorno Git y Gemini CLI."
echo ""
echo "Para commits guiados:"
echo "👉  npx cz"
echo ""
echo "Para usar Gemini CLI:"
echo "👉  gemini"
echo ""
echo "💡 BONUS: considera añadir un README.md con tu estructura de ramas y convención de commits."
