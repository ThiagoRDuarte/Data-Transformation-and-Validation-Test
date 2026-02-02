import pandas as pd
import re
import numpy as np

# ==========================
# Função de validação de CNPJ
# ==========================
def validar_cnpj(cnpj):
    cnpj = re.sub(r'\D', '', str(cnpj))

    if len(cnpj) != 14 or cnpj == cnpj[0] * 14:
        return False

    def calcula_digito(cnpj, pesos):
        soma = sum(int(d) * p for d, p in zip(cnpj, pesos))
        resto = soma % 11
        return 0 if resto < 2 else 11 - resto

    digito1 = calcula_digito(cnpj[:12], [5,4,3,2,9,8,7,6,5,4,3,2])
    digito2 = calcula_digito(cnpj[:13], [6,5,4,3,2,9,8,7,6,5,4,3,2])

    return cnpj[-2:] == f"{digito1}{digito2}"

# ==========================
# 1. Leitura do CSV consolidado
# ==========================
df = pd.read_csv("consolidado_despesas.csv")

df["CNPJ"] = df["CNPJ"].astype(str)
df["ValorDespesas"] = pd.to_numeric(df["ValorDespesas"], errors="coerce")

# ==========================
# 2. Validações de dados
# ==========================
df = df[df["CNPJ"].apply(validar_cnpj)]
df = df[df["ValorDespesas"] > 0]
df = df[df["RazaoSocial"].notna() & (df["RazaoSocial"].str.strip() != "")]

# ==========================
# 3. Leitura dos dados cadastrais
# ==========================
cadastro = pd.read_csv(
    "operadoras_ativas.csv",
    sep=";",
    encoding="latin1"
)

cadastro["CNPJ"] = cadastro["CNPJ"].astype(str)

# Remove duplicidades mantendo o primeiro registro
cadastro = cadastro.drop_duplicates(subset="CNPJ")

# ==========================
