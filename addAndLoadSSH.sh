#!/bin/bash

# Sobe o servico ssh-agent e adiciona a chave via ssh-add, necessario apenas para o GKE:
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa
