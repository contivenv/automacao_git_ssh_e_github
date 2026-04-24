# --- CONFIGURAÇÕES FIXAS ---
# se não quiser quebrar o código, não altere essa estruta. Mas se for modificar, atenção ! Os parêmetros de nome e e-mail estão aqui
EMAIL="seu_email"
NOME="seu_nome"
KEY_PATH="$HOME/.ssh/id_ed25519"

echo "[INFO] Iniciando provisionamento do ambiente (Debian/Fedora)..."

# 1. Detecção de SO e Instalação de Dependências
# aqui ele indentifica quais das distribuições Linux você está usando. Seja ela derivadas do Debian ou ou da Red Hat (usei fedora aqui)
if command -v apt &> /dev/null; then
    echo "[INFO] Gerenciador de pacotes APT detectado (Base Debian/Mint/Ubuntu)."
    echo "[INFO] Atualizando repositórios e instalando dependências..."
    sudo apt update
    sudo apt install -y git gh
elif command -v dnf &> /dev/null; then
    echo "[INFO] Gerenciador de pacotes DNF detectado (Base Fedora/RHEL)."
    echo "[INFO] Instalando dependências..."
    sudo dnf install -y git gh
else
    echo "[ERROR] Sistema operacional não suportado por este script (apt/dnf não encontrados)."
    echo "[ERROR] Instale o git e o gh manualmente e execute o script novamente."
    exit 1
fi

# 2. Configuração de Identidade Global
# alterações de informações e updates novos solicitam informações suas, então preencha elas para deixar rastrebilidade das suas mudanças !
echo "[INFO] Configurando credenciais locais do Git..."
git config --global user.name "$NOME"
git config --global user.email "$EMAIL"

# 3. Geração de Par de Chaves SSH Ed25519
# geração de par de chaves criptografadas para liberação de push e pull aos seus repositórios com liberações com chave SSH
if [ ! -f "$KEY_PATH" ]; then
    echo "[INFO] Gerando chave SSH Ed25519..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N "" 
else
    echo "[WARN] Chave SSH já detectada no sistema."
fi

# 4. Agente SSH e Persistência
# deixa a chave gravada/salva no seu sistema operacional
echo "[INFO] Inicializando agente SSH..."
eval "$(ssh-agent -s)"
ssh-add "$KEY_PATH"

# 5. Autenticação GitHub CLI (Fluxo de Terminal)
# responsável pela chamada da função que puxa a validação da inserção da chave a autenticação pelo terminal
echo "[INFO] Iniciando autenticação."
echo "[INSTRUÇÃO] Siga os passos no terminal e utilize o Device Code gerado."
echo "------------------------------------------------------"
if command -v gh &> /dev/null; then
    gh auth login -p ssh
else
    echo "[ERROR] Falha ao detectar a GitHub CLI pós-instalação."
    exit 1
fi

# 6. Definição Manual de Caminho e Clonagem
# fiz esse passo pois cada distro Linux tem o nome dos repositórios diferentes para clonagem. Exemplo: /home/guilherme/Documentos/ para /home/guilherme/Documents. Parece bobo, mas não funciona se deixar padrão
echo "------------------------------------------------------"
read -p "[PROMPT] Insira o caminho absoluto para salvar o Vault (ex: /home/usuario/Estudos): " TARGET_PATH

# Expande o til (~) para o caminho absoluto da home do usuário atual
TARGET_PATH="${TARGET_PATH/#\~/$HOME}"

if [ -d "$TARGET_PATH" ]; then
    echo "[INFO] Diretório existente detectado. Acessando..."
else
    echo "[INFO] Criando novo diretório: $TARGET_PATH"
    mkdir -p "$TARGET_PATH"
fi

cd "$TARGET_PATH" || exit
echo "[INFO] Clonando repositório em: $(pwd)"
git clone git@github.com:contivenv/CompTIA-Security-.git .

echo "[SUCCESS] Ambiente provisionado com sucesso."
