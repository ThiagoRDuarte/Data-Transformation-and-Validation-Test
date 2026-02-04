-- =========================================================
-- TESTE 3 - Importação de Dados (compatível com pgAdmin)
-- Banco: PostgreSQL
-- =========================================================

-- =========================
-- Tabela temporária - Operadoras
-- =========================
CREATE TEMP TABLE operadoras_temp (
    cnpj TEXT,
    razao_social TEXT,
    registro_ans TEXT,
    modalidade TEXT,
    uf TEXT
);

INSERT INTO operadoras (cnpj, razao_social, registro_ans, modalidade, uf)
SELECT
    TRIM(cnpj),
    razao_social,
    registro_ans,
    modalidade,
    uf
FROM operadoras_temp
WHERE cnpj IS NOT NULL AND cnpj <> '';

-- =========================
-- Tabela temporária - Despesas
-- =========================
CREATE TEMP TABLE despesas_temp (
    cnpj TEXT,
    valor_despesas TEXT
);

INSERT INTO despesas_consolidadas (cnpj, valor_despesas)
SELECT
    TRIM(cnpj),
    REPLACE(valor_despesas, ',', '.')::DECIMAL(15,2)
FROM despesas_temp
WHERE valor_despesas ~ '^[0-9,]+$';

-- =========================
-- Tabela temporária - Agregados
-- =========================
DROP TABLE IF EXISTS agregadas_temp;

CREATE TEMP TABLE agregadas_temp (
    razao_social TEXT,
    uf TEXT,
    total_despesas TEXT,
    media_trimestral TEXT,
    desvio_padrao TEXT
);


INSERT INTO despesas_agregadas (razao_social, uf, total_despesas, media_trimestral, desvio_padrao)
SELECT
    razao_social,
    uf,
    REPLACE(total_despesas, ',', '.')::DECIMAL(15,2),
    REPLACE(media_trimestral, ',', '.')::DECIMAL(15,2),
    REPLACE(desvio_padrao, ',', '.')::DECIMAL(15,2)
FROM agregadas_temp
WHERE total_despesas ~ '^[0-9,]+$';
