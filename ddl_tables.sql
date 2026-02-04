-- =========================================================
-- TESTE 3 - DDL
-- Banco: PostgreSQL
-- =========================================================

DROP TABLE IF EXISTS despesas_agregadas;
DROP TABLE IF EXISTS despesas_consolidadas;
DROP TABLE IF EXISTS operadoras;

-- =========================
-- Tabela: Operadoras
-- =========================
CREATE TABLE operadoras (
    cnpj VARCHAR(14) PRIMARY KEY,
    razao_social TEXT NOT NULL,
    registro_ans VARCHAR(20),
    modalidade VARCHAR(50),
    uf CHAR(2)
);

CREATE INDEX idx_operadoras_uf ON operadoras (uf);

-- =========================
-- Tabela: Despesas Consolidadas
-- =========================
CREATE TABLE despesas_consolidadas (
    id SERIAL PRIMARY KEY,
    cnpj VARCHAR(14) NOT NULL,
    valor_despesas DECIMAL(15,2) NOT NULL,
    CONSTRAINT fk_despesas_operadoras
        FOREIGN KEY (cnpj)
        REFERENCES operadoras (cnpj)
);

CREATE INDEX idx_despesas_cnpj ON despesas_consolidadas (cnpj);
CREATE INDEX idx_despesas_periodo ON despesas_consolidadas (ano, trimestre);

-- =========================
-- Tabela: Despesas Agregadas
-- =========================
CREATE TABLE despesas_agregadas (
    id SERIAL PRIMARY KEY,
    razao_social TEXT NOT NULL,
    uf CHAR(2),
    total_despesas DECIMAL(15,2),
    media_trimestral DECIMAL(15,2),
    desvio_padrao DECIMAL(15,2)
);

CREATE INDEX idx_agregadas_uf ON despesas_agregadas (uf);
