# Desafio Docker Swarm com Vagrant

## Descrição do Projeto

Este projeto implementa um Cluster Docker Swarm local utilizando máquinas virtuais criadas através do Vagrant. A automação da criação e configuração do ambiente elimina a necessidade de implementações manuais, proporcionando maior eficiência e padronização para o desenvolvimento.

## Pré-requisitos

- VirtualBox
- Vagrant
- Conhecimento básico em Docker Swarm
- Conhecimento básico em Git e GitHub
- Aproximadamente 2GB de RAM disponível (para 3 VMs com 512MB cada)

## Estrutura do Projeto

```bash
├── Vagrantfile            # Definição das máquinas virtuais
├── docker.sh              # Script de instalação do Docker
├── master.sh              # Script de inicialização do Swarm no nó master
├── worker.sh              # Script para os workers se unirem ao cluster
└── docs/                  # Arquivos de exemplo e documentação
    ├── index.html         # Página web de exemplo
    ├── index.php          # Aplicação PHP de exemplo
    ├── dataset.sql        # Script para criação de banco de dados
    └── guide.md           # Guia detalhado de uso
```

## Implementação

### Configuração das Máquinas Virtuais

O arquivo Vagrantfile define três máquinas virtuais:

- **master (10.10.10.100)**: Nó manager do Swarm
- **node01 (10.10.10.101)**: Nó worker
- **node02 (10.10.10.102)**: Nó worker

Cada máquina está configurada com:

- Ubuntu 24.04 (bento/ubuntu-24.04)
- 512MB de RAM
- 1 CPU
- Docker pré-instalado
- IP fixo na rede privada 10.10.10.0/24

### Provisionamento Automatizado

- **docker.sh**: Executa em todas as máquinas para instalar o Docker e o Docker Compose.
- **master.sh**: Configura o nó master como manager do Swarm e gera o token para os workers.
- **worker.sh**: Executa nos nós workers para ingressar no cluster Swarm.

## Instruções de Uso

### 1. Iniciar o Ambiente

Clone este repositório e navegue até o diretório do projeto:

```bash
git clone <url-do-repositorio>
cd <nome-do-diretorio>
```

Inicie as máquinas virtuais com o Vagrant:

```bash
vagrant up
```

Este processo pode levar alguns minutos, pois inclui:

- Download da imagem do Ubuntu (se não estiver em cache)
- Criação das 3 máquinas virtuais
- Instalação do Docker em cada máquina
- Configuração do cluster Swarm

### 2. Verificando o Cluster

Acesse o nó master:

```bash
vagrant ssh master
```

Verifique o status do cluster:

```bash
docker node ls
```

Você deverá ver uma saída semelhante a esta, mostrando o nó master como manager e os nós node01 e node02 como workers:

```bash
ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
abc123xyz456... *             master     Ready     Active         Leader           24.0.5
def456uvw789...               node01     Ready     Active                          24.0.5
ghi789rst012...               node02     Ready     Active                          24.0.5
```

### 3. Implantando um Serviço

Para testar o cluster, implante um serviço web simples:

```bash
sudo docker service create --name webserver --replicas 3 -p 80:80 httpd
```

Verifique se o serviço foi criado e distribuído:

```bash
sudo docker service ls
sudo docker service ps webserver
```

Você pode acessar o serviço em qualquer um dos IPs das máquinas virtuais:

- http://10.10.10.100
- http://10.10.10.101
- http://10.10.10.102

### 4. Encerrando o Ambiente

Para desligar as máquinas virtuais:

```bash
vagrant halt
```

Para remover completamente o ambiente:

```bash
vagrant destroy -f
```

## Personalização do Projeto

Para adicionar mais nós, edite o arquivo Vagrantfile e adicione novas definições de máquinas no hash `machines`. Por exemplo, para adicionar `node03`:

```ruby
machines = {
  "master" => {"memory" => "512", "cpu" => "1", "ip" => "100", "image" => "bento/ubuntu-24.04"},
  "node01" => {"memory" => "512", "cpu" => "1", "ip" => "101", "image" => "bento/ubuntu-24.04"},
  "node02" => {"memory" => "512", "cpu" => "1", "ip" => "102", "image" => "bento/ubuntu-24.04"},
  "node03" => {"memory" => "512", "cpu" => "1", "ip" => "103", "image" => "bento/ubuntu-24.04"}
}
```

## Informações Adicionais

Este projeto atende a todos os requisitos do desafio:

- ✅ Criação de máquinas virtuais (master, node01, node02)
- ✅ Definição de IPs fixos para cada VM
- ✅ Docker pré-instalado em todas as máquinas
- ✅ Configuração do nó master como manager do cluster Swarm
- ✅ Inclusão dos demais nós como workers

Para um guia mais detalhado sobre Docker Swarm e Vagrant, consulte o arquivo `docs/guide.md`.

## Recursos Úteis

- [Documentação oficial do Docker Swarm](https://docs.docker.com/engine/swarm/)
- [Documentação do Vagrant](https://www.vagrantup.com/docs)
- [Documentação do VirtualBox](https://www.virtualbox.org/manual/)
