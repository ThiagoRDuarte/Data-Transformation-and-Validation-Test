import pandas as pd
import os

# =========================
# Configuração de diretório
# =========================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# =========================
# 1. Leitura do consolidado de despesas
# =========================
df = pd.read_csv(
    os.path.join(BASE_DIR, "consolidado_despesas.csv"),
    sep=";",
    encoding="latin1"
)

# Garantir tipo correto
df["CNPJ"] = df["CNPJ"].astype(str)

# =========================
# 2. Leitura do cadastro das operadoras (ANS)
# =========================
cadastro = pd.read_csv(
    os.path.join(BASE_DIR, "operadoras_ativas.csv"),
    sep=";",
    encoding="latin1"
)

cadastro["CNPJ"] = cadastro["CNPJ"].astype(str)
cadastro = cadastro.drop_duplicates(subset="CNPJ")

# =========================
# 3. Enriquecimento dos dados (MERGE)
# =========================
df = df.merge(
    cadastro[["CNPJ", "RazaoSocial", "RegistroANS", "Modalidade", "UF"]],
    on="CNPJ",
    how="left"
)

# DEBUG (pode remover depois)
print("Colunas após o merge:")
print(df.columns)

# =========================
# 4. Tratamento do valor da despesa
# =========================
df["ValorDespesa"] = pd.to_numeric(
    df["ValorDespesa"],
    errors="coerce"
)

# =========================
# 5. Validações exigidas pelo enunciado
# =========================

# Remover registros sem valor de despesa
df = df[df["ValorDespesa"].notna()]

# Remover registros sem Razão Social válida
df = df[
    df["RazaoSocial"].notna() &
    (df["RazaoSocial"].str.strip() != "")
]

# =========================
# 6. Consolidação (exemplo: soma por operadora)
# =========================
resultado = (
    df.groupby(
        ["CNPJ", "RazaoSocial", "RegistroANS", "Modalidade", "UF"],
        as_index=False
    )["ValorDespesa"]
    .sum()
    .rename(columns={"ValorDespesa": "TotalDespesas"})
)

# =========================
# 7. Exportação do resultado final
# =========================
resultado.to_csv(
    os.path.join(BASE_DIR, "resultado_final.csv"),
    sep=";",
    index=False,
    encoding="latin1"
)

print("Processamento concluído com sucesso!")
print("Arquivo gerado: resultado_final.csv")
