# TRANSFORMAÇÃO E VALIDAÇÃO DE DADOS

## OBJETIVO

Implementar um pipeline de **validação, enriquecimento e agregação de dados**, utilizando Python e arquivos CSV.

O processamento parte do **CSV consolidado no Teste 1.3**.

---

## TECNOLOGIAS

* Python 3
* pandas
* Arquivos CSV

---

## 2.1 VALIDAÇÃO DE DADOS

### Validações aplicadas

* **CNPJ**: limpeza, verificação de tamanho e validação dos dígitos verificadores
* **Valores numéricos**: conversão para numérico e remoção de valores nulos ou negativos
* **RazaoSocial**: remoção de registros nulos, vazios ou em branco

### Trade-off — CNPJs inválidos

**Estratégia adotada:** descarte dos registros

**Justificativa:**
O CNPJ é a chave de integração entre os datasets. Manter CNPJs inválidos compromete joins, agregações e a consistência do resultado final.

---

## 2.2 ENRIQUECIMENTO DE DADOS

### Fonte externa

Dados cadastrais das operadoras ativas (ANS):
[https://dadosabertos.ans.gov.br/FTP/PDA/operadoras_de_plano_de_saude_ativas/](https://dadosabertos.ans.gov.br/FTP/PDA/operadoras_de_plano_de_saude_ativas/)

### Estratégia de join

* Tipo: **LEFT JOIN**
* Chave: **CNPJ**
* Colunas adicionadas:

  * RegistroANS
  * Modalidade
  * UF

### Tratamento de inconsistências

* **Sem match no cadastro**: registros mantidos, colunas enriquecidas nulas
* **CNPJs duplicados no cadastro**: deduplicação mantendo o primeiro registro

### Trade-off — Processamento

**Estratégia adotada:** processamento em memória

**Justificativa:** volume de dados compatível, melhor desempenho e código mais simples.

---

## 2.3 AGREGAÇÃO DE DADOS

### Agrupamento

* RazaoSocial
* UF

### Métricas calculadas

* Total de despesas
* Média de despesas por trimestre
* Desvio padrão das despesas

### Trade-off — Ordenação

**Estratégia adotada:** ordenação em memória

**Justificativa:** dados de volume moderado e uso de algoritmos otimizados do pandas.

---

## RESULTADO

A solução atende integralmente ao enunciado, com foco em **qualidade dos dados**, **consistência** e **clareza técnica**, documentando explicitamente todas as decisões e trade-offs exigidos pelo teste.

## AUTOR
Thiago Ramos
Estudante de Ciencia da Computação - Unip.
