# Desafio: Criando um Container de uma Aplicação WEB

Este projeto é parte de um desafio para uma formação em Docker Fundamentals.

O objetivo é criar e configurar um container Docker para uma aplicação web simples utilizando o servidor Apache (httpd) e o Docker Compose. A aplicação será um exemplo básico de "Hello World" acessível via navegador, demonstrando boas práticas na containerização.

## Descrição

O desafio tem como meta criar um container Docker para uma aplicação web simples usando o servidor Apache (httpd). O foco é utilizar o Docker Compose para definir, configurar e executar a aplicação em um ambiente containerizado, mapeando arquivos locais para o container e garantindo que a aplicação seja acessível pelo navegador.

## Requisitos Mínimos

- Docker Engine: Versão 20.10 ou superior (necessária para compatibilidade com Docker Compose v2).
- Docker Compose: Versão v2.20.0 ou superior (recomenda-se a mais recente, como v2.24.x em março de 2025).
- Sistema operacional compatível (ex.: Ubuntu).

## Passo a Passo

Siga os passos abaixo para completar o desafio e executar a aplicação web.

### 1. Criar o Arquivo de Configuração do Docker Compose

Crie um arquivo chamado `compose.yaml` na raiz do projeto com as definições do servidor Apache. Este arquivo especifica a imagem do Apache, portas, volumes e outras configurações.

#### Conteúdo do `compose.yaml`:

```yaml
services:
  web:
    image: httpd:latest
    container_name: my-apache-app
    ports:
      - "8080:80"
    volumes:
      - ./website:/usr/local/apache2/htdocs
    environment:
      - APACHE_LOG_DIR=/var/log/apache2
    healthcheck:
      test: ["CMD", "httpd", "-t"]
      interval: 30s
      timeout: 3s
      retries: 3
    restart: unless-stopped
```

#### Explicação:

- `web`: Nome do serviço, representando o servidor web.
- `image: httpd:latest`: Usa a imagem oficial mais recente do Apache.
- `ports: "8080:80"`: Mapeia a porta 8080 do host para a porta 80 do container.
- `volumes`: Liga o diretório local `./website` ao diretório de conteúdo do Apache.
- `healthcheck`: Verifica a saúde do Apache a cada 30 segundos.
- `restart: unless-stopped`: Garante que o container reinicie automaticamente, exceto se for parado manualmente.

### 2. Configurar os Arquivos da Aplicação

Crie um diretório chamado `website` no mesmo local do `compose.yaml` e adicione um arquivo `index.html` com um "Hello World" básico.

#### Comandos:

```bash
mkdir website
echo "<h1>Hello World from Docker!</h1>" > website/index.html
```

#### Explicação:

O diretório `website` será mapeado para `/usr/local/apache2/htdocs` no container, onde o Apache serve os arquivos. O `index.html` será a página inicial exibida.

### 3. Executar a Aplicação com Docker Compose

Com o Docker Engine e o Docker Compose instalados, execute o seguinte comando na raiz do projeto para iniciar o container em segundo plano:

```bash
docker compose up -d
```

#### Explicação:

O comando `docker compose up` cria e inicia o container conforme definido no `compose.yaml`. A flag `-d` (detached) faz ele rodar em background.

Verifique se o container está ativo:

```bash
docker ps
```

### 4. Acessar a Aplicação Web

Abra um navegador e acesse:

```
http://localhost:8080
```

Você verá a mensagem "Hello World from Docker!" exibida na página.

**Dica:** Se a porta 8080 estiver em uso, altere o mapeamento no `compose.yaml` (ex.: "8081:80") e ajuste a URL.

## Estrutura do Projeto

Após seguir os passos, sua estrutura de diretórios será:

```
projeto/
├── compose.yaml
└── website/
        └── index.html
```

## Parar a Aplicação

Para parar o container sem remover os recursos:

```bash
docker compose stop
```

Para parar e remover o container:

```bash
docker compose down
```

## Boas Práticas Aplicadas

- Uso do Docker Compose v2 (sem a chave `version`, compatível com versões recentes).
- Mapeamento de porta ajustado para evitar conflitos (8080 em vez de 80).
- Adição de `healthcheck` para monitoramento da saúde do serviço.
- Política de reinício (`unless-stopped`) para maior resiliência.
- Nomenclatura semântica do serviço (`web` em vez de `apache`).

## Notas Adicionais

- **Produção:** Para um ambiente real, considere fixar a versão da imagem (ex.: `httpd:2.4`) e adicionar configurações de segurança (ex.: HTTPS).
- **Depuração:** Veja os logs com `docker compose logs` se houver problemas.
