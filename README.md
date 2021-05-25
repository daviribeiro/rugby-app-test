# DoT - Distributed Ops Tester

# Introdução

DoT - Distributed Ops Tester é uma ferramenta baseada em imagens JMeter rodando através de um cluster kubernetes (k8s), com arquitetura
master / slave distribuída.
Em resumo, temos um pod master que envia instruções de testes para os pods slaves, alimentando o resultado em um servidor InfluxDB para 
acompanhamento (quase) em tempo real via Grafana, a exemplo da já conhecida arquitetura de testes de carga distribuidos usando JMeter.


# Projetos no GCP

O primeiro passo é criar e selecionar um novo projeto para hospedar o(s) namespace(s) criado(s) no GKE para execução dos testes. Após fazer a criação,
podemos acessar o Google Shell e fazer o clone do repositorio com a estrutura pronta para execução.
Após o clone criado, devemos alterar o namespace rodando o script changeNamespaces.sh nomedonamespace para definição do namespace de acordo com o desejado.


# Conteudo do Repositório

Este repositório possui os scripts e ferramentas necessárias para execução dos testes. Utiliza scripts shell para execução via GKE (Google Kubernetes Engine).

Os pré requisitos para utilizar a ferramenta são:

1) Acesso ao GCP/GKE  na área da Vericode;
2) Acesso ao servidor do Grafana e InfluxDB para customização de buckets e dashboards por namespaces;
3) Conhecimentos básicos de shell script, JMeter e git


# Como utilizar o DoT

Local (On Premises):

1) Requisitos: Java JDK 11 ou superior, JMeter 5.0 ou superior, git
2) Incluir o plugin jmeter-plugin-influxdb2-listener-1.1.jar no path lib/ext no seu path JMETER_HOME/lib/ext
3) Não utilize a JDK 1.8 em hipótese alguma, pois o plugin acima só funciona com JDK 11+ e haverá quebra na configuração do Listener.
4) Adicionar o Backend Listener do InfluxDB pré configurado conforme o rugby-app-test.jmx deste repositório no seu JMX.

Cloud - Preparação do InfluxDB / Grafana:

1) Criar uma VM via imagem disponibliizada no GCP ou inicializar a VM com InfluxDB/Grafana já criada e disponivel no GCP 
2) Criar o bucket (database) no InfluxDB correspondente ao namespace a ser usado no cluster GKE
3) Dentro do InfluxDB, coletar a chave de acesso (token) do user que possui o acesso ao database e copiar dentro do Backend Listener 
   criado no JMeter
4) A mesma chave de acesso gerada no InfluxDB, deve ser configurada no Grafana após a configuração do Datasource apontando 
   para o bucket criado
5) Importar o JSON de template correspondente ao dashboard padrao no Grafana acessando o Grafana pelo endereço IP da VM;
6) Incluir o endereço IP do InfluxDB no backend Listener no JMeter
7) Em caso de dúvidas para criação do InfluxDb/Grafana, favor seguir o documentado neste link: https://confluence.vericode.com.br/pages/viewpage.action?pageId=13435152

    

# Definições iniciais de configuração do ambiente de testes

O DOT atualmente trabalha com uma quantidade média de configurações manuais necessárias dentro dos scripts e arquivos yaml.
As configurações mais importantes são as relacionadas com a quantidade de slaves que impactam diretamente a execução dos testes, sendo configurados
nos arquivos através do script setSlaveSize.sh numerodepods:

- startconfigs.sh
- jmeter-deploy.yaml 

Por exemplo: se quisermos rodar um teste com 10.000 VU´s no DOT, é possível rodar com 13 slaves para atingir a quantidade de VU´s especificada, com 800 VU´s
configurada no JMeter no Thread Group padrão. Portanto, devem ser configurados 800 VU´s no JMX e 13 slaves nos arquivos, totalizando 10.400 VU´s - 
ou dividir 10.000 por 13, resultando em cerca de 770 VU´s - depende da preferencia do teste.
A configuração da quantidade de pods slaves é efetuada através do arquivo setSlaveSize.sh qtde, podendo ser executada localmente caso esteja usando 
Linux ou remotamente no Google Shell.
Após configurado o JMeter + scripts de inicialização, podemos colocar os dados no GKE utilizando o git. Opcionalmente, podemos configurar os arquivos 
diretamente no Google Shell na area do GCP através do vi/vim após fazer um clone do repositorio no GCP, vai de acordo com a preferencia.
Sobre o Google Shell e acesso, pode ser utilizada uma conta comum do Google com acesso ao GCP da Vericode.


