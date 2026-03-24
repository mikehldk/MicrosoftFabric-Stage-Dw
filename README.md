# Microsoft Fabric: Arquitetura Stage + DW com T-SQL

> Repositório de apoio ao vídeo publicado no YouTube.  
> Demonstração completa de uma arquitetura **Stage → Data Warehouse** usando **Microsoft Fabric Warehouse** e **T-SQL puro**, sem Spark, sem Notebook.

---

## 📐 Arquitetura

O fluxo cobre três etapas principais:

1. **OLTP → Stage** - cópia dos dados brutos via Copy Data Activity no Pipeline
2. **Stage → DW** - transformação e carga via Stored Procedures T-SQL
3. **Orquestração** - Pipeline único encadeando ingestão + carga do DW

### Por que Stage + DW antes do Medallion?

A arquitetura Stage/DW é a linguagem que profissionais vindos do mundo SQL Server já conhecem. É um ponto de entrada mais direto para quem está chegando ao Fabric, sem precisar aprender Spark, Delta Lake ou PySpark antes de entregar valor.

---

## 🗂️ Estrutura do Repositório

```
MicrosoftFabric-Stage-Dw/
├── assets/          # prints e diagramas do vídeo
├── dados/           # CSVs com dados fictícios para carga no SQL Database
├── sql/             # scripts DDL, views e stored procedures
└── pipeline/        # fragmentos JSON de configuração do Pipeline
```

---

## ⚙️ Pré-requisitos

| Item | Detalhe |
|---|---|
| Microsoft Fabric | Capacidade F2 ou superior (ou Trial) |
| SQL Database | Azure SQL Database ou SQL Server On-Premise com gateway |
| Permissões | Admin do Workspace + acesso ao SQL Database de origem |

---

## 🚀 Passo a Passo

### 1. Preparar o ambiente

1. Criar o **Workspace** no Fabric e atribuir a capacidade do Azure
2. Criar dois **Warehouses** dentro do Workspace:
   - `Stage` - espelho raw da fonte
   - `DW` - modelo estrela com dimensões e fatos

### 2. Carregar os dados no SQL Database de origem

Importe os CSVs da pasta `/dados` para o seu SQL Database de origem. Eles simulam um sistema OLTP com dados brutos, incluindo variações de formato de data e campos com case misto intencionais para demonstrar a necessidade da camada de tratamento.

| Arquivo | Tabela | Linhas |
|---|---|---|
| `tbCliente.csv` | tbCliente | 100 |
| `tbProduto.csv` | tbProduto | 35 |
| `tbVendas.csv` | tbVendas | ~1,44 M |
| `tbItensVendas.csv` | tbItensVendas | ~2,09 M |

### 3. Criar as tabelas no DW

Execute o script `sql/01_ddl_dw.sql` no Warehouse `Dw`.

Modelo estrela criado:

```
DimData
DimCliente
DimProduto
DimCanal
FatoVenda
```

### 4. Ingestão OLTP → Stage (Copy Data Activity)

A cópia é feita via **Copy Data Activity** dentro de um Pipeline.

**Fragmento JSON do mapeamento adicional** (arquivo `pipeline/copy-data.json`):

```json
[
    {"src_schema":"vendas", "src_table":"tbProduto",        "dst_schema":"vendas",  "dst_table":"tbProduto"},
    {"src_schema":"vendas", "src_table":"tbVendas",         "dst_schema":"vendas",  "dst_table":"tbVendas"},
    {"src_schema":"vendas", "src_table":"tbItensVendas",    "dst_schema":"vendas",  "dst_table":"tbItensVendas"}
]
```

![Configuração do mapeamento no Copy Data](assets/copy-data-mapping.png)


### 5. Views de tratamento no DW

Antes de executar as procedures de carga, criamos views no Warehouse `Dw` que leem as tabelas da Stage via cross-warehouse query e encapsulam todo o tratamento: normalização de case, padronização de datas e tratamento de nulos.

> **Por que views no DW e não direto na procedure?**  
> As views isolam a lógica de limpeza, deixando as procedures de carga mais simples e legíveis. Qualquer ajuste de tratamento é feito em um único lugar. Como ficam no DW, as procedures já as consomem diretamente sem precisar referenciar a Stage a cada execução.

Execute o script `sql/02_views_dw.sql` **no Warehouse `Dw`**. Ele cria:

**`vw_tbCliente`** - padroniza case e datas  
**`vw_tbProduto`** - padroniza case e datas  
**`vw_tbVenda`** - padroniza case e datas

