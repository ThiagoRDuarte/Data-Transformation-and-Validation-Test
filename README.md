# TRANSFORMAÇÃO E VALIDAÇÃO DE DADOS

## OBJETIVO

Implementar um pipeline de **validação, enriquecimento e agregação de dados**, utilizando Python e arquivos CSV.

O processamento parte do **CSV consolidado no Teste 1.3**.

---

## TECNOLOGIAS

* Python 3
* pandas
* Arquivos CSV
* PostGre SQL
* PSQL
* PgAdmin4

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

---

## TESTE DE BANCO E ANÁLISE

## 📌 Objetivo

Implementar um pipeline de dados capaz de:
- Modelar corretamente as entidades do domínio
- Importar arquivos CSV
- Garantir integridade referencial
- Consolidar e agregar informações financeiras
- Gerar métricas estatísticas para análise

## 🗂 Estrutura de Dados

### Tabela: `operadoras`
Armazena os dados cadastrais das operadoras.

| Campo | Tipo |
|------|-----|
| cnpj | VARCHAR(14) (PK) |
| razao_social | TEXT |
| registro_ans | VARCHAR |
| modalidade | VARCHAR |
| uf | CHAR(2) |

---

### Tabela: `despesas_consolidadas`
Armazena as despesas financeiras associadas às operadoras.

| Campo | Tipo |
|------|-----|
| id | SERIAL (PK) |
| cnpj | VARCHAR(14) (FK) |
| ano | INTEGER |
| trimestre | INTEGER |
| valor_despesas | DECIMAL |

---

### Tabela: `despesas_agregadas`
Tabela analítica gerada a partir da consolidação dos dados.

| Campo | Tipo |
|------|-----|
| id | SERIAL (PK) |
| razao_social | TEXT |
| uf | CHAR(2) |
| total_despesas | DECIMAL |
| media_trimestral | DECIMAL |
| desvio_padrao | DECIMAL |

---

## 🔄 Pipeline de Processamento (ETL)

1. **Criação das tabelas (DDL)**
2. **Carga dos CSVs**
   - Uso de `\copy` para importação
   - Delimitador `;`
3. **Staging**
   - Utilização de tabela temporária para validação e conversão de dados
4. **Transformação**
   - Conversão de tipos
   - Validação de chaves estrangeiras
5. **Agregação**
   - JOIN entre operadoras e despesas
   - Cálculo de soma, média e desvio padrão
6. **Persistência**
   - Inserção final na tabela `despesas_agregadas`

---

## ⚖️ Trade-offs Técnicos

### 1️⃣ Uso de tabela temporária (TEMP TABLE)

**Decisão:** Utilizar tabela temporária como staging antes da inserção definitiva.

**Vantagens:**
- Permite validação e tratamento de dados antes da persistência
- Evita corromper tabelas finais com dados inconsistentes
- Simula um pipeline de ETL real

**Desvantagens:**
- Escopo limitado à sessão
- Exige execução do processo em uma única conexão

**Justificativa:**  
Foi escolhida por refletir boas práticas de ETL e controle de qualidade de dados.

---

### 2️⃣ Integridade referencial via Foreign Key

**Decisão:** Manter `FOREIGN KEY` entre `despesas_consolidadas` e `operadoras`.

**Vantagens:**
- Garante consistência entre despesas e operadoras
- Evita registros órfãos
- Facilita validação automática pelo banco

**Desvantagens:**
- Pode bloquear inserções caso existam inconsistências no CSV
- Requer ordem correta de carga

**Justificativa:**  
A integridade dos dados foi priorizada em detrimento da flexibilidade de carga.

---

### 3️⃣ Agregação pré-calculada em tabela física

**Decisão:** Persistir os dados agregados em `despesas_agregadas`.

**Vantagens:**
- Consultas analíticas mais rápidas
- Redução de custo computacional em leituras frequentes
- Facilita consumo por BI ou relatórios

**Desvantagens:**
- Dados precisam ser recalculados em novas cargas
- Possível redundância de informação

**Justificativa:**  
Adequado para cenários de leitura intensiva e análise estatística.

---

### 4️⃣ Uso de `\copy` ao invés de `COPY`

**Decisão:** Utilizar `\copy` via `psql`.

**Vantagens:**
- Não requer permissões elevadas no servidor
- Permite leitura de arquivos locais
- Mais simples em ambientes de desenvolvimento

**Desvantagens:**
- Dependente do cliente
- Menor controle sobre execução em ambientes distribuídos

**Justificativa:**  
Escolha alinhada ao contexto de execução local do teste técnico.

---

## 📊 Query de Geração das Despesas Agregadas

```sql
INSERT INTO despesas_agregadas (
    razao_social,
    uf,
    total_despesas,
    media_trimestral,
    desvio_padrao
)
SELECT
    o.razao_social,
    o.uf,
    SUM(d.valor_despesas),
    AVG(d.valor_despesas),
    STDDEV(d.valor_despesas)
FROM despesas_consolidadas d
JOIN operadoras o
    ON o.cnpj = d.cnpj
GROUP BY
    o.razao_social,
    o.uf;

---

## AUTOR
Thiago Ramos
Estudante de Ciencia da Computação - Unip.
