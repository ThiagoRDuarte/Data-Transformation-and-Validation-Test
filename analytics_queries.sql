-- =========================================================
-- QUERY 1 - Crescimento percentual
-- =========================================================
WITH despesas_rank AS (
    SELECT
        cnpj,
        ano,
        trimestre,
        valor_despesas,
        ROW_NUMBER() OVER (PARTITION BY cnpj ORDER BY ano, trimestre) AS rn_inicio,
        ROW_NUMBER() OVER (PARTITION BY cnpj ORDER BY ano DESC, trimestre DESC) AS rn_fim
    FROM despesas_consolidadas
),
inicio_fim AS (
    SELECT
        i.cnpj,
        i.valor_despesas AS valor_inicio,
        f.valor_despesas AS valor_fim
    FROM despesas_rank i
    JOIN despesas_rank f
      ON i.cnpj = f.cnpj
    WHERE i.rn_inicio = 1
      AND f.rn_fim = 1
)
SELECT
    o.razao_social,
    ROUND(((valor_fim - valor_inicio) / NULLIF(valor_inicio,0)) * 100, 2) AS crescimento_percentual
FROM inicio_fim
JOIN operadoras o ON o.cnpj = inicio_fim.cnpj
ORDER BY crescimento_percentual DESC
LIMIT 5;

-- =========================================================
-- QUERY 2 - Despesas por UF
-- =========================================================
SELECT
    o.uf,
    SUM(d.valor_despesas) AS total_despesas,
    AVG(d.valor_despesas) AS media_por_operadora
FROM despesas_consolidadas d
JOIN operadoras o ON o.cnpj = d.cnpj
GROUP BY o.uf
ORDER BY total_despesas DESC
LIMIT 5;

-- =========================================================
-- QUERY 3 - Acima da média em 2 trimestres
-- =========================================================
WITH media_geral AS (
    SELECT AVG(valor_despesas) AS media FROM despesas_consolidadas
),
acima_media AS (
    SELECT
        cnpj,
        COUNT(*) AS trimestres_acima
    FROM despesas_consolidadas, media_geral
    WHERE valor_despesas > media_geral.media
    GROUP BY cnpj
)
SELECT COUNT(*) AS quantidade_operadoras
FROM acima_media
WHERE trimestres_acima >= 2;