```sql
CASE
    WHEN LEN(dtVenda) = 10 AND SUBSTRING(dtVenda,5,1) = '-'
        THEN CONVERT(DATE, dtVenda, 120)
    WHEN LEN(dtVenda) = 10 AND SUBSTRING(dtVenda,3,1) = '/'
        THEN CONVERT(DATE,
            SUBSTRING(dtVenda,7,4)+'-'+SUBSTRING(dtVenda,4,2)+'-'+SUBSTRING(dtVenda,1,2), 120)
    WHEN LEN(dtVenda) = 10 AND SUBSTRING(dtVenda,3,1) = '-'
        THEN CONVERT(DATE,
            SUBSTRING(dtVenda,7,4)+'-'+SUBSTRING(dtVenda,4,2)+'-'+SUBSTRING(dtVenda,1,2), 120)
    WHEN LEN(dtVenda) = 8 AND ISNUMERIC(dtVenda) = 1
        THEN CONVERT(DATE,
            SUBSTRING(dtVenda,1,4)+'-'+SUBSTRING(dtVenda,5,2)+'-'+SUBSTRING(dtVenda,7,2), 120)
    ELSE NULL
END AS dtVenda
```

### 6. Stored Procedures - carga do DW

Execute os scripts na ordem abaixo no Warehouse `Dw`:

| Ordem | Script | Procedure | O que faz |
|---|---|---|---|
| 1 | `03_proc_dim_data.sql` | `sp_carga_DimData` | Gera calendário 2022–2026 |
| 2 | `04_proc_dim_canal.sql` | `sp_carga_DimCanal` | Deriva canais da tbVendas da Stage |
| 3 | `05_proc_dim_cliente.sql` | `sp_carga_DimCliente` | MERGE com SCD Type 1 |
| 4 | `06_proc_dim_produto.sql` | `sp_carga_DimProduto` | MERGE com SCD Type 1 |
| 5 | `07_proc_fato_venda.sql` | `sp_carga_FatoVenda` | JOIN Stage + LOOKUP Dims |
| 6 | `08_sp_carga_Full.sql` | `sp_carga_full` | Chama tudo na ordem certa |
| 6 | `09_sp_carga_Incremental.sql` | `sp_carga_incremental` | Versão incremental (7 dias) |

Cada procedure aceita `@modo = 'FULL'` ou `@modo = 'INCR'`.

### 7. Pipeline de orquestração

O mesmo Pipeline que faz a ingestão OLTP → Stage é estendido com um **Execute Stored Procedure** apontando para `sp_carga_Full` ou `sp_carga_Incremental`.

Fluxo final do Pipeline:

```
[Copy Data: tbCliente]   ──┐
[Copy Data: tbProduto]   ──┤
[Copy Data: tbVendas]    ──┼──► (On Success) ──► [Execute SP: usp_carga_full]
[Copy Data: tbItensVendas] ┘
```

---

## 💡 Decisões de arquitetura comentadas

**Stage com tudo VARCHAR**  
A camada Stage é um espelho fiel da fonte. Usar `VARCHAR` em tudo garante que nenhuma linha seja rejeitada por incompatibilidade de tipo. A conversão acontece nas views e procedures.

**Views antes das procedures**  
Isola a lógica de limpeza (case, datas, nulos) das procedures de carga. Facilita manutenção e reaproveitamento.
---

## 📺 Vídeo

> 🔗 https://youtu.be/KIuoOvZLU2A

---

## 📁 Scripts SQL

| Arquivo | Conteúdo |
|---|---|
| `01_ddl_dw.sql` | CREATE TABLE das Dims e Fato |
| `02_views_stage.sql` | vw_tbCliente, vw_tbProduto, vw_tbVenda |
| `03_proc_dim_data.sql` | sp_carga_DimData |
| `04_proc_dim_canal.sql` | sp_carga_DimCanal |
| `05_proc_dim_cliente.sql` | sp_carga_DimCliente |
| `06_proc_dim_produto.sql` | sp_carga_DimProduto |
| `07_proc_fato_venda.sql` | sp_carga_FatoVenda |
| `08_sp_carga_Full.sql` | sp_carga_full |
| `09_sp_carga_Incremental.sql` | sp_carga_full |

---

## ⚠️ Observações

- Os dados dos CSVs são **fictícios**, gerados para fins didáticos
- Os nomes de produtos e categorias são inspirados no segmento de eletrodomésticos mas não representam dados reais
- Testado em capacidade **F2**, adequado para demonstração e cargas de até ~2M registros

---

*Dúvidas ou sugestões? Abre uma [issue](../../issues) ou comenta no vídeo!*