# Criação de cluster no GKE

Após todos os passos citados, devemos fazer a criação do cluster para posterior execução dos testes. Basta executar o comando:

startconfigs.sh

Ele irá provisionar o cluster conforme as configurações executadas anteriormente
Aguarde cerca de 3 minutos até o cluster estar disponível e rode o comando:

checkClusterState.sh

A saida esperada deve mostrar todos os pods com o status Running.

# Copia de massa de dados arquivos CSV para os slaves e execução do teste

Após a geração do cluster, deve ser executado o comando:

copyCSVs.sh

No qual irá dividir o(s) arquivo(s) CSV(s) de massa de dados e copiá-los para cada um dos slaves no cluster. Também é recomendado que o comando
seja executado assim que o cluster é provisionado, pois dependendo da quantidade de arquivos e/ou de pods no cluster o processo pode ser demorado.

E por fim, para executar o teste basta rodar o comando:

start_test.sh

Irá mostrar no Google Shell a execução do teste a exemplo do que acontece quando rodamos o JMeter em modo texto, sem gui. Para acompanhar os resultados,
deve ser acompanhado o Grafana criado anteriormente no servidor.
Para interromper o teste, pode ser usado o comando stopTestExecution.sh ou shutdownTestExecution.sh. Caso o teste não seja parado com os comandos,
os pods podem ser reiniciados usando o comando podsRestart.sh informando o mesmo número de slaves configurados no provisionamento.

# Inclusão de VU´s durante a execução

Para incluir mais VU´s durante a execução, pode ser provisionado um namespace/cluster adicional com as mesmas caracteristicas do cluster inicial, 
trocando o namespace, mas usando configurações distintas na quantidade de VU´s no script do Jmeter no novo namespace. Desta forma, ao executar o teste
em um novo namespace adicional com o mesmo script as VU´s utilizadas serão adicionadas ao teste e na visualização do Grafana, por exemplo:

1) Namespace teste possui 10.000 VU´s já rodando
2) Preciso adicionar mais 5.000 VU´s no teste. Deve ser ou já ter criado um namespace (cluster) adicional, por exemplo, com 10 pods slaves.
   No JMeter adicional para o cluster, devemos configurar a quantidade de VU´s com 500 users. Ao rodar o teste no novo namespace irá alimentar
   o mesmo bucket com os resultados, adicionando as VU´s "on the fly"


# Passo a passo para o provisionamento e execução do teste:

1) Criação de projeto no GCP (exemplo: viavarejo)
2) Ajustes do InfluxDB + Grafana para receber o(s) dado(s) do(s) teste(s)
3) Ajustes do Backend Listener no arquivo JMX para enviar o(s) dado(s) do(s) teste(s)
4) Clone de repositorio com os arquivos necessários na área de usuário do GCP/GKE
5) Definição de namespace e quantidade de pods slaves a serem provisionados através dos scripts changeNamespaces.sh e setSlaveSize.sh
6) Inicio de provisionamento de cluster através do script startconfigs.sh e acompanhamento da subida do cluster através do checkClusterState.sh
7) Copia da massa de dados para os slaves usando o comando copyCSVs.sh
8) Execução do teste usando start_test.sh
9) Caso seja necessário, para o teste usando os comandos stopTestExecution.sh, shutdownTestExecution.sh ou podsRestart.sh

# TODOs

A solução possui complexidade média devido a criação dos clusters para execução, sendo necessárias melhorias:

1) Criação de interface Web integrada para todo o processo;
2) Migração para AWS e Azure, possibilitando o uso de multi providers nos testes;
3) Integração do Grafana ou geração de saida customizada para a interface web;
4) Coleta de dados do InfluxDB possibilitando analises posteriores, sem dependencia do grafana;
5) Desenvolvimento de alternativa a divisão dos arquivos CSVs para ganho de performance no provisionamento do cluster;
6) Integração com serviço de autenticaçao dentro da interface web para maior segurança da ferramenta