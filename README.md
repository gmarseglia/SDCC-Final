# SDCC-Final
Repository per l'esame finale di SDCC.

# Guida all'uso

## Introduzione rapida

Ci sono 3 attori:

1. I client, che creano le richieste.
2. I worker, che evadono le richieste.
3. Il server, che fa da tramite tra gli attori.

Per avviare l'applicazione i passi principali sono:

1. Avviare il server.
2. Avviare 1+ workers che notificano al server la loro presenza.
3. Avviare 1+ client che iniziano le richieste.

## Configurazione 

Tutti i **campi** indicati in **grassetto** possono essere impostati in più modi, la cui priorità è:
1. Tramite flag, direttamente all'avvio, es: `-FrontPort`.
2. Come variabile di ambiente.
3. Secondo il valore di default.

A seconda dell'ambiente di deployment otrebbe essere necessario esporre le porte.

# Server

## Introduzione

Repo: https://github.com/gmarseglia/SDCC-Server

Avviare 1 server.

I client invocheranno le RPC alla **front port** (`FrontPort`, default: `55555`).

I worker invocheranno le RPC alla **master port** (`MasterPort`, default: `55556`).

## Esempi

### Run

```
git clone https://github.com/gmarseglia/SDCC-Server
cd SDCC-Server/server
go run server.go
```

### Impostazioni

```
-FrontPort string
    The port for front service.
-MasterPort string
    The port for master service.
-ParallelWorkers int
    The number of parallel workers. (default 2)
-ReplicationGrade int
    The replication grade. (default 2)
```

### Runtime

SIGTERM per avviare la procedura di arresto.

### Docker

Dockerfile: `SDCC-Server/Dockerfile`


# Workers

## Introduzione

Repo: https://github.com/gmarseglia/SDCC-Worker


Avviare 1+ workers.

I worker si connetteranno al **master address** (`MasterAddr`, campo obbligatorio) e alla **master port** (`MasterPort` ,default: `55556`) del server.

I worker si notificheranno al server come raggiungibili al **host address** (`HostAddr`, indirizzo raggiungibile dalla rete) e alla **host port** (`HostPort`, default: `55557`). 

Se viene avviato in un container e vuole essere raggiungibile dall'esterno, allora vanno pubblicate le porte e va usato l'indirizzo IP dell'host.

Indicare `HostPort` come `0` permette al worker di scegliere automaticamente una porta libera.

## Esempi

### Run

```
git clone Repo: https://github.com/gmarseglia/SDCC-Worker
cd SDCC-Worker/worker
go run worker.go -MasterAddr 127.0.0.1
```

### Impostazioni

```
-HostAddr string
    The address of the host to advertise.
-HostPort string
    The port of the host to advertise.
-MasterAddr string
    The address to connect to.
-MasterPort string
    The port of the master service.
-PingTimeout int
    The ping timeout in seconds. (default 1)
```

### Runtime

SIGTERM per avviare la procedura di arresto.

### Docker

Dockerfile: `SDCC-Worker/Dockerfile`.

Una volta avviato in un container non verrà automaticamente avviato. Se necessario usare `--entrypoint="worker -MasterAddr 127.0.0.1"`.

# Client

## Introduzione

Repo: https://github.com/gmarseglia/SDCC-Client

Avviare 1+ client.

Il client invocherà RPC al **front address** (`FrontAddr`, obbligatorio) e alla *front port** (`FrontPort`, default: `55555`) del server.

Il client invierà **request count** (`RequestCount`, default: `1`) richieste al server, con un breve intervallo.

## Esempi

### Run

```
git clone https://github.com/gmarseglia/SDCC-Client
cd SDCC-Client/client
go run client.go -FrontAddr 127.0.0.1
```

### Impostazioni 

```
-AvgPoolSize int
    The size of the average pooling. (default -1)
-FrontAddr string
    The address to connect to.
-FrontPort string
    The port of the master service.
-KernelNum int
    The number of kernels. (default -1)
-KernelSize int
    The size of the kernel. (default -1)
-ManualValues
    Use manual values.
-RandomValues
    Use random values.
-RequestCount string
    The number of requests to send.
-TargetSize int
    The target size of the image. (default -1)
-UseSigmoid
    Use sigmoid function.
-Verbose
    Enable verbose output.
```

## Docker 

Dockerfile: `Docker/client/Dockerfile`.

On Linux, the image can be build from root directory with the script `./Docker/client/build.sh`.

### Run 

When running a containerized client it's mandatory to:
- Specify the **master address** in the envoironment variable `MasterAddr`.

The client application will start automatically at container launch.

On Linux, the container can be launched from root directory with the script `./Docker/client/run.sh`.

# Example deploy from Docker Desktop
# Esempio di deploy con container

Esempio:
1. Prendere nota dell'indirizzo IP dell'host, che verrà indicato come `<host_address>`.
2. Lanciare il server, pubblicando le porte `55555:55555` e `55556:55556` per permettere al server di essere raggiungibile.
3. Lanciare i worker, indicando `MasterAddr=<host_address>`,  `HostAddr=<host_address>`, `HostAddr=<worker_port>` e pubblicando la porta `<worker_port>:<worker_port>`.
4. Lanciare il client, indicando `FrontAddr=<host_address>`

Per "indicando" si intende impostare o come variabile di ambiente o direttamente dalla flag se avviato come container interattivo.

# Finale

La repo attuale (https://github.com/gmarseglia/SDCC-Final) contiene due `docker-compose.yaml` che possono essere per testare rapidamente l'utilizzo.

In particolare quello in `SDCC-Final\docker-compose.yaml` è un ambiente con server, 6 worker e 2 client.

Mentre quello in `SDCC-Final\3-worker\docker-compose.yaml` è un ambiente con server e 3 worker, senza client.

Entrambi gli ambienti comunicano all'interno del proprio network, che è possibile controllare con `docker network ls`.

Nella cartella `ec2` ci sono le istruzioni per lanciare le istanze e far produrre automaticamente le immagini.

# Common 

Infine nella repo https://github.com/gmarseglia/SDCC-Common c'è il codice dei protobuf e un package di utility condiviso tra server, client e worker.
