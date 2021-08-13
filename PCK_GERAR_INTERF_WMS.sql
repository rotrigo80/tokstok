CREATE OR REPLACE PACKAGE GC.PCK_GERAR_INTERF_WMS AS
   -- TESTE DIFF GIT BASH
   -- TESTE GIT DIFF
   --
   -- ALTERAÇÃO SINCRONIZADA
   --
   -- AGORA FOI EU QUE ALTEREI AS 18:24
   --
   --
   -- ARQUIVO...: PCK_GERAR_INTERF_WMS.SQL
   -- OBJETIVO..:
   -- AUTOR/DATA: Helena 27/05/2020
   -- ALTERACOES: 01/08/2020 - Implementa��o das procedures de gera��o das informa��es dos Pedidos nas INT_E_CAB_PEDIDO e INT_E_DET_PEDIDO
   --                          no momento da gera��o do romaneio
   --
   -- Pacote de procedures que ir�o popular as tabelas de Interfaces para envio das informa��es do GC para o WMS
   --
   D_SQLERRM GC.GC_MSG.TX_OCOR%TYPE;
   D_ID_MSG  GC.GC_MSG.ID_MSG%TYPE;
   P_MSG     GC.GC_MSG%ROWTYPE;
   --
   -- Dados da Produto no WMS --
   PROCEDURE PR_GRV_PRODUTO(P_ID_PROD IN GC.PRODUTO.ID_PROD%TYPE);
   --
   -- Dados de C�digo de Barra do Produto no WMS --
   PROCEDURE PR_GRV_BARRA_PROD(P_ID_PROD IN GC.PRODUTO.ID_PROD%TYPE,
                               P_TP_PROD IN VARCHAR2,
                               P_NU_SEQ  IN NUMBER);
   --
   -- Dados de Cliente no WMS --
   PROCEDURE PR_GRV_CLIENTE(P_ID_CLIENTE IN GC.PESSOA.ID_PESSOA%TYPE,
                            P_CD_DEP_WMS IN VARCHAR2);

   --
   -- Dados de Fornecedor no WMS --
   PROCEDURE PR_GRV_FORNECEDOR(P_ID_FORNEC  IN GC.PESSOA.ID_PESSOA%TYPE,
                               P_CD_DEP_WMS IN VARCHAR2);
   --
   -- Dados de Transportadora no WMS --
   PROCEDURE PR_GRV_TRANSP(P_ID_TRANSP  IN GC.PESSOA.ID_PESSOA%TYPE,
                           P_CD_DEP_WMS IN VARCHAR2);
   --
   -- Dados da Nota Fiscal no WMS --
   -- Se NFT ou NFS - desce pela GUIA/placa para buscar as NF da Guia liberada
   -- Se NFE - passa somente a placa
   PROCEDURE PR_GRV_CAB_NOTA_FISCAL(P_DS_PLACA    IN NF_TERCEIRO.DS_PLACA%TYPE,
                                    P_ID_GUIA_LIB IN NF_TERCEIRO.ID_GUIA_LIB_GLB%TYPE,
                                    P_DT_INIC     IN NF_TERCEIRO.DT_INIC_DES%TYPE,
                                    P_ID_AUTORIZA IN VARCHAR2);
   --
   -- Dados dos Itens da Nota Fiscal no WMS --
   PROCEDURE PR_GRV_DET_NOTA_FISCAL(P_TP_NF     IN VARCHAR2,
                                    P_CD_FIL_NF IN GC.FILIAL.CD_FIL%TYPE,
                                    P_REC_CABNF IN WMS.INT_E_CAB_NOTA_FISCAL%ROWTYPE);
   --
   -- Processo chamado das telas/processo de libera��o Romaneio que aciona as procedures popular
   --   as interfaces de INT_E de PEDIDO_SAIDA de acordo com o tipo de romaneio
   --   P_FIL_ROMANEIO/P_NR_ROMANEIO/P_DT_ROMANEIO - Dados do Romaneio
   --   P_TP_ROMANEIO - PDS / GUIA / REQ / POS / RUC
   --   P_TP_AGRUPA / NR_AGRUPA - casos de agrupamento (PDS/GUIA/REQ) - informa o Tipo e o Cod. do Agrupador
   --   P_CD_SITUACAO - 1 - Insere Pedido Saida WMS / 2 - Faturamento Pedido Saida / 3 - Cancela Pedido Saida WMS / 4 - Cancela NF
   --
   PROCEDURE PR_LIBERA_PEDIDO_SAIDA(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                                    P_TP_ROMANEIO  IN ROMANEIO_SEPARACAO.SG_REQUERENTE_RSD%TYPE,
                                    P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                                    P_DT_ROMANEIO  IN ROMANEIO_SEPARACAO.DT_GERA%TYPE,
                                    P_TP_AGRUPA    IN VARCHAR2,
                                    P_NR_AGRUPA    IN NUMBER,
                                    P_CD_SITUACAO  IN NUMBER);
   -- busca Nome e CPF/CGC da pessoa
   PROCEDURE PR_BUSCA_DADOS_PESSOA(P_ID_PESSOA  IN PESSOA.ID_PESSOA%TYPE,
                                   P_NM_PESSOA  OUT PESSOA.NM_PESSOA%TYPE,
                                   P_ID_CPF_CGC OUT PESSOA.ID_CGC%TYPE,
                                   P_CD_FIL_TOK OUT PESSOA.CD_FIL_TOK%TYPE);
   -- Procedure acionada por PR_LIBERA_SEPARACAO, para buscar os dados dos PDS e gerar o PEDIDO_SAIDA para o WMS
   PROCEDURE PR_PEDIDO_PDS(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                           P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                           P_TP_AGRUPA    IN VARCHAR2,
                           P_NR_AGRUPA    IN NUMBER,
                           P_CD_SITUACAO  IN NUMBER);
   -- Procedure acionada por PR_LIBERA_SEPARACAO, para buscar os dados da Guia liberada e gerar o PEDIDO_SAIDA para o WMS
   PROCEDURE PR_PEDIDO_GUIA(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                            P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                            P_TP_AGRUPA    IN VARCHAR2,
                            P_NR_AGRUPA    IN NUMBER,
                            P_CD_SITUACAO  IN NUMBER);
   -- Procedure acionada por PR_LIBERA_SEPARACAO, para buscar os dados das Requisi��es de Abastecimento Loja / Pedidos Retira Loja
   -- e gerar o PEDIDO_SAIDA para o WMS (Acess�rios e Moveis)
   PROCEDURE PR_PEDIDO_REQ(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                           P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                           P_TP_AGRUPA    IN VARCHAR2,
                           P_NR_AGRUPA    IN NUMBER,
                           P_CD_SITUACAO  IN NUMBER);
   -- Procedure acionada por PR_LIBERA_SEPARACAO, para buscar os dados das POS GERADAS - Requisi��es Interna entre Filiais e Outros
   -- e gerar o PEDIDO_SAIDA para o WMS
   PROCEDURE PR_PEDIDO_POS(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                           P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                           P_TP_AGRUPA    IN VARCHAR2,
                           P_NR_AGRUPA    IN NUMBER,
                           P_CD_SITUACAO  IN NUMBER);
   -- Procedure acionada por PR_LIBERA_SEPARACAO, para buscar os dados da RUC e gerar o PEDIDO_SAIDA para o WMS
   PROCEDURE PR_PEDIDO_RUC(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                           P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                           P_DT_ROMANEIO  IN ROMANEIO_SEPARACAO.DT_GERA%TYPE,
                           P_CD_SITUACAO  IN NUMBER);
   -- Dados de Ajustes de Estoque - Movimenta��es Internas Dep�sito - WMS --
   PROCEDURE PR_GRV_AJUSTE_ESTQ(P_NR_REQ      IN ITEM_REQ_INTERNA.NR_REQ%TYPE,
                                P_AB_REQ      IN ITEM_REQ_INTERNA.AB_REQ%TYPE,
                                P_CD_CCO      IN ITEM_REQ_INTERNA.CD_CCO%TYPE,
                                P_CD_FIL      IN ITEM_REQ_INTERNA.CD_FIL%TYPE,
                                P_ID_ROM      IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                                P_AREA_ORIG   IN VARCHAR2,
                                P_AREA_DEST   IN VARCHAR2,
                                P_CD_SITUACAO IN NUMBER);
   -- Dados de Transportadora Rota no WMS -- falta definir a informa��o que ser� repassada ao WMS
   PROCEDURE PR_GRV_TRANSP_ROTA(P_CD_ROTA IN FRETE_REGRA_ORIGEM_DESTINO.ID_FROD%TYPE);
   /*
      --
      -- Dados de Embalagem no WMS --
      PROCEDURE PR_GRV_EMBALAGEM;
      --
      -- Dados de Alterados do Pedido Sa�da no WMS --
      PROCEDURE PR_GRV_ALTERA_DADOS_PEDIDO;
      --
   */
   -- Dados de Solicita��o LGPD - Lei Geral de Prote��o de Dados - para o WMS --
   PROCEDURE PR_GRV_LGPD(P_CNPJ_CPF IN PESSOA.ID_CPF%TYPE);
   --

   -- Procedures que inserem registros nas tabelas de Interface do owner WMS --
   PROCEDURE PR_INS_PRODUTO(P_REC_PROD IN OUT WMS.INT_E_PRODUTO%ROWTYPE);
   --
   PROCEDURE PR_INS_COD_BARRA(P_REC_BARRA IN WMS.INT_E_CODIGO_BARRA%ROWTYPE);
   --
   PROCEDURE PR_INS_CLIENTE(P_REC_CLIENTE IN WMS.INT_E_CLIENTE%ROWTYPE);
   --
   PROCEDURE PR_INS_FORNEC(P_REC_FORNEC IN WMS.INT_E_FORNECEDOR%ROWTYPE);
   --
   PROCEDURE PR_INS_TRANSP(P_REC_TRANSP IN WMS.INT_E_TRANSPORTADORA%ROWTYPE);
   --
   PROCEDURE PR_INS_CAB_NOTA_FISCAL(P_REC_CABNF IN OUT WMS.INT_E_CAB_NOTA_FISCAL%ROWTYPE);
   --
   PROCEDURE PR_INS_DET_NOTA_FISCAL(P_REC_DETNF IN WMS.INT_E_DET_NOTA_FISCAL%ROWTYPE);
   -- Insere NF da GUIA/Placa enviadas ao WMS para recebimento - para controle do retorno
   PROCEDURE PR_INS_CTR_NF_RECEB(P_TP_NF       IN VARCHAR2,
                                 P_ID_LOCAL    IN NUMBER,
                                 P_CD_FIL_ESTQ IN NUMBER,
                                 P_DT_INIC     IN DATE,
                                 P_REC_CABNF   IN WMS.INT_E_CAB_NOTA_FISCAL%ROWTYPE);
   --
   PROCEDURE PR_INS_CAB_PEDIDO_SAIDA(P_REC_CPS IN OUT WMS.INT_E_CAB_PEDIDO_SAIDA%ROWTYPE);
   --
   PROCEDURE PR_INS_DET_PEDIDO_SAIDA(P_REC_DPS IN WMS.INT_E_DET_PEDIDO_SAIDA%ROWTYPE);
   --
   PROCEDURE PR_INS_AJUSTE_ESTOQUE(P_REC_AJUSTE_ESTQ IN WMS.INT_E_AJUSTE_ESTOQUE%ROWTYPE);
   --
   PROCEDURE PR_INS_ALTERA_PEDIDO(P_REC_ALTPED IN WMS.INT_E_ALTERA_DADOS_PEDIDO%ROWTYPE);
   --
   PROCEDURE PR_INS_TRANSP_ROTA(P_REC_TRANSP_ROTA IN WMS.INT_E_TRANSPORTADORA_ROTA%ROWTYPE);
   --
END PCK_GERAR_INTERF_WMS;
/
CREATE OR REPLACE PACKAGE BODY GC.PCK_GERAR_INTERF_WMS AS
   --
   -- ARQUIVO...: PCK_GERAR_INTERF_WMS.SQL
   -- OBJETIVO..: Pacote de procedures que ir�o popular as tabelas de Interfaces para envio das informa��es do GC para o WMS
   -- AUTOR/DATA: Helena 27/05/2020
   -- ALTERACOES: 01/08/2020 - Implementa��o das procedures de gera��o das informa��es dos Pedidos nas INT_E_CAB_PEDIDO e INT_E_DET_PEDIDO
   --                          no momento da gera��o do romaneio
   --             17/12/2020 - Inclus�o da regi�o concatenada a DS_PROGRAM_DIARIA_SERVICO]
   --
   --             31/03/2021 - LBUENO - Inclus�o do campo ID_FROD para popular o campo CD_ROTA.(LOG-520)
   --
   -- Cada registro gerado nas tabelas de interface para Envio - INT_E deve ser gerado sequencia do campo NU_SEQ
   -- obte-lo pela function WMS.PCK_GERAR_INTERF_WMS.FC_SEQ_ENTRADA
   --
   -- Dados da Produto no WMS --
   PROCEDURE PR_GRV_PRODUTO(P_ID_PROD IN GC.PRODUTO.ID_PROD%TYPE) IS
      -- Declara rowtype para insert
      P_REC_PROD WMS.INT_E_PRODUTO%ROWTYPE;
      -- Busca os dados do Produto master - Mono e Multi-Embalagem (KIT)
      CURSOR C_PROD IS
         SELECT 1 CD_EMPRESA,
                '001' CD_DEPOSITO,
                TO_CHAR(P.ID_PROD) CD_PRODUTO,
                DP.NM_PROD DS_PRODUTO,
                DP.CD_ALFA DS_REDUZIDA,
                DP.IN_UNID_MEDIDA CD_UNIDADE_MEDIDA,
                DP.IN_UNID_MEDIDA DS_UNIDADE_MEDIDA,
                'N' ID_ACEITA_DECIMAL,
                'NC' CD_EMBALAGEM,
                'N�O CADASTRADO' DS_EMBALAGEM,
                -- LOG-348 - Troca do campo de Acondicionamento na interface
                1  QT_UNI_EMBALAGEM, -- QTDE DE UNID. POR embalagem
                NVL(DPUE.QT_ACOND, 1) DS_ESPECIFICACAO,
                P.ID_PROD CD_PRODUTO_MASTER, -- SE IGUAL CD_produto - mono sen�o multi embalagem
                1 QT_ITENS,
                DP.CD_GEP CD_FAMILIA,
                SUBSTR(GE.DS_GEP, 1, 60) DS_FAMILIA,
                -- 05/11/2020 - busca dimens�o - n�o considerar o produto montado - so caso n�o exista informa��o do Unitario
                DECODE(NVL(DPUE_U.MD_ALT,0), 0, DP.MD_ALT_MONT_MIN, DPUE_U.MD_ALT) VL_ALTURA,
                DECODE(NVL(DPUE_U.MD_LARG,0), 0, DP.MD_LARG_MONT_MIN, DPUE_U.MD_LARG) VL_LARGURA,
                DECODE(NVL(DPUE_U.MD_PROF,0), 0, DP.MD_PROF_MONT_MIN, DPUE_U.MD_PROF) VL_PROFUNDIDADE,
                DECODE(NVL(DPUE_U.MD_PESO,0), 0, DP.MD_PESO, DPUE_U.MD_PESO) PS_LIQUIDO,
                DECODE(NVL(DPUE_U.MD_PESO,0), 0, DP.MD_PESO, DPUE_U.MD_PESO) PS_BRUTO,
                NULL QT_MAX_PALETE,
                15 CD_SITUACAO,
                --NVL(DP.CD_DIV || LPAD(DP.CD_GEP, 4, '0'),'NC') CD_CLASSE, -- SETOR DO PRODUTO
                NVL(DPC.CD_CLASSE, 'NC') CD_CLASSE, -- SETOR DO PRODUTO
                --SUBSTR(GE.DS_GEP, 1, 35) DS_CLASSE,
                SUBSTR(DPC.DS_CLASSE, 1, 35) DS_CLASSE,
                NULL QT_DIAS_VALIDADE,
                NULL QT_DIAS_REMONTE,
                'N' ID_CONTROLE_LOTE,
                'N' ID_CONTROLE_SERIE,
                'N' ID_CONTROLE_VALIDADE,
                1 QT_CAIXA_FECHADA,
                NULL CD_FORNECEDOR,
                NULL CD_CNPJ_FORNECEDOR,
                P.CD_NUM CD_PRODUTO_FORNECEDOR,
                DP.CD_DIV CD_LINHA,
                SUBSTR(D.NM_DIV, 1, 60) DS_LINHA,
                DP.CD_FAM CD_GRUPO,
                SUBSTR(F.NM_FAM, 1, 60) DS_GRUPO,
                'NC' CD_SUBGRUPO,
                'N�O CADASTRADO' DS_SUBGRUPO,
                'NC' CD_MODELO,
                'N�O CADASTRADO' DS_MODELO,
                --NULL TP_ARMAZENAGEM_PRODUTO,
                /*Caso o dt_inval seja nulo, pego o maior nr_tot, se n�o significa que o produto e embalagem unica*/
                (SELECT DECODE(MAX(NVL(DECODE(CPM.DT_INVAL,NULL,CPM.NR_TOT,1), 1)), 1, 'P', 'C')
                   FROM PRODUTO            PRD,
                        MULTIPLA_EMBALAGEM CPM
                  WHERE PRD.ID_PROD = P.ID_PROD
                    AND PRD.ID_PROD = CPM.ID_PROD(+)) TP_ARMAZENAGEM_PRODUTO,
                NULL CD_DEPARTAMENTO,
                NULL DS_DEPARTAMENTO,
                NULL FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5,
                NULL QT_PERC_PROD_DIAS_EXPEDICAO,
                SUBSTR(COR.DS_COR, 1, 40) DS_COR_PRODUTO,
                NULL NM_ARQUIVO_IMAGEM,
                NULL DS_EXTENSAO_ARQUIVO_IMAGEM,
                NULL DS_TAMANHO_PRODUTO,
                NULL CD_PRODUTO_REFERENCIA,
                'N' ID_PRODUTO_GRADE,
                --NULL TP_PRODUTO, -- NO JSON S� ENVIA QDO KIT
                /*Caso o dt_inval seja nulo, pego o maior nr_tot, se n�o significa que o produto e embalagem unica*/
                (SELECT DECODE(MAX(NVL(DECODE(CPM.DT_INVAL,NULL,CPM.NR_TOT,1), 1)), 1, 'P', 'K')
                   FROM PRODUTO            PRD,
                        MULTIPLA_EMBALAGEM CPM
                  WHERE PRD.ID_PROD = P.ID_PROD
                    AND PRD.ID_PROD = CPM.ID_PROD(+)) TP_PRODUTO, -- Para identif. se Master ou Componente KIT
                NULL QT_FATOR_CONVERSAO_SORTER,
                NULL TP_UNIDADE_LOGISTICA_SORTER,
                'NC' CD_EMBALAGE_EXPEDICAO,
                'N' ID_CX_FECHADA_VOLUME_PRONTO,
                'N' ID_CONFERE_DURANTE_SEPARACAO,
                'P' TP_PROD, -- Para identif. se Master ou Componente KIT
                P.ID_PROD
           FROM PRODUTO                     P,
                DESCRICAO_PRODUTO           DP,
                REFERENCIA_PRODUTO          RPR,
                COR_ACABAMENTO              COR,
                DIVISAO                     D,
                GRUPO_ESTATISTICO           GE,
                FAMILIA                     F,
                DESC_PROD_USO_EMBALAGEM     DPUE, -- A
                DESC_PROD_USO_EMBALAGEM     DPUE_U,
                DIVISAO_GRUPO_PARA_SETOR_CD DPC
          WHERE P.ID_PROD = P_ID_PROD
            AND DP.ID_DESCR = P.ID_DESCR
            AND RPR.CD_REF = P.CD_REF
            AND COR.AB_COR = RPR.AB_COR1
            AND D.CD_DIV = DP.CD_DIV
            AND GE.CD_GEP = DP.CD_GEP
            AND GE.CD_DIV = DP.CD_DIV
            AND F.CD_FAM = DP.CD_FAM
            AND F.CD_GEP = DP.CD_GEP
            AND F.CD_DIV = DP.CD_DIV
            AND DP.CD_DIV = DPC.CD_DIV(+)
            AND DP.CD_GEP = DPC.CD_GEP(+)
            AND DPUE.ID_DESCR(+) = DP.ID_DESCR
            AND DPUE.AB_USO(+) = 'A' -- ARMAZENAMENTO
            -- 05/11/20 - Incluido para buscar dimensoes do produto mono
            AND DPUE_U.ID_DESCR(+) = DP.ID_DESCR
            AND DPUE_U.AB_USO(+) = 'U' -- UNITARIO
         UNION
         SELECT 1 CD_EMPRESA,
                '001' CD_DEPOSITO,
                P.ID_PROD || '/' || CMP.NR_COMP CD_PRODUTO,
                DP.NM_PROD || ' VOL.' || CMP.NR_COMP || '/' || CMP.NR_TOT DS_PRODUTO,
                DP.CD_ALFA || ' VOL.' || CMP.NR_COMP || '/' || CMP.NR_TOT DS_REDUZIDA,
                DP.IN_UNID_MEDIDA CD_UNIDADE_MEDIDA,
                DP.IN_UNID_MEDIDA DS_UNIDADE_MEDIDA,
                'N' ID_ACEITA_DECIMAL,
                'NC' CD_EMBALAGEM,
                'N�O CADASTRADO' DS_EMBALAGEM,
                -- LOG-348 - Troca do campo de Acondicionamento na interface
                1  QT_UNI_EMBALAGEM, -- QTDE DE UNID. POR embalagem
                NVL(DPUE.QT_ACOND, 1) DS_ESPECIFICACAO,
                P.ID_PROD CD_PRODUTO_MASTER, -- SE IGUAL CD_produto - mono sen�o multi embalagem
                1 QT_ITENS,
                DP.CD_GEP CD_FAMILIA,
                SUBSTR(GE.DS_GEP, 1, 60) DS_FAMILIA,
                CMP.MD_ALT VL_ALTURA,
                CMP.MD_LARG VL_LARGURA,
                CMP.MD_PROF VL_PROFUNDIDADE,
                CMP.MD_PESO PS_LIQUIDO,
                CMP.MD_PESO PS_BRUTO,
                NULL QT_MAX_PALETE,
                15 CD_SITUACAO,
                --NVL(DP.CD_DIV || LPAD(DP.CD_GEP, 4, '0'),'NC') CD_CLASSE, -- SETOR DO PRODUTO
                NVL(DPC.CD_CLASSE, 'NC') CD_CLASSE, -- SETOR DO PRODUTO
                --SUBSTR(GE.DS_GEP, 1, 35) DS_CLASSE,
                SUBSTR(DPC.DS_CLASSE, 1, 35) DS_CLASSE,
                NULL QT_DIAS_VALIDADE,
                NULL QT_DIAS_REMONTE,
                'N' ID_CONTROLE_LOTE,
                'N' ID_CONTROLE_SERIE,
                'N' ID_CONTROLE_VALIDADE,
                1 QT_CAIXA_FECHADA,
                NULL CD_FORNECEDOR,
                NULL CD_CNPJ_FORNECEDOR,
                P.CD_NUM CD_PRODUTO_FORNECEDOR,
                DP.CD_DIV CD_LINHA,
                SUBSTR(D.NM_DIV, 1, 60) DS_LINHA,
                DP.CD_FAM CD_GRUPO,
                SUBSTR(F.NM_FAM, 1, 60) DS_GRUPO,
                'NC' CD_SUBGRUPO,
                'N�O CADASTRADO' DS_SUBGRUPO,
                'NC' CD_MODELO,
                'N�O CADASTRADO' DS_MODELO,
                --NULL TP_ARMAZENAGEM_PRODUTO,
                'C' TP_ARMAZENAGEM_PRODUTO,
                NULL CD_DEPARTAMENTO,
                NULL DS_DEPARTAMENTO,
                CMP.DS_COMP FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5,
                NULL QT_PERC_PROD_DIAS_EXPEDICAO,
                SUBSTR(COR.DS_COR, 1, 40) DS_COR_PRODUTO,
                NULL NM_ARQUIVO_IMAGEM,
                NULL DS_EXTENSAO_ARQUIVO_IMAGEM,
                NULL DS_TAMANHO_PRODUTO,
                NULL CD_PRODUTO_REFERENCIA,
                'N' ID_PRODUTO_GRADE, --
                'C' TP_PRODUTO, -- NO JSON S� ENVIA QDO KIT - componente
                NULL QT_FATOR_CONVERSAO_SORTER,
                NULL TP_UNIDADE_LOGISTICA_SORTER,
                'NC' CD_EMBALAGE_EXPEDICAO,
                'N' ID_CX_FECHADA_VOLUME_PRONTO,
                'N' ID_CONFERE_DURANTE_SEPARACAO,
                'C' TP_PROD, -- Para identif. se Master ou Componente KIT
                P.ID_PROD
           FROM PRODUTO                     P,
                MULTIPLA_EMBALAGEM          CMP,
                DESCRICAO_PRODUTO           DP,
                REFERENCIA_PRODUTO          RPR,
                COR_ACABAMENTO              COR,
                DIVISAO                     D,
                GRUPO_ESTATISTICO           GE,
                FAMILIA                     F,
                DESC_PROD_USO_EMBALAGEM     DPUE,
                DIVISAO_GRUPO_PARA_SETOR_CD DPC
          WHERE DP.ID_DESCR = P.ID_DESCR
            AND CMP.ID_PROD(+) = P.ID_PROD
            AND CMP.NR_TOT <> 1 -- para desconsiderar cadastros errados - prods cancelados
            AND P.ID_PROD = P_ID_PROD
            AND CMP.DT_INVAL IS NULL  -- se o valor n�o e null significa que a embalagem foi cancelada
            AND RPR.CD_REF = P.CD_REF
            AND COR.AB_COR = RPR.AB_COR1
            AND D.CD_DIV = DP.CD_DIV
            AND GE.CD_GEP = DP.CD_GEP
            AND GE.CD_DIV = DP.CD_DIV
            AND F.CD_FAM = DP.CD_FAM
            AND F.CD_GEP = DP.CD_GEP
            AND F.CD_DIV = DP.CD_DIV
            AND DP.CD_DIV = DPC.CD_DIV(+)
            AND DP.CD_GEP = DPC.CD_GEP(+)
            AND DPUE.ID_DESCR(+) = DP.ID_DESCR
            AND DPUE.AB_USO(+) = 'A' -- ARMAZENAMENTO
          ORDER BY TP_PROD DESC,
                   CD_PRODUTO;
      R_PROD C_PROD%ROWTYPE;
      --
      -- Busca a ultima curva calculada para o produto
      /*
      -- Comentado para Inicialmente considerar como default 88
      CURSOR C_ROTAT (P_PROD  IN NUMBER,
                      P_DIV   IN NUMBER,
                      P_GEP   IN NUMBER,
                      P_FAM   IN NUMBER) IS
         SELECT CCP.SG_CURVA_FAM SG_ROTATIVIDADE
           FROM CLASSIF_CURVA_PROD_VOLUME CCP
          WHERE CCP.ID_PROD  = P_PROD
            AND CCP.CD_DIV   = P_DIV
            AND CCP.CD_GEP   = P_GEP
            AND CCP.CD_FAM   = P_FAM
            AND CCP.DT_PROC  = (SELECT MAX(CCP1.DT_PROC)
                                 FROM CLASSIF_CURVA_PROD_VOLUME CCP1
                                WHERE CCP1.CD_DIV = CCP.CD_DIV
                                  AND CCP1.CD_GEP = CCP.CD_GEP
                                  AND CCP1.CD_FAM = CCP.CD_FAM
                                  AND CCP1.ID_PROD = CCP.ID_PROD);
      R_ROTAT   C_ROTAT%ROWTYPE;
      */
      --
      V_INS_BARRA_CMP VARCHAR2(1);
   BEGIN
      IF P_ID_PROD IS NOT NULL THEN
         V_INS_BARRA_CMP := 'S';
         --
         OPEN C_PROD;
         LOOP
            FETCH C_PROD
               INTO R_PROD;
            EXIT WHEN C_PROD%NOTFOUND;
            --
            -- Passa o ID_PROD, pois o CD_PRODUTO � montado para Produtos Multi Embalagem
            /*
            -- Comentado para Inicialmente considerar como default 88
            OPEN C_ROTAT(R_PROD.ID_PROD,
                         R_PROD.CD_LINHA,
                         R_PROD.CD_FAMILIA,
                         R_PROD.CD_GRUPO);
            FETCH C_ROTAT
               INTO R_ROTAT;
            CLOSE C_ROTAT;
            */
            --
            P_REC_PROD                      := NULL;
            P_REC_PROD.CD_EMPRESA           := R_PROD.CD_EMPRESA;
            P_REC_PROD.CD_DEPOSITO          := R_PROD.CD_DEPOSITO;
            P_REC_PROD.CD_PRODUTO           := R_PROD.CD_PRODUTO;
            P_REC_PROD.DS_PRODUTO           := R_PROD.DS_PRODUTO;
            P_REC_PROD.DS_REDUZIDA          := R_PROD.DS_REDUZIDA;
            P_REC_PROD.CD_UNIDADE_MEDIDA    := R_PROD.CD_UNIDADE_MEDIDA;
            P_REC_PROD.DS_UNIDADE_MEDIDA    := R_PROD.DS_UNIDADE_MEDIDA;
            P_REC_PROD.ID_ACEITA_DECIMAL    := R_PROD.ID_ACEITA_DECIMAL;
            P_REC_PROD.CD_EMBALAGEM         := R_PROD.CD_EMBALAGEM;
            P_REC_PROD.DS_EMBALAGEM         := R_PROD.DS_EMBALAGEM;
            -- LOG-348
            P_REC_PROD.QT_UNIDADE_EMBALAGEM := R_PROD.QT_UNI_EMBALAGEM;
            P_REC_PROD.DS_ESPECIFICACAO     := R_PROD.DS_ESPECIFICACAO;
            --
            P_REC_PROD.CD_PRODUTO_MASTER    := R_PROD.CD_PRODUTO_MASTER;
            P_REC_PROD.QT_ITENS             := R_PROD.QT_ITENS;
            P_REC_PROD.CD_FAMILIA           := R_PROD.CD_FAMILIA;
            P_REC_PROD.DS_FAMILIA           := R_PROD.DS_FAMILIA;
            P_REC_PROD.VL_ALTURA            := R_PROD.VL_ALTURA;
            P_REC_PROD.VL_LARGURA           := R_PROD.VL_LARGURA;
            P_REC_PROD.VL_PROFUNDIDADE      := R_PROD.VL_PROFUNDIDADE;
            P_REC_PROD.PS_LIQUIDO           := R_PROD.PS_LIQUIDO;
            P_REC_PROD.PS_BRUTO             := R_PROD.PS_BRUTO;
            P_REC_PROD.QT_MAX_PALETE        := R_PROD.QT_MAX_PALETE;
            P_REC_PROD.CD_SITUACAO          := R_PROD.CD_SITUACAO;
            --            P_REC_PROD.CD_ROTATIVIDADE              := NVL(R_ROTAT.SG_ROTATIVIDADE,'NC');
            P_REC_PROD.CD_ROTATIVIDADE              := 99;
            P_REC_PROD.CD_CLASSE                    := R_PROD.CD_CLASSE;
            P_REC_PROD.DS_CLASSE                    := R_PROD.DS_CLASSE;
            P_REC_PROD.QT_DIAS_VALIDADE             := R_PROD.QT_DIAS_VALIDADE;
            P_REC_PROD.QT_DIAS_REMONTE              := R_PROD.QT_DIAS_REMONTE;
            P_REC_PROD.ID_CONTROLE_LOTE             := R_PROD.ID_CONTROLE_LOTE;
            P_REC_PROD.ID_CONTROLE_SERIE            := R_PROD.ID_CONTROLE_SERIE;
            P_REC_PROD.ID_CONTROLE_VALIDADE         := R_PROD.ID_CONTROLE_VALIDADE;
            P_REC_PROD.QT_CAIXA_FECHADA             := R_PROD.QT_CAIXA_FECHADA;
            P_REC_PROD.CD_FORNECEDOR                := R_PROD.CD_FORNECEDOR;
            P_REC_PROD.CD_CNPJ_FORNECEDOR           := R_PROD.CD_CNPJ_FORNECEDOR;
            P_REC_PROD.CD_PRODUTO_FORNECEDOR        := R_PROD.CD_PRODUTO_FORNECEDOR;
            P_REC_PROD.CD_LINHA                     := R_PROD.CD_LINHA;
            P_REC_PROD.DS_LINHA                     := R_PROD.DS_LINHA;
            P_REC_PROD.CD_GRUPO                     := R_PROD.CD_GRUPO;
            P_REC_PROD.DS_GRUPO                     := R_PROD.DS_GRUPO;
            P_REC_PROD.CD_SUBGRUPO                  := R_PROD.CD_SUBGRUPO;
            P_REC_PROD.DS_SUBGRUPO                  := R_PROD.DS_SUBGRUPO;
            P_REC_PROD.CD_MODELO                    := R_PROD.CD_MODELO;
            P_REC_PROD.DS_MODELO                    := R_PROD.DS_MODELO;
            P_REC_PROD.TP_ARMAZENAGEM_PRODUTO       := R_PROD.TP_ARMAZENAGEM_PRODUTO;
            P_REC_PROD.CD_DEPARTAMENTO              := R_PROD.CD_DEPARTAMENTO;
            P_REC_PROD.DS_DEPARTAMENTO              := R_PROD.DS_DEPARTAMENTO;
            P_REC_PROD.FILLER_1                     := R_PROD.FILLER_1;
            P_REC_PROD.FILLER_2                     := R_PROD.FILLER_2;
            P_REC_PROD.FILLER_3                     := R_PROD.FILLER_3;
            P_REC_PROD.FILLER_4                     := R_PROD.FILLER_4;
            P_REC_PROD.FILLER_5                     := R_PROD.FILLER_5;
            P_REC_PROD.QT_PERC_PROD_DIAS_EXPEDICAO  := R_PROD.QT_PERC_PROD_DIAS_EXPEDICAO;
            P_REC_PROD.DS_COR_PRODUTO               := R_PROD.DS_COR_PRODUTO;
            P_REC_PROD.DS_ESPECIFICACAO             := R_PROD.DS_ESPECIFICACAO;
            P_REC_PROD.NM_ARQUIVO_IMAGEM            := R_PROD.NM_ARQUIVO_IMAGEM;
            P_REC_PROD.DS_EXTENSAO_ARQUIVO_IMAGEM   := R_PROD.DS_EXTENSAO_ARQUIVO_IMAGEM;
            P_REC_PROD.DS_TAMANHO_PRODUTO           := R_PROD.DS_TAMANHO_PRODUTO;
            P_REC_PROD.CD_PRODUTO_REFERENCIA        := R_PROD.CD_PRODUTO_REFERENCIA;
            P_REC_PROD.ID_PRODUTO_GRADE             := R_PROD.ID_PRODUTO_GRADE;
            P_REC_PROD.TP_PRODUTO                   := R_PROD.TP_PRODUTO;
            P_REC_PROD.QT_FATOR_CONVERSAO_SORTER    := R_PROD.QT_FATOR_CONVERSAO_SORTER;
            P_REC_PROD.TP_UNIDADE_LOGISTICA_SORTER  := R_PROD.TP_UNIDADE_LOGISTICA_SORTER;
            P_REC_PROD.CD_EMBALAGE_EXPEDICAO        := R_PROD.CD_EMBALAGE_EXPEDICAO;
            P_REC_PROD.ID_CX_FECHADA_VOLUME_PRONTO  := R_PROD.ID_CX_FECHADA_VOLUME_PRONTO;
            P_REC_PROD.ID_CONFERE_DURANTE_SEPARACAO := R_PROD.ID_CONFERE_DURANTE_SEPARACAO;
            -- Insere na tabela INT_E_PRODUTO
            PR_INS_PRODUTO(P_REC_PROD);
            -- Chama Procedure Insere os c�digos da barra do produto
            IF R_PROD.TP_PROD = 'P' OR
               (R_PROD.TP_PROD = 'C' AND V_INS_BARRA_CMP = 'S') THEN
               --
               PR_GRV_BARRA_PROD(R_PROD.ID_PROD, R_PROD.TP_PROD, P_REC_PROD.NU_SEQ); -- Prod. Master / Componentes KIT
               -- controle para o compenente s� executar no 1o, pois gera barra de todos volumes na 1a vez
               IF R_PROD.TP_PROD = 'C' THEN
                  V_INS_BARRA_CMP := 'N';
               END IF;
            END IF;
         END LOOP;
         CLOSE C_PROD;
      END IF; -- P_ID_PROD IS NOT NULL
      --
      COMMIT;
      --
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         D_SQLERRM            := SQLERRM;
         P_MSG                := NULL;
         P_MSG.CD_FIL         := GC.PCK_1.G_FIL_AMBIENTE;
         P_MSG.ID_MSG         := NULL;
         P_MSG.NM_PACOTE      := 'PCK_GERAR_INTERF_WMS';
         P_MSG.NM_PROGR       := 'PR_GRV_PRODUTO';
         P_MSG.IN_TEL_RET     := 'T';
         P_MSG.ID_USR_ORIGEM  := USER;
         P_MSG.ID_USR_DESTINO := 'HELPDESK';
         P_MSG.NR_ITENS       := 0;
         P_MSG.NR_OCOR        := 0;
         P_MSG.TX_OCOR        := 'INTERFACE DE PRODUTO PARA WMS ' || 'ERRO<' || D_SQLERRM || '> ';
         D_ID_MSG             := GC.GRV_GC_MSG(P_MSG);
         COMMIT;
         --
   END PR_GRV_PRODUTO;
   --
   -- Dados de C�digo de Barra do Produto no WMS --
   PROCEDURE PR_GRV_BARRA_PROD(P_ID_PROD IN GC.PRODUTO.ID_PROD%TYPE,
                               P_TP_PROD IN VARCHAR2,
                               P_NU_SEQ  IN NUMBER) IS
      --
      -- Acionado da PR_GRV_PRODUTO
      -- P_TP_PROD = "P" - Produto Master / "C" - Componente KIT
      -- CD_SITUACAO - 1-Inserir / 2-Cancelar -- considerando s� a inclus�o
      --
      -- Declara rowtype para insert
      P_REC_BARRA WMS.INT_E_CODIGO_BARRA%ROWTYPE;
      -- Cursor Codigo Barra da Master
      -- produto master de Multi Volumes n�o gera o tipo 1 - padr�o WIS, s� gerar EAN13
      CURSOR C_BARRA_MASTER IS
         SELECT 1 CD_EMPRESA,
                P.ID_PROD CD_PRODUTO,
                P.ID_PROD CD_BARRAS,
                1 CD_SITUACAO,
                1 TP_CODIGO_BARRAS, -- PADRAO WIS
                1 QT_EMBALAGEM,
                'S' ID_CODIGO_PRINCIPAL,
                1 NU_PRIORIDADE_USO,
                NULL ID_VOLUME,
                NULL FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5
           FROM PRODUTO P
          WHERE P.ID_PROD = P_ID_PROD
            AND NOT EXISTS (SELECT 1
                   FROM MULTIPLA_EMBALAGEM MP
                  WHERE MP.ID_PROD = P.ID_PROD
                    AND MP.DT_INVAL IS NULL)  -- se o valor n�o e null significa que a embalagem foi cancelada
         UNION
         SELECT 1 CD_EMPRESA,
                P.ID_PROD CD_PRODUTO,
                P.CD_INTER CD_BARRAS,
                1 CD_SITUACAO,
                13 TP_CODIGO_BARRAS, -- EAN13
                1 QT_EMBALAGEM,
                'N' ID_CODIGO_PRINCIPAL,
                2 NU_PRIORIDADE_USO,
                NULL ID_VOLUME,
                NULL FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5
           FROM PRODUTO P
          WHERE P.ID_PROD = P_ID_PROD
            AND P.ID_PROD <> P.CD_INTER
          ORDER BY TP_CODIGO_BARRAS;
      --
      -- Cursor Cod. Barras dos Compomente do Produto
      -- componentes n�o gera o tipo 1 - padr�o WIS, s� gerar EAN13 e 128
      CURSOR C_BARRA_KIT IS
         SELECT 1 CD_EMPRESA,
                P.ID_PROD || '/' || CMP.NR_COMP CD_PRODUTO,
                P.ID_PROD || LPAD(CMP.NR_COMP, 2, '0') || LPAD(CMP.NR_TOT, 2, '0') CD_BARRAS,
                1 CD_SITUACAO,
                1 TP_CODIGO_BARRAS,
                1 QT_EMBALAGEM,
                'S' ID_CODIGO_PRINCIPAL,
                NULL NU_PRIORIDADE_USO,
                NULL ID_VOLUME,
                NULL FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5
           FROM PRODUTO            P,
                MULTIPLA_EMBALAGEM CMP
          WHERE P.ID_PROD = P_ID_PROD
            AND CMP.ID_PROD = P.ID_PROD
            AND CMP.DT_INVAL IS NULL  -- se o valor n�o e null significa que a embalagem foi cancelada
         UNION
         SELECT 1 CD_EMPRESA,
                P.ID_PROD || '/' || CMP.NR_COMP CD_PRODUTO,
                P.CD_INTER || LPAD(CMP.NR_COMP, 2, '0') || LPAD(CMP.NR_TOT, 2, '0') CD_BARRAS,
                1 CD_SITUACAO,
                128 TP_CODIGO_BARRAS,
                1 QT_EMBALAGEM,
                'N' ID_CODIGO_PRINCIPAL,
                NULL NU_PRIORIDADE_USO,
                NULL ID_VOLUME,
                NULL FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5
           FROM PRODUTO            P,
                MULTIPLA_EMBALAGEM CMP
          WHERE P.ID_PROD = P_ID_PROD
            AND CMP.ID_PROD = P.ID_PROD
            AND P.ID_PROD <> P.CD_INTER
            AND CMP.DT_INVAL IS NULL  -- se o valor n�o e null significa que a embalagem foi cancelada
          ORDER BY TP_CODIGO_BARRAS;
   BEGIN
      IF P_TP_PROD = 'P' THEN
         FOR R_BARRA_MASTER IN C_BARRA_MASTER
         LOOP
            P_REC_BARRA                     := NULL;
            P_REC_BARRA.NU_SEQ              := P_NU_SEQ;
            P_REC_BARRA.CD_EMPRESA          := R_BARRA_MASTER.CD_EMPRESA;
            P_REC_BARRA.CD_PRODUTO          := R_BARRA_MASTER.CD_PRODUTO;
            P_REC_BARRA.CD_BARRAS           := R_BARRA_MASTER.CD_BARRAS;
            P_REC_BARRA.CD_SITUACAO         := R_BARRA_MASTER.CD_SITUACAO;
            P_REC_BARRA.TP_CODIGO_BARRAS    := R_BARRA_MASTER.TP_CODIGO_BARRAS;
            P_REC_BARRA.QT_EMBALAGEM        := R_BARRA_MASTER.QT_EMBALAGEM;
            P_REC_BARRA.ID_CODIGO_PRINCIPAL := R_BARRA_MASTER.ID_CODIGO_PRINCIPAL;
            P_REC_BARRA.NU_PRIORIDADE_USO   := R_BARRA_MASTER.NU_PRIORIDADE_USO;
            P_REC_BARRA.ID_VOLUME           := R_BARRA_MASTER.ID_VOLUME;
            P_REC_BARRA.FILLER_1            := R_BARRA_MASTER.FILLER_1;
            P_REC_BARRA.FILLER_2            := R_BARRA_MASTER.FILLER_2;
            P_REC_BARRA.FILLER_3            := R_BARRA_MASTER.FILLER_3;
            P_REC_BARRA.FILLER_4            := R_BARRA_MASTER.FILLER_4;
            P_REC_BARRA.FILLER_5            := R_BARRA_MASTER.FILLER_5;
            --
            PR_INS_COD_BARRA(P_REC_BARRA);
         END LOOP; -- C_BARRA_MASTER
      ELSE
         -- P_TP_PROD = 'C'
         FOR R_BARRA_KIT IN C_BARRA_KIT
         LOOP
            P_REC_BARRA                     := NULL;
            P_REC_BARRA.NU_SEQ              := P_NU_SEQ;
            P_REC_BARRA.CD_EMPRESA          := R_BARRA_KIT.CD_EMPRESA;
            P_REC_BARRA.CD_PRODUTO          := R_BARRA_KIT.CD_PRODUTO;
            P_REC_BARRA.CD_BARRAS           := R_BARRA_KIT.CD_BARRAS;
            P_REC_BARRA.CD_SITUACAO         := R_BARRA_KIT.CD_SITUACAO;
            P_REC_BARRA.TP_CODIGO_BARRAS    := R_BARRA_KIT.TP_CODIGO_BARRAS;
            P_REC_BARRA.QT_EMBALAGEM        := R_BARRA_KIT.QT_EMBALAGEM;
            P_REC_BARRA.ID_CODIGO_PRINCIPAL := R_BARRA_KIT.ID_CODIGO_PRINCIPAL;
            P_REC_BARRA.NU_PRIORIDADE_USO   := R_BARRA_KIT.NU_PRIORIDADE_USO;
            P_REC_BARRA.ID_VOLUME           := R_BARRA_KIT.ID_VOLUME;
            P_REC_BARRA.FILLER_1            := R_BARRA_KIT.FILLER_1;
            P_REC_BARRA.FILLER_2            := R_BARRA_KIT.FILLER_2;
            P_REC_BARRA.FILLER_3            := R_BARRA_KIT.FILLER_3;
            P_REC_BARRA.FILLER_4            := R_BARRA_KIT.FILLER_4;
            P_REC_BARRA.FILLER_5            := R_BARRA_KIT.FILLER_5;
            --
            PR_INS_COD_BARRA(P_REC_BARRA);
         END LOOP; -- C_BARRA_MASTER
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         D_SQLERRM            := SQLERRM;
         P_MSG                := NULL;
         P_MSG.CD_FIL         := GC.PCK_1.G_FIL_AMBIENTE;
         P_MSG.ID_MSG         := NULL;
         P_MSG.NM_PACOTE      := 'PCK_GERAR_INTERF_WMS';
         P_MSG.NM_PROGR       := 'PR_GRV_BARRA_PROD';
         P_MSG.IN_TEL_RET     := 'T';
         P_MSG.ID_USR_ORIGEM  := USER;
         P_MSG.ID_USR_DESTINO := 'HELPDESK';
         P_MSG.NR_ITENS       := 0;
         P_MSG.NR_OCOR        := 0;
         P_MSG.TX_OCOR        := 'INTERFACE DE COD.BARRA DO PRODUTO PARA WMS ' || 'ERRO<' || D_SQLERRM || '> ';
         D_ID_MSG             := GC.GRV_GC_MSG(P_MSG);
         COMMIT;
         --
   END PR_GRV_BARRA_PROD;
   --
   -- Dados de Cliente no WMS --
   PROCEDURE PR_GRV_CLIENTE(P_ID_CLIENTE IN GC.PESSOA.ID_PESSOA%TYPE,
                            P_CD_DEP_WMS IN VARCHAR2) IS
      -- P_cd_dep_wms j� deve vir com LPAD aplicado
      -- Declara rowtype para insert
      P_REC_CLIENTE WMS.INT_E_CLIENTE%ROWTYPE;
      -- LOG-595 - Invers�o do NM_PESSOA da FILIAL para sigla/nome filial
      -- Busca Informa��o dos Clientes (Externos e Filiais)
      CURSOR C_CLIENTE IS
         SELECT 1 CD_EMPRESA,
                '001' CD_DEPOSITO,
                P.ID_PESSOA CD_CLIENTE,
                DECODE(P.CD_FIL_TOK, NULL, P.NM_PESSOA, F.SG_FIL || ' - ' || F.NM_FIL) DS_CLIENTE,
                NULL NU_INSCRICAO,
                NVL(P.ID_CPF, P.ID_CGC) CD_CNPJ_CLIENTE,
                NULL CD_ROTA, -- SE Filial - tem cadastro de rota fixa?
                DECODE(P.CD_FIL_TOK, NULL, 'C', 'F') ID_CLIENTE_FILIAL, -- C-Cliente / F-Filial
                15 CD_SITUACAO,
                NULL FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5
           FROM PESSOA          P,
                FILIAL          F
          WHERE P.ID_PESSOA = P_ID_CLIENTE
            AND F.CD_FIL(+) = P.CD_FIL_TOK;
      R_CLIENTE C_CLIENTE%ROWTYPE;
      --
      CURSOR C_END (P_CLIENTE IN NUMBER) IS
         SELECT LPAD(EP.CD_CEP1,5,0)||LPAD(EP.CD_CEP2,3,'0') CD_CEP,
                SUBSTR(TL.AB_TIPO_LOGR, 1, 35) || ' ' || EP.NM_LOGR DS_ENDERECO,
                SUBSTR(EP.NR_LOGR, 1, 8) NU_ENDERECO,
                EP.CM_LOGR DS_COMPLEMENTO,
                SUBSTR(EP.NM_BAIRRO, 1, 72) DS_BAIRRO,
                C.NM_CIDADE DS_MUNICIPIO,
                EP.SG_ESTADO_CID CD_UF,
                NULL NU_TELEFONE,
                NULL NU_FAX
           FROM ENDERECO_PESSOA EP,
                TIPO_LOGRADOURO TL,
                CIDADE          C,
                FILIAL          F
          WHERE EP.ID_PESSOA = P_CLIENTE
            AND EP.AB_ENDER IN ('CAD', 'ENT')
            AND TL.ID_TIPO_LOGR(+) = EP.ID_TIPO_LOGR
            AND C.CD_CIDADE = EP.CD_CIDADE_CID
            AND C.SG_ESTADO = EP.SG_ESTADO_CID
            AND C.SG_PAIS = EP.SG_PAIS_CID;
      R_END C_END%ROWTYPE;
   BEGIN
      IF P_ID_CLIENTE IS NOT NULL THEN
         OPEN C_CLIENTE;
         FETCH C_CLIENTE
            INTO R_CLIENTE;
         CLOSE C_CLIENTE;
         --
         P_REC_CLIENTE                   := NULL;
         P_REC_CLIENTE.CD_EMPRESA        := R_CLIENTE.CD_EMPRESA;
         P_REC_CLIENTE.CD_DEPOSITO       := NVL(P_CD_DEP_WMS, R_CLIENTE.CD_DEPOSITO);
         P_REC_CLIENTE.CD_CLIENTE        := R_CLIENTE.CD_CLIENTE;
         P_REC_CLIENTE.DS_CLIENTE        := R_CLIENTE.DS_CLIENTE;
         P_REC_CLIENTE.NU_INSCRICAO      := R_CLIENTE.NU_INSCRICAO;
         P_REC_CLIENTE.CD_CNPJ_CLIENTE   := R_CLIENTE.CD_CNPJ_CLIENTE;
         P_REC_CLIENTE.CD_ROTA           := R_CLIENTE.CD_ROTA;
         P_REC_CLIENTE.ID_CLIENTE_FILIAL := R_CLIENTE.ID_CLIENTE_FILIAL;
         P_REC_CLIENTE.CD_SITUACAO       := R_CLIENTE.CD_SITUACAO;
         P_REC_CLIENTE.FILLER_1          := R_CLIENTE.FILLER_1;
         P_REC_CLIENTE.FILLER_2          := R_CLIENTE.FILLER_2;
         P_REC_CLIENTE.FILLER_3          := R_CLIENTE.FILLER_3;
         P_REC_CLIENTE.FILLER_4          := R_CLIENTE.FILLER_4;
         P_REC_CLIENTE.FILLER_5          := R_CLIENTE.FILLER_5;
         -- Busca dados endere�o cadastral do cliente
         OPEN C_END(R_CLIENTE.CD_CLIENTE);
         FETCH C_END
            INTO R_END;
         IF C_END%FOUND THEN
            P_REC_CLIENTE.CD_CEP            := R_END.CD_CEP;
            P_REC_CLIENTE.DS_ENDERECO       := R_END.DS_ENDERECO;
            P_REC_CLIENTE.NU_ENDERECO       := R_END.NU_ENDERECO;
            P_REC_CLIENTE.DS_COMPLEMENTO    := R_END.DS_COMPLEMENTO;
            P_REC_CLIENTE.DS_BAIRRO         := R_END.DS_BAIRRO;
            P_REC_CLIENTE.DS_MUNICIPIO      := R_END.DS_MUNICIPIO;
            P_REC_CLIENTE.CD_UF             := R_END.CD_UF;
            P_REC_CLIENTE.NU_TELEFONE       := R_END.NU_TELEFONE;
            P_REC_CLIENTE.NU_FAX            := R_END.NU_FAX;
         END IF;
         CLOSE C_END;
         --
         PR_INS_CLIENTE(P_REC_CLIENTE);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         D_SQLERRM            := SQLERRM;
         P_MSG                := NULL;
         P_MSG.CD_FIL         := GC.PCK_1.G_FIL_AMBIENTE;
         P_MSG.ID_MSG         := NULL;
         P_MSG.NM_PACOTE      := 'PCK_GERAR_INTERF_WMS';
         P_MSG.NM_PROGR       := 'PR_GRV_CLIENTE';
         P_MSG.IN_TEL_RET     := 'T';
         P_MSG.ID_USR_ORIGEM  := USER;
         P_MSG.ID_USR_DESTINO := 'HELPDESK';
         P_MSG.NR_ITENS       := 0;
         P_MSG.NR_OCOR        := 0;
         P_MSG.TX_OCOR        := 'INTERFACE DE CLIENTE PARA WMS ' || 'ERRO<' || D_SQLERRM || '> ';
         D_ID_MSG             := GC.GRV_GC_MSG(P_MSG);
         COMMIT;
         --
   END PR_GRV_CLIENTE;
   --
   -- Dados de Fornecedor no WMS --
   PROCEDURE PR_GRV_FORNECEDOR(P_ID_FORNEC  IN GC.PESSOA.ID_PESSOA%TYPE,
                               P_CD_DEP_WMS IN VARCHAR2) IS
      -- Declara rowtype para insert
      P_REC_FORNEC WMS.INT_E_FORNECEDOR%ROWTYPE;
      -- Busca Informa��o dos fornecedores
      CURSOR C_FORNEC IS
         SELECT 1 CD_EMPRESA,
                '001' CD_DEPOSITO,
                P.ID_PESSOA CD_FORNECEDOR,
                P.NM_PESSOA DS_RAZAO_SOCIAL,
                SUBSTR(P.NM_FANT, 1, 30) NM_FANTASIA,
                P.ID_CGC CD_CNPJ_FORNECEDOR,
                NULL NU_INSCRICAO,
                SUBSTR(TL.AB_TIPO_LOGR, 1, 35) || ' ' || EP.NM_LOGR DS_ENDERECO,
                SUBSTR(EP.NM_BAIRRO, 1, 72) DS_BAIRRO,
                C.NM_CIDADE DS_MUNICIPIO,
                EP.SG_ESTADO_CID CD_UF,
                LPAD(EP.CD_CEP1,5,0)||LPAD(EP.CD_CEP2,3,'0') CD_CEP,
                NULL NU_TELEFONE,
                NULL NU_FAX,
                15 CD_SITUACAO,
                NULL FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5,
                SUBSTR(EP.NR_LOGR, 1, 8) NU_ENDERECO,
                EP.CM_LOGR DS_COMPLEMENTO
           FROM PESSOA          P,
                ENDERECO_PESSOA EP,
                TIPO_LOGRADOURO TL,
                CIDADE          C
          WHERE P.ID_PESSOA = P_ID_FORNEC
            AND (NVL(P.IN_FOR, 'N') IN ('S','N') OR NVL(P.IN_TOK, 'N') = 'S') -- Para considerar Filiais Estok como emitente tbm
            AND P.DT_INATIVA_FORNEC IS NULL
            AND EP.ID_PESSOA = P.ID_PESSOA
            AND EP.DT_EXCL IS NULL
            AND TL.ID_TIPO_LOGR(+) = EP.ID_TIPO_LOGR
            AND C.CD_CIDADE = EP.CD_CIDADE_CID
            AND C.SG_ESTADO = EP.SG_ESTADO_CID
            AND C.SG_PAIS = EP.SG_PAIS_CID;
      R_FORNEC C_FORNEC%ROWTYPE;
   BEGIN
      IF P_ID_FORNEC IS NOT NULL THEN
         OPEN C_FORNEC;
         FETCH C_FORNEC
            INTO R_FORNEC;
         --
         P_REC_FORNEC                    := NULL;
         P_REC_FORNEC.CD_EMPRESA         := R_FORNEC.CD_EMPRESA;
         P_REC_FORNEC.CD_DEPOSITO        := NVL(P_CD_DEP_WMS, R_FORNEC.CD_DEPOSITO);
         P_REC_FORNEC.CD_FORNECEDOR      := R_FORNEC.CD_FORNECEDOR;
         P_REC_FORNEC.DS_RAZAO_SOCIAL    := R_FORNEC.DS_RAZAO_SOCIAL;
         P_REC_FORNEC.NM_FANTASIA        := R_FORNEC.NM_FANTASIA;
         P_REC_FORNEC.CD_CNPJ_FORNECEDOR := R_FORNEC.CD_CNPJ_FORNECEDOR;
         P_REC_FORNEC.DS_ENDERECO        := R_FORNEC.DS_ENDERECO;
         P_REC_FORNEC.NU_INSCRICAO       := R_FORNEC.NU_INSCRICAO;
         P_REC_FORNEC.DS_BAIRRO          := R_FORNEC.DS_BAIRRO;
         P_REC_FORNEC.DS_MUNICIPIO       := R_FORNEC.DS_MUNICIPIO;
         P_REC_FORNEC.CD_UF              := R_FORNEC.CD_UF;
         P_REC_FORNEC.CD_CEP             := R_FORNEC.CD_CEP;
         P_REC_FORNEC.NU_TELEFONE        := R_FORNEC.NU_TELEFONE;
         P_REC_FORNEC.NU_FAX             := R_FORNEC.NU_FAX;
         P_REC_FORNEC.CD_SITUACAO        := R_FORNEC.CD_SITUACAO;
         P_REC_FORNEC.FILLER_1           := R_FORNEC.FILLER_1;
         P_REC_FORNEC.FILLER_2           := R_FORNEC.FILLER_2;
         P_REC_FORNEC.FILLER_3           := R_FORNEC.FILLER_3;
         P_REC_FORNEC.FILLER_4           := R_FORNEC.FILLER_4;
         P_REC_FORNEC.FILLER_5           := R_FORNEC.FILLER_5;
         P_REC_FORNEC.NU_ENDERECO        := R_FORNEC.NU_ENDERECO;
         P_REC_FORNEC.DS_COMPLEMENTO     := R_FORNEC.DS_COMPLEMENTO;
         --
         PR_INS_FORNEC(P_REC_FORNEC);
         CLOSE C_FORNEC;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         D_SQLERRM            := SQLERRM;
         P_MSG                := NULL;
         P_MSG.CD_FIL         := GC.PCK_1.G_FIL_AMBIENTE;
         P_MSG.ID_MSG         := NULL;
         P_MSG.NM_PACOTE      := 'PCK_GERAR_INTERF_WMS';
         P_MSG.NM_PROGR       := 'PR_GRV_FORNECEDOR';
         P_MSG.IN_TEL_RET     := 'T';
         P_MSG.ID_USR_ORIGEM  := USER;
         P_MSG.ID_USR_DESTINO := 'HELPDESK';
         P_MSG.NR_ITENS       := 0;
         P_MSG.NR_OCOR        := 0;
         P_MSG.TX_OCOR        := 'INTERFACE DE FORNECEDOR PARA WMS ' || 'ERRO<' || D_SQLERRM || '> ';
         D_ID_MSG             := GC.GRV_GC_MSG(P_MSG);
         COMMIT;
         --
   END PR_GRV_FORNECEDOR;
   --
   -- Dados de Transportadora no WMS --
   PROCEDURE PR_GRV_TRANSP(P_ID_TRANSP  IN GC.PESSOA.ID_PESSOA%TYPE,
                           P_CD_DEP_WMS IN VARCHAR2) IS
      -- P_cd_dep_wms j� deve vir com LPAD aplicado
      -- Declara rowtype para insert
      P_REC_TRANSP WMS.INT_E_TRANSPORTADORA%ROWTYPE;
      -- Busca Informa��o dos fornecedores
      CURSOR C_TRANSP IS
         SELECT 1 CD_EMPRESA,
                '001' CD_DEPOSITO,
                P.ID_PESSOA CD_TRANSPORTADORA,
                P.NM_PESSOA DS_TRANSPORTADORA,
                --P.NR_INSC_ESTL NU_INSCRICAO,
                NULL NU_INSCRICAO,
                P.ID_CGC CD_CNPJ_TRANSPORTADORA,
                LPAD(EP.CD_CEP1,5,0)||LPAD(EP.CD_CEP2,3,'0') CD_CEP,
                SUBSTR(TL.AB_TIPO_LOGR, 1, 35) || ' ' || EP.NM_LOGR DS_ENDERECO,
                SUBSTR(EP.NR_LOGR, 1, 8) NU_ENDERECO,
                EP.CM_LOGR DS_COMPLEMENTO,
                SUBSTR(EP.NM_BAIRRO, 1, 72) DS_BAIRRO,
                C.NM_CIDADE DS_MUNICIPIO,
                EP.SG_ESTADO_CID CD_UF,
                NULL NU_TELEFONE,
                NULL NU_FAX,
                15 CD_SITUACAO,
                NULL FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5,
                NULL CD_IMPR_ETIQ_EXPEDICAO
           FROM PESSOA          P,
                ENDERECO_PESSOA EP,
                TIPO_LOGRADOURO TL,
                CIDADE          C
          WHERE P.ID_PESSOA = P_ID_TRANSP
            AND P.IN_TRP = 'S'
            AND P.DT_INATIVA_FORNEC IS NULL
            AND EP.ID_PESSOA = P.ID_PESSOA
            AND EP.DT_EXCL IS NULL
            AND TL.ID_TIPO_LOGR(+) = EP.ID_TIPO_LOGR
            AND C.CD_CIDADE = EP.CD_CIDADE_CID
            AND C.SG_ESTADO = EP.SG_ESTADO_CID
            AND C.SG_PAIS = EP.SG_PAIS_CID;
      R_TRANSP C_TRANSP%ROWTYPE;
   BEGIN
      IF P_ID_TRANSP IS NOT NULL THEN
         OPEN C_TRANSP;
         FETCH C_TRANSP
            INTO R_TRANSP;
         --
         P_REC_TRANSP                              := NULL;
         P_REC_TRANSP.CD_EMPRESA                   := R_TRANSP.CD_EMPRESA;
         P_REC_TRANSP.CD_DEPOSITO                  := NVL(P_CD_DEP_WMS, R_TRANSP.CD_DEPOSITO);
         P_REC_TRANSP.CD_TRANSPORTADORA            := R_TRANSP.CD_TRANSPORTADORA;
         P_REC_TRANSP.DS_TRANSPORTADORA            := R_TRANSP.DS_TRANSPORTADORA;
         P_REC_TRANSP.NU_INSCRICAO                 := R_TRANSP.NU_INSCRICAO;
         P_REC_TRANSP.CD_CNPJ_TRANSPORTADORA       := R_TRANSP.CD_CNPJ_TRANSPORTADORA;
         P_REC_TRANSP.CD_CEP                       := R_TRANSP.CD_CEP;
         P_REC_TRANSP.DS_ENDERECO                  := R_TRANSP.DS_ENDERECO;
         P_REC_TRANSP.NU_ENDERECO                  := R_TRANSP.NU_ENDERECO;
         P_REC_TRANSP.DS_COMPLEMENTO               := R_TRANSP.DS_COMPLEMENTO;
         P_REC_TRANSP.DS_BAIRRO                    := R_TRANSP.DS_BAIRRO;
         P_REC_TRANSP.DS_MUNICIPIO                 := R_TRANSP.DS_MUNICIPIO;
         P_REC_TRANSP.CD_UF                        := R_TRANSP.CD_UF;
         P_REC_TRANSP.NU_TELEFONE                  := R_TRANSP.NU_TELEFONE;
         P_REC_TRANSP.NU_FAX                       := R_TRANSP.NU_FAX;
         P_REC_TRANSP.CD_SITUACAO                  := R_TRANSP.CD_SITUACAO;
         P_REC_TRANSP.FILLER_1                     := R_TRANSP.FILLER_1;
         P_REC_TRANSP.FILLER_2                     := R_TRANSP.FILLER_2;
         P_REC_TRANSP.FILLER_3                     := R_TRANSP.FILLER_3;
         P_REC_TRANSP.FILLER_4                     := R_TRANSP.FILLER_4;
         P_REC_TRANSP.FILLER_5                     := R_TRANSP.FILLER_5;
         P_REC_TRANSP.CD_IMPRESSORA_ETIQ_EXPEDICAO := R_TRANSP.CD_IMPR_ETIQ_EXPEDICAO;
         --
         PR_INS_TRANSP(P_REC_TRANSP);
         CLOSE C_TRANSP;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         D_SQLERRM            := SQLERRM;
         P_MSG                := NULL;
         P_MSG.CD_FIL         := GC.PCK_1.G_FIL_AMBIENTE;
         P_MSG.ID_MSG         := NULL;
         P_MSG.NM_PACOTE      := 'PCK_GERAR_INTERF_WMS';
         P_MSG.NM_PROGR       := 'PR_GRV_TRANSP';
         P_MSG.IN_TEL_RET     := 'T';
         P_MSG.ID_USR_ORIGEM  := USER;
         P_MSG.ID_USR_DESTINO := 'HELPDESK';
         P_MSG.NR_ITENS       := 0;
         P_MSG.NR_OCOR        := 0;
         P_MSG.TX_OCOR        := 'INTERFACE DE FORNECEDOR PARA WMS ' || 'ERRO<' || D_SQLERRM || '> ';
         D_ID_MSG             := GC.GRV_GC_MSG(P_MSG);
         COMMIT;
         --
   END PR_GRV_TRANSP;
   --
   -- Dados da Nota Fiscal no WMS --
   -- Se NFT ou NFS - desce pela GUIA/placa para buscar as NF da Guia liberada
   -- Se NFE - passa somente a placa
   PROCEDURE PR_GRV_CAB_NOTA_FISCAL(P_DS_PLACA    IN NF_TERCEIRO.DS_PLACA%TYPE,
                                    P_ID_GUIA_LIB IN NF_TERCEIRO.ID_GUIA_LIB_GLB%TYPE,
                                    P_DT_INIC     IN NF_TERCEIRO.DT_INIC_DES%TYPE,
                                    P_ID_AUTORIZA IN VARCHAR2) IS
      -- Se NFT ou NFS - desce pela GUIA para buscar as NF da Guia liberada
      -- Se NFE - passa o Numero da NF de entrada
      -- Declara rowtype para insert
      P_REC_CABNF WMS.INT_E_CAB_NOTA_FISCAL%ROWTYPE;
      --
      V_CD_DEP_WMS VARCHAR2(3);
      V_ENVIA_FORN VARCHAR2(1) := 'S';
      -- Busca os dados da Nota Fiscal para Recebimento
      CURSOR C_NF IS
         SELECT 1 CD_EMPRESA,
                NULL CD_AGENDA, -- a agenda ser� controlada pelo WMS
                NFT.NR_NF NU_NOTA,
                NFT.DS_SER NU_SERIE_NOTA,
                NULL CD_TRANSPORTADORA,
                NULL DS_TRANSPORTADORA,
                NULL CD_CNPJ_TRANSPORTADORA,
                NFT.ID_PESSOA CD_FORNECEDOR,
                P.ID_CGC CD_CNPJ_FORNECEDOR,
                TO_CHAR(NFT.DT_EMIS, 'DD/MM/YYYY HH24:MI:SS') DT_EMISSAO,
                NFT.DS_PLACA DS_PLACA,
                TO_CHAR(NVL(NFT.DT_INIC_DES, SYSDATE), 'DD/MM/YYYY HH24:MI:SS') DT_AGENDAMENTO,
                DECODE(P_ID_AUTORIZA, 'S', 1, 2) CD_SITUACAO, -- 1 - INCLUS�O / 2 - CANCELAMENTO
                NVL(NTN.CD_TIPO_NF_WMS, 'FRN') CD_TIPO_NOTA,
                NFT.ID_GUIA_LIB_GLB NU_DOC_ERP,
                NULL CD_RAV,
                NULL FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5,
                NULL QT_VOLUMES,
                NFT.ID_LOCAL_DES ID_LOCAL_DES,
                NFT.CD_FIL_ESTQ_DES CD_FIL_ESTQ_DES,
                NFT.DT_INIC_DES DT_INIC_DES,
                NFT.CD_FIL CD_FIL_NF,
                'NFT' TP_NF
           FROM NF_TERCEIRO        NFT,
                PESSOA             P,
                NATUREZA_TIPO_NOTA NTN
          WHERE NFT.ID_GUIA_LIB_GLB = P_ID_GUIA_LIB
            AND NFT.DS_PLACA = P_DS_PLACA
            AND TRUNC(NFT.DT_INIC_DES) = P_DT_INIC
            AND NFT.DT_REJ IS NULL
            AND NFT.IN_NF_PROD = 'S'
            AND NFT.DT_REC IS NULL
            AND NFT.IN_PEND_REC = 'S'
            AND P.ID_PESSOA = NFT.ID_PESSOA
            AND GC.NF_TERCEIRO_VALIDA(NFT.NR_NF, NFT.DT_EMIS, NFT.ID_PESSOA, NFT.DS_SER, NFT.NR_SUBSER) = 'V'
            AND NTN.CD_NAT_OPER = NFT.CD_NAT_OPER
            AND NTN.IN_ENTR_SAIDA = NFT.IN_ENTR_SAIDA
            AND NTN.CD_TIPO_NF = NFT.CD_TIPO_NF
            AND NOT EXISTS (SELECT 1
                              FROM CTR_NOTA_FISCAL_RECEB CNFR
                             WHERE CNFR.NU_NOTA = NFT.NR_NF
                               AND CNFR.NU_SERIE_NOTA = NFT.DS_SER
                               AND CNFR.DS_PLACA = NFT.DS_PLACA
                               AND CNFR.ID_GUIA_LIB_GLB = NFT.ID_GUIA_LIB_GLB
                               AND CNFR.ID_RECEBIDO NOT IN ('C','E')) -- CANCELADO / ERRO
         UNION
         -- union para busca NFs de Saida que ser�o recebidas no CD Extrema-
         SELECT 1 CD_EMPRESA,
                NULL CD_AGENDA, -- a agenda ser� controlada pelo WMS
                NFS.NR_NF NU_NOTA,
                NFS.DS_SER NU_SERIE_NOTA,
                NULL CD_TRANSPORTADORA,
                NULL DS_TRANSPORTADORA,
                NULL CD_CNPJ_TRANSPORTADORA,
                P.ID_PESSOA CD_FORNECEDOR,
                P.ID_CGC CD_CNPJ_FORNECEDOR,
                TO_CHAR(NFS.DT_EMIS, 'DD/MM/YYYY HH24:MI:SS') DT_EMISSAO,
                NFS.DS_PLACA DS_PLACA,
                TO_CHAR(NVL(NFS.DT_INIC_DES, SYSDATE), 'DD/MM/YYYY HH24:MI:SS') DT_AGENDAMENTO,
                DECODE(P_ID_AUTORIZA, 'S', 1, 2) CD_SITUACAO, -- 1 - INCLUS�O / 2 - CANCELAMENTO
                NVL(NTN.CD_TIPO_NF_WMS, 'TRF') CD_TIPO_NOTA,
                NFS.ID_GUIA_LIB_GLB NU_DOC_ERP,
                NULL CD_RAV,
                NULL FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5,
                NULL QT_VOLUMES,
                NFS.ID_LOCAL_RCP_DES ID_LOCAL_DES,
                NFS.CD_FIL_ESTQ_RCP_DES CD_FIL_ESTQ_DES,
                NFS.DT_INIC_DES DT_INIC_DES,
                NFS.CD_FIL CD_FIL_NF,
                'NFS' TP_NF
           FROM NF_SAIDA           NFS,
                PESSOA             P,
                NATUREZA_TIPO_NOTA NTN
          WHERE NFS.ID_GUIA_LIB_GLB = P_ID_GUIA_LIB
            AND NFS.DS_PLACA = P_DS_PLACA
            AND TRUNC(NFS.DT_INIC_DES) = P_DT_INIC
            AND NFS.DT_REC IS NULL
            AND NFS.IN_NF_PROD = 'S'
            AND P.CD_FIL_TOK = NFS.CD_FIL -- filial que emitiu a NF
            AND NTN.CD_NAT_OPER = NFS.CD_NAT_OPER_NZN
            AND NTN.IN_ENTR_SAIDA = NFS.IN_ENTR_SAIDA_NZN
            AND NTN.CD_TIPO_NF = NFS.CD_TIPO_NF_NZN
            AND NOT EXISTS (SELECT 1
                              FROM CTR_NOTA_FISCAL_RECEB CNFR
                             WHERE CNFR.NU_NOTA = NFS.NR_NF
                               AND CNFR.NU_SERIE_NOTA = NFS.DS_SER
                               AND CNFR.DS_PLACA = NFS.DS_PLACA
                               AND CNFR.ID_GUIA_LIB_GLB = NFS.ID_GUIA_LIB_GLB
                               AND CNFR.ID_RECEBIDO NOT IN ('C','E')) -- CANCELADO / ERRO
          ORDER BY 4;
      R_NF C_NF%ROWTYPE;
      --
      CURSOR C_NFE IS
         SELECT 1 CD_EMPRESA,
                NULL CD_AGENDA, -- a agenda ser� controlada pelo WMS
                NFE.NR_NF NU_NOTA,
                NFE.DS_SER NU_SERIE_NOTA,
                TO_CHAR(NFE.DT_EMIS, 'DD/MM/YYYY HH24:MI:SS') DT_EMISSAO,
                NFE.DS_PLACA DS_PLACA,
                P.ID_PESSOA CD_FORNECEDOR,
                P.ID_CGC CD_CNPJ_FORNECEDOR,
                TO_CHAR(NVL(NFE.DT_INIC_DES, SYSDATE), 'DD/MM/YYYY HH24:MI:SS') DT_AGENDAMENTO,
                DECODE(P_ID_AUTORIZA, 'S', 1, 2) CD_SITUACAO, -- 1 - INCLUS�O / 2 - CANCELAMENTO
                NVL(NTN.CD_TIPO_NF_WMS, 'DEV') CD_TIPO_NOTA,
                NFE.NR_NF NU_DOC_ERP, -- nfe n�o possui Guia de libera��o, grava NR_NF - campo obrig no WMS
                NULL FILLER_1,
                NULL FILLER_2,
                NULL FILLER_3,
                NULL FILLER_4,
                NULL FILLER_5,
                NULL QT_VOLUMES,
                NFE.ID_LOCAL_RCP_DES ID_LOCAL_DES,
                NFE.CD_FIL_ESTQ_RCP_DES CD_FIL_ESTQ_DES,
                NFE.DT_INIC_DES DT_INIC_DES,
                NFE.CD_FIL CD_FIL_NF,
                'NFE' TP_NF
           FROM NF_ENTRADA         NFE,
                NATUREZA_TIPO_NOTA NTN,
                PESSOA             P
          WHERE NFE.DS_PLACA = P_DS_PLACA
            AND TRUNC(NFE.DT_INIC_DES) = P_DT_INIC
            AND NFE.DT_CANC IS NULL
            AND NFE.DT_REC IS NULL
            AND P.CD_FIL_TOK = NFE.CD_FIL
            AND NTN.CD_NAT_OPER = NFE.CD_NAT_OPER
            AND NTN.IN_ENTR_SAIDA = NFE.IN_ENTR_SAIDA
            AND NTN.CD_TIPO_NF = NFE.CD_TIPO_NF
            AND NOT EXISTS (SELECT 1
                              FROM CTR_NOTA_FISCAL_RECEB CNFR
                             WHERE CNFR.NU_NOTA = NFE.NR_NF
                               AND CNFR.NU_SERIE_NOTA = NFE.DS_SER
                               AND CNFR.DS_PLACA = NFE.DS_PLACA
                               AND CNFR.ID_RECEBIDO NOT IN ('C','E')) -- CANCELADO / ERRO
          ORDER BY 4; -- NR_NF
      R_NFE C_NFE%ROWTYPE;
      --
      V_NR_NF NF_TERCEIRO.NR_NF%TYPE;
      --
      CURSOR C_DOCA IS
         SELECT L.NR_DOCA
           FROM GUIA_LIBERACAO L
          WHERE L.ID_GUIA_LIB = P_ID_GUIA_LIB
            AND L.DS_PLACA = P_DS_PLACA;
      V_NR_DOCA GUIA_LIBERACAO.NR_DOCA%TYPE;
      --
   BEGIN
      IF P_DS_PLACA IS NOT NULL AND
         P_ID_GUIA_LIB IS NOT NULL THEN
         OPEN C_NF;
         LOOP
            FETCH C_NF
               INTO R_NF;
            EXIT WHEN C_NF%NOTFOUND;
            --
            V_NR_NF      := R_NF.NU_NOTA;
            V_CD_DEP_WMS := WMS.RET_DEP_WMS_FILIAL(R_NF.CD_FIL_ESTQ_DES);
            --
            OPEN C_DOCA;
            FETCH C_DOCA
               INTO V_NR_DOCA;
            CLOSE C_DOCA;
            --
            P_REC_CABNF                        := NULL;
            P_REC_CABNF.CD_EMPRESA             := R_NF.CD_EMPRESA;
            P_REC_CABNF.CD_DEPOSITO            := V_CD_DEP_WMS;
            P_REC_CABNF.CD_AGENDA              := R_NF.CD_AGENDA;
            P_REC_CABNF.NU_NOTA                := R_NF.NU_NOTA;
            P_REC_CABNF.NU_SERIE_NOTA          := R_NF.NU_SERIE_NOTA;
            P_REC_CABNF.CD_PORTA               := V_NR_DOCA;
            P_REC_CABNF.CD_TRANSPORTADORA      := R_NF.CD_TRANSPORTADORA;
            P_REC_CABNF.DS_TRANSPORTADORA      := R_NF.DS_TRANSPORTADORA;
            P_REC_CABNF.CD_CNPJ_TRANSPORTADORA := R_NF.CD_CNPJ_TRANSPORTADORA;
            P_REC_CABNF.CD_FORNECEDOR          := R_NF.CD_FORNECEDOR;
            P_REC_CABNF.CD_CNPJ_FORNECEDOR     := R_NF.CD_CNPJ_FORNECEDOR;
            P_REC_CABNF.DT_EMISSAO             := R_NF.DT_EMISSAO;
            P_REC_CABNF.DS_PLACA               := R_NF.DS_PLACA;
            P_REC_CABNF.DT_AGENDAMENTO         := R_NF.DT_AGENDAMENTO;
            P_REC_CABNF.CD_SITUACAO            := R_NF.CD_SITUACAO;
            P_REC_CABNF.CD_TIPO_NOTA           := R_NF.CD_TIPO_NOTA;
            P_REC_CABNF.NU_DOC_ERP             := R_NF.NU_DOC_ERP;
            P_REC_CABNF.CD_RAV                 := R_NF.CD_RAV;
            P_REC_CABNF.FILLER_1               := R_NF.FILLER_1;
            P_REC_CABNF.FILLER_2               := R_NF.FILLER_2;
            P_REC_CABNF.FILLER_3               := R_NF.FILLER_3;
            P_REC_CABNF.FILLER_4               := R_NF.FILLER_4;
            P_REC_CABNF.FILLER_5               := R_NF.FILLER_5;
            P_REC_CABNF.QT_VOLUMES             := R_NF.QT_VOLUMES;
            -- Insere na tabela INT_E_CAB_NOTA_FISCAL
            PR_INS_CAB_NOTA_FISCAL(P_REC_CABNF);
            -- Chama Procedure Insere os Itens da NF
            PR_GRV_DET_NOTA_FISCAL(R_NF.TP_NF, R_NF.CD_FIL_NF, P_REC_CABNF);
            --
            IF R_NF.CD_SITUACAO = 1 THEN
               -- INCLUS�O
               PR_INS_CTR_NF_RECEB(R_NF.TP_NF, R_NF.ID_LOCAL_DES, R_NF.CD_FIL_ESTQ_DES, R_NF.DT_INIC_DES, P_REC_CABNF);
               -- Chama Procedure Insere o Fornecedor(emitente) NF
               IF V_ENVIA_FORN = 'S' THEN
                  PR_GRV_FORNECEDOR(R_NF.CD_FORNECEDOR, V_CD_DEP_WMS);
                  V_ENVIA_FORN := 'N';
               END IF;
            END IF;
            --
            COMMIT;
         END LOOP;
         CLOSE C_NF;
      ELSIF P_DS_PLACA IS NOT NULL AND
            P_ID_GUIA_LIB IS NULL THEN
         OPEN C_NFE;
         LOOP
            FETCH C_NFE
               INTO R_NFE;
            EXIT WHEN C_NFE%NOTFOUND;
            --
            V_NR_NF      := R_NFE.NU_NOTA;
            V_CD_DEP_WMS := WMS.RET_DEP_WMS_FILIAL(R_NFE.CD_FIL_ESTQ_DES);
            --
            P_REC_CABNF                    := NULL;
            P_REC_CABNF.CD_EMPRESA         := R_NFE.CD_EMPRESA;
            P_REC_CABNF.CD_DEPOSITO        := V_CD_DEP_WMS;
            P_REC_CABNF.CD_AGENDA          := R_NFE.CD_AGENDA;
            P_REC_CABNF.NU_NOTA            := R_NFE.NU_NOTA;
            P_REC_CABNF.NU_SERIE_NOTA      := R_NFE.NU_SERIE_NOTA;
            P_REC_CABNF.CD_PORTA           := V_NR_DOCA;
            P_REC_CABNF.CD_FORNECEDOR      := R_NFE.CD_FORNECEDOR;
            P_REC_CABNF.CD_CNPJ_FORNECEDOR := R_NFE.CD_CNPJ_FORNECEDOR;
            P_REC_CABNF.DT_EMISSAO         := R_NFE.DT_EMISSAO;
            P_REC_CABNF.DS_PLACA           := R_NFE.DS_PLACA;
            P_REC_CABNF.DT_AGENDAMENTO     := R_NFE.DT_AGENDAMENTO;
            P_REC_CABNF.CD_SITUACAO        := R_NFE.CD_SITUACAO;
            P_REC_CABNF.CD_TIPO_NOTA       := R_NFE.CD_TIPO_NOTA;
            P_REC_CABNF.NU_DOC_ERP         := R_NFE.NU_DOC_ERP;
            P_REC_CABNF.FILLER_1           := R_NFE.FILLER_1;
            P_REC_CABNF.FILLER_2           := R_NFE.FILLER_2;
            P_REC_CABNF.FILLER_3           := R_NFE.FILLER_3;
            P_REC_CABNF.FILLER_4           := R_NFE.FILLER_4;
            P_REC_CABNF.FILLER_5           := R_NFE.FILLER_5;
            P_REC_CABNF.QT_VOLUMES         := R_NFE.QT_VOLUMES;
            -- Insere na tabela INT_E_CAB_NOTA_FISCAL
            PR_INS_CAB_NOTA_FISCAL(P_REC_CABNF);
            -- Chama Procedure Insere os Itens da NF
            PR_GRV_DET_NOTA_FISCAL(R_NFE.TP_NF, R_NFE.CD_FIL_NF, P_REC_CABNF);
            --
            IF R_NFE.CD_SITUACAO = 1 THEN
               -- INCLUS�O
               PR_INS_CTR_NF_RECEB(R_NFE.TP_NF,
                                   R_NFE.ID_LOCAL_DES,
                                   R_NFE.CD_FIL_ESTQ_DES,
                                   R_NFE.DT_INIC_DES,
                                   P_REC_CABNF);
               --
               -- Chama Procedure Insere o Fornecedor(emitente) NF
               IF V_ENVIA_FORN = 'S' THEN
                  PR_GRV_FORNECEDOR(R_NFE.CD_FORNECEDOR, V_CD_DEP_WMS);
                  V_ENVIA_FORN := 'N';
               END IF;
            END IF;
            --
            COMMIT;
         END LOOP;
         CLOSE C_NFE;
      END IF; -- P_DS_PLACA IS NOT NULL...
      --
   EXCEPTION
      WHEN OTHERS THEN
         D_SQLERRM := SQLERRM;
         RAISE_APPLICATION_ERROR(-20001,
                                 'INTERF. CAB NOTA FISCAL PARA WMS NF:' || V_NR_NF || 'ERRO<' || D_SQLERRM || '> ');
         --
   END PR_GRV_CAB_NOTA_FISCAL;
   --
   -- Dados dos Itens da Nota Fiscal no WMS --
   PROCEDURE PR_GRV_DET_NOTA_FISCAL(P_TP_NF     IN VARCHAR2,
                                    P_CD_FIL_NF IN GC.FILIAL.CD_FIL%TYPE,
                                    P_REC_CABNF IN WMS.INT_E_CAB_NOTA_FISCAL%ROWTYPE) IS
      -- Declara rowtype para insert
      P_REC_DETNF WMS.INT_E_DET_NOTA_FISCAL%ROWTYPE;
      -- Busca os dados dos itens da Nota Fiscal para Recebimento (NF Terceiro / NF Saida / NF Entrada)
      CURSOR C_INF IS
         SELECT INFT.NR_ITEM NU_ITEM_CORP,
                INFT.ID_PROD CD_PRODUTO,
                INFT.QT_ITEM QT_PRODUTO,
                NULL         NU_LOTE,
                NULL         NU_LOTE_FORNECEDOR,
                NULL         DT_FABRICACAO,
                NULL         DS_AREA_ERP,
                NULL         FILLER_1,
                NULL         FILLER_2,
                NULL         FILLER_3,
                NULL         FILLER_4,
                NULL         FILLER_5,
                NULL         CD_CLIENTE,
                NULL         CD_CNPJ_CLIENTE,
                NULL         NU_PEDIDO_ORIGEM,
                NULL         CD_PRODUTO_GRADE,
                NULL         CD_EMBALAGEM,
                NULL         NU_ETIQUETA_LOTE
           FROM ITEM_NF_TERC_PRODUTO INFT
          WHERE P_TP_NF = 'NFT'
            AND INFT.ID_PESSOA = P_REC_CABNF.CD_FORNECEDOR
            AND INFT.NR_NF = P_REC_CABNF.NU_NOTA
            AND INFT.DS_SER = P_REC_CABNF.NU_SERIE_NOTA
            AND INFT.DT_EMIS = TO_DATE(P_REC_CABNF.DT_EMISSAO, 'DD/MM/YYYY HH24:MI:SS')
         UNION
         SELECT INFS.NR_ITEM NU_ITEM_CORP,
                INFS.ID_PROD CD_PRODUTO,
                INFS.QT_ITEM QT_PRODUTO,
                NULL         NU_LOTE,
                NULL         NU_LOTE_FORNECEDOR,
                NULL         DT_FABRICACAO,
                NULL         DS_AREA_ERP,
                NULL         FILLER_1,
                NULL         FILLER_2,
                NULL         FILLER_3,
                NULL         FILLER_4,
                NULL         FILLER_5,
                NULL         CD_CLIENTE,
                NULL         CD_CNPJ_CLIENTE,
                NULL         NU_PEDIDO_ORIGEM,
                NULL         CD_PRODUTO_GRADE,
                NULL         CD_EMBALAGEM,
                NULL         NU_ETIQUETA_LOTE
           FROM ITEM_NF_SAIDA_PRODUTO INFS
          WHERE P_TP_NF = 'NFS'
            AND INFS.CD_FIL = P_CD_FIL_NF
            AND INFS.NR_NF = P_REC_CABNF.NU_NOTA
            AND INFS.DS_SER = P_REC_CABNF.NU_SERIE_NOTA
            AND INFS.DT_EMIS = TO_DATE(P_REC_CABNF.DT_EMISSAO, 'DD/MM/YYYY HH24:MI:SS')
         UNION
         SELECT INFEP.NR_ITEM NU_ITEM_CORP,
                INFEP.ID_PROD CD_PRODUTO,
                INFEP.QT_ITEM QT_PRODUTO,
                NULL          NU_LOTE,
                NULL          NU_LOTE_FORNECEDOR,
                NULL          DT_FABRICACAO,
                NULL          DS_AREA_ERP, -- ver se h�vera tratamento de retorno neste caso
                NULL          FILLER_1,
                NULL          FILLER_2,
                NULL          FILLER_3,
                NULL          FILLER_4,
                NULL          FILLER_5,
                NULL          CD_CLIENTE,
                NULL          CD_CNPJ_CLIENTE,
                NULL          NU_PEDIDO_ORIGEM,
                NULL          CD_PRODUTO_GRADE,
                NULL          CD_EMBALAGEM,
                NULL          NU_ETIQUETA_LOTE
           FROM ITEM_NF_ENTR_PRODUTO INFEP
          WHERE P_TP_NF = 'NFE'
            AND INFEP.CD_FIL = P_CD_FIL_NF
            AND INFEP.NR_NF = P_REC_CABNF.NU_NOTA
            AND INFEP.DS_SER = P_REC_CABNF.NU_SERIE_NOTA
            AND INFEP.DT_EMIS = TO_DATE(P_REC_CABNF.DT_EMISSAO, 'DD/MM/YYYY HH24:MI:SS');
      R_INF C_INF%ROWTYPE;
      --
   BEGIN
      OPEN C_INF;
      LOOP
         FETCH C_INF
            INTO R_INF;
         EXIT WHEN C_INF%NOTFOUND;
         --
         P_REC_DETNF := NULL;
         --
         P_REC_DETNF.NU_SEQ             := P_REC_CABNF.NU_SEQ;
         P_REC_DETNF.CD_EMPRESA         := P_REC_CABNF.CD_EMPRESA;
         P_REC_DETNF.CD_DEPOSITO        := P_REC_CABNF.CD_DEPOSITO;
         P_REC_DETNF.CD_CLIENTE         := R_INF.CD_CLIENTE;
         P_REC_DETNF.CD_AGENDA          := P_REC_CABNF.CD_AGENDA;
         P_REC_DETNF.NU_NOTA            := P_REC_CABNF.NU_NOTA;
         P_REC_DETNF.NU_SERIE_NOTA      := P_REC_CABNF.NU_SERIE_NOTA;
         P_REC_DETNF.CD_FORNECEDOR      := P_REC_CABNF.CD_FORNECEDOR;
         P_REC_DETNF.CD_CGC_FORNECEDOR  := P_REC_CABNF.CD_CNPJ_FORNECEDOR;
         P_REC_DETNF.CD_SITUACAO        := P_REC_CABNF.CD_SITUACAO;
         P_REC_DETNF.NU_ITEM_CORP       := R_INF.NU_ITEM_CORP;
         P_REC_DETNF.CD_PRODUTO         := R_INF.CD_PRODUTO;
         P_REC_DETNF.QT_PRODUTO         := R_INF.QT_PRODUTO;
         P_REC_DETNF.NU_LOTE            := R_INF.NU_LOTE;
         P_REC_DETNF.NU_LOTE_FORNECEDOR := R_INF.NU_LOTE_FORNECEDOR;
         P_REC_DETNF.DT_FABRICACAO      := R_INF.DT_FABRICACAO;
         P_REC_DETNF.DS_AREA_ERP        := R_INF.DS_AREA_ERP;
         P_REC_DETNF.FILLER_1           := R_INF.FILLER_1;
         P_REC_DETNF.FILLER_2           := R_INF.FILLER_2;
         P_REC_DETNF.FILLER_3           := R_INF.FILLER_3;
         P_REC_DETNF.FILLER_4           := R_INF.FILLER_4;
         P_REC_DETNF.FILLER_5           := R_INF.FILLER_5;
         P_REC_DETNF.CD_CNPJ_CLIENTE    := R_INF.CD_CNPJ_CLIENTE;
         P_REC_DETNF.NU_PEDIDO_ORIGEM   := R_INF.NU_PEDIDO_ORIGEM;
         P_REC_DETNF.CD_PRODUTO_GRADE   := R_INF.CD_PRODUTO_GRADE;
         P_REC_DETNF.CD_EMBALAGEM       := R_INF.CD_EMBALAGEM;
         P_REC_DETNF.NU_ETIQUETA_LOTE   := R_INF.NU_ETIQUETA_LOTE;
         --
         -- Insere na tabela INT_E_CAB_PEDIDO_SAIDA
         PR_INS_DET_NOTA_FISCAL(P_REC_DETNF);
         -- enviar o fornecedor(Emitente) da NF para evitar problemas na descida da NF
         -- enviar os produtos que constam na NF para evitar problemas na descida da NF
         BEGIN
            PR_GRV_PRODUTO(R_INF.CD_PRODUTO);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;
      CLOSE C_INF;
      --
   EXCEPTION
      WHEN OTHERS THEN
         D_SQLERRM := SQLERRM;
         RAISE_APPLICATION_ERROR(-20001,
                                 'INTERF. DET NOTA FISCAL PARA WMS ' || ' seq ' || P_REC_CABNF.NU_SEQ || ' item corp ' ||
                                 P_REC_DETNF.NU_ITEM_CORP || ' - ' || P_REC_DETNF.CD_PRODUTO || 'ERRO<' || D_SQLERRM || '> ');
         --
   END PR_GRV_DET_NOTA_FISCAL;
   -------
   --
   -- Processo chamado das telas/processo de libera��o Romaneio que aciona as procedures popular
   --   as interfaces de INT_E de PEDIDO_SAIDA de acordo com o tipo de romaneio
   --   P_FIL_ROMANEIO/P_NR_ROMANEIO/P_DT_ROMANEIO - Dados do Romaneio
   --   P_TP_ROMANEIO - PDS / GUIA / REQ / POS / RUC
   --   P_TP_AGRUPA / NR_AGRUPA - casos de agrupamento (PDS/GUIA/REQ) - informa o Tipo e o Cod. do Agrupador
   --   P_CD_SITUACAO - 1 - Insere Pedido Saida WMS / 2 - Faturamento Pedido Saida / 3 - Cancela Pedido Saida WMS / 4 - Cancela NF
   --
   PROCEDURE PR_LIBERA_PEDIDO_SAIDA(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                                    P_TP_ROMANEIO  IN ROMANEIO_SEPARACAO.SG_REQUERENTE_RSD%TYPE,
                                    P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                                    P_DT_ROMANEIO  IN ROMANEIO_SEPARACAO.DT_GERA%TYPE,
                                    P_TP_AGRUPA    IN VARCHAR2,
                                    P_NR_AGRUPA    IN NUMBER,
                                    P_CD_SITUACAO  IN NUMBER) IS
      -- define as procedures que ser�o acionadas para gerar as informa��es nas tabelas de envio de PEDIDO_SAIDA
   BEGIN
      IF P_FIL_ROMANEIO IS NOT NULL AND
         P_NR_ROMANEIO IS NOT NULL THEN
         --
         IF P_TP_ROMANEIO = 'PDS' THEN
            -- Romaneio de PDS de Pedido Entrega Terceiro
            PR_PEDIDO_PDS(P_FIL_ROMANEIO, P_NR_ROMANEIO, P_TP_AGRUPA, P_NR_AGRUPA, P_CD_SITUACAO);
         ELSIF P_TP_ROMANEIO = 'GUIA' THEN
    	      -- LOG-551 - Helena.Matsui 24/02/21 - retirado chamada do forms - 08/04/21
      	    -- procedure busca os corte de romaneio e retira da IGES para descer para o WMS a qtde ajustada
            BEGIN
              GC.PCK_FALTA_ROM_WMS.PR_AVALIA_FALTA_ROM(P_FIL_ROMANEIO, P_NR_ROMANEIO);
            END;
            -- Romaneio de Guia de Libera��o de Pedido Entrega Terceiro
            PR_PEDIDO_GUIA(P_FIL_ROMANEIO, P_NR_ROMANEIO, P_TP_AGRUPA, P_NR_AGRUPA, P_CD_SITUACAO);
         ELSIF P_TP_ROMANEIO = 'REQ' THEN
            -- Romaneio de Requisi��o de Abastecimento Loja e Pedido Retira Loja
            PR_PEDIDO_REQ(P_FIL_ROMANEIO, P_NR_ROMANEIO, P_TP_AGRUPA, P_NR_AGRUPA, P_CD_SITUACAO);
         ELSIF P_TP_ROMANEIO = 'POS' THEN
            -- Romaneio de Requisi��o de POS e Requisi��o Interna com POS
            PR_PEDIDO_POS(P_FIL_ROMANEIO, P_NR_ROMANEIO, P_TP_AGRUPA, P_NR_AGRUPA, P_CD_SITUACAO);
         ELSIF P_TP_ROMANEIO = 'RUC' THEN
            IF P_DT_ROMANEIO IS NOT NULL THEN
               -- Romaneio de Requisi��o de Uso e Consumo
               PR_PEDIDO_RUC(P_FIL_ROMANEIO, P_NR_ROMANEIO, P_DT_ROMANEIO, P_CD_SITUACAO);
            ELSE
               RAISE_APPLICATION_ERROR (-20001, 'DT_GERA<' || P_DT_ROMANEIO ||'> '|| 'DEVE SER INFORMADO PARA REQUISICAO USO CONSUMO.');
            END IF;
         END IF; -- P_TP_ROMANEIO
      ELSE
         NULL;
         --RAISE_APPLICATION_ERROR (-20001, 'CD_FIL<' || P_FIL_ROMANEIO ||'> '|| 'ID_ROM<' || P_NR_ROMANEIO ||'> '|| 'DEVEM SER INFORMADOS.');
      END IF; -- Verifica Preenchimento Romaneio
   END PR_LIBERA_PEDIDO_SAIDA;
   --
   -- busca Nome e CPF/CGC da pessoa
   PROCEDURE PR_BUSCA_DADOS_PESSOA(P_ID_PESSOA  IN PESSOA.ID_PESSOA%TYPE,
                                   P_NM_PESSOA  OUT PESSOA.NM_PESSOA%TYPE,
                                   P_ID_CPF_CGC OUT PESSOA.ID_CGC%TYPE,
                                   P_CD_FIL_TOK OUT PESSOA.CD_FIL_TOK%TYPE) IS
      CURSOR C_PES IS
         SELECT P.NM_PESSOA              NM_PESSOA,
                NVL(P.ID_CPF, P.ID_CGC)  ID_CPF_CGC,
                P.CD_FIL_TOK             CD_FIL_TOK
           FROM PESSOA          P
          WHERE P.ID_PESSOA = P_ID_PESSOA
            AND P.CD_FIL_TOK IS NULL
         UNION
         -- LOG-595 - Invers�o do NM_PESSOA da FILIAL para sigla/nome filial
         SELECT F.SG_FIL || ' - ' || F.NM_FIL NM_PESSOA,
                P.ID_CGC                      ID_CPF_CGC,
                P.CD_FIL_TOK                  CD_FIL_TOK
           FROM PESSOA          P,
                FILIAL          F
          WHERE P.ID_PESSOA = P_ID_PESSOA
            AND P.CD_FIL_TOK IS NOT NULL
            AND F.CD_FIL    = P.CD_FIL_TOK;
   BEGIN
      OPEN C_PES;
      FETCH C_PES
         INTO P_NM_PESSOA,
              P_ID_CPF_CGC,
              P_CD_FIL_TOK;
      CLOSE C_PES;
   END PR_BUSCA_DADOS_PESSOA;

   -- Procedure acionada por PR_LIBERA_SEPARACAO, para buscar os dados dos PDS e gerar o PEDIDO_SAIDA para o WMS
      PROCEDURE PR_PEDIDO_PDS(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                           P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                           P_TP_AGRUPA    IN VARCHAR2,
                           P_NR_AGRUPA    IN NUMBER,
                           P_CD_SITUACAO  IN NUMBER) IS
      -- Busca os PDS agrupados no Romaneio
      -- 07/12/2020 Helena - Retirado a busca do ID_FROD na FROD para enviar como CD_ROTA - Retorno cursor original
      -- 31/03/2021 LOG-520 - LBUENO - Inclus�o do ID_FROD na FROD para enviar como CD_ROTA
      CURSOR C_PDS(P_FIL IN NUMBER,
                   P_ROM IN NUMBER) IS
         SELECT RSGP.ID_PDS,
                RSGP.ID_PESSOA_DEST  ID_TRANSP_RSGP,
                PDS.NR_PLACA,
                MIN(FROD.ID_FROD) CD_ROTA
           FROM GRUPO_PDS_ROM_SEPARACAO    GPRS,
                ROM_SEP_GRUPO_PDS          RSGP,
                PDS                        PDS,
                FRETE_REGRA_ORIGEM_DESTINO FROD,
                PESSOA                     PO
          WHERE RSGP.ID_GRUPO_PDS   = GPRS.ID_GRUPO_PDS
            AND PDS.ID_PDS          = RSGP.ID_PDS
            AND FROD.ID_PESSOA_DEST = RSGP.ID_PESSOA_DEST
            AND FROD.ID_ENDER_DEST  = RSGP.ID_ENDER_DEST
            AND FROD.ID_PESSOA_ORIG = PO.ID_PESSOA
            AND PO.CD_FIL_TOK       = GPRS.CD_FIL
            AND GPRS.CD_FIL = P_FIL
            AND GPRS.ID_ROM = P_ROM
         GROUP BY RSGP.ID_PDS,
                  RSGP.ID_PESSOA_DEST,
                  PDS.NR_PLACA ;
      R_PDS C_PDS%ROWTYPE;
      --
      --
      -- busca os Pedidos/Itens do PDS (IPV, POS, SPV)
      CURSOR C_ITEM_PED(P_FIL IN NUMBER,
                        P_ROM IN NUMBER,
                        P_PDS IN NUMBER) IS
         -- sele��o PVD
         SELECT 'PVD'              TP_DOCTO,
                PVD.DT_EMIS        DT_DOCTO,
                PVD.CD_FIL         CD_FIL_DOCTO,
                PVD.NR_PV          NR_DOCTO,
                IPV.ID_TGE         ID_TGE,
                (CASE
                   WHEN PVD.ID_PESSOA_CLI = 0 THEN
                    PVD.ID_PESSOA_EEC
                   ELSE
                    PVD.ID_PESSOA_CLI
                END)               CD_CLIENTE,
                PVD.ID_ENDER_EEC   ID_ENDER_EEC,
                PVD.ID_PESSOA_EEC  ID_PESSOA_EEC,
                TO_CHAR(PVD.DT_EMIS, 'DD/MM/YYYY HH24:MI:SS') DT_ENTRADA,
                PVD.ID_CANAL       ID_CANAL,
                CV.NM_CANAL        NM_CANAL,
                IPV.NR_ITEM        NR_ITEM,
                IPV.ID_PROD        ID_PROD,
                TRPS.QT_ITEM       QT_ITEM,
                IPS.ID_PDS         ID_PDS
           FROM ITEM_PED_VENDA    IPV,
                PEDIDO_VENDA      PVD,
                CANAL_VENDA       CV,
                ITEM_PDS          IPS,
                ITEM_ROMANEIO_PDS TRPS
          WHERE IPV.CD_FIL = IPS.CD_FIL_IPV
            AND IPV.NR_PV = IPS.NR_PV_IPV
            AND IPV.DT_EMIS = IPS.DT_EMIS_IPV
            AND IPV.NR_ITEM = IPS.NR_ITEM_IPV
               --
            AND PVD.DT_EMIS = IPV.DT_EMIS
            AND PVD.NR_PV = IPV.NR_PV
            AND PVD.CD_FIL = IPV.CD_FIL
            AND CV.ID_CANAL = PVD.ID_CANAL
               --
            AND IPS.ID_PDS = TRPS.ID_PDS
            AND IPS.NR_ITEM = TRPS.NR_ITEM_IPS
            AND IPS.ID_PROD_PRD = TRPS.ID_PROD
            AND IPS.NR_PV_IPV IS NOT NULL
            AND TRPS.CD_FIL = P_FIL
            AND TRPS.ID_ROM = P_ROM
            AND TRPS.ID_PDS = P_PDS
         UNION
         -- sele��o POS
         SELECT 'POS'              TP_DOCTO,
                PSO.DT_EMIS        DT_DOCTO,
                PSO.CD_FIL         CD_FIL_DOCTO,
                PSO.NR_PED         NR_DOCTO,
                NULL               ID_TGE,
                PSO.ID_PESSOA      CD_CLIENTE,
                PSO.ID_ENDER       ID_ENDER_EEC,
                PSO.ID_PESSOA_EEC  ID_PESSOA_EEC,
                TO_CHAR(PSO.DT_EMIS, 'DD/MM/YYYY HH24:MI:SS') DT_ENTRADA,
                NULL               ID_CANAL,
                NULL               NM_CANAL,
                IPX.NR_ITEM        NR_ITEM,
                IPX.ID_PROD        ID_PROD,
                TRPS.QT_ITEM       QT_ITEM,
                IPS.ID_PDS         ID_PDS
           FROM ITEM_PED_OUTRA_SAIDA  IPX,
                PED_OUTRA_SAIDA       PSO,
                ITEM_PDS              IPS,
                ITEM_ROMANEIO_PDS    TRPS
          WHERE IPX.CD_FIL      = IPS.CD_FIL_IPX
            AND IPX.NR_PED      = IPS.NR_PED_IPX
            AND IPX.NR_ITEM     = IPS.NR_ITEM_IPX
               --
            AND PSO.NR_PED      = IPX.NR_PED
            AND PSO.CD_FIL      = IPX.CD_FIL
               --
            AND IPS.ID_PDS      = TRPS.ID_PDS
            AND IPS.NR_ITEM     = TRPS.NR_ITEM_IPS
            AND IPS.ID_PROD_PRD = TRPS.ID_PROD
            AND IPS.NR_PED_IPX  IS NOT NULL
            AND TRPS.CD_FIL     = P_FIL
            AND TRPS.ID_ROM     = P_ROM
            AND TRPS.ID_PDS     = P_PDS
         UNION
         -- sele��o SPV
         SELECT 'SPV'                 TP_DOCTO,
                SPV.DT_EMIS           DT_DOCTO,
                SPV.CD_FIL            CD_FIL_DOCTO,
                SPV.NR_SOLIC          NR_DOCTO,
                NULL                  ID_TGE,
                SPV.ID_PESSOA_EEC     CD_CLIENTE,
                SPV.ID_ENDER_EEC      ID_ENDER_EEC,
                SPV.ID_PESSOA_EEC     ID_PESSOA_EEC,
                TO_CHAR(SPV.DT_EMIS, 'DD/MM/YYYY HH24:MI:SS') DT_ENTRADA,
                NULL                  ID_CANAL,
                NULL                  NM_CANAL,
                AIS.NR_SEQ_ITEM_ISV   NR_ITEM,
                NVL(ISV.ID_PROD_PRD, NVL(ISV.ID_PROD_ICF, ISV.ID_PROD_ISP)) ID_PROD,
                TRPS.QT_ITEM     QT_ITEM,
                IPS.ID_PDS       ID_PDS
           FROM ACAO_ITEM_SERVICO_POS_VENDA AIS,
                SERVICO_POS_VENDA           SPV,
                ITEM_SERVICO_POS_VENDA      ISV,
                ITEM_PDS                    IPS,
                ITEM_ROMANEIO_PDS           TRPS
          WHERE AIS.NR_ACAO     = IPS.NR_ACAO_AIS
            AND SPV.NR_SOLIC    = AIS.NR_SOLIC_ISV
            AND ISV.NR_SOLIC    = AIS.NR_SOLIC_ISV
            AND ISV.NR_SEQ_ITEM = AIS.NR_SEQ_ITEM_ISV
            --
            AND IPS.ID_PDS      = TRPS.ID_PDS
            AND IPS.NR_ITEM     = TRPS.NR_ITEM_IPS
            AND IPS.NR_ACAO_AIS IS NOT NULL
            AND TRPS.CD_FIL     = P_FIL
            AND TRPS.ID_ROM     = P_ROM
            AND TRPS.ID_PDS     = P_PDS
            ORDER BY 1 DESC,  -- TP_DOCTO
                     3,  -- CD_FIL_DOCTO
                     4,  -- NR_DOCTO
                     5;  -- ID_TGE
            -- incluir ID_TGE para ordenar corretamente - Qdo 2 ID_TGE do mesmo pedido vir no Romaneio/pds
      R_ITEM_PED C_ITEM_PED%ROWTYPE;
      --
      -- Regi�o com base no pds para concatena��o com o campo DS_PROGRAM_DIARIA_SERVICO
      CURSOR C_REG(P_ID_PDS PDS.ID_PDS%TYPE) IS
        SELECT RSE.SG_RSE
          FROM REGIAO_SERVICO RSE,
               PDS
         WHERE RSE.CD_REGIAO = PDS.CD_REGIAO
           AND PDS.ID_PDS = P_ID_PDS;
      R_REG  C_REG%ROWTYPE;
      --
      -- dados Grupo Entrega do pedido
      CURSOR C_TGE(P_ID_TGE IN NUMBER) IS
         SELECT TGE.ORDER_ID,
                LPAD(TGE.ORDER_FF,2,'0') ORDER_FF,
                TGE.ID_PESSOA_TRANSP,
                TO_CHAR(TGE.DT_ENTREGA, 'DD/MM/YYYY HH24:MI:SS') DT_ENTREGA
           FROM TOK_GRUPO_ENTREGA TGE
          WHERE TGE.ID_TGE = P_ID_TGE
            AND DT_CANC IS NULL;
      R_TGE C_TGE%ROWTYPE;
      --
      -- dados Endereco de Entrega ID_ENDERECO_EEC
      CURSOR C_END_ENTR(P_ID_ENDER IN NUMBER,
                        P_ID_PESSOA IN NUMBER) IS
         SELECT LPAD(EP.CD_CEP1,5,0)||LPAD(EP.CD_CEP2,3,'0') CD_CEP,
                SUBSTR(TL.AB_TIPO_LOGR, 1, 35) || ' ' || EP.NM_LOGR DS_ENDERECO,
                SUBSTR(EP.NR_LOGR, 1, 8) NU_ENDERECO,
                EP.CM_LOGR DS_COMPLEMENTO,
                SUBSTR(EP.NM_BAIRRO, 1, 72) DS_BAIRRO,
                C.NM_CIDADE DS_MUNICIPIO,
                EP.SG_ESTADO_CID CD_UF
           FROM ENDERECO_PESSOA EP,
                TIPO_LOGRADOURO TL,
                CIDADE          C
          WHERE EP.ID_ENDER   = P_ID_ENDER
            AND EP.ID_PESSOA  = P_ID_PESSOA
            AND EP.DT_EXCL IS NULL
            AND TL.ID_TIPO_LOGR(+) = EP.ID_TIPO_LOGR
            AND C.CD_CIDADE   = EP.CD_CIDADE_CID
            AND C.SG_ESTADO   = EP.SG_ESTADO_CID
            AND C.SG_PAIS     = EP.SG_PAIS_CID;
      R_END_ENTR C_END_ENTR%ROWTYPE;
      --
      -- busca UF se n�o vier o ID_ENDER_EEC prenchido
      CURSOR C_UF (P_PESSOA IN NUMBER) IS
         SELECT EP.SG_ESTADO_CID  SG_ESTADO
           FROM ENDERECO_PESSOA EP
          WHERE EP.ID_PESSOA = P_PESSOA
            AND EP.AB_ENDER IN ('CAD', 'ENT')
            AND EP.DT_EXCL IS NULL;
      R_UF   C_UF%ROWTYPE;
      --
      -- Declara rowtype para insert
      P_RELAC_PED  WMS.T_RELACIONA_PEDIDO_GC_WMS%ROWTYPE;
      P_REC_CABPED WMS.INT_E_CAB_PEDIDO_SAIDA%ROWTYPE;
      P_REC_DETPED WMS.INT_E_DET_PEDIDO_SAIDA%ROWTYPE;
      --
      -- Define se gera o Detalhe do Pedido/Produto Agrupando a Qtde do SKU ou por Unidade do SKU
      V_AGRUPA_QTDE_POR_SKU  VARCHAR2(1) := FNC_LE_GC_PARAMETRO(P_DS_PAR => 'AGRUPA_QTDE_POR_SKU');
      V_CD_DEP_WMS           VARCHAR2(3);
      --
      V_NU_PED_ORIGEM        T_RELACIONA_PEDIDO_GC_WMS.NU_PEDIDO_ORIGEM%TYPE;
      V_NU_CTRL_ITEM         INT_E_DET_PEDIDO_SAIDA.NU_CTRL_ITEM%TYPE;
      -- Para controlar quebra de pedido e incluir novo cabecalho de pedido
      V_TP_DOCTO_ANT         VARCHAR2(3) := NULL;
      V_NR_DOCTO_ANT         NUMBER      := NULL;
      V_DT_DOCTO_ANT         DATE        := NULL;
      V_CD_FIL_ANT           FILIAL.CD_FIL%TYPE := NULL;
      V_ID_TGE_ANT           TOK_GRUPO_ENTREGA.ID_TGE%TYPE := NULL;
      -- recebe retorno pr_busca_dados_pessoa
      V_AUX_CPF_CGC          PESSOA.ID_CGC%TYPE;
      V_CD_FIL_TOK           PESSOA.CD_FIL_TOK%TYPE;
      --
   BEGIN
      -- busca o deposito WMS associado � Filial (DP/DS) do GC
      V_CD_DEP_WMS := WMS.RET_DEP_WMS_FILIAL(P_FIL_ROMANEIO);
      --
      OPEN C_PDS(P_FIL_ROMANEIO, P_NR_ROMANEIO);
      LOOP
         FETCH C_PDS
            INTO R_PDS;
         EXIT WHEN C_PDS%NOTFOUND;
         --
         -- Retorna os pedidos/itens tratados no romaneio
         OPEN C_ITEM_PED(P_FIL_ROMANEIO, P_NR_ROMANEIO, R_PDS.ID_PDS);
         LOOP
            FETCH C_ITEM_PED
               INTO R_ITEM_PED;
            EXIT WHEN C_ITEM_PED%NOTFOUND;
            -- Determina a quebra de pedido para criar as tabelas de relacionamento e o cabecalho do Pedido Saida
            IF (V_NR_DOCTO_ANT IS NULL) OR
               (V_NR_DOCTO_ANT <> R_ITEM_PED.NR_DOCTO OR V_CD_FIL_ANT <> R_ITEM_PED.CD_FIL_DOCTO OR
               V_DT_DOCTO_ANT <> R_ITEM_PED.DT_DOCTO OR V_ID_TGE_ANT <> R_ITEM_PED.ID_TGE) OR
               (V_TP_DOCTO_ANT <> R_ITEM_PED.TP_DOCTO) THEN
               --
               V_NR_DOCTO_ANT  := R_ITEM_PED.NR_DOCTO;
               V_CD_FIL_ANT    := R_ITEM_PED.CD_FIL_DOCTO;
               V_DT_DOCTO_ANT  := R_ITEM_PED.DT_DOCTO;
               V_ID_TGE_ANT    := R_ITEM_PED.ID_TGE;
               V_TP_DOCTO_ANT  := R_ITEM_PED.TP_DOCTO;
               -- REINICIALIZA O CONTADOR DE ITENS DO PEDIDO
               V_NU_CTRL_ITEM  := 0;
               --
               -- verifica se j� existe um numero gerado para o PVD/REQ/RUC/...na tabela DE/PARA
               V_NU_PED_ORIGEM := WMS.PCK_CTRL_PEDIDO_SAIDA.FC_BUSCA_PED_ORIGEM(R_ITEM_PED.CD_FIL_DOCTO,
                                                                                R_ITEM_PED.NR_DOCTO,
                                                                                R_ITEM_PED.TP_DOCTO,
                                                                                R_ITEM_PED.DT_DOCTO,
                                                                                NULL,
                                                                                R_ITEM_PED.ID_TGE,
                                                                                P_NR_ROMANEIO,
                                                                                P_FIL_ROMANEIO);
               --
               IF V_NU_PED_ORIGEM IS NULL THEN
                  -- gera o registro para relacionar o romaneio/req.uso consumo da filial
                  P_RELAC_PED                  := NULL;
                  P_RELAC_PED.NU_PEDIDO_ORIGEM := NULL;
                  -- todos tipos de pedidos GC (PVD/SPV/POS) gerados no PDS ser�o tratados como PVP (Pedido Venda - Transp. Propria) no WMS - pois seguirao o mesmo fluxo
                  P_RELAC_PED.TP_PEDIDO_WMS    := 'PVP';
                  P_RELAC_PED.CD_FIL_DOCTO     := R_ITEM_PED.CD_FIL_DOCTO;
                  P_RELAC_PED.NR_DOCTO         := R_ITEM_PED.NR_DOCTO;
                  P_RELAC_PED.TP_DOCTO         := R_ITEM_PED.TP_DOCTO; -- tipo pedido GC
                  P_RELAC_PED.DT_EMIS_DOCTO    := R_ITEM_PED.DT_DOCTO;
                  P_RELAC_PED.ID_TGE           := R_ITEM_PED.ID_TGE;
                  P_RELAC_PED.ID_AGRUPADOR     := R_ITEM_PED.ID_PDS; -- P_NR_AGRUPA
                  P_RELAC_PED.TP_AGRUPADOR     := P_TP_AGRUPA; -- 'PDS'
                  P_RELAC_PED.ID_ROM           := P_NR_ROMANEIO;
                  P_RELAC_PED.CD_FIL_ROM       := P_FIL_ROMANEIO;
                  -- Insere registro com relacionamento do PED/REQ GC com Pedido WMS
                  WMS.PCK_CTRL_PEDIDO_SAIDA.PR_INS_RELACIONA_PEDIDOS(P_RELAC_PED);
               ELSE
                  -- � reenvio do pedido para o WMS - j� possui Pedido Origem gerado e deve manter o mesmo
                  P_RELAC_PED                  := NULL;
                  P_RELAC_PED.NU_PEDIDO_ORIGEM := V_NU_PED_ORIGEM;
                  P_RELAC_PED.TP_PEDIDO_WMS    := 'PVP';
               END IF;
               --
               -- Chama Procedure Insere o cliente
               PR_GRV_CLIENTE(R_ITEM_PED.CD_CLIENTE, V_CD_DEP_WMS);
               --
               -- Busco regi�o do PDS
               OPEN C_REG(R_PDS.ID_PDS);
               FETCH C_REG INTO R_REG;
               CLOSE C_REG;
               --
               -- Gerar o registro do cabecalho do Pedido Saida
               P_REC_CABPED := NULL;
               --
               P_REC_CABPED.NU_SEQ           := NULL; -- ser� gerado no PR_INS_CAB_PEDIDO_SAIDA
               P_REC_CABPED.CD_EMPRESA       := 1;
               P_REC_CABPED.CD_DEPOSITO      := V_CD_DEP_WMS;
               P_REC_CABPED.NU_PEDIDO_ORIGEM := P_RELAC_PED.NU_PEDIDO_ORIGEM;
               P_REC_CABPED.CD_CLIENTE       := R_ITEM_PED.CD_CLIENTE;
               --
               -- 20/10/2020 - LOG-365 Incluido campos para passagem das informa��es de PDS e PLACA do caminhao roteirizado
               P_REC_CABPED.DS_PROGRAM_DIARIA_SERVICO   := R_PDS.ID_PDS||'-'||R_REG.SG_RSE;
               P_REC_CABPED.DS_PLACA                    := R_PDS.NR_PLACA;
               --
               -- 20/11/2020 - LOG-441 - Envio ID_FROD como rota
               -- 07/12/2020 - retirar o envio do ID_FROD (R_PDS.CD_ROTA) como rota
               -- 31/03/2021 LOG-520 - LBUENO - Inclus�o do ID_FROD na FROD para enviar como CD_ROTA
               P_REC_CABPED.CD_ROTA          := R_PDS.CD_ROTA;
               P_REC_CABPED.DT_ENTRADA       := R_ITEM_PED.DT_ENTRADA;
               -- 04/01/2021 - Ajuste montagem Carga - Passando a Sigla da Praca da regi�o + Sequencia por pedido no lugar do P_NR_ROMANEIO
               --              P_REC_CABPED.CD_CARGA         := P_NR_ROMANEIO;
               BEGIN
                  SELECT SUBSTR(R_REG.SG_RSE,1,4)|| GC.SEQ_CARGA_PVP_WMS.NEXTVAL
                    INTO P_REC_CABPED.CD_CARGA
                    FROM DUAL;
               END;
               P_REC_CABPED.CD_SITUACAO      := P_CD_SITUACAO;
               P_REC_CABPED.TP_PEDIDO        := P_RELAC_PED.TP_PEDIDO_WMS;
               P_REC_CABPED.DS_TPPEDIDO      := NULL;
               P_REC_CABPED.CD_PORTA         := 0;
               -- Dados Cliente e Cliente Entrega
               PR_BUSCA_DADOS_PESSOA(R_ITEM_PED.CD_CLIENTE, P_REC_CABPED.DS_CLIENTE, P_REC_CABPED.CD_CNPJ_CLIENTE, V_CD_FIL_TOK);
               --
               IF R_ITEM_PED.CD_CLIENTE = R_ITEM_PED.ID_PESSOA_EEC THEN
                  P_REC_CABPED.DS_CLIENTE_ENTREGA := P_REC_CABPED.DS_CLIENTE;
               ELSE
                  PR_BUSCA_DADOS_PESSOA(R_ITEM_PED.ID_PESSOA_EEC, P_REC_CABPED.DS_CLIENTE_ENTREGA, V_AUX_CPF_CGC, V_CD_FIL_TOK);
               END IF;
               --
               IF R_ITEM_PED.ID_ENDER_EEC IS NOT NULL THEN
                  -- busca dados entrega de entrega
                  OPEN C_END_ENTR(R_ITEM_PED.ID_ENDER_EEC,
                                  NVL(R_ITEM_PED.ID_PESSOA_EEC, R_ITEM_PED.CD_CLIENTE));
                  FETCH C_END_ENTR
                     INTO R_END_ENTR;
                  CLOSE C_END_ENTR;
                  --
                  P_REC_CABPED.DS_ENDERECO_ENTREGA    := R_END_ENTR.DS_ENDERECO;
                  P_REC_CABPED.NU_ENDERECO_ENTREGA    := R_END_ENTR.NU_ENDERECO;
                  P_REC_CABPED.DS_COMPLEMENTO_ENTREGA := R_END_ENTR.DS_COMPLEMENTO;
                  P_REC_CABPED.DS_BAIRRO_ENTREGA      := R_END_ENTR.DS_BAIRRO;
                  P_REC_CABPED.DS_MUNICIPIO_ENTREGA   := R_END_ENTR.DS_MUNICIPIO;
                  P_REC_CABPED.CD_UF_ENTREGA          := R_END_ENTR.CD_UF;
                  P_REC_CABPED.CD_CEP_ENTREGA         := R_END_ENTR.CD_CEP;
               ELSE
                  -- Busca a sigla do estado do cliente - informa��o obrigatoria no wms
                  OPEN C_UF (R_ITEM_PED.CD_CLIENTE);
                  FETCH C_UF
                     INTO R_UF;
                  CLOSE C_UF;
                  --
                  P_REC_CABPED.CD_UF_ENTREGA := R_UF.SG_ESTADO;
               END IF;
               --
               IF R_ITEM_PED.ID_TGE IS NOT NULL THEN
                  OPEN C_TGE(R_ITEM_PED.ID_TGE);
                  FETCH C_TGE
                     INTO R_TGE;
                  CLOSE C_TGE;
                  --
                  --10/11/2020 - ajuste na montagem do NU_DOC_ERP - para n�o utilizar ORDER_ID - que estoura para MercadoLivre
                  --20/11/2020 - LOG-439 - Mudan�a ordem montagem de "FIL||NR_PV||DT EMS" Para "FIL ||DT EMIS||NR PV"
                  --P_REC_CABPED.NU_DOC_ERP := R_TGE.ORDER_ID || R_TGE.ORDER_FF;
                  P_REC_CABPED.NU_DOC_ERP := LPAD(R_ITEM_PED.CD_FIL_DOCTO, 3, '0') || TO_CHAR(R_ITEM_PED.DT_DOCTO, 'DDMMYYYY')||
                                             LPAD(R_ITEM_PED.NR_DOCTO, 7, '0') || R_TGE.ORDER_FF;
                  P_REC_CABPED.DT_ENTREGA := R_TGE.DT_ENTREGA;
               ELSE
                  P_REC_CABPED.NU_DOC_ERP := LPAD(R_ITEM_PED.CD_FIL_DOCTO, 3, '0') || TO_CHAR(R_ITEM_PED.DT_DOCTO, 'DDMMYYYY') ||
                                             LPAD(R_ITEM_PED.NR_DOCTO, 7, '0');
               END IF; -- ID_TGE
               --
               IF R_PDS.ID_TRANSP_RSGP IS NOT NULL THEN
                  P_REC_CABPED.CD_TRANSPORTADORA := R_PDS.ID_TRANSP_RSGP;
                  --
                  PR_BUSCA_DADOS_PESSOA(R_PDS.ID_TRANSP_RSGP,
                                        P_REC_CABPED.DS_TRANSPORTADORA,
                                        P_REC_CABPED.CD_CNPJ_TRANSPORTADORA,
                                        V_CD_FIL_TOK);
               ELSE
                  P_REC_CABPED.CD_TRANSPORTADORA      := 'NC';
                  P_REC_CABPED.CD_CNPJ_TRANSPORTADORA := 0;
                  P_REC_CABPED.DS_TRANSPORTADORA      := NULL;
               END IF;
               -- S� ser�o preenchidos depois de realizado o faturamento do pedido
               P_REC_CABPED.DT_FATURAMENTO     := NULL;
               P_REC_CABPED.NU_OBJETO_POSTAGEM := NULL;
               --
               --Chama Procedure Insere o Pedidpo Saida da RUC enviada no romaneio
               PR_INS_CAB_PEDIDO_SAIDA(P_REC_CABPED);
            END IF; -- V_NR_PVD_ANT IS NULL OR...
            --
            -- Tratamento det da requisi��o/romaneio - Detalhes Pedido Saida
            -- Verifica se gera a linha do SKU por Qtde Total ou por Unidade
            IF V_AGRUPA_QTDE_POR_SKU = 'S' THEN
               V_NU_CTRL_ITEM := NVL(V_NU_CTRL_ITEM,0) + 1;
               --
               P_REC_DETPED                       := NULL;
               P_REC_DETPED.NU_SEQ                := P_REC_CABPED.NU_SEQ;
               P_REC_DETPED.CD_EMPRESA            := P_REC_CABPED.CD_EMPRESA;
               P_REC_DETPED.CD_DEPOSITO           := P_REC_CABPED.CD_DEPOSITO;
               P_REC_DETPED.NU_PEDIDO_ORIGEM      := P_REC_CABPED.NU_PEDIDO_ORIGEM;
               P_REC_DETPED.CD_CLIENTE            := P_REC_CABPED.CD_CLIENTE;
               P_REC_DETPED.CD_PRODUTO            := R_ITEM_PED.ID_PROD;
               P_REC_DETPED.NU_ITEM_CORP          := R_ITEM_PED.NR_ITEM;
               P_REC_DETPED.QT_SEPARAR            := R_ITEM_PED.QT_ITEM;
               P_REC_DETPED.CD_SITUACAO           := P_REC_CABPED.CD_SITUACAO;
               P_REC_DETPED.NU_LOTE               := NULL;
               P_REC_DETPED.NU_PEDIDO             := NULL;
               P_REC_DETPED.ID_EMBALAGEM_PRESENTE := 'N';
               P_REC_DETPED.DS_AREA_ERP           := NULL;
               P_REC_DETPED.CD_CARGA              := P_REC_CABPED.CD_CARGA;
               P_REC_DETPED.NU_CTRL_ITEM          := V_NU_CTRL_ITEM;
               -- S� ser�o preenchidos depois de realizado o faturamento do pedido
               P_REC_DETPED.NU_NOTA        := NULL;
               P_REC_DETPED.NU_SERIE_NOTA  := NULL;
               P_REC_DETPED.CFOP           := NULL;
               P_REC_DETPED.DT_NOTA_FISCAL := NULL;
               P_REC_DETPED.CD_CHAVE_DANFE := NULL;
               --
               -- Chama Procedure Insere os Itens da RUC enviadas no romaneio
               PR_INS_DET_PEDIDO_SAIDA(P_REC_DETPED);
            ELSE
               FOR I IN 1 .. R_ITEM_PED.QT_ITEM LOOP
                  V_NU_CTRL_ITEM := NVL(V_NU_CTRL_ITEM,0) + 1;
                  --
                  P_REC_DETPED                       := NULL;
                  P_REC_DETPED.NU_SEQ                := P_REC_CABPED.NU_SEQ;
                  P_REC_DETPED.CD_EMPRESA            := P_REC_CABPED.CD_EMPRESA;
                  P_REC_DETPED.CD_DEPOSITO           := P_REC_CABPED.CD_DEPOSITO;
                  P_REC_DETPED.NU_PEDIDO_ORIGEM      := P_REC_CABPED.NU_PEDIDO_ORIGEM;
                  P_REC_DETPED.CD_CLIENTE            := P_REC_CABPED.CD_CLIENTE;
                  P_REC_DETPED.CD_PRODUTO            := R_ITEM_PED.ID_PROD;
                  P_REC_DETPED.NU_ITEM_CORP          := R_ITEM_PED.NR_ITEM;
                  P_REC_DETPED.QT_SEPARAR            := 1;
                  P_REC_DETPED.CD_SITUACAO           := P_REC_CABPED.CD_SITUACAO;
                  P_REC_DETPED.NU_LOTE               := NULL;
                  P_REC_DETPED.NU_PEDIDO             := NULL;
                  P_REC_DETPED.ID_EMBALAGEM_PRESENTE := 'N';
                  P_REC_DETPED.DS_AREA_ERP           := NULL;
                  P_REC_DETPED.CD_CARGA              := P_REC_CABPED.CD_CARGA;
                  P_REC_DETPED.NU_CTRL_ITEM          := V_NU_CTRL_ITEM;
                  -- S� ser�o preenchidos depois de realizado o faturamento do pedido
                  P_REC_DETPED.NU_NOTA               := NULL;
                  P_REC_DETPED.NU_SERIE_NOTA         := NULL;
                  P_REC_DETPED.CFOP                  := NULL;
                  P_REC_DETPED.DT_NOTA_FISCAL        := NULL;
                  P_REC_DETPED.CD_CHAVE_DANFE        := NULL;
                  --
                  -- Chama Procedure Insere os Itens do PDS enviadas no romaneio
                  PR_INS_DET_PEDIDO_SAIDA(P_REC_DETPED);
               END LOOP; -- FOR I IN ...
            END IF; -- V_AGRUPA_QTDE_POR_SKU
            --
         END LOOP; -- C_ITEM_PED
         CLOSE C_ITEM_PED;
         --
         COMMIT;
      END LOOP; -- C_PDS
      CLOSE C_PDS;
   EXCEPTION
      WHEN OTHERS THEN
         D_SQLERRM := SQLERRM;
         RAISE_APPLICATION_ERROR(-20001,
                                 'INTERF. PEDIDO SAIDA PDS PARA WMS :' ||   'ERRO<' || D_SQLERRM || '> ');

   END PR_PEDIDO_PDS;

   -- Procedure acionada por PR_LIBERA_SEPARACAO, para buscar os dados da Guia liberada e gerar o PEDIDO_SAIDA para o WMS
   PROCEDURE PR_PEDIDO_GUIA(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                            P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                            P_TP_AGRUPA    IN VARCHAR2,
                            P_NR_AGRUPA    IN NUMBER,
                            P_CD_SITUACAO  IN NUMBER) IS
      -- LOG-389 Alteracao da procedure de PVT - CARGA
      -- Data 14/10 - n�o popular o CD_CARGA

      -- busca os Pedidos/Itens no romaneio gerado
      -- neste cen�rio n�o foi considerado
      --      SPV - pois em entrega Terceiro n�o h� itens de PSV para acompanhar
      --      POS - n�o n�o h� ocorrencias na tabela RGVI - e no processo de GUIA s� trata PEDIDO DE VENDA entrega Terceiros
      CURSOR C_ITEM_PED(P_FIL IN NUMBER,
                        P_ROM IN NUMBER) IS
         SELECT 'PVD'              TP_DOCTO,
                PVD.DT_EMIS        DT_DOCTO,
                PVD.CD_FIL         CD_FIL_DOCTO,
                PVD.NR_PV          NR_DOCTO,
                (CASE
                   WHEN PVD.ID_PESSOA_CLI = 0 THEN
                    PVD.ID_PESSOA_EEC
                   ELSE
                    PVD.ID_PESSOA_CLI
                END) CD_CLIENTE,
                PVD.ID_ENDER_EEC,
                PVD.ID_PESSOA_EEC,
                TO_CHAR(PVD.DT_EMIS, 'DD/MM/YYYY HH24:MI:SS') DT_ENTRADA,
                PVD.ID_CANAL,
                CV.NM_CANAL,
                IPV.NR_ITEM,
                IPV.ID_TGE,
                IPV.ID_PROD,
                IGES.QT_PROGR_IPV  QT_PROGR,
                --09/12/20 - mudanca tab. busca ID_FROD de RSGV para GES
                GES.ID_FROD,
                RSGG.ID_RSGV
           FROM ITEM_PED_VENDA               IPV,
                PEDIDO_VENDA                 PVD,
                CANAL_VENDA                  CV,
                CLIENTE_RESERVA_ESTOQUE      CLR,
                GUIA_EMPACOTAMENTO_SITE      GES,
                ITEM_GUIA_EMPACOTAMENTO_SITE IGES,
                ROM_SEP_GRUPO_VENDA          RSGV,
                ROM_SEP_GRUPO_VENDA_ITEM     RGVI,
                ROM_SEP_GERADO_GRUPO_VENDA   RSGG
          WHERE IPV.CD_FIL       = RGVI.CD_FIL_IPV
            AND IPV.NR_PV        = RGVI.NR_PV_IPV
            AND IPV.DT_EMIS      = RGVI.DT_EMIS_IPV
            AND IPV.NR_ITEM      = RGVI.NR_ITEM_IPV
               --
            AND PVD.DT_EMIS      = IPV.DT_EMIS
            AND PVD.NR_PV        = IPV.NR_PV
            AND PVD.CD_FIL       = IPV.CD_FIL
            AND CV.ID_CANAL      = PVD.ID_CANAL
               --
            AND GES.ID_RSGV      = RSGG.ID_RSGV
            AND IGES.ID_GES      = GES.ID_GES
            AND IGES.CD_FIL_IPV  = IPV.CD_FIL
            AND IGES.NR_PV_IPV   = IPV.NR_PV
            AND IGES.ID_PROD_IPV = IPV.ID_PROD
            AND IGES.NR_ITEM_IPV = IPV.NR_ITEM
            -- incluido para n�o entrar produtos que n�o puderam ser romaneados e n�o gera INT_E_DET 22/01 - HMatsui
            AND NVL(IGES.QT_PROGR_IPV,0) <> 0
               --
            AND CLR.CD_FIL_IPV  = IPV.CD_FIL
            AND CLR.NR_PV_IPV   = IPV.NR_PV
            AND CLR.ID_PROD     = IPV.ID_PROD
            AND CLR.NR_ITEM_IPV = IPV.NR_ITEM
            AND CLR.CD_FIL_RESV = RSGG.CD_FIL_RSD
               --
            AND RSGV.ID_RSGV     = RSGG.ID_RSGV
            AND RGVI.ID_RSGV     = RSGG.ID_RSGV
            AND RGVI.NR_PV_IPV   IS NOT NULL
            AND RSGG.ID_ROM_RSD  = P_ROM
            AND RSGG.CD_FIL_RSD  = P_FIL
          ORDER BY RGVI.CD_FIL_IPV,
                   RGVI.NR_PV_IPV,
                   IPV.ID_TGE,
                   RGVI.NR_ITEM_IPV;
      R_ITEM_PED C_ITEM_PED%ROWTYPE;
      --
      -- dados Grupo Entrega do pedido
      CURSOR C_TGE(P_ID_TGE IN NUMBER) IS
         SELECT TGE.ORDER_ID,
                LPAD(TGE.ORDER_FF,2,'0') ORDER_FF,
                TGE.ID_PESSOA_TRANSP,
                TO_CHAR(TGE.DT_ENTREGA, 'DD/MM/YYYY HH24:MI:SS') DT_ENTREGA
           FROM TOK_GRUPO_ENTREGA TGE
          WHERE TGE.ID_TGE = P_ID_TGE
            AND DT_CANC IS NULL;
      R_TGE C_TGE%ROWTYPE;
      --
      -- dados Endereco de Entrega ID_ENDERECO_EEC
      CURSOR C_END_ENTR(P_ID_ENDER  IN NUMBER,
                        P_ID_PESSOA IN NUMBER) IS
         SELECT LPAD(EP.CD_CEP1,5,0)||LPAD(EP.CD_CEP2,3,'0') CD_CEP,
                SUBSTR(TL.AB_TIPO_LOGR, 1, 35) || ' ' || EP.NM_LOGR DS_ENDERECO,
                SUBSTR(EP.NR_LOGR, 1, 8) NU_ENDERECO,
                EP.CM_LOGR DS_COMPLEMENTO,
                SUBSTR(EP.NM_BAIRRO, 1, 72) DS_BAIRRO,
                C.NM_CIDADE DS_MUNICIPIO,
                EP.SG_ESTADO_CID CD_UF
           FROM ENDERECO_PESSOA EP,
                TIPO_LOGRADOURO TL,
                CIDADE          C
          WHERE EP.ID_ENDER        = P_ID_ENDER
            AND EP.ID_PESSOA       = P_ID_PESSOA
            AND EP.DT_EXCL IS NULL
            AND TL.ID_TIPO_LOGR(+) = EP.ID_TIPO_LOGR
            AND C.CD_CIDADE        = EP.CD_CIDADE_CID
            AND C.SG_ESTADO        = EP.SG_ESTADO_CID
            AND C.SG_PAIS          = EP.SG_PAIS_CID;
      R_END_ENTR C_END_ENTR%ROWTYPE;
      -- busca UF se n�o vier o ID_ENDER_EEC preenchido
      CURSOR C_UF (P_PESSOA IN NUMBER) IS
         SELECT EP.SG_ESTADO_CID  SG_ESTADO
           FROM ENDERECO_PESSOA EP
          WHERE EP.ID_PESSOA = P_PESSOA
            AND EP.AB_ENDER IN ('CAD', 'ENT')
            AND EP.DT_EXCL  IS NULL;
      R_UF   C_UF%ROWTYPE;
      --
      -- Declara rowtype para insert
      P_RELAC_PED  WMS.T_RELACIONA_PEDIDO_GC_WMS%ROWTYPE;
      P_REC_CABPED WMS.INT_E_CAB_PEDIDO_SAIDA%ROWTYPE;
      P_REC_DETPED WMS.INT_E_DET_PEDIDO_SAIDA%ROWTYPE;
      --
      -- Define se gera o Detalhe do Pedido/Produto Agrupando a Qtde do SKU ou por Unidade do SKU
      V_AGRUPA_QTDE_POR_SKU  VARCHAR2(1) := FNC_LE_GC_PARAMETRO(P_DS_PAR => 'AGRUPA_QTDE_POR_SKU');
      V_CD_DEP_WMS           VARCHAR2(3);
      --
      V_NU_PED_ORIGEM        T_RELACIONA_PEDIDO_GC_WMS.NU_PEDIDO_ORIGEM%TYPE;
      V_NU_CTRL_ITEM         INT_E_DET_PEDIDO_SAIDA.NU_CTRL_ITEM%TYPE;
      -- Para controlar quebra de pedido e incluir novo cabecalho de pedido
      V_TP_DOCTO_ANT         VARCHAR2(3) := NULL;
      V_NR_DOCTO_ANT         NUMBER      := NULL;
      V_DT_DOCTO_ANT         DATE        := NULL;
      V_CD_FIL_ANT           FILIAL.CD_FIL%TYPE := NULL;
      V_ID_TGE_ANT           TOK_GRUPO_ENTREGA.ID_TGE%TYPE := NULL;
      -- recebe retorno pr_busca_dados_pessoa
      V_AUX_CPF_CGC          PESSOA.ID_CGC%TYPE;
      V_CD_FIL_TOK           PESSOA.CD_FIL_TOK%TYPE;
      --
   BEGIN
      -- busca o deposito WMS associado � Filial (DP/DS) do GC
      V_CD_DEP_WMS := WMS.RET_DEP_WMS_FILIAL(P_FIL_ROMANEIO);
      --
      -- Retorna os pedidos/itens tratados no romaneio
      OPEN C_ITEM_PED(P_FIL_ROMANEIO, P_NR_ROMANEIO);
      LOOP
         FETCH C_ITEM_PED
            INTO R_ITEM_PED;
         EXIT WHEN C_ITEM_PED%NOTFOUND;
         -- Determina a quebra de pedido para criar as tabelas de relacionamento e o cabecalho do Pedido Saida
         IF (V_NR_DOCTO_ANT IS NULL) OR
            (V_NR_DOCTO_ANT <> R_ITEM_PED.NR_DOCTO OR V_CD_FIL_ANT <> R_ITEM_PED.CD_FIL_DOCTO OR
             V_DT_DOCTO_ANT <> R_ITEM_PED.DT_DOCTO OR V_ID_TGE_ANT <> R_ITEM_PED.ID_TGE) OR
            (V_TP_DOCTO_ANT <> R_ITEM_PED.TP_DOCTO) THEN
            --
            V_NR_DOCTO_ANT  := R_ITEM_PED.NR_DOCTO;
            V_CD_FIL_ANT    := R_ITEM_PED.CD_FIL_DOCTO;
            V_DT_DOCTO_ANT  := R_ITEM_PED.DT_DOCTO;
            V_ID_TGE_ANT    := R_ITEM_PED.ID_TGE;
            V_TP_DOCTO_ANT  := R_ITEM_PED.TP_DOCTO;
            -- REINICIALIZA O CONTADOR DE ITENS DO PEDIDO
            V_NU_CTRL_ITEM  := 0;
            --
            -- verifica se j� existe um numero gerado para o PVD/REQ/RUC/...na tabela DE/PARA
            V_NU_PED_ORIGEM := WMS.PCK_CTRL_PEDIDO_SAIDA.FC_BUSCA_PED_ORIGEM(R_ITEM_PED.CD_FIL_DOCTO,
                                                                             R_ITEM_PED.NR_DOCTO,
                                                                             R_ITEM_PED.TP_DOCTO,
                                                                             R_ITEM_PED.DT_DOCTO,
                                                                             NULL,
                                                                             R_ITEM_PED.ID_TGE,
                                                                             P_NR_ROMANEIO,
                                                                             P_FIL_ROMANEIO);
            --
            IF V_NU_PED_ORIGEM IS NULL THEN
               -- gera o registro para relacionar o romaneio/req.uso consumo da filial
               P_RELAC_PED                  := NULL;
               P_RELAC_PED.NU_PEDIDO_ORIGEM := NULL;
               -- todos tipos de pedidos GC (PVD) gerados na Guia ser�o tratados como PVT (Pedido - Transp. Terceiro) no WMS - pois seguirao o mesmo fluxo
               P_RELAC_PED.TP_PEDIDO_WMS    := 'PVT';
               P_RELAC_PED.CD_FIL_DOCTO     := R_ITEM_PED.CD_FIL_DOCTO;
               P_RELAC_PED.NR_DOCTO         := R_ITEM_PED.NR_DOCTO;
               P_RELAC_PED.TP_DOCTO         := R_ITEM_PED.TP_DOCTO;
               P_RELAC_PED.DT_EMIS_DOCTO    := R_ITEM_PED.DT_DOCTO;
               P_RELAC_PED.ID_TGE           := R_ITEM_PED.ID_TGE;
               P_RELAC_PED.ID_AGRUPADOR     := R_ITEM_PED.ID_RSGV; -- P_NR_AGRUPA
               P_RELAC_PED.TP_AGRUPADOR     := P_TP_AGRUPA; -- 'GUIA'
               P_RELAC_PED.ID_ROM           := P_NR_ROMANEIO;
               P_RELAC_PED.CD_FIL_ROM       := P_FIL_ROMANEIO;
               -- Insere registro com relacionamento do PED/REQ GC com Pedido WMS
               WMS.PCK_CTRL_PEDIDO_SAIDA.PR_INS_RELACIONA_PEDIDOS(P_RELAC_PED);
            ELSE
               -- � reenvio do pedido para o WMS - j� possui Pedido Origem gerado e deve manter o mesmo
               P_RELAC_PED                  := NULL;
               P_RELAC_PED.NU_PEDIDO_ORIGEM := V_NU_PED_ORIGEM;
               P_RELAC_PED.TP_PEDIDO_WMS    := 'PVT';
            END IF;
            --
            -- Chama Procedure Insere o cliente
            PR_GRV_CLIENTE(R_ITEM_PED.CD_CLIENTE, V_CD_DEP_WMS);
            --
            -- Gerar o registro do cabecalho do Pedido Saida
            P_REC_CABPED := NULL;
            --
            P_REC_CABPED.NU_SEQ           := NULL; -- ser� gerado no PR_INS_CAB_PEDIDO_SAIDA
            P_REC_CABPED.CD_EMPRESA       := 1;
            P_REC_CABPED.CD_DEPOSITO      := V_CD_DEP_WMS;
            P_REC_CABPED.NU_PEDIDO_ORIGEM := P_RELAC_PED.NU_PEDIDO_ORIGEM;
            P_REC_CABPED.CD_CLIENTE       := R_ITEM_PED.CD_CLIENTE;
            --
            P_REC_CABPED.DT_ENTRADA       := R_ITEM_PED.DT_ENTRADA;
            -- LOG-389 - n�o popular CD_CARGA com ID Romaneio
            --P_REC_CABPED.CD_CARGA         := P_NR_ROMANEIO;
            P_REC_CABPED.CD_SITUACAO      := P_CD_SITUACAO;
            P_REC_CABPED.TP_PEDIDO        := P_RELAC_PED.TP_PEDIDO_WMS;
            P_REC_CABPED.DS_TPPEDIDO      := NULL;
            P_REC_CABPED.CD_PORTA         := 0;
            -- 16/11/2020 - LOG-441 - Envio ID_FROD como rota
            P_REC_CABPED.CD_ROTA          := R_ITEM_PED.ID_FROD;
            --
            -- Dados Cliente e Cliente Entrega
            PR_BUSCA_DADOS_PESSOA(R_ITEM_PED.CD_CLIENTE, P_REC_CABPED.DS_CLIENTE, P_REC_CABPED.CD_CNPJ_CLIENTE, V_CD_FIL_TOK);
            --
            IF R_ITEM_PED.CD_CLIENTE = R_ITEM_PED.ID_PESSOA_EEC THEN
               P_REC_CABPED.DS_CLIENTE_ENTREGA := P_REC_CABPED.DS_CLIENTE;
            ELSE
               PR_BUSCA_DADOS_PESSOA(R_ITEM_PED.ID_PESSOA_EEC, P_REC_CABPED.DS_CLIENTE_ENTREGA, V_AUX_CPF_CGC, V_CD_FIL_TOK);
            END IF;
            --
            IF R_ITEM_PED.ID_ENDER_EEC IS NOT NULL THEN
               -- busca dados entrega de entrega
               OPEN C_END_ENTR(R_ITEM_PED.ID_ENDER_EEC,
                               NVL(R_ITEM_PED.ID_PESSOA_EEC, R_ITEM_PED.CD_CLIENTE));
               FETCH C_END_ENTR
                  INTO R_END_ENTR;
               CLOSE C_END_ENTR;
               --
               P_REC_CABPED.DS_ENDERECO_ENTREGA    := R_END_ENTR.DS_ENDERECO;
               P_REC_CABPED.NU_ENDERECO_ENTREGA    := R_END_ENTR.NU_ENDERECO;
               P_REC_CABPED.DS_COMPLEMENTO_ENTREGA := R_END_ENTR.DS_COMPLEMENTO;
               P_REC_CABPED.DS_BAIRRO_ENTREGA      := R_END_ENTR.DS_BAIRRO;
               P_REC_CABPED.DS_MUNICIPIO_ENTREGA   := R_END_ENTR.DS_MUNICIPIO;
               P_REC_CABPED.CD_UF_ENTREGA          := R_END_ENTR.CD_UF;
               P_REC_CABPED.CD_CEP_ENTREGA         := R_END_ENTR.CD_CEP;
            ELSE
               -- Busca a sigla do estado do cliente - informa��o obrigatoria no wms
               OPEN C_UF (R_ITEM_PED.CD_CLIENTE);
               FETCH C_UF
                  INTO R_UF;
               CLOSE C_UF;
               --
               P_REC_CABPED.CD_UF_ENTREGA := R_UF.SG_ESTADO;
            END IF;
            --
            IF R_ITEM_PED.ID_TGE IS NOT NULL THEN
               OPEN C_TGE(R_ITEM_PED.ID_TGE);
               FETCH C_TGE
                  INTO R_TGE;
               CLOSE C_TGE;
               --
               --10/11/2020 - ajuste na montagem do NU_DOC_ERP - para n�o utilizar ORDER_ID - que estoura para MercadoLivre
               --20/11/2020 - LOG-439 - Mudan�a ordem montagem de "FIL||NR_PV||DT EMS" Para "FIL ||DT EMIS||NR PV"
               --P_REC_CABPED.NU_DOC_ERP := R_TGE.ORDER_ID || R_TGE.ORDER_FF;
               P_REC_CABPED.NU_DOC_ERP := LPAD(R_ITEM_PED.CD_FIL_DOCTO, 3, '0') || TO_CHAR(R_ITEM_PED.DT_DOCTO , 'DDMMYYYY')||
                                          LPAD(R_ITEM_PED.NR_DOCTO , 7, '0') || R_TGE.ORDER_FF;
               P_REC_CABPED.DT_ENTREGA := R_TGE.DT_ENTREGA;
               -- busca dados transportadora
               IF NVL(R_TGE.ID_PESSOA_TRANSP,0) <> 0 THEN
                  P_REC_CABPED.CD_TRANSPORTADORA      := R_TGE.ID_PESSOA_TRANSP;
                  --
                  PR_BUSCA_DADOS_PESSOA(R_TGE.ID_PESSOA_TRANSP,
                                        P_REC_CABPED.DS_TRANSPORTADORA,
                                        P_REC_CABPED.CD_CNPJ_TRANSPORTADORA,
                                        V_CD_FIL_TOK);
               ELSE
                  P_REC_CABPED.CD_TRANSPORTADORA      := 'NC';
                  P_REC_CABPED.CD_CNPJ_TRANSPORTADORA := 0;
                  P_REC_CABPED.DS_TRANSPORTADORA      := NULL;
               END IF;
            ELSE
               P_REC_CABPED.NU_DOC_ERP := LPAD(R_ITEM_PED.CD_FIL_DOCTO, 3, '0') || LPAD(R_ITEM_PED.NR_DOCTO , 7, '0') ||
                                          TO_CHAR(R_ITEM_PED.DT_DOCTO , 'DDMMYYYY');
               --
               P_REC_CABPED.CD_TRANSPORTADORA      := 'NC';
               P_REC_CABPED.CD_CNPJ_TRANSPORTADORA := 0;
               P_REC_CABPED.DS_TRANSPORTADORA      := NULL;
            END IF; -- ID_TGE
            -- S� ser�o preenchidos depois de realizado o faturamento do pedido
            P_REC_CABPED.DT_FATURAMENTO     := NULL;
            P_REC_CABPED.NU_OBJETO_POSTAGEM := NULL;
            P_REC_CABPED.DS_PLACA           := NULL;
            --
            --Chama Procedure Insere o Pedidpo Saida da RUC enviada no romaneio
            PR_INS_CAB_PEDIDO_SAIDA(P_REC_CABPED);
         END IF; -- V_NR_PVD_ANT IS NULL OR...
         --
         -- Tratamento det da requisi��o/romaneio - Detalhes Pedido Saida
         -- Verifica se gera a linha do SKU por Qtde Total ou por Unidade
         IF V_AGRUPA_QTDE_POR_SKU = 'S' THEN
            V_NU_CTRL_ITEM := NVL(V_NU_CTRL_ITEM,0) + 1;
            --
            P_REC_DETPED                       := NULL;
            P_REC_DETPED.NU_SEQ                := P_REC_CABPED.NU_SEQ;
            P_REC_DETPED.CD_EMPRESA            := P_REC_CABPED.CD_EMPRESA;
            P_REC_DETPED.CD_DEPOSITO           := P_REC_CABPED.CD_DEPOSITO;
            P_REC_DETPED.NU_PEDIDO_ORIGEM      := P_REC_CABPED.NU_PEDIDO_ORIGEM;
            P_REC_DETPED.CD_CLIENTE            := P_REC_CABPED.CD_CLIENTE;
            P_REC_DETPED.CD_PRODUTO            := R_ITEM_PED.ID_PROD;
            P_REC_DETPED.NU_ITEM_CORP          := R_ITEM_PED.NR_ITEM;
            P_REC_DETPED.QT_SEPARAR            := R_ITEM_PED.QT_PROGR;
            P_REC_DETPED.CD_SITUACAO           := P_REC_CABPED.CD_SITUACAO;
            P_REC_DETPED.NU_LOTE               := NULL;
            P_REC_DETPED.NU_PEDIDO             := NULL;
            P_REC_DETPED.ID_EMBALAGEM_PRESENTE := 'N';
            P_REC_DETPED.DS_AREA_ERP           := NULL;
            -- LOG-389 - n�o popular CD_CARGA com ID Romaneio
            --P_REC_DETPED.CD_CARGA              := P_REC_CABPED.CD_CARGA;
            P_REC_DETPED.NU_CTRL_ITEM          := V_NU_CTRL_ITEM;
            -- S� ser�o preenchidos depois de realizado o faturamento do pedido
            P_REC_DETPED.NU_NOTA               := NULL;
            P_REC_DETPED.NU_SERIE_NOTA         := NULL;
            P_REC_DETPED.CFOP                  := NULL;
            P_REC_DETPED.DT_NOTA_FISCAL        := NULL;
            P_REC_DETPED.CD_CHAVE_DANFE        := NULL;
            --
            -- Chama Procedure Insere os Itens da RUC enviadas no romaneio
            PR_INS_DET_PEDIDO_SAIDA(P_REC_DETPED);
         ELSE
            FOR I IN 1 .. R_ITEM_PED.QT_PROGR LOOP
               V_NU_CTRL_ITEM := NVL(V_NU_CTRL_ITEM,0) + 1;
               --
               P_REC_DETPED                       := NULL;
               P_REC_DETPED.NU_SEQ                := P_REC_CABPED.NU_SEQ;
               P_REC_DETPED.CD_EMPRESA            := P_REC_CABPED.CD_EMPRESA;
               P_REC_DETPED.CD_DEPOSITO           := P_REC_CABPED.CD_DEPOSITO;
               P_REC_DETPED.NU_PEDIDO_ORIGEM      := P_REC_CABPED.NU_PEDIDO_ORIGEM;
               P_REC_DETPED.CD_CLIENTE            := P_REC_CABPED.CD_CLIENTE;
               P_REC_DETPED.CD_PRODUTO            := R_ITEM_PED.ID_PROD;
               P_REC_DETPED.NU_ITEM_CORP          := R_ITEM_PED.NR_ITEM;
               P_REC_DETPED.QT_SEPARAR            := 1;
               P_REC_DETPED.CD_SITUACAO           := P_REC_CABPED.CD_SITUACAO;
               P_REC_DETPED.NU_LOTE               := NULL;
               P_REC_DETPED.NU_PEDIDO             := NULL;
               P_REC_DETPED.ID_EMBALAGEM_PRESENTE := 'N';
               P_REC_DETPED.DS_AREA_ERP           := NULL;
               P_REC_DETPED.CD_CARGA              := P_REC_CABPED.CD_CARGA;
               P_REC_DETPED.NU_CTRL_ITEM          := V_NU_CTRL_ITEM;
               -- S� ser�o preenchidos depois de realizado o faturamento do pedido
               P_REC_DETPED.NU_NOTA               := NULL;
               P_REC_DETPED.NU_SERIE_NOTA         := NULL;
               P_REC_DETPED.CFOP                  := NULL;
               P_REC_DETPED.DT_NOTA_FISCAL        := NULL;
               P_REC_DETPED.CD_CHAVE_DANFE        := NULL;
               --
               -- Chama Procedure Insere os Itens do PDS enviadas no romaneio
               PR_INS_DET_PEDIDO_SAIDA(P_REC_DETPED);
            END LOOP; -- FOR I IN ...
         END IF; -- V_AGRUPA_QTDE_POR_SKU
         --
      END LOOP; -- C_ITEM_PED
      CLOSE C_ITEM_PED;
      --
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         D_SQLERRM := SQLERRM;
         RAISE_APPLICATION_ERROR(-20001,
                                 'INTERF. PEDIDO_SAIDA GUIA ROMANEIO:' || P_NR_ROMANEIO || 'ERRO<' || D_SQLERRM || '> ');
         --
   END PR_PEDIDO_GUIA;

   -- Procedure acionada por PR_LIBERA_SEPARACAO, para buscar os dados das Requisi��es de Abastecimento Loja / Pedidos Retira Loja
   -- e gerar o PEDIDO_SAIDA para o WMS (Acess�rios e Moveis)
   PROCEDURE PR_PEDIDO_REQ(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                           P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                           P_TP_AGRUPA    IN VARCHAR2,
                           P_NR_AGRUPA    IN NUMBER,
                           P_CD_SITUACAO  IN NUMBER) IS
      -- busca os Pedidos/Itens do REQ (IRQ E IRT/IPV)
      CURSOR C_ITEM_REQ(P_FIL IN NUMBER,
                        P_ROM IN NUMBER) IS
         -- sele��o REQ - Filial
         SELECT 'REQ'              TP_PEDIDO_WMS,
                'REQ'              TP_DOCTO,
                REQ.DT_EMIS        DT_DOCTO,
                REQ.CD_FIL         CD_FIL_DOCTO,
                REQ.NR_REQ         NR_DOCTO,
                P.ID_PESSOA        CD_CLIENTE,
                P.ID_CGC           CD_CNPJ_CLIENTE,
                RSD.ID_ROM         CD_CARGA,
                P.ID_PESSOA        ID_PESSOA_EEC,
                TO_CHAR(REQ.DT_EMIS, 'DD/MM/YYYY HH24:MI:SS') DT_ENTRADA,
                IRD.NR_ITEM        NR_ITEM,
                NULL               ID_TGE,
                IRQ.ID_PROD        ID_PROD,
                RFRE.QT_ATEND      QT_ITEM,
                RSD.NR_REQ         ID_AGRUPADOR
           FROM PESSOA              P,
                REQ_FILIAL          REQ,
                ITEM_REQ_FILIAL     IRQ,
                REQ_FILIAL_RESERVA_ESTOQUE RFRE,
                ITEM_ROM_SEP        IRD,
                ROMANEIO_SEPARACAO  RSD
          WHERE P.CD_FIL_TOK = REQ.CD_FIL
            AND IRQ.ID_PROD = NVL(IRD.ID_PROD, IRD.ID_PROD_CMP)
            AND NVL(IRQ.QT_ATEND,0) <> 0
            AND IRQ.CD_FIL = REQ.CD_FIL
            AND IRQ.NR_REQ = REQ.NR_REQ
            AND REQ.CD_FIL = RSD.CD_FIL_REQ
            AND REQ.NR_REQ = RSD.NR_REQ
            --
            AND RFRE.CD_FIL_IRQ = IRQ.CD_FIL
            AND RFRE.NR_REQ_IRQ = IRQ.NR_REQ
            AND RFRE.ID_PROD    = IRQ.ID_PROD
            -- Para considerar somente as reservas da filial do romaneio gerado
            AND RFRE.CD_FIL_RESV = RSD.CD_FIL
            --
            AND (IRD.NR_COMP_CMP IS NULL OR IRD.NR_COMP_CMP = 1)
            AND IRD.CD_FIL = RSD.CD_FIL
            AND IRD.ID_ROM = RSD.ID_ROM
            AND RSD.CD_FIL = P_FIL
            AND RSD.ID_ROM = P_ROM
         UNION
         -- sele��o REQ - PVD Retira
         SELECT 'RET'              TP_PEDIDO_WMS,
                'PVD'              TP_DOCTO,
                PVD.DT_EMIS        DT_DOCTO,
                PVD.CD_FIL         CD_FIL_DOCTO,
                PVD.NR_PV          NR_DOCTO,
                P.ID_PESSOA        CD_CLIENTE,
                P.ID_CGC           CD_CNPJ_CLIENTE,
                RSD.ID_ROM         CD_CARGA,
                PVD.ID_PESSOA_CLI  ID_PESSOA_EEC,
                TO_CHAR(REQ.DT_EMIS, 'DD/MM/YYYY HH24:MI:SS') DT_ENTRADA,
                IPV.NR_ITEM        NR_ITEM,
                IPV.ID_TGE         ID_TGE,
                IRT.ID_PROD        ID_PROD,
                RFRE.QT_ATEND      QT_ITEM,
                RSD.NR_REQ         ID_AGRUPADOR
           FROM PESSOA              P,
                REQ_FILIAL          REQ,
                PEDIDO_VENDA        PVD,
                ITEM_PED_VENDA      IPV,
                ITEM_REQ_RETIRADA   IRT,
                REQ_FILIAL_RESERVA_ESTOQUE RFRE,
                ITEM_ROM_SEP        IRD,
                ROMANEIO_SEPARACAO  RSD
          WHERE P.CD_FIL_TOK = REQ.CD_FIL
            AND PVD.DT_EMIS  = IRT.DT_EMIS
            AND PVD.NR_PV    = IRT.NR_PV
            AND PVD.CD_FIL   = IRT.CD_FIL_IPV
            AND IPV.DT_EMIS  = PVD.DT_EMIS
            AND IPV.CD_FIL   = PVD.CD_FIL
            AND IPV.NR_PV    = PVD.NR_PV
            AND IPV.ID_PROD  = IRT.ID_PROD
            -- Correcao 23/10/20 Helena
            AND IPV.NR_ITEM  = IRT.NR_ITEM
            AND IRT.ID_PROD = NVL(IRD.ID_PROD, IRD.ID_PROD_CMP)
            AND NVL(IRT.QT_ATEND,0) <> 0
            AND IRT.CD_FIL = REQ.CD_FIL
            AND IRT.NR_REQ = REQ.NR_REQ
            AND REQ.CD_FIL = RSD.CD_FIL_REQ
            AND REQ.NR_REQ = RSD.NR_REQ
            --
            AND (IRD.NR_COMP_CMP IS NULL OR IRD.NR_COMP_CMP = 1)
            AND RFRE.CD_FIL_IRT  = IRT.CD_FIL
            AND RFRE.NR_REQ_IRT  = IRT.NR_REQ
            AND RFRE.NR_ITEM_IRT = IRT.NR_ITEM_IRT
            AND RFRE.ID_PROD     = IRT.ID_PROD
            -- Para considerar somente as reservas da filial do romaneio gerado
            AND RFRE.CD_FIL_RESV = RSD.CD_FIL
            --
            AND IRD.CD_FIL = RSD.CD_FIL
            AND IRD.ID_ROM = RSD.ID_ROM
            AND RSD.CD_FIL = P_FIL
            AND RSD.ID_ROM = P_ROM
            ORDER BY 2 desc,  -- TP_DOCTO
                     3,  -- CD_FIL_DOCTO
                     4,  -- NR_DOCTO
                    12;  -- id_tge
      R_ITEM_REQ C_ITEM_REQ%ROWTYPE;
      --
      -- dados Grupo Entrega do pedido
      CURSOR C_TGE(P_ID_TGE IN NUMBER) IS
         SELECT TGE.ORDER_ID,
                LPAD(TGE.ORDER_FF,2,'0') ORDER_FF,
                TGE.ID_PESSOA_TRANSP,
                TO_CHAR(TGE.DT_ENTREGA, 'DD/MM/YYYY HH24:MI:SS') DT_ENTREGA
           FROM TOK_GRUPO_ENTREGA TGE
          WHERE TGE.ID_TGE = P_ID_TGE
            AND DT_CANC IS NULL;
      R_TGE C_TGE%ROWTYPE;
      --
      -- dados Endereco de Entrega ID_ENDERECO_EEC
      CURSOR C_END_ENTR(P_ID_ENDER IN NUMBER,
                        P_ID_PESSOA IN NUMBER) IS
         SELECT LPAD(EP.CD_CEP1,5,0)||LPAD(EP.CD_CEP2,3,'0') CD_CEP,
                SUBSTR(TL.AB_TIPO_LOGR, 1, 35) || ' ' || EP.NM_LOGR DS_ENDERECO,
                SUBSTR(EP.NR_LOGR, 1, 8) NU_ENDERECO,
                EP.CM_LOGR DS_COMPLEMENTO,
                SUBSTR(EP.NM_BAIRRO, 1, 72) DS_BAIRRO,
                C.NM_CIDADE DS_MUNICIPIO,
                EP.SG_ESTADO_CID CD_UF
           FROM ENDERECO_PESSOA EP,
                TIPO_LOGRADOURO TL,
                CIDADE          C
          WHERE EP.ID_ENDER = P_ID_ENDER
            AND EP.ID_PESSOA = P_ID_PESSOA
            AND EP.DT_EXCL IS NULL
            AND TL.ID_TIPO_LOGR(+) = EP.ID_TIPO_LOGR
            AND C.CD_CIDADE = EP.CD_CIDADE_CID
            AND C.SG_ESTADO = EP.SG_ESTADO_CID
            AND C.SG_PAIS = EP.SG_PAIS_CID;
      R_END_ENTR C_END_ENTR%ROWTYPE;
      --
      -- busca UF da filial da requisi��o para abastecimento
      CURSOR C_UF (P_PESSOA IN NUMBER) IS
         SELECT EP.SG_ESTADO_CID  SG_ESTADO
           FROM ENDERECO_PESSOA EP
          WHERE EP.ID_PESSOA = P_PESSOA
            AND EP.AB_ENDER IN ('CAD', 'ENT')
            AND EP.DT_EXCL IS NULL;
      R_UF   C_UF%ROWTYPE;
      --
      -- Busca ID_FROD - CD_ROTA da FIL/Requisicao
      CURSOR C_FROD (P_FIL_ROM     IN NUMBER,
                     P_PESSOA_DEST IN NUMBER) IS
         SELECT FROD.ID_FROD
           FROM FRETE_REGRA_ORIGEM_DESTINO FROD,
                PESSOA                     PO
          WHERE FROD.ID_PESSOA_DEST = P_PESSOA_DEST
            AND FROD.ID_PESSOA_ORIG = PO.ID_PESSOA
            AND PO.CD_FIL_TOK = P_FIL_ROM;

      -- Declara rowtype para insert
      P_RELAC_PED  WMS.T_RELACIONA_PEDIDO_GC_WMS%ROWTYPE;
      P_REC_CABPED WMS.INT_E_CAB_PEDIDO_SAIDA%ROWTYPE;
      P_REC_DETPED WMS.INT_E_DET_PEDIDO_SAIDA%ROWTYPE;
      --
      -- Define se gera o Detalhe do Pedido/Produto Agrupando a Qtde do SKU ou por Unidade do SKU
      V_AGRUPA_QTDE_POR_SKU  VARCHAR2(1) := FNC_LE_GC_PARAMETRO(P_DS_PAR => 'AGRUPA_QTDE_POR_SKU');
      V_CD_DEP_WMS           VARCHAR2(3);
      --
      V_NU_PED_ORIGEM        T_RELACIONA_PEDIDO_GC_WMS.NU_PEDIDO_ORIGEM%TYPE;
      V_NU_CTRL_ITEM         INT_E_DET_PEDIDO_SAIDA.NU_CTRL_ITEM%TYPE;
      -- Para controlar quebra de pedido e incluir novo cabecalho de pedido
      V_TP_DOCTO_ANT         VARCHAR2(3) := NULL;
      V_NR_DOCTO_ANT         NUMBER      := NULL;
      V_DT_DOCTO_ANT         DATE        := NULL;
      V_CD_FIL_ANT           FILIAL.CD_FIL%TYPE := NULL;
      V_ID_TGE_ANT           TOK_GRUPO_ENTREGA.ID_TGE%TYPE := NULL;
      -- recebe retorno pr_busca_dados_pessoa
      V_AUX_CPF_CGC          PESSOA.ID_CGC%TYPE;
      V_CD_FIL_TOK           PESSOA.CD_FIL_TOK%TYPE;
      --
   BEGIN
      -- busca o deposito WMS associado � Filial (DP/DS) do GC
      V_CD_DEP_WMS := WMS.RET_DEP_WMS_FILIAL(P_FIL_ROMANEIO);
      --
      -- Retorna os pedidos/itens tratados no romaneio
      OPEN C_ITEM_REQ(P_FIL_ROMANEIO, P_NR_ROMANEIO);
      LOOP
         FETCH C_ITEM_REQ
            INTO R_ITEM_REQ;
         EXIT WHEN C_ITEM_REQ%NOTFOUND;
         -- Determina a quebra de pedido para criar as tabelas de relacionamento e o cabecalho do Pedido Saida
         IF (V_NR_DOCTO_ANT IS NULL) OR
            (V_NR_DOCTO_ANT <> R_ITEM_REQ.NR_DOCTO OR V_CD_FIL_ANT <> R_ITEM_REQ.CD_FIL_DOCTO OR
             V_DT_DOCTO_ANT <> R_ITEM_REQ.DT_DOCTO OR V_ID_TGE_ANT <> R_ITEM_REQ.ID_TGE) OR
            (V_TP_DOCTO_ANT <> R_ITEM_REQ.TP_DOCTO) THEN
            --
            V_NR_DOCTO_ANT  := R_ITEM_REQ.NR_DOCTO;
            V_CD_FIL_ANT    := R_ITEM_REQ.CD_FIL_DOCTO;
            V_DT_DOCTO_ANT  := R_ITEM_REQ.DT_DOCTO;
            V_ID_TGE_ANT    := R_ITEM_REQ.ID_TGE;
            V_TP_DOCTO_ANT  := R_ITEM_REQ.TP_DOCTO;
            -- REINICIALIZA O CONTADOR DE ITENS DO PEDIDO
            V_NU_CTRL_ITEM  := 0;
            --
            -- verifica se j� existe um numero gerado para o PVD/REQ/RUC/...na tabela DE/PARA
            V_NU_PED_ORIGEM := WMS.PCK_CTRL_PEDIDO_SAIDA.FC_BUSCA_PED_ORIGEM(R_ITEM_REQ.CD_FIL_DOCTO,
                                                                             R_ITEM_REQ.NR_DOCTO,
                                                                             R_ITEM_REQ.TP_DOCTO,
                                                                             R_ITEM_REQ.DT_DOCTO,
                                                                             NULL,
                                                                             R_ITEM_REQ.ID_TGE,
                                                                             P_NR_ROMANEIO,
                                                                             P_FIL_ROMANEIO);
            --
            IF V_NU_PED_ORIGEM IS NULL THEN
               -- gera o registro para relacionar o romaneio/req.uso consumo da filial
               P_RELAC_PED                  := NULL;
               P_RELAC_PED.NU_PEDIDO_ORIGEM := NULL;
               -- todos tipos de pedidos GC (PVD/SPV/POS) gerados no PDS ser�o tratados como PVP (Pedido Venda - Transp. Propria) no WMS - pois seguirao o mesmo fluxo
               P_RELAC_PED.TP_PEDIDO_WMS    := R_ITEM_REQ.TP_PEDIDO_WMS;
               P_RELAC_PED.CD_FIL_DOCTO     := R_ITEM_REQ.CD_FIL_DOCTO;
               P_RELAC_PED.NR_DOCTO         := R_ITEM_REQ.NR_DOCTO;
               P_RELAC_PED.TP_DOCTO         := R_ITEM_REQ.TP_DOCTO; -- tipo pedido GC
               P_RELAC_PED.DT_EMIS_DOCTO    := R_ITEM_REQ.DT_DOCTO;
               P_RELAC_PED.ID_TGE           := R_ITEM_REQ.ID_TGE;
               P_RELAC_PED.ID_AGRUPADOR     := R_ITEM_REQ.ID_AGRUPADOR;
               P_RELAC_PED.TP_AGRUPADOR     := P_TP_AGRUPA; -- 'REQ'
               P_RELAC_PED.ID_ROM           := P_NR_ROMANEIO;
               P_RELAC_PED.CD_FIL_ROM       := P_FIL_ROMANEIO;
               -- Insere registro com relacionamento do PED/REQ GC com Pedido WMS
               WMS.PCK_CTRL_PEDIDO_SAIDA.PR_INS_RELACIONA_PEDIDOS(P_RELAC_PED);
            ELSE
              -- � reenvio do pedido para o WMS - j� possui Pedido Origem gerado e deve manter o mesmo
               P_RELAC_PED                  := NULL;
               P_RELAC_PED.NU_PEDIDO_ORIGEM := V_NU_PED_ORIGEM;
               P_RELAC_PED.TP_PEDIDO_WMS    := R_ITEM_REQ.TP_PEDIDO_WMS;
            END IF;
            --
            -- Chama Procedure Insere o cliente
            PR_GRV_CLIENTE(R_ITEM_REQ.CD_CLIENTE, V_CD_DEP_WMS);
            --
            -- Gerar o registro do cabecalho do Pedido Saida
            P_REC_CABPED := NULL;
            --
            P_REC_CABPED.NU_SEQ           := NULL; -- ser� gerado no PR_INS_CAB_PEDIDO_SAIDA
            P_REC_CABPED.CD_EMPRESA       := 1;
            P_REC_CABPED.CD_DEPOSITO      := V_CD_DEP_WMS;
            P_REC_CABPED.NU_PEDIDO_ORIGEM := P_RELAC_PED.NU_PEDIDO_ORIGEM;
            P_REC_CABPED.CD_CLIENTE       := R_ITEM_REQ.CD_CLIENTE;
            -- 27/11/20 Helena - Retirar o envio do Romaneio no CD_CARGA de pedidos RET p/ desvincular do pedido REQ
            IF R_ITEM_REQ.TP_PEDIDO_WMS = 'REQ' THEN
               P_REC_CABPED.CD_CARGA         := P_NR_ROMANEIO;
            ELSE
               P_REC_CABPED.CD_CARGA         := NULL;
            END IF;
            --
            P_REC_CABPED.DT_ENTRADA       := R_ITEM_REQ.DT_ENTRADA;
            P_REC_CABPED.CD_SITUACAO      := P_CD_SITUACAO;
            P_REC_CABPED.TP_PEDIDO        := P_RELAC_PED.TP_PEDIDO_WMS;
            P_REC_CABPED.DS_TPPEDIDO      := NULL;
            P_REC_CABPED.CD_PORTA         := 0;
            --
            -- 20/11/2020 - LOG-441 - Busca ID_FROD - CD_ROTA da FIL/Requisicao
            OPEN C_FROD (P_FIL_ROMANEIO, R_ITEM_REQ.CD_CLIENTE);
            FETCH C_FROD
               INTO P_REC_CABPED.CD_ROTA;
            CLOSE C_FROD;
            --
            -- Dados Cliente e Cliente Entrega
            PR_BUSCA_DADOS_PESSOA(R_ITEM_REQ.CD_CLIENTE, P_REC_CABPED.DS_CLIENTE, P_REC_CABPED.CD_CNPJ_CLIENTE, V_CD_FIL_TOK);
            --
            IF R_ITEM_REQ.CD_CLIENTE = R_ITEM_REQ.ID_PESSOA_EEC THEN
               P_REC_CABPED.DS_CLIENTE_ENTREGA := P_REC_CABPED.DS_CLIENTE;
            ELSE
               PR_BUSCA_DADOS_PESSOA(R_ITEM_REQ.ID_PESSOA_EEC, P_REC_CABPED.DS_CLIENTE_ENTREGA, V_AUX_CPF_CGC, V_CD_FIL_TOK);
            END IF;
            --
            -- Busca a sigla do estado do cliente (Filial) - informa��o obrigatoria no wms
            OPEN C_UF (R_ITEM_REQ.CD_CLIENTE);
            FETCH C_UF
               INTO R_UF;
            CLOSE C_UF;
            --
            P_REC_CABPED.CD_UF_ENTREGA := R_UF.SG_ESTADO;
            --
            IF R_ITEM_REQ.ID_TGE IS NOT NULL THEN
               OPEN C_TGE(R_ITEM_REQ.ID_TGE);
               FETCH C_TGE
                  INTO R_TGE;
               CLOSE C_TGE;
               --
               --10/11/2020 - ajuste na montagem do NU_DOC_ERP - para n�o utilizar ORDER_ID - que estoura para MercadoLivre
               --20/11/2020 - LOG-439 - Mudan�a ordem montagem de "FIL||NR_PV||DT EMS" Para "FIL ||DT EMIS||NR PV"
               --30/11/2020 - Ajuste no tam max do campo NR_DOCTO de 7 para 10
               --P_REC_CABPED.NU_DOC_ERP := R_TGE.ORDER_ID || R_TGE.ORDER_FF;
               P_REC_CABPED.NU_DOC_ERP := LPAD(R_ITEM_REQ.CD_FIL_DOCTO, 3, '0') || TO_CHAR(R_ITEM_REQ.DT_DOCTO, 'DDMMYYYY') ||
                                          LPAD(R_ITEM_REQ.NR_DOCTO, 10, '0') || R_TGE.ORDER_FF;
               P_REC_CABPED.DT_ENTREGA := R_TGE.DT_ENTREGA;
            ELSE
               P_REC_CABPED.NU_DOC_ERP := LPAD(R_ITEM_REQ.CD_FIL_DOCTO, 3, '0') || TO_CHAR(R_ITEM_REQ.DT_DOCTO, 'DDMMYYYY') ||
                                          LPAD(R_ITEM_REQ.NR_DOCTO, 10, '0') ;
            END IF; -- ID_TGE
            -- -- incluir o tratamento para buscar a transportadora - hmm
            P_REC_CABPED.CD_TRANSPORTADORA      := 'NC';
            P_REC_CABPED.CD_CNPJ_TRANSPORTADORA := 0;
            P_REC_CABPED.DS_TRANSPORTADORA      := NULL;
            -- S� ser�o preenchidos depois de realizado o faturamento do pedido
            P_REC_CABPED.DT_FATURAMENTO         := NULL;
            P_REC_CABPED.NU_OBJETO_POSTAGEM     := NULL;
            P_REC_CABPED.DS_PLACA               := NULL;
            --
            --Chama Procedure Insere o Pedidpo Saida da RUC enviada no romaneio
            PR_INS_CAB_PEDIDO_SAIDA(P_REC_CABPED);
         END IF; -- V_NR_PVD_ANT IS NULL OR...
            --
            -- Tratamento det da requisi��o/romaneio - Detalhes Pedido Saida
            -- Verifica se gera a linha do SKU por Qtde Total ou por Unidade
            IF V_AGRUPA_QTDE_POR_SKU = 'S' THEN
               V_NU_CTRL_ITEM := NVL(V_NU_CTRL_ITEM,0) + 1;
               --
               P_REC_DETPED                       := NULL;
               P_REC_DETPED.NU_SEQ                := P_REC_CABPED.NU_SEQ;
               P_REC_DETPED.CD_EMPRESA            := P_REC_CABPED.CD_EMPRESA;
               P_REC_DETPED.CD_DEPOSITO           := P_REC_CABPED.CD_DEPOSITO;
               P_REC_DETPED.NU_PEDIDO_ORIGEM      := P_REC_CABPED.NU_PEDIDO_ORIGEM;
               P_REC_DETPED.CD_CLIENTE            := P_REC_CABPED.CD_CLIENTE;
               P_REC_DETPED.CD_PRODUTO            := R_ITEM_REQ.ID_PROD;
               P_REC_DETPED.NU_ITEM_CORP          := R_ITEM_REQ.NR_ITEM;
               P_REC_DETPED.QT_SEPARAR            := R_ITEM_REQ.QT_ITEM;
               P_REC_DETPED.CD_SITUACAO           := P_REC_CABPED.CD_SITUACAO;
               P_REC_DETPED.NU_LOTE               := NULL;
               P_REC_DETPED.NU_PEDIDO             := NULL;
               P_REC_DETPED.ID_EMBALAGEM_PRESENTE := 'N';
               P_REC_DETPED.DS_AREA_ERP           := NULL;
               P_REC_DETPED.CD_CARGA              := P_REC_CABPED.CD_CARGA;
               P_REC_DETPED.NU_CTRL_ITEM          := V_NU_CTRL_ITEM;
               -- S� ser�o preenchidos depois de realizado o faturamento do pedido
               P_REC_DETPED.NU_NOTA               := NULL;
               P_REC_DETPED.NU_SERIE_NOTA         := NULL;
               P_REC_DETPED.CFOP                  := NULL;
               P_REC_DETPED.DT_NOTA_FISCAL        := NULL;
               P_REC_DETPED.CD_CHAVE_DANFE        := NULL;
               --
               -- Chama Procedure Insere os Itens da RUC enviadas no romaneio
               PR_INS_DET_PEDIDO_SAIDA(P_REC_DETPED);
            ELSE
               FOR I IN 1 .. R_ITEM_REQ.QT_ITEM LOOP
                  V_NU_CTRL_ITEM := NVL(V_NU_CTRL_ITEM,0) + 1;
                  --
                  P_REC_DETPED                       := NULL;
                  P_REC_DETPED.NU_SEQ                := P_REC_CABPED.NU_SEQ;
                  P_REC_DETPED.CD_EMPRESA            := P_REC_CABPED.CD_EMPRESA;
                  P_REC_DETPED.CD_DEPOSITO           := P_REC_CABPED.CD_DEPOSITO;
                  P_REC_DETPED.NU_PEDIDO_ORIGEM      := P_REC_CABPED.NU_PEDIDO_ORIGEM;
                  P_REC_DETPED.CD_CLIENTE            := P_REC_CABPED.CD_CLIENTE;
                  P_REC_DETPED.CD_PRODUTO            := R_ITEM_REQ.ID_PROD;
                  P_REC_DETPED.NU_ITEM_CORP          := R_ITEM_REQ.NR_ITEM;
                  P_REC_DETPED.QT_SEPARAR            := 1;
                  P_REC_DETPED.CD_SITUACAO           := P_REC_CABPED.CD_SITUACAO;
                  P_REC_DETPED.NU_LOTE               := NULL;
                  P_REC_DETPED.NU_PEDIDO             := NULL;
                  P_REC_DETPED.ID_EMBALAGEM_PRESENTE := 'N';
                  P_REC_DETPED.DS_AREA_ERP           := NULL;
                  P_REC_DETPED.CD_CARGA              := P_REC_CABPED.CD_CARGA;
                  P_REC_DETPED.NU_CTRL_ITEM          := V_NU_CTRL_ITEM;
                  -- S� ser�o preenchidos depois de realizado o faturamento do pedido
                  P_REC_DETPED.NU_NOTA               := NULL;
                  P_REC_DETPED.NU_SERIE_NOTA         := NULL;
                  P_REC_DETPED.CFOP                  := NULL;
                  P_REC_DETPED.DT_NOTA_FISCAL        := NULL;
                  P_REC_DETPED.CD_CHAVE_DANFE        := NULL;
                  --
                  -- Chama Procedure Insere os Itens do PDS enviadas no romaneio
                  PR_INS_DET_PEDIDO_SAIDA(P_REC_DETPED);
               END LOOP; -- FOR I IN ...
            END IF; -- V_AGRUPA_QTDE_POR_SKU
            --
      END LOOP; -- C_ITEM_PED
      CLOSE C_ITEM_REQ;
      --
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         D_SQLERRM := SQLERRM;
         RAISE_APPLICATION_ERROR(-20001,
                                 'INTERF. PEDIDO SAIDA REQ PARA WMS :' ||   'ERRO<' || D_SQLERRM || '> ');

   END PR_PEDIDO_REQ;
   -- Procedure acionada por PR_LIBERA_SEPARACAO, para buscar os dados das POS GERADAS - Requisi��es Interna entre Filiais e Outros
   -- e gerar o PEDIDO_SAIDA para o WMS
   PROCEDURE PR_PEDIDO_POS(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                           P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                           P_TP_AGRUPA    IN VARCHAR2,
                           P_NR_AGRUPA    IN NUMBER,
                           P_CD_SITUACAO  IN NUMBER) IS
      -- busca os Pedidos/Itens do REQ (IRQ E IRT/IPV)
      CURSOR C_ITEM_POS(P_FIL IN NUMBER,
                        P_ROM IN NUMBER) IS
         SELECT 'POS'          TP_DOCTO,
                PSO.DT_EMIS    DT_DOCTO,
                PSO.CD_FIL     CD_FIL_DOCTO,
                PSO.NR_PED     NR_DOCTO,
                PSO.ID_PESSOA  CD_CLIENTE,
                RSD.ID_ROM     CD_CARGA,
                PSO.ID_PESSOA_EEC,
                PSO.ID_ENDER,
                TO_CHAR(PSO.DT_EMIS, 'DD/MM/YYYY HH24:MI:SS') DT_ENTRADA,
                IPX.NR_ITEM    NR_ITEM,
                IPX.ID_PROD    ID_PROD,
                IRD.QT_ROM     QT_ITEM,
                PSO.IN_ENTR_SAIDA_NZN,
                PSO.CD_TIPO_NF_NZN,
                PSO.CD_NAT_OPER_NZN
           FROM PED_OUTRA_SAIDA      PSO,
                ITEM_PED_OUTRA_SAIDA IPX,
                ITEM_ROM_SEP         IRD,
                ROMANEIO_SEPARACAO   RSD
          WHERE PSO.CD_FIL = RSD.CD_FIL_PSO
            AND PSO.NR_PED = RSD.NR_PED_PSO
            AND IPX.CD_FIL = PSO.CD_FIL
            AND IPX.NR_PED = PSO.NR_PED
            AND IPX.ID_PROD = NVL(IRD.ID_PROD, IRD.ID_PROD_CMP)
            --
            AND (IRD.NR_COMP_CMP IS NULL OR IRD.NR_COMP_CMP = 1)
            AND IRD.CD_FIL = RSD.CD_FIL
            AND IRD.ID_ROM = RSD.ID_ROM
            AND RSD.CD_FIL = P_FIL
            AND RSD.ID_ROM = P_ROM
          ORDER BY PSO.CD_FIL,
                   PSO.NR_PED,
                   IPX.NR_ITEM;
      R_ITEM_POS C_ITEM_POS%ROWTYPE;
      --
      -- dados Endereco de Entrega ID_ENDERECO_EEC
      CURSOR C_END_ENTR(P_ID_ENDER IN NUMBER,
                        P_ID_PESSOA IN NUMBER) IS
         SELECT LPAD(EP.CD_CEP1,5,0)||LPAD(EP.CD_CEP2,3,'0') CD_CEP,
                SUBSTR(TL.AB_TIPO_LOGR, 1, 35) || ' ' || EP.NM_LOGR DS_ENDERECO,
                SUBSTR(EP.NR_LOGR, 1, 8) NU_ENDERECO,
                EP.CM_LOGR DS_COMPLEMENTO,
                SUBSTR(EP.NM_BAIRRO, 1, 72) DS_BAIRRO,
                C.NM_CIDADE DS_MUNICIPIO,
                EP.SG_ESTADO_CID CD_UF
           FROM ENDERECO_PESSOA EP,
                TIPO_LOGRADOURO TL,
                CIDADE          C
          WHERE EP.ID_ENDER = P_ID_ENDER
            AND EP.ID_PESSOA = P_ID_PESSOA
            AND EP.DT_EXCL IS NULL
            AND TL.ID_TIPO_LOGR(+) = EP.ID_TIPO_LOGR
            AND C.CD_CIDADE = EP.CD_CIDADE_CID
            AND C.SG_ESTADO = EP.SG_ESTADO_CID
            AND C.SG_PAIS = EP.SG_PAIS_CID;
      R_END_ENTR C_END_ENTR%ROWTYPE;
      --
      -- Busca o Indicador de Tipo de NF - Determina se � (V, D, T, E, O)
      CURSOR C_TNF (P_IN_ENTR_SAI IN VARCHAR2,
                    P_CD_TP_NF    IN NUMBER) IS
         SELECT TNF.IN_TIPO_NF
           FROM TIPO_NOTA_FISCAL TNF
          WHERE TNF.CD_TIPO_NF    = P_CD_TP_NF
            AND TNF.IN_ENTR_SAIDA = P_IN_ENTR_SAI;
      V_IN_TIPO_NF    TIPO_NOTA_FISCAL.IN_TIPO_NF%TYPE;
      --
      -- Declara rowtype para insert
      P_RELAC_PED  WMS.T_RELACIONA_PEDIDO_GC_WMS%ROWTYPE;
      P_REC_CABPED WMS.INT_E_CAB_PEDIDO_SAIDA%ROWTYPE;
      P_REC_DETPED WMS.INT_E_DET_PEDIDO_SAIDA%ROWTYPE;
      --
      V_AGRUPA_QTDE_POR_SKU  VARCHAR2(1) := FNC_LE_GC_PARAMETRO(P_DS_PAR => 'AGRUPA_QTDE_POR_SKU');
      V_CD_DEP_WMS           VARCHAR2(3);
      --
      V_NU_PED_ORIGEM        T_RELACIONA_PEDIDO_GC_WMS.NU_PEDIDO_ORIGEM%TYPE;
      V_TP_PEDIDO_WMS        T_RELACIONA_PEDIDO_GC_WMS.TP_PEDIDO_WMS%TYPE := 'POS';
      V_DS_CLIENTE           INT_E_CAB_PEDIDO_SAIDA.DS_CLIENTE%TYPE;
      V_NU_CTRL_ITEM         INT_E_DET_PEDIDO_SAIDA.NU_CTRL_ITEM%TYPE;
      --
      -- Para controlar quebra de pedido e incluir novo cabecalho de pedido
      V_TP_DOCTO_ANT         VARCHAR2(3) := NULL;
      V_NR_DOCTO_ANT         NUMBER      := NULL;
      V_DT_DOCTO_ANT         DATE        := NULL;
      V_CD_FIL_ANT           FILIAL.CD_FIL%TYPE := NULL;
      --
      -- recebe retorno pr_busca_dados_pessoa
      V_AUX_CPF_CGC          PESSOA.ID_CGC%TYPE;
      V_CD_FIL_TOK           PESSOA.CD_FIL_TOK%TYPE;
      --
   BEGIN
      -- busca o deposito WMS associado � Filial (DP/DS) do GC
      V_CD_DEP_WMS := WMS.RET_DEP_WMS_FILIAL(P_FIL_ROMANEIO);
      --
      -- Retorna os pedidos/itens tratados no romaneio
      OPEN C_ITEM_POS(P_FIL_ROMANEIO, P_NR_ROMANEIO);
      LOOP
         FETCH C_ITEM_POS
            INTO R_ITEM_POS;
         EXIT WHEN C_ITEM_POS%NOTFOUND;
         --
         -- Determina a quebra de pedido para criar as tabelas de relacionamento e o cabecalho do Pedido Saida
         IF (V_NR_DOCTO_ANT IS NULL) OR
            (V_NR_DOCTO_ANT <> R_ITEM_POS.NR_DOCTO OR V_CD_FIL_ANT <> R_ITEM_POS.CD_FIL_DOCTO OR
             V_DT_DOCTO_ANT <> R_ITEM_POS.DT_DOCTO) OR
            (V_TP_DOCTO_ANT <> R_ITEM_POS.TP_DOCTO) THEN
            --
            V_NR_DOCTO_ANT  := R_ITEM_POS.NR_DOCTO;
            V_CD_FIL_ANT    := R_ITEM_POS.CD_FIL_DOCTO;
            V_DT_DOCTO_ANT  := R_ITEM_POS.DT_DOCTO;
            V_TP_DOCTO_ANT  := R_ITEM_POS.TP_DOCTO;
            -- REINICIALIZA O CONTADOR DE ITENS DO PEDIDO
            V_NU_CTRL_ITEM  := 0;
            --
            -- verifica se j� existe um numero gerado para o PVD/REQ/RUC/...na tabela DE/PARA
            V_NU_PED_ORIGEM := WMS.PCK_CTRL_PEDIDO_SAIDA.FC_BUSCA_PED_ORIGEM(R_ITEM_POS.CD_FIL_DOCTO,
                                                                             R_ITEM_POS.NR_DOCTO,
                                                                             R_ITEM_POS.TP_DOCTO,
                                                                             R_ITEM_POS.DT_DOCTO,
                                                                             NULL,
                                                                             NULL,
                                                                             P_NR_ROMANEIO,
                                                                             P_FIL_ROMANEIO);
            -- busca o tipo de NF para determinar o tipo de pedido WMS
            OPEN C_TNF(R_ITEM_POS.IN_ENTR_SAIDA_NZN, R_ITEM_POS.CD_TIPO_NF_NZN);
            FETCH C_TNF
               INTO V_IN_TIPO_NF;
            CLOSE C_TNF;
            -- Dados Cliente e Cliente Entrega
            PR_BUSCA_DADOS_PESSOA(R_ITEM_POS.CD_CLIENTE, V_DS_CLIENTE, V_AUX_CPF_CGC, V_CD_FIL_TOK);
            --
            IF V_IN_TIPO_NF = 'D' THEN -- NF DEVOLU��O
               V_TP_PEDIDO_WMS := 'POD';
            ELSIF V_IN_TIPO_NF = 'V' THEN -- NF VENDA
               IF V_CD_FIL_TOK IS NULL THEN
                  V_TP_PEDIDO_WMS := 'POC';
               ELSE
                  V_TP_PEDIDO_WMS := 'POF'; -- FALTA RAFA DEFINIR -- MULTI EMPRESA
               END IF;
            ELSIF V_IN_TIPO_NF = 'T' THEN -- NF TRANSFERENCIA
               -- 28/12/2020 - incluir tratamento transf. Reversa e Loja Saldo e Req. Int - WMS
               IF R_ITEM_POS.CD_TIPO_NF_NZN = 453 THEN
                  V_TP_PEDIDO_WMS := 'RQI';
               /*ELSIF R_ITEM_POS.CD_TIPO_NF_NZN = 443 THEN
                  IF V_CD_FIL_TOK = 103 THEN
                     V_TP_PEDIDO_WMS := 'POR'; -- POS REVERSA
                  ELSIF V_CD_FIL_TOK = 56 THEN
                     V_TP_PEDIDO_WMS := 'LJS'; -- LOJA DE SALDOS
                  ELSE
                     V_TP_PEDIDO_WMS := 'POT'; -- POS TRANSFERENCIA
                  END IF;*/
               ELSE
                  V_TP_PEDIDO_WMS := 'POT'; -- POS TRANSFERENCIA
               END IF;
            ELSIF V_IN_TIPO_NF IN ('O', 'R') THEN -- NF OUTRAS / RETORNOS
               V_TP_PEDIDO_WMS := 'POO';
            END IF;
            -- determina o tipo de POS --> POC - cliente / POD - Dev. fornec /
            IF V_NU_PED_ORIGEM IS NULL THEN
               -- gera o registro para relacionar o romaneio/req.uso consumo da filial
               P_RELAC_PED                  := NULL;
               P_RELAC_PED.NU_PEDIDO_ORIGEM := NULL;
               P_RELAC_PED.TP_PEDIDO_WMS    := V_TP_PEDIDO_WMS;
               P_RELAC_PED.CD_FIL_DOCTO     := R_ITEM_POS.CD_FIL_DOCTO;
               P_RELAC_PED.NR_DOCTO         := R_ITEM_POS.NR_DOCTO;
               P_RELAC_PED.TP_DOCTO         := R_ITEM_POS.TP_DOCTO; -- tipo pedido GC
               P_RELAC_PED.DT_EMIS_DOCTO    := R_ITEM_POS.DT_DOCTO;
               P_RELAC_PED.ID_TGE           := NULL;
               P_RELAC_PED.ID_AGRUPADOR     := NULL;
               P_RELAC_PED.TP_AGRUPADOR     := NULL;
               P_RELAC_PED.ID_ROM           := P_NR_ROMANEIO;
               P_RELAC_PED.CD_FIL_ROM       := P_FIL_ROMANEIO;
               -- Insere registro com relacionamento do PED/REQ GC com Pedido WMS
               WMS.PCK_CTRL_PEDIDO_SAIDA.PR_INS_RELACIONA_PEDIDOS(P_RELAC_PED);
            ELSE
              -- � reenvio do pedido para o WMS - j� possui Pedido Origem gerado e deve manter o mesmo
               P_RELAC_PED                  := NULL;
               P_RELAC_PED.NU_PEDIDO_ORIGEM := V_NU_PED_ORIGEM;
               P_RELAC_PED.TP_PEDIDO_WMS    := V_TP_PEDIDO_WMS;
            END IF;
            --
            -- Chama Procedure Insere o Cliente
            PR_GRV_CLIENTE(R_ITEM_POS.CD_CLIENTE, V_CD_DEP_WMS);
            --
            -- Gerar o registro do cabecalho do Pedido Saida
            P_REC_CABPED := NULL;
            --
            P_REC_CABPED.NU_SEQ           := NULL; -- ser� gerado no PR_INS_CAB_PEDIDO_SAIDA
            P_REC_CABPED.CD_EMPRESA       := 1;
            P_REC_CABPED.CD_DEPOSITO      := V_CD_DEP_WMS;
            P_REC_CABPED.NU_PEDIDO_ORIGEM := P_RELAC_PED.NU_PEDIDO_ORIGEM;
            P_REC_CABPED.CD_CLIENTE       := R_ITEM_POS.CD_CLIENTE;
            P_REC_CABPED.CD_CNPJ_CLIENTE  := V_AUX_CPF_CGC;
            P_REC_CABPED.DS_CLIENTE       := V_DS_CLIENTE;
            --
            P_REC_CABPED.DT_ENTRADA       := R_ITEM_POS.DT_ENTRADA;
            P_REC_CABPED.CD_CARGA         := R_ITEM_POS.CD_CARGA;
            P_REC_CABPED.CD_SITUACAO      := P_CD_SITUACAO;
            P_REC_CABPED.TP_PEDIDO        := P_RELAC_PED.TP_PEDIDO_WMS;
            P_REC_CABPED.DS_TPPEDIDO      := NULL;
            P_REC_CABPED.CD_PORTA         := 0;

            --
            IF R_ITEM_POS.CD_CLIENTE = R_ITEM_POS.ID_PESSOA_EEC THEN
               P_REC_CABPED.DS_CLIENTE_ENTREGA := P_REC_CABPED.DS_CLIENTE;
            ELSE
               PR_BUSCA_DADOS_PESSOA(R_ITEM_POS.ID_PESSOA_EEC, P_REC_CABPED.DS_CLIENTE_ENTREGA, V_AUX_CPF_CGC, V_CD_FIL_TOK);
            END IF;
            --
            -- busca dados entrega de entrega
            OPEN C_END_ENTR(R_ITEM_POS.ID_ENDER, R_ITEM_POS.CD_CLIENTE);
            FETCH C_END_ENTR
               INTO R_END_ENTR;
            CLOSE C_END_ENTR;
            --
            P_REC_CABPED.DS_ENDERECO_ENTREGA    := R_END_ENTR.DS_ENDERECO;
            P_REC_CABPED.NU_ENDERECO_ENTREGA    := R_END_ENTR.NU_ENDERECO;
            P_REC_CABPED.DS_COMPLEMENTO_ENTREGA := R_END_ENTR.DS_COMPLEMENTO;
            P_REC_CABPED.DS_BAIRRO_ENTREGA      := R_END_ENTR.DS_BAIRRO;
            P_REC_CABPED.DS_MUNICIPIO_ENTREGA   := R_END_ENTR.DS_MUNICIPIO;
            P_REC_CABPED.CD_UF_ENTREGA          := R_END_ENTR.CD_UF;
            P_REC_CABPED.CD_CEP_ENTREGA         := R_END_ENTR.CD_CEP;
            --
            --20/11/2020 - LOG-439 - Mudan�a ordem montagem de "FIL||NR_PV||DT EMS" Para "FIL ||DT EMIS||NR PV"
            P_REC_CABPED.NU_DOC_ERP := LPAD(R_ITEM_POS.CD_FIL_DOCTO, 3, '0') || TO_CHAR(R_ITEM_POS.DT_DOCTO, 'DDMMYYYY') ||
                                       LPAD(R_ITEM_POS.NR_DOCTO, 7, '0');
            --
            P_REC_CABPED.CD_TRANSPORTADORA      := 'NC';
            P_REC_CABPED.CD_CNPJ_TRANSPORTADORA := 0;
            P_REC_CABPED.DS_TRANSPORTADORA      := NULL;
            -- S� ser�o preenchidos depois de realizado o faturamento do pedido
            P_REC_CABPED.DT_FATURAMENTO     := NULL;
            P_REC_CABPED.NU_OBJETO_POSTAGEM := NULL;
            P_REC_CABPED.DS_PLACA           := NULL;
            --
            --Chama Procedure Insere o Pedidpo Saida da RUC enviada no romaneio
            PR_INS_CAB_PEDIDO_SAIDA(P_REC_CABPED);
         END IF; -- (V_NR_DOCTO_ANT IS NULL)
         --
         -- Tratamento det da requisi��o/romaneio - Detalhes Pedido Saida
         -- Verifica se gera a linha do SKU por Qtde Total ou por Unidade
         IF V_AGRUPA_QTDE_POR_SKU = 'S' THEN
            V_NU_CTRL_ITEM := NVL(V_NU_CTRL_ITEM,0) + 1;
            --
            P_REC_DETPED                       := NULL;
            P_REC_DETPED.NU_SEQ                := P_REC_CABPED.NU_SEQ;
            P_REC_DETPED.CD_EMPRESA            := P_REC_CABPED.CD_EMPRESA;
            P_REC_DETPED.CD_DEPOSITO           := P_REC_CABPED.CD_DEPOSITO;
            P_REC_DETPED.NU_PEDIDO_ORIGEM      := P_REC_CABPED.NU_PEDIDO_ORIGEM;
            P_REC_DETPED.CD_CLIENTE            := P_REC_CABPED.CD_CLIENTE;
            P_REC_DETPED.CD_PRODUTO            := R_ITEM_POS.ID_PROD;
            P_REC_DETPED.NU_ITEM_CORP          := R_ITEM_POS.NR_ITEM;
            P_REC_DETPED.QT_SEPARAR            := R_ITEM_POS.QT_ITEM;
            P_REC_DETPED.CD_SITUACAO           := P_REC_CABPED.CD_SITUACAO;
            P_REC_DETPED.NU_LOTE               := NULL;
            P_REC_DETPED.NU_PEDIDO             := NULL;
            P_REC_DETPED.ID_EMBALAGEM_PRESENTE := 'N';
            P_REC_DETPED.DS_AREA_ERP           := NULL;
            P_REC_DETPED.CD_CARGA              := P_REC_CABPED.CD_CARGA;
            P_REC_DETPED.NU_CTRL_ITEM          := V_NU_CTRL_ITEM;
            -- S� ser�o preenchidos depois de realizado o faturamento do pedido
            P_REC_DETPED.NU_NOTA               := NULL;
            P_REC_DETPED.NU_SERIE_NOTA         := NULL;
            P_REC_DETPED.CFOP                  := NULL;
            P_REC_DETPED.DT_NOTA_FISCAL        := NULL;
            P_REC_DETPED.CD_CHAVE_DANFE        := NULL;
            --
            -- Chama Procedure Insere os Itens da RUC enviadas no romaneio
            PR_INS_DET_PEDIDO_SAIDA(P_REC_DETPED);
         ELSE
            FOR I IN 1 .. R_ITEM_POS.QT_ITEM LOOP
               V_NU_CTRL_ITEM := NVL(V_NU_CTRL_ITEM,0) + 1;
               --
               P_REC_DETPED                       := NULL;
               P_REC_DETPED.NU_SEQ                := P_REC_CABPED.NU_SEQ;
               P_REC_DETPED.CD_EMPRESA            := P_REC_CABPED.CD_EMPRESA;
               P_REC_DETPED.CD_DEPOSITO           := P_REC_CABPED.CD_DEPOSITO;
               P_REC_DETPED.NU_PEDIDO_ORIGEM      := P_REC_CABPED.NU_PEDIDO_ORIGEM;
               P_REC_DETPED.CD_CLIENTE            := P_REC_CABPED.CD_CLIENTE;
               P_REC_DETPED.CD_PRODUTO            := R_ITEM_POS.ID_PROD;
               P_REC_DETPED.NU_ITEM_CORP          := R_ITEM_POS.NR_ITEM;
               P_REC_DETPED.QT_SEPARAR            := 1;
               P_REC_DETPED.CD_SITUACAO           := P_REC_CABPED.CD_SITUACAO;
               P_REC_DETPED.NU_LOTE               := NULL;
               P_REC_DETPED.NU_PEDIDO             := NULL;
               P_REC_DETPED.ID_EMBALAGEM_PRESENTE := 'N';
               P_REC_DETPED.DS_AREA_ERP           := NULL;
               P_REC_DETPED.CD_CARGA              := P_REC_CABPED.CD_CARGA;
               P_REC_DETPED.NU_CTRL_ITEM          := V_NU_CTRL_ITEM;
               -- S� ser�o preenchidos depois de realizado o faturamento do pedido
               P_REC_DETPED.NU_NOTA               := NULL;
               P_REC_DETPED.NU_SERIE_NOTA         := NULL;
               P_REC_DETPED.CFOP                  := NULL;
               P_REC_DETPED.DT_NOTA_FISCAL        := NULL;
               P_REC_DETPED.CD_CHAVE_DANFE        := NULL;
               --
               -- Chama Procedure Insere os Itens do PDS enviadas no romaneio
               PR_INS_DET_PEDIDO_SAIDA(P_REC_DETPED);
            END LOOP; -- FOR I IN ...
         END IF; -- V_AGRUPA_QTDE_POR_SKU
         --
      END LOOP; -- C_ITEM_POS
      CLOSE C_ITEM_POS;
      --
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         D_SQLERRM := SQLERRM;
         RAISE_APPLICATION_ERROR(-20001,
                                 'INTERF. PEDIDO_SAIDA POS ROMANEIO:' || P_NR_ROMANEIO || 'ERRO<' || D_SQLERRM || '> ');
         --
   END PR_PEDIDO_POS;

   --
   -- Procedure acionada por PR_LIBERA_SEPARACAO, para buscar os dados da RUC e gerar o PEDIDO_SAIDA para o WMS
   PROCEDURE PR_PEDIDO_RUC(P_FIL_ROMANEIO IN ROMANEIO_SEPARACAO.CD_FIL%TYPE,
                           P_NR_ROMANEIO  IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                           P_DT_ROMANEIO  IN ROMANEIO_SEPARACAO.DT_GERA%TYPE,
                           P_CD_SITUACAO  IN NUMBER) IS
      -- LOG-595 - Invers�o do NM_PESSOA da FILIAL para sigla/nome filial
      CURSOR C_RUC(P_FIL IN NUMBER,
                   P_ROM IN NUMBER,
                   P_DT  IN DATE) IS
         SELECT RUC.NR_REQ,
                RUC.CD_CCO,
                RUC.CD_FIL,
                RUC.DT_REQ,
                RSD.DT_GERA,
                P.ID_PESSOA CD_CLIENTE,
                P.ID_CGC CD_CNPJ_CLIENTE,
                F.SG_FIL || ' - ' || F.NM_FIL DS_CLIENTE,
                RSD.ID_ROM CD_CARGA,
                LPAD(RUC.CD_FIL, 3, '0') || LPAD(RUC.NR_REQ, 7, '0') || RUC.CD_CCO NU_DOC_ERP,
                TO_CHAR(RUC.DT_REQ, 'DD/MM/YYYY HH24:MI:SS') DT_ENTRADA
           FROM ROMANEIO_SEPARACAO RSD,
                REQ_USO_CONSUMO    RUC,
                PESSOA             P,
                FILIAL             F
          WHERE RSD.CD_FIL = P_FIL
            AND RSD.ID_ROM = P_ROM
            AND TRUNC(RSD.DT_GERA) = TRUNC(P_DT)
            AND RUC.NR_REQ = RSD.NR_REQ_RUC
            AND RUC.CD_CCO = RSD.CD_CCO_RUC
            AND RUC.CD_FIL = RSD.CD_FIL_RUC
            AND P.CD_FIL_TOK = RUC.CD_FIL
            AND F.CD_FIL = RUC.CD_FIL;
      R_RUC C_RUC%ROWTYPE;
      --
      CURSOR C_ITEM(P_FIL IN NUMBER,
                    P_ROM IN NUMBER,
                    P_REQ IN NUMBER,
                    P_CCO IN NUMBER) IS
         SELECT IRC.ID_PROD,
                IRD.QT_ROM,
                IRD.NR_ITEM
           FROM ITEM_ROM_SEP         IRD,
                ITEM_REQ_USO_CONSUMO IRC
          WHERE IRD.CD_FIL = P_FIL
            AND IRD.ID_ROM = P_ROM
            AND IRD.NR_REQ_IRC = P_REQ
            AND IRD.CD_CCO_IRC = P_CCO
            AND IRC.NR_REQ = IRD.NR_REQ_IRC
            AND IRC.CD_FIL = IRD.CD_FIL_IRC
            AND IRC.CD_CCO = IRD.CD_CCO_IRC
            AND IRC.ID_PROD = NVL(IRD.ID_PROD, IRD.ID_PROD_CMP)
          ORDER BY IRD.NR_ITEM;
      R_ITEM C_ITEM%ROWTYPE;
      --
      CURSOR C_UF (P_PESSOA IN NUMBER) IS
         SELECT EP.SG_ESTADO_CID  SG_ESTADO
           FROM ENDERECO_PESSOA EP
          WHERE EP.ID_PESSOA = P_PESSOA
            AND EP.AB_ENDER IN ('CAD', 'ENT')
            AND EP.DT_EXCL IS NULL;
      R_UF   C_UF%ROWTYPE;
      -- Declara rowtype para insert
      P_RELAC_PED  WMS.T_RELACIONA_PEDIDO_GC_WMS%ROWTYPE;
      P_REC_CABPED WMS.INT_E_CAB_PEDIDO_SAIDA%ROWTYPE;
      P_REC_DETPED WMS.INT_E_DET_PEDIDO_SAIDA%ROWTYPE;
      --
      -- Define se gera o Detalhe do Pedido/Produto Agrupando a Qtde do SKU ou por Unidade do SKU
      V_AGRUPA_QTDE_POR_SKU  VARCHAR2(1) := FNC_LE_GC_PARAMETRO(P_DS_PAR => 'AGRUPA_QTDE_POR_SKU');
      V_CD_DEP_WMS           VARCHAR2(3);
      --
      V_NU_PED_ORIGEM        T_RELACIONA_PEDIDO_GC_WMS.NU_PEDIDO_ORIGEM%TYPE;
      V_NU_CTRL_ITEM         INT_E_DET_PEDIDO_SAIDA.NU_CTRL_ITEM%TYPE;
      --
   BEGIN
      -- busca o deposito WMS associado � Filial (DP/DS) do GC
      V_CD_DEP_WMS := WMS.RET_DEP_WMS_FILIAL(P_FIL_ROMANEIO);
      --
      OPEN C_RUC(P_FIL_ROMANEIO, P_NR_ROMANEIO, P_DT_ROMANEIO);
      LOOP
         FETCH C_RUC
            INTO R_RUC;
         EXIT WHEN C_RUC%NOTFOUND;
         --
         -- verifica se j� existe um numero gerado para o PVD/REQ/RUC/...na tabela DE/PARA
         V_NU_PED_ORIGEM := WMS.PCK_CTRL_PEDIDO_SAIDA.FC_BUSCA_PED_ORIGEM(R_RUC.CD_FIL,
                                                                          R_RUC.NR_REQ,
                                                                          'RUC',
                                                                          R_RUC.DT_REQ,
                                                                          R_RUC.CD_CCO,
                                                                          NULL,
                                                                          P_NR_ROMANEIO,
                                                                          P_FIL_ROMANEIO);
            --
            IF V_NU_PED_ORIGEM IS NULL THEN
               -- gera o registro para relacionar o romaneio/req.uso consumo da filial
               P_RELAC_PED                  := NULL;
               P_RELAC_PED.NU_PEDIDO_ORIGEM := NULL;
               P_RELAC_PED.TP_PEDIDO_WMS    := 'RUC';
               P_RELAC_PED.CD_FIL_DOCTO     := R_RUC.CD_FIL;
               P_RELAC_PED.NR_DOCTO         := R_RUC.NR_REQ;
               P_RELAC_PED.TP_DOCTO         := 'RUC';
               P_RELAC_PED.DT_EMIS_DOCTO    := R_RUC.DT_REQ;
               P_RELAC_PED.CD_CCO           := R_RUC.CD_CCO;
               P_RELAC_PED.ID_TGE           := NULL;
               P_RELAC_PED.ID_AGRUPADOR     := NULL;
               P_RELAC_PED.TP_AGRUPADOR     := NULL;
               P_RELAC_PED.ID_ROM           := P_NR_ROMANEIO;
               P_RELAC_PED.CD_FIL_ROM       := P_FIL_ROMANEIO;
               -- Insere registro com relacionamento do PED/REQ GC com Pedido WMS
               WMS.PCK_CTRL_PEDIDO_SAIDA.PR_INS_RELACIONA_PEDIDOS(P_RELAC_PED);
            ELSE
               -- � reenvio do pedido para o WMS - j� possui Pedido Origem gerado e deve manter o mesmo
               P_RELAC_PED                  := NULL;
               P_RELAC_PED.NU_PEDIDO_ORIGEM := V_NU_PED_ORIGEM;
               P_RELAC_PED.TP_PEDIDO_WMS    := 'RUC';
            END IF;
            -- Chama Procedure Insere o cliente
            PR_GRV_CLIENTE(R_RUC.CD_CLIENTE, V_CD_DEP_WMS);

         -- Busca a sigla do estado da filial solicitante - informa��o obrigatoria no WMS
         OPEN C_UF (R_RUC.CD_CLIENTE);
         FETCH C_UF
            INTO R_UF;
         CLOSE C_UF;
         --
         -- Gerar o registro do cabecalho do Pedido Saida
         P_REC_CABPED                        := NULL;
         P_REC_CABPED.NU_SEQ                 := NULL; -- ser� gerado no PR_INS_CAB_PEDIDO_SAIDA
         P_REC_CABPED.CD_EMPRESA             := 1;
         P_REC_CABPED.CD_DEPOSITO            := V_CD_DEP_WMS;
         P_REC_CABPED.NU_PEDIDO_ORIGEM       := P_RELAC_PED.NU_PEDIDO_ORIGEM;
         P_REC_CABPED.CD_CLIENTE             := R_RUC.CD_CLIENTE;
         P_REC_CABPED.CD_CNPJ_CLIENTE        := R_RUC.CD_CNPJ_CLIENTE;
         P_REC_CABPED.DS_CLIENTE             := R_RUC.DS_CLIENTE;
         P_REC_CABPED.CD_CARGA               := R_RUC.CD_CARGA;
         P_REC_CABPED.CD_SITUACAO            := P_CD_SITUACAO;
         P_REC_CABPED.TP_PEDIDO              := P_RELAC_PED.TP_PEDIDO_WMS;
         P_REC_CABPED.DS_TPPEDIDO            := NULL;
         P_REC_CABPED.CD_PORTA               := 0;
         P_REC_CABPED.CD_TRANSPORTADORA      := 'NC';
         P_REC_CABPED.CD_CNPJ_TRANSPORTADORA := 0;
         P_REC_CABPED.DS_TRANSPORTADORA      := NULL;
         P_REC_CABPED.NU_DOC_ERP             := R_RUC.NU_DOC_ERP;
         P_REC_CABPED.DS_CLIENTE_ENTREGA     := R_RUC.DS_CLIENTE;
         P_REC_CABPED.DT_ENTRADA             := R_RUC.DT_ENTRADA;
         P_REC_CABPED.CD_UF_ENTREGA          := R_UF.SG_ESTADO;
         -- S� ser�o preenchidos depois de realizado o faturamento do pedido
         P_REC_CABPED.DT_FATURAMENTO         := NULL;
         P_REC_CABPED.NU_OBJETO_POSTAGEM     := NULL;
         P_REC_CABPED.DS_PLACA               := NULL;
         --
         --Chama Procedure Insere o Pedidpo Saida da RUC enviada no romaneio
         PR_INS_CAB_PEDIDO_SAIDA(P_REC_CABPED);
         --
         -- Tratamento det da requisi��o/romaneio - Detalhes Pedido Saida
         -- Inicializa o contator de itens do pedido para compor a chave de PK - quando n�o ira agrupar a qtde por SKU
         V_NU_CTRL_ITEM := 0;
         --
         OPEN C_ITEM(P_FIL_ROMANEIO, P_NR_ROMANEIO, R_RUC.NR_REQ, R_RUC.CD_CCO);
         LOOP
            FETCH C_ITEM
               INTO R_ITEM;
            EXIT WHEN C_ITEM%NOTFOUND;
            --
            -- Tratamento det da requisi��o/romaneio - Detalhes Pedido Saida
            -- Verifica se gera a linha do SKU por Qtde Total ou por Unidade
            IF V_AGRUPA_QTDE_POR_SKU = 'S' THEN
               V_NU_CTRL_ITEM := NVL(V_NU_CTRL_ITEM,0) + 1;
               --
               P_REC_DETPED                       := NULL;
               P_REC_DETPED.NU_SEQ                := P_REC_CABPED.NU_SEQ;
               P_REC_DETPED.CD_EMPRESA            := P_REC_CABPED.CD_EMPRESA;
               P_REC_DETPED.CD_DEPOSITO           := P_REC_CABPED.CD_DEPOSITO;
               P_REC_DETPED.NU_PEDIDO_ORIGEM      := P_REC_CABPED.NU_PEDIDO_ORIGEM;
               P_REC_DETPED.CD_CLIENTE            := P_REC_CABPED.CD_CLIENTE;
               P_REC_DETPED.CD_PRODUTO            := R_ITEM.ID_PROD;
               P_REC_DETPED.NU_ITEM_CORP          := R_ITEM.NR_ITEM;
               P_REC_DETPED.QT_SEPARAR            := R_ITEM.QT_ROM;
               P_REC_DETPED.CD_SITUACAO           := P_REC_CABPED.CD_SITUACAO;
               P_REC_DETPED.NU_LOTE               := NULL;
               P_REC_DETPED.NU_PEDIDO             := NULL;
               P_REC_DETPED.ID_EMBALAGEM_PRESENTE := 'N';
               P_REC_DETPED.DS_AREA_ERP           := NULL;
               P_REC_DETPED.CD_CARGA              := P_REC_CABPED.CD_CARGA;
               P_REC_DETPED.NU_CTRL_ITEM          := V_NU_CTRL_ITEM;
               -- S� ser�o preenchidos depois de realizado o faturamento do pedido
               P_REC_DETPED.NU_NOTA               := NULL;
               P_REC_DETPED.NU_SERIE_NOTA         := NULL;
               P_REC_DETPED.CFOP                  := NULL;
               P_REC_DETPED.DT_NOTA_FISCAL        := NULL;
               P_REC_DETPED.CD_CHAVE_DANFE        := NULL;
               --
               -- Chama Procedure Insere os Itens da RUC enviadas no romaneio
               PR_INS_DET_PEDIDO_SAIDA(P_REC_DETPED);
            ELSE
               FOR I IN 1 .. R_ITEM.QT_ROM LOOP
                  V_NU_CTRL_ITEM := NVL(V_NU_CTRL_ITEM,0) + 1;
                  --
                  P_REC_DETPED                       := NULL;
                  P_REC_DETPED.NU_SEQ                := P_REC_CABPED.NU_SEQ;
                  P_REC_DETPED.CD_EMPRESA            := P_REC_CABPED.CD_EMPRESA;
                  P_REC_DETPED.CD_DEPOSITO           := P_REC_CABPED.CD_DEPOSITO;
                  P_REC_DETPED.NU_PEDIDO_ORIGEM      := P_REC_CABPED.NU_PEDIDO_ORIGEM;
                  P_REC_DETPED.CD_CLIENTE            := P_REC_CABPED.CD_CLIENTE;
                  P_REC_DETPED.CD_PRODUTO            := R_ITEM.ID_PROD;
                  P_REC_DETPED.NU_ITEM_CORP          := R_ITEM.NR_ITEM;
                  P_REC_DETPED.QT_SEPARAR            := 1;
                  P_REC_DETPED.CD_SITUACAO           := P_REC_CABPED.CD_SITUACAO;
                  P_REC_DETPED.NU_LOTE               := NULL;
                  P_REC_DETPED.NU_PEDIDO             := NULL;
                  P_REC_DETPED.ID_EMBALAGEM_PRESENTE := 'N';
                  P_REC_DETPED.DS_AREA_ERP           := NULL;
                  P_REC_DETPED.CD_CARGA              := P_REC_CABPED.CD_CARGA;
                  P_REC_DETPED.NU_CTRL_ITEM          := V_NU_CTRL_ITEM;
                  -- S� ser�o preenchidos depois de realizado o faturamento do pedido
                  P_REC_DETPED.NU_NOTA               := NULL;
                  P_REC_DETPED.NU_SERIE_NOTA         := NULL;
                  P_REC_DETPED.CFOP                  := NULL;
                  P_REC_DETPED.DT_NOTA_FISCAL        := NULL;
                  P_REC_DETPED.CD_CHAVE_DANFE        := NULL;
                  --
                  -- Chama Procedure Insere os Itens da RUC enviadas no romaneio
                  PR_INS_DET_PEDIDO_SAIDA(P_REC_DETPED);
                END LOOP; -- FOR I IN ...
            END IF; -- V_AGRUPA_QTDE_POR_SKU
            --
         END LOOP; -- C_ITEM
         CLOSE C_ITEM;
         --
         COMMIT;
      END LOOP; -- C_RUC
      CLOSE C_RUC;
   EXCEPTION
      WHEN OTHERS THEN
         D_SQLERRM := SQLERRM;
         RAISE_APPLICATION_ERROR(-20001,
                                 'INTERF. PEDIDO_SAIDA RUC ROMANEIO:' || P_NR_ROMANEIO || 'ERRO<' || D_SQLERRM || '> ');
         --
   END PR_PEDIDO_RUC;
   --

   /*   -- Dados de Alterados do Pedido Sa�da no WMS --
   PROCEDURE PROCEDURE PR_GRV_ALTERA_DADOS_PEDIDO (P_) IS

   BEGIN

   END PROCEDURE PR_GRV_ALTERA_DADOS_PEDIDO;*/
   --
   -- Dados de Ajustes de Estoque - Movimenta��es Internas Dep�sito - WMS --
   PROCEDURE PR_GRV_AJUSTE_ESTQ(P_NR_REQ      IN ITEM_REQ_INTERNA.NR_REQ%TYPE,
                                P_AB_REQ      IN ITEM_REQ_INTERNA.AB_REQ%TYPE,
                                P_CD_CCO      IN ITEM_REQ_INTERNA.CD_CCO%TYPE,
                                P_CD_FIL      IN ITEM_REQ_INTERNA.CD_FIL%TYPE,
                                P_ID_ROM      IN ROMANEIO_SEPARACAO.ID_ROM%TYPE,
                                P_AREA_ORIG   IN VARCHAR2,
                                P_AREA_DEST   IN VARCHAR2,
                                P_CD_SITUACAO IN NUMBER) IS
      --
      -- OBJETIVO..: Popular a Interface para realizar o ajuste de Estoque - tarefa de movimenta��o entre Departamento(Areas) do Deposito ---
      -- AUTOR/DATA: HELENA M. 31/07/2020
      -- ALTERACOES:
      --
      -- *************baseado na procedure GERAR_ROM_SEP_RQI*********************hmm
      --
      -- Declara rowtype para insert
      P_AJUSTE_ESTOQUE WMS.INT_E_AJUSTE_ESTOQUE%ROWTYPE;
      -- Busca itens da Requisi��o Interna - Movimentacao no Deposito
      CURSOR C_IRI(P_NR_REQ IRI.NR_REQ%TYPE,
                   P_AB_REQ IRI.AB_REQ%TYPE,
                   P_CD_CCO IRI.CD_CCO%TYPE,
                   P_CD_FIL IRI.CD_FIL%TYPE,
                   P_ID_ROM RSD.ID_ROM%TYPE) IS
         SELECT IRI.NR_ITEM,
                IRI.ID_PROD,
                IRD.QT_ROM
           FROM ITEM_ROM_SEP       IRD,
                ROMANEIO_SEPARACAO RSD,
                ITEM_REQ_INTERNA   IRI
          WHERE IRD.CD_FIL     = RSD.CD_FIL
            AND IRD.ID_ROM     = RSD.ID_ROM
            AND IRI.ID_PROD    = NVL(IRD.ID_PROD, IRD.ID_PROD_CMP)
            AND (IRD.NR_COMP_CMP IS NULL OR IRD.NR_COMP_CMP = 1)
            AND RSD.CD_FIL_RQI = IRI.CD_FIL
            AND RSD.CD_CCO_RQI = IRI.CD_CCO
            AND RSD.AB_RQI     = IRI.AB_REQ
            AND RSD.NR_RQI     = IRI.NR_REQ
            AND RSD.ID_ROM     = P_ID_ROM
            AND IRI.CD_FIL     = P_CD_FIL
            AND IRI.NR_REQ     = P_NR_REQ
            AND IRI.AB_REQ     = P_AB_REQ
            AND IRI.CD_CCO     = P_CD_CCO
          ORDER BY NR_ITEM;
      R_IRI C_IRI%ROWTYPE;
      --
      V_CD_DEP_WMS VARCHAR2(3);
      --
   BEGIN
      IF P_NR_REQ IS NOT NULL THEN
         -- Busca o Deposito WMS referente a filial GC
         V_CD_DEP_WMS := WMS.RET_DEP_WMS_FILIAL(P_CD_FIL);
         --
         -- Busca itens da Requisi��o interna com Qtde Pendente
         OPEN C_IRI(P_NR_REQ, P_AB_REQ, P_CD_CCO, P_CD_FIL, P_ID_ROM);
         LOOP
            FETCH C_IRI
               INTO R_IRI;
            EXIT WHEN C_IRI%NOTFOUND;
            --
            -- popula a interface WMS int_e_ajuste_estoque para envio ao WMS
            P_AJUSTE_ESTOQUE := NULL;
            --
            P_AJUSTE_ESTOQUE.CD_EMPRESA            := 1;
            P_AJUSTE_ESTOQUE.CD_DEPOSITO           := V_CD_DEP_WMS;
            P_AJUSTE_ESTOQUE.CD_PRODUTO            := R_IRI.ID_PROD;
            P_AJUSTE_ESTOQUE.QT_MOVIMENTO          := R_IRI.QT_ROM;
            P_AJUSTE_ESTOQUE.DT_MOVIMENTO          := TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS');
            P_AJUSTE_ESTOQUE.DS_AREA_ERP_ORIGEM    := P_AREA_ORIG;
            P_AJUSTE_ESTOQUE.DS_AREA_ERP_DESTINO   := P_AREA_DEST;
            P_AJUSTE_ESTOQUE.NU_DOC_ERP            := P_ID_ROM;
            P_AJUSTE_ESTOQUE.CD_SITUACAO           := P_CD_SITUACAO;
            P_AJUSTE_ESTOQUE.FILLER_1              := NULL;
            P_AJUSTE_ESTOQUE.FILLER_2              := NULL;
            P_AJUSTE_ESTOQUE.FILLER_3              := NULL;
            P_AJUSTE_ESTOQUE.FILLER_4              := NULL;
            P_AJUSTE_ESTOQUE.FILLER_5              := NULL;
            P_AJUSTE_ESTOQUE.DT_LIB_QUARENTENA     := NULL;
            P_AJUSTE_ESTOQUE.CD_AREA_ARMAZ_ORIGEM  := NULL;
            P_AJUSTE_ESTOQUE.CD_AREA_ARMAZ_DESTINO := NULL;
            --
            PR_INS_AJUSTE_ESTOQUE(P_AJUSTE_ESTOQUE);
            --
            COMMIT;
            --
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         D_SQLERRM            := SQLERRM;
         P_MSG                := NULL;
         P_MSG.CD_FIL         := GC.PCK_1.G_FIL_AMBIENTE;
         P_MSG.ID_MSG         := NULL;
         P_MSG.NM_PACOTE      := 'PCK_GERAR_INTERF_WMS';
         P_MSG.NM_PROGR       := 'PR_GRV_AJUSTE_ESTQ';
         P_MSG.IN_TEL_RET     := 'T';
         P_MSG.ID_USR_ORIGEM  := USER;
         P_MSG.ID_USR_DESTINO := 'HELPDESK';
         P_MSG.NR_ITENS       := 0;
         P_MSG.NR_OCOR        := 0;
         P_MSG.TX_OCOR        := 'INTERFACE DE AJUSTE ESTOQUE PARA WMS ' || 'ERRO<' || D_SQLERRM || '> ';
         D_ID_MSG             := GC.GRV_GC_MSG(P_MSG);
         COMMIT;
         --
   END PR_GRV_AJUSTE_ESTQ;
   --
   -- Dados de Transportadora Rota no WMS -- falta definir a informa��o que ser� repassada ao WMS
   PROCEDURE PR_GRV_TRANSP_ROTA(P_CD_ROTA IN FRETE_REGRA_ORIGEM_DESTINO.ID_FROD%TYPE) IS
      --
      -- OBJETIVO..: Popular a Interface de Transportadora Rota
      -- AUTOR/DATA: HELENA M. 16/11/2020
      -- ALTERACOES:
      --
      -- Declara rowtype para insert
      P_TRANSP_ROTA WMS.INT_E_TRANSPORTADORA_ROTA%ROWTYPE;
      -- Busca as Rotas/transportadoras - FROD
      CURSOR C_FROD(P_FROD FROD.ID_FROD%TYPE) IS
         SELECT FROD.ID_FROD CD_ROTA,
                (CASE
                   WHEN PD.CD_FIL_TOK IS NULL THEN
                    'ROTA TRANSP. ' || PD.NM_FANT
                   ELSE
                    'ROTA FILIAL ' || LPAD(FD.CD_FIL, 3, '0') || ' - ' || FD.SG_FIL
                END) DS_ROTA,
                PO.CD_FIL_TOK FIL_ORIG,
                --
                (CASE
                   WHEN PD.CD_FIL_TOK IS NULL THEN
                    FROD.ID_PESSOA_DEST
                   ELSE
                    0
                END) CD_TRANSPORTADORA,
                PD.CD_FIL_TOK FIL_DEST,
                PD.ID_PESSOA
           FROM GC.FILIAL_DEPOSITO_SECUNDARIO FDS,
                GC.FRETE_REGRA_ORIGEM_DESTINO FROD,
                GC.PESSOA                     PO,
                GC.PESSOA                     PD,
                GC.FILIAL                     FD
          WHERE ((P_FROD IS NOT NULL AND FROD.ID_FROD = P_FROD) OR (P_FROD IS NULL))
            AND FROD.ID_PESSOA_ORIG = PO.ID_PESSOA
            AND FDS.CD_FIL_DS = PO.CD_FIL_TOK
            AND NVL(FDS.IN_INTERFACE_WMS, 'N') = 'S'
            AND PD.ID_PESSOA = FROD.ID_PESSOA_DEST
            AND FD.CD_FIL(+) = PD.CD_FIL_TOK;
      R_FROD C_FROD%ROWTYPE;
      --
      CURSOR C_LOCAL(P_PESSOA GC.PESSOA.ID_PESSOA%TYPE) IS
        SELECT DISTINCT
               EP.SG_ESTADO_CID CD_UF,
               CI.NM_CIDADE     DS_MUNICIPIO
          FROM GC.ENDERECO_PESSOA EP,
               GC.CIDADE          CI
         WHERE EP.ID_PESSOA = P_PESSOA
           AND EP.CD_CIDADE_CID = CI.CD_CIDADE;
      R_LOCAL C_LOCAL%ROWTYPE;
      --
      --
      V_CD_DEP_WMS VARCHAR2(3);
      --
   BEGIN
      --
      -- Busca as Rotas cadastradas para a Filial - WMS - FROD
      OPEN C_FROD(P_CD_ROTA);
      LOOP
         FETCH C_FROD
            INTO R_FROD;
         EXIT WHEN C_FROD%NOTFOUND;
         --
         IF R_FROD.CD_TRANSPORTADORA <> 0 THEN
            -- Busca o Deposito WMS referente a filial GC
            V_CD_DEP_WMS := WMS.RET_DEP_WMS_FILIAL(R_FROD.FIL_ORIG);
            --
            --Busco local com base no id_pessoa origem
            OPEN C_LOCAL(R_FROD.ID_PESSOA);
            FETCH C_LOCAL INTO R_LOCAL;
            CLOSE C_LOCAL;
            --
            -- popula a interface WMS int_e_ajuste_estoque para envio ao WMS
            P_TRANSP_ROTA := NULL;
            --
            P_TRANSP_ROTA.CD_SEQ                := NULL;
            P_TRANSP_ROTA.CD_EMPRESA            := 1;
            P_TRANSP_ROTA.CD_DEPOSITO           := V_CD_DEP_WMS;
            P_TRANSP_ROTA.CD_TRANSPORTADORA     := R_FROD.CD_TRANSPORTADORA;
            P_TRANSP_ROTA.CD_UF                 := R_LOCAL.CD_UF;
            P_TRANSP_ROTA.DS_MUNICIPIO          := R_LOCAL.DS_MUNICIPIO;
            P_TRANSP_ROTA.CD_ROTA               := R_FROD.CD_ROTA;
            P_TRANSP_ROTA.DS_ROTA               := R_FROD.DS_ROTA;
            P_TRANSP_ROTA.DS_SIGLA_ROTEIRIZADOR := NULL;
            --
            PR_INS_TRANSP_ROTA(P_TRANSP_ROTA);
            --
            COMMIT;
         END IF; -- R_FROD.CD_TRANSPORTADORA <> 0
         --
      END LOOP;
      CLOSE C_FROD;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         D_SQLERRM            := SQLERRM;
         P_MSG                := NULL;
         P_MSG.CD_FIL         := GC.PCK_1.G_FIL_AMBIENTE;
         P_MSG.ID_MSG         := NULL;
         P_MSG.NM_PACOTE      := 'PCK_GERAR_INTERF_WMS';
         P_MSG.NM_PROGR       := 'PR_GRV_TRANSP_ROTA';
         P_MSG.IN_TEL_RET     := 'T';
         P_MSG.ID_USR_ORIGEM  := USER;
         P_MSG.ID_USR_DESTINO := 'HELPDESK';
         P_MSG.NR_ITENS       := 0;
         P_MSG.NR_OCOR        := 0;
         P_MSG.TX_OCOR        := 'INTERFACE DE TRANSP.ROTA PARA WMS ' || 'ERRO<' || D_SQLERRM || '> ';
         D_ID_MSG             := GC.GRV_GC_MSG(P_MSG);
         COMMIT;
         --
   END PR_GRV_TRANSP_ROTA;
   --
   -- Dados de Solicita��o LGPD - Lei Geral de Prote��o de Dados - para o WMS --
   PROCEDURE PR_GRV_LGPD(P_CNPJ_CPF IN PESSOA.ID_CPF%TYPE) IS
      V_NU_SEQ WMS.INT_E_LGPD.NU_SEQ%TYPE;
   BEGIN
      IF P_CNPJ_CPF IS NOT NULL THEN
         V_NU_SEQ := WMS.PCK_INTERFACE_WMS.FC_SEQ_ENTRADA;
         --
         INSERT INTO INT_E_LGPD
            (NU_SEQ,
             CD_EMPRESA,
             CD_DEPOSITO,
             CD_CNPJ_CPF)
         VALUES
            (V_NU_SEQ,
             1,
             '001',
             P_CNPJ_CPF);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         D_SQLERRM            := SQLERRM;
         P_MSG                := NULL;
         P_MSG.CD_FIL         := GC.PCK_1.G_FIL_AMBIENTE;
         P_MSG.ID_MSG         := NULL;
         P_MSG.NM_PACOTE      := 'PCK_GERAR_INTERF_WMS';
         P_MSG.NM_PROGR       := 'PR_GRV_LGPD';
         P_MSG.IN_TEL_RET     := 'T';
         P_MSG.ID_USR_ORIGEM  := USER;
         P_MSG.ID_USR_DESTINO := 'HELPDESK';
         P_MSG.NR_ITENS       := 0;
         P_MSG.NR_OCOR        := 0;
         P_MSG.TX_OCOR        := 'INTERFACE DE LGPD PARA WMS ' || 'ERRO<' || D_SQLERRM || '> ';
         D_ID_MSG             := GC.GRV_GC_MSG(P_MSG);
         COMMIT;
         --
   END PR_GRV_LGPD;
   --
   PROCEDURE PR_INS_PRODUTO(P_REC_PROD IN OUT WMS.INT_E_PRODUTO%ROWTYPE) IS
   BEGIN
      -- Busca a sequence da PK das tabelas de entrada
      P_REC_PROD.NU_SEQ := WMS.PCK_INTERFACE_WMS.FC_SEQ_ENTRADA;
      --
      INSERT INTO WMS.INT_E_PRODUTO
         (NU_SEQ,
          CD_EMPRESA,
          CD_DEPOSITO,
          CD_PRODUTO,
          DS_PRODUTO,
          DS_REDUZIDA,
          CD_UNIDADE_MEDIDA,
          DS_UNIDADE_MEDIDA,
          ID_ACEITA_DECIMAL,
          CD_EMBALAGEM,
          DS_EMBALAGEM,
          QT_UNIDADE_EMBALAGEM,
          CD_PRODUTO_MASTER,
          QT_ITENS,
          CD_FAMILIA,
          DS_FAMILIA,
          VL_ALTURA,
          VL_LARGURA,
          VL_PROFUNDIDADE,
          PS_LIQUIDO,
          PS_BRUTO,
          QT_MAX_PALETE,
          CD_SITUACAO,
          CD_ROTATIVIDADE,
          CD_CLASSE,
          DS_CLASSE,
          QT_DIAS_VALIDADE,
          QT_DIAS_REMONTE,
          ID_CONTROLE_LOTE,
          ID_CONTROLE_SERIE,
          ID_CONTROLE_VALIDADE,
          QT_CAIXA_FECHADA,
          CD_FORNECEDOR,
          CD_CNPJ_FORNECEDOR,
          CD_PRODUTO_FORNECEDOR,
          CD_LINHA,
          DS_LINHA,
          CD_GRUPO,
          DS_GRUPO,
          CD_SUBGRUPO,
          DS_SUBGRUPO,
          CD_MODELO,
          DS_MODELO,
          TP_ARMAZENAGEM_PRODUTO,
          CD_DEPARTAMENTO,
          DS_DEPARTAMENTO,
          FILLER_1,
          FILLER_2,
          FILLER_3,
          FILLER_4,
          FILLER_5,
          QT_PERC_PROD_DIAS_EXPEDICAO,
          DS_COR_PRODUTO,
          DS_ESPECIFICACAO,
          NM_ARQUIVO_IMAGEM,
          DS_EXTENSAO_ARQUIVO_IMAGEM,
          DS_TAMANHO_PRODUTO,
          CD_PRODUTO_REFERENCIA,
          ID_PRODUTO_GRADE,
          TP_PRODUTO,
          QT_FATOR_CONVERSAO_SORTER,
          TP_UNIDADE_LOGISTICA_SORTER,
          CD_EMBALAGE_EXPEDICAO,
          ID_CX_FECHADA_VOLUME_PRONTO,
          ID_CONFERE_DURANTE_SEPARACAO)
      VALUES
         (P_REC_PROD.NU_SEQ,
          P_REC_PROD.CD_EMPRESA,
          P_REC_PROD.CD_DEPOSITO,
          P_REC_PROD.CD_PRODUTO,
          P_REC_PROD.DS_PRODUTO,
          P_REC_PROD.DS_REDUZIDA,
          NVL(P_REC_PROD.CD_UNIDADE_MEDIDA, 'NC'),
          NVL(P_REC_PROD.DS_UNIDADE_MEDIDA, 'N�O CADASTRADO'),
          P_REC_PROD.ID_ACEITA_DECIMAL,
          NVL(P_REC_PROD.CD_EMBALAGEM, 'NC'),
          NVL(P_REC_PROD.DS_EMBALAGEM, 'N�O CADASTRADO'),
          NVL(P_REC_PROD.QT_UNIDADE_EMBALAGEM, 1),
          P_REC_PROD.CD_PRODUTO_MASTER,
          NVL(P_REC_PROD.QT_ITENS, 1),
          NVL(P_REC_PROD.CD_FAMILIA, 'NC'),
          NVL(P_REC_PROD.DS_FAMILIA, 'N�O CADASTRADO'),
          NVL(P_REC_PROD.VL_ALTURA, 0),
          NVL(P_REC_PROD.VL_LARGURA, 0),
          NVL(P_REC_PROD.VL_PROFUNDIDADE, 0),
          NVL(P_REC_PROD.PS_LIQUIDO, 0),
          NVL(P_REC_PROD.PS_BRUTO, 0),
          P_REC_PROD.QT_MAX_PALETE,
          NVL(P_REC_PROD.CD_SITUACAO, 15),
          NVL(P_REC_PROD.CD_ROTATIVIDADE, 'NC'),
          NVL(P_REC_PROD.CD_CLASSE, 'NC'),
          NVL(P_REC_PROD.DS_CLASSE, 'N�O CADASTRADO'),
          P_REC_PROD.QT_DIAS_VALIDADE,
          P_REC_PROD.QT_DIAS_REMONTE,
          NVL(P_REC_PROD.ID_CONTROLE_LOTE, 'N'),
          NVL(P_REC_PROD.ID_CONTROLE_SERIE, 'N'),
          NVL(P_REC_PROD.ID_CONTROLE_VALIDADE, 'N'),
          NVL(P_REC_PROD.QT_CAIXA_FECHADA, 1),
          P_REC_PROD.CD_FORNECEDOR,
          P_REC_PROD.CD_CNPJ_FORNECEDOR,
          P_REC_PROD.CD_PRODUTO_FORNECEDOR,
          NVL(P_REC_PROD.CD_LINHA, 'N'),
          NVL(P_REC_PROD.DS_LINHA, 'N�O CADASTRADO'),
          NVL(P_REC_PROD.CD_GRUPO, 'N'),
          NVL(P_REC_PROD.DS_GRUPO, 'N�O CADASTRADO'),
          NVL(P_REC_PROD.CD_SUBGRUPO, 'N'),
          NVL(P_REC_PROD.DS_SUBGRUPO, 'N�O CADASTRADO'),
          NVL(P_REC_PROD.CD_MODELO, 'N'),
          NVL(P_REC_PROD.DS_MODELO, 'N�O CADASTRADO'),
          P_REC_PROD.TP_ARMAZENAGEM_PRODUTO,
          P_REC_PROD.CD_DEPARTAMENTO,
          P_REC_PROD.DS_DEPARTAMENTO,
          P_REC_PROD.FILLER_1,
          P_REC_PROD.FILLER_2,
          P_REC_PROD.FILLER_3,
          P_REC_PROD.FILLER_4,
          P_REC_PROD.FILLER_5,
          P_REC_PROD.QT_PERC_PROD_DIAS_EXPEDICAO,
          P_REC_PROD.DS_COR_PRODUTO,
          P_REC_PROD.DS_ESPECIFICACAO,
          P_REC_PROD.NM_ARQUIVO_IMAGEM,
          P_REC_PROD.DS_EXTENSAO_ARQUIVO_IMAGEM,
          P_REC_PROD.DS_TAMANHO_PRODUTO,
          P_REC_PROD.CD_PRODUTO_REFERENCIA,
          NVL(P_REC_PROD.ID_PRODUTO_GRADE, 'N'),
          P_REC_PROD.TP_PRODUTO,
          P_REC_PROD.QT_FATOR_CONVERSAO_SORTER,
          P_REC_PROD.TP_UNIDADE_LOGISTICA_SORTER,
          NVL(P_REC_PROD.CD_EMBALAGE_EXPEDICAO, 'NC'),
          P_REC_PROD.ID_CX_FECHADA_VOLUME_PRONTO,
          P_REC_PROD.ID_CONFERE_DURANTE_SEPARACAO);
   END PR_INS_PRODUTO;
   --
   PROCEDURE PR_INS_COD_BARRA(P_REC_BARRA IN WMS.INT_E_CODIGO_BARRA%ROWTYPE) IS
      V_NU_SEQ INT_E_CODIGO_BARRA.NU_SEQ%TYPE;
   BEGIN
      -- Busca a sequence da PK das tabelas de entrada
      IF P_REC_BARRA.NU_SEQ IS NULL THEN
         V_NU_SEQ := WMS.PCK_INTERFACE_WMS.FC_SEQ_ENTRADA;
      ELSE
         V_NU_SEQ := P_REC_BARRA.NU_SEQ;
      END IF;
      --
      BEGIN
         INSERT INTO WMS.INT_E_CODIGO_BARRA
            (NU_SEQ,
             CD_EMPRESA,
             CD_PRODUTO,
             CD_BARRAS,
             CD_SITUACAO,
             TP_CODIGO_BARRAS,
             QT_EMBALAGEM,
             ID_CODIGO_PRINCIPAL,
             NU_PRIORIDADE_USO,
             ID_VOLUME,
             FILLER_1,
             FILLER_2,
             FILLER_3,
             FILLER_4,
             FILLER_5)
         VALUES
            (V_NU_SEQ,
             P_REC_BARRA.CD_EMPRESA,
             P_REC_BARRA.CD_PRODUTO,
             P_REC_BARRA.CD_BARRAS,
             P_REC_BARRA.CD_SITUACAO,
             P_REC_BARRA.TP_CODIGO_BARRAS,
             NVL(P_REC_BARRA.QT_EMBALAGEM, 1),
             NVL(P_REC_BARRA.ID_CODIGO_PRINCIPAL, 'N'),
             P_REC_BARRA.NU_PRIORIDADE_USO,
             P_REC_BARRA.ID_VOLUME,
             P_REC_BARRA.FILLER_1,
             P_REC_BARRA.FILLER_2,
             P_REC_BARRA.FILLER_3,
             P_REC_BARRA.FILLER_4,
             P_REC_BARRA.FILLER_5);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;
   END PR_INS_COD_BARRA;
   --
   PROCEDURE PR_INS_CLIENTE(P_REC_CLIENTE IN WMS.INT_E_CLIENTE%ROWTYPE) IS
      V_NU_SEQ WMS.INT_E_CLIENTE.NU_SEQ%TYPE;
   BEGIN
      -- Busca a sequence da PK das tabelas de entrada
      V_NU_SEQ := WMS.PCK_INTERFACE_WMS.FC_SEQ_ENTRADA;
      --
      INSERT INTO WMS.INT_E_CLIENTE
         (NU_SEQ,
          CD_EMPRESA,
          CD_DEPOSITO,
          CD_CLIENTE,
          DS_CLIENTE,
          NU_INSCRICAO,
          CD_CNPJ_CLIENTE,
          CD_CEP,
          DS_ENDERECO,
          NU_ENDERECO,
          DS_COMPLEMENTO,
          DS_BAIRRO,
          DS_MUNICIPIO,
          CD_UF,
          NU_TELEFONE,
          NU_FAX,
          CD_ROTA,
          ID_CLIENTE_FILIAL,
          CD_SITUACAO,
          FILLER_1,
          FILLER_2,
          FILLER_3,
          FILLER_4,
          FILLER_5)
      VALUES
         (V_NU_SEQ,
          P_REC_CLIENTE.CD_EMPRESA,
          P_REC_CLIENTE.CD_DEPOSITO,
          P_REC_CLIENTE.CD_CLIENTE,
          P_REC_CLIENTE.DS_CLIENTE,
          P_REC_CLIENTE.NU_INSCRICAO,
          P_REC_CLIENTE.CD_CNPJ_CLIENTE,
          P_REC_CLIENTE.CD_CEP,
          P_REC_CLIENTE.DS_ENDERECO,
          P_REC_CLIENTE.NU_ENDERECO,
          P_REC_CLIENTE.DS_COMPLEMENTO,
          P_REC_CLIENTE.DS_BAIRRO,
          P_REC_CLIENTE.DS_MUNICIPIO,
          P_REC_CLIENTE.CD_UF,
          P_REC_CLIENTE.NU_TELEFONE,
          P_REC_CLIENTE.NU_FAX,
          P_REC_CLIENTE.CD_ROTA,
          P_REC_CLIENTE.ID_CLIENTE_FILIAL,
          NVL(P_REC_CLIENTE.CD_SITUACAO, 15),
          P_REC_CLIENTE.FILLER_1,
          P_REC_CLIENTE.FILLER_2,
          P_REC_CLIENTE.FILLER_3,
          P_REC_CLIENTE.FILLER_4,
          P_REC_CLIENTE.FILLER_5);
   END PR_INS_CLIENTE;
   --
   PROCEDURE PR_INS_FORNEC(P_REC_FORNEC IN WMS.INT_E_FORNECEDOR%ROWTYPE) IS
      V_NU_SEQ WMS.INT_E_FORNECEDOR.NU_SEQ%TYPE;
   BEGIN
      -- Busca a sequence da PK das tabelas de entrada
      V_NU_SEQ := WMS.PCK_INTERFACE_WMS.FC_SEQ_ENTRADA;
      --
      INSERT INTO WMS.INT_E_FORNECEDOR
         (NU_SEQ,
          CD_EMPRESA,
          CD_DEPOSITO,
          CD_FORNECEDOR,
          DS_RAZAO_SOCIAL,
          NM_FANTASIA,
          CD_CNPJ_FORNECEDOR,
          NU_INSCRICAO,
          DS_ENDERECO,
          DS_BAIRRO,
          DS_MUNICIPIO,
          CD_UF,
          CD_CEP,
          NU_TELEFONE,
          NU_FAX,
          CD_SITUACAO,
          FILLER_1,
          FILLER_2,
          FILLER_3,
          FILLER_4,
          FILLER_5,
          NU_ENDERECO,
          DS_COMPLEMENTO)
      VALUES
         (V_NU_SEQ,
          P_REC_FORNEC.CD_EMPRESA,
          P_REC_FORNEC.CD_DEPOSITO,
          P_REC_FORNEC.CD_FORNECEDOR,
          P_REC_FORNEC.DS_RAZAO_SOCIAL,
          P_REC_FORNEC.NM_FANTASIA,
          P_REC_FORNEC.CD_CNPJ_FORNECEDOR,
          P_REC_FORNEC.NU_INSCRICAO,
          P_REC_FORNEC.DS_ENDERECO,
          P_REC_FORNEC.DS_BAIRRO,
          P_REC_FORNEC.DS_MUNICIPIO,
          P_REC_FORNEC.CD_UF,
          P_REC_FORNEC.CD_CEP,
          P_REC_FORNEC.NU_TELEFONE,
          P_REC_FORNEC.NU_FAX,
          P_REC_FORNEC.CD_SITUACAO,
          P_REC_FORNEC.FILLER_1,
          P_REC_FORNEC.FILLER_2,
          P_REC_FORNEC.FILLER_3,
          P_REC_FORNEC.FILLER_4,
          P_REC_FORNEC.FILLER_5,
          P_REC_FORNEC.NU_ENDERECO,
          P_REC_FORNEC.DS_COMPLEMENTO);
   END PR_INS_FORNEC;
   --
   PROCEDURE PR_INS_TRANSP(P_REC_TRANSP IN WMS.INT_E_TRANSPORTADORA%ROWTYPE) IS
      V_NU_SEQ WMS.INT_E_TRANSPORTADORA.NU_SEQ%TYPE;
   BEGIN
      -- Busca a sequence da PK das tabelas de entrada
      V_NU_SEQ := WMS.PCK_INTERFACE_WMS.FC_SEQ_ENTRADA;
      --
      INSERT INTO WMS.INT_E_TRANSPORTADORA
         (NU_SEQ,
          CD_EMPRESA,
          CD_DEPOSITO,
          CD_TRANSPORTADORA,
          DS_TRANSPORTADORA,
          NU_INSCRICAO,
          CD_CNPJ_TRANSPORTADORA,
          CD_CEP,
          DS_ENDERECO,
          NU_ENDERECO,
          DS_COMPLEMENTO,
          DS_BAIRRO,
          DS_MUNICIPIO,
          CD_UF,
          NU_TELEFONE,
          NU_FAX,
          CD_SITUACAO,
          FILLER_1,
          FILLER_2,
          FILLER_3,
          FILLER_4,
          FILLER_5,
          CD_IMPRESSORA_ETIQ_EXPEDICAO)
      VALUES
         (V_NU_SEQ,
          P_REC_TRANSP.CD_EMPRESA,
          P_REC_TRANSP.CD_DEPOSITO,
          P_REC_TRANSP.CD_TRANSPORTADORA,
          P_REC_TRANSP.DS_TRANSPORTADORA,
          P_REC_TRANSP.NU_INSCRICAO,
          P_REC_TRANSP.CD_CNPJ_TRANSPORTADORA,
          P_REC_TRANSP.CD_CEP,
          P_REC_TRANSP.DS_ENDERECO,
          P_REC_TRANSP.NU_ENDERECO,
          P_REC_TRANSP.DS_COMPLEMENTO,
          P_REC_TRANSP.DS_BAIRRO,
          P_REC_TRANSP.DS_MUNICIPIO,
          P_REC_TRANSP.CD_UF,
          P_REC_TRANSP.NU_TELEFONE,
          P_REC_TRANSP.NU_FAX,
          P_REC_TRANSP.CD_SITUACAO,
          P_REC_TRANSP.FILLER_1,
          P_REC_TRANSP.FILLER_2,
          P_REC_TRANSP.FILLER_3,
          P_REC_TRANSP.FILLER_4,
          P_REC_TRANSP.FILLER_5,
          P_REC_TRANSP.CD_IMPRESSORA_ETIQ_EXPEDICAO);
   END PR_INS_TRANSP;
   --
   PROCEDURE PR_INS_CAB_NOTA_FISCAL(P_REC_CABNF IN OUT WMS.INT_E_CAB_NOTA_FISCAL%ROWTYPE) IS
   BEGIN
      -- Busca a sequence da PK das tabelas de entrada
      P_REC_CABNF.NU_SEQ := WMS.PCK_INTERFACE_WMS.FC_SEQ_ENTRADA;
      --
      INSERT INTO INT_E_CAB_NOTA_FISCAL
         (NU_SEQ,
          CD_EMPRESA,
          CD_DEPOSITO,
          CD_AGENDA,
          NU_NOTA,
          NU_SERIE_NOTA,
          CD_PORTA,
          CD_TRANSPORTADORA,
          DS_TRANSPORTADORA,
          CD_CNPJ_TRANSPORTADORA,
          CD_FORNECEDOR,
          CD_CNPJ_FORNECEDOR,
          DT_EMISSAO,
          DS_PLACA,
          DT_AGENDAMENTO,
          CD_SITUACAO,
          CD_TIPO_NOTA,
          NU_DOC_ERP,
          CD_RAV,
          FILLER_1,
          FILLER_2,
          FILLER_3,
          FILLER_4,
          FILLER_5,
          QT_VOLUMES)
      VALUES
         (P_REC_CABNF.NU_SEQ,
          P_REC_CABNF.CD_EMPRESA,
          P_REC_CABNF.CD_DEPOSITO,
          P_REC_CABNF.CD_AGENDA,
          P_REC_CABNF.NU_NOTA,
          P_REC_CABNF.NU_SERIE_NOTA,
          P_REC_CABNF.CD_PORTA,
          P_REC_CABNF.CD_TRANSPORTADORA,
          P_REC_CABNF.DS_TRANSPORTADORA,
          P_REC_CABNF.CD_CNPJ_TRANSPORTADORA,
          P_REC_CABNF.CD_FORNECEDOR,
          P_REC_CABNF.CD_CNPJ_FORNECEDOR,
          P_REC_CABNF.DT_EMISSAO,
          P_REC_CABNF.DS_PLACA,
          P_REC_CABNF.DT_AGENDAMENTO,
          NVL(P_REC_CABNF.CD_SITUACAO, 1),
          P_REC_CABNF.CD_TIPO_NOTA,
          P_REC_CABNF.NU_DOC_ERP,
          P_REC_CABNF.CD_RAV,
          P_REC_CABNF.FILLER_1,
          P_REC_CABNF.FILLER_2,
          P_REC_CABNF.FILLER_3,
          P_REC_CABNF.FILLER_4,
          P_REC_CABNF.FILLER_5,
          P_REC_CABNF.QT_VOLUMES);
   END PR_INS_CAB_NOTA_FISCAL;
   --
   PROCEDURE PR_INS_DET_NOTA_FISCAL(P_REC_DETNF IN WMS.INT_E_DET_NOTA_FISCAL%ROWTYPE) IS
   BEGIN
      --
      INSERT INTO INT_E_DET_NOTA_FISCAL
         (NU_SEQ,
          CD_EMPRESA,
          CD_DEPOSITO,
          CD_CLIENTE,
          CD_AGENDA,
          NU_NOTA,
          NU_SERIE_NOTA,
          CD_FORNECEDOR,
          CD_CGC_FORNECEDOR,
          CD_SITUACAO,
          NU_ITEM_CORP,
          CD_PRODUTO,
          QT_PRODUTO,
          NU_LOTE,
          NU_LOTE_FORNECEDOR,
          DT_FABRICACAO,
          DS_AREA_ERP,
          FILLER_1,
          FILLER_2,
          FILLER_3,
          FILLER_4,
          FILLER_5,
          CD_CNPJ_CLIENTE,
          NU_PEDIDO_ORIGEM,
          CD_PRODUTO_GRADE,
          CD_EMBALAGEM,
          NU_ETIQUETA_LOTE)
      VALUES
         (P_REC_DETNF.NU_SEQ,
          P_REC_DETNF.CD_EMPRESA,
          P_REC_DETNF.CD_DEPOSITO,
          P_REC_DETNF.CD_CLIENTE,
          P_REC_DETNF.CD_AGENDA,
          P_REC_DETNF.NU_NOTA,
          P_REC_DETNF.NU_SERIE_NOTA,
          P_REC_DETNF.CD_FORNECEDOR,
          P_REC_DETNF.CD_CGC_FORNECEDOR,
          NVL(P_REC_DETNF.CD_SITUACAO, 1),
          P_REC_DETNF.NU_ITEM_CORP,
          P_REC_DETNF.CD_PRODUTO,
          P_REC_DETNF.QT_PRODUTO,
          P_REC_DETNF.NU_LOTE,
          P_REC_DETNF.NU_LOTE_FORNECEDOR,
          P_REC_DETNF.DT_FABRICACAO,
          P_REC_DETNF.DS_AREA_ERP,
          P_REC_DETNF.FILLER_1,
          P_REC_DETNF.FILLER_2,
          P_REC_DETNF.FILLER_3,
          P_REC_DETNF.FILLER_4,
          P_REC_DETNF.FILLER_5,
          P_REC_DETNF.CD_CNPJ_CLIENTE,
          P_REC_DETNF.NU_PEDIDO_ORIGEM,
          P_REC_DETNF.CD_PRODUTO_GRADE,
          P_REC_DETNF.CD_EMBALAGEM,
          P_REC_DETNF.NU_ETIQUETA_LOTE);

   END PR_INS_DET_NOTA_FISCAL;
   --
   -- Insere NF da GUIA/Placa enviadas ao WMS para recebimento - para controle do retorno
   PROCEDURE PR_INS_CTR_NF_RECEB(P_TP_NF       IN VARCHAR2,
                                 P_ID_LOCAL    IN NUMBER,
                                 P_CD_FIL_ESTQ IN NUMBER,
                                 P_DT_INIC     IN DATE,
                                 P_REC_CABNF   IN WMS.INT_E_CAB_NOTA_FISCAL%ROWTYPE) IS
   BEGIN
      --
      INSERT INTO CTR_NOTA_FISCAL_RECEB
         (NU_SEQ,
          CD_DEPOSITO,
          NU_NOTA,
          NU_SERIE_NOTA,
          DT_EMISSAO,
          ID_GUIA_LIB_GLB,
          DS_PLACA,
          ID_LOCAL_DES,
          CD_FIL_ESTQ_DES,
          DT_INIC_DES,
          TIPO_NOTA,
          ID_RECEBIDO,
          DT_ADDROW,
          ID_PROCESSADO)
      VALUES
         (P_REC_CABNF.NU_SEQ,
          P_REC_CABNF.CD_DEPOSITO,
          P_REC_CABNF.NU_NOTA,
          P_REC_CABNF.NU_SERIE_NOTA,
          TO_DATE(P_REC_CABNF.DT_EMISSAO, 'DD/MM/YYYY HH24:MI:SS'),
          DECODE(P_TP_NF, 'NFE', NULL, P_REC_CABNF.NU_DOC_ERP), -- id da guia de libera��o do desembarque
          P_REC_CABNF.DS_PLACA,
          P_ID_LOCAL,
          P_CD_FIL_ESTQ,
          P_DT_INIC,
          P_TP_NF,
          'N',
          SYSDATE,
          'N');
   END PR_INS_CTR_NF_RECEB;
   --
   PROCEDURE PR_INS_CAB_PEDIDO_SAIDA(P_REC_CPS IN OUT WMS.INT_E_CAB_PEDIDO_SAIDA%ROWTYPE) IS
   BEGIN
      -- Busca a sequence da PK das tabelas de entrada
      P_REC_CPS.NU_SEQ := WMS.PCK_INTERFACE_WMS.FC_SEQ_ENTRADA;
      --
      INSERT INTO INT_E_CAB_PEDIDO_SAIDA
         (NU_SEQ,
          CD_EMPRESA,
          CD_DEPOSITO,
          NU_PEDIDO_ORIGEM,
          CD_CLIENTE,
          CD_CNPJ_CLIENTE,
          DS_CLIENTE,
          CD_CARGA,
          CD_SITUACAO,
          TP_PEDIDO,
          DS_TPPEDIDO,
          CD_PORTA,
          CD_TRANSPORTADORA,
          CD_CNPJ_TRANSPORTADORA,
          DS_TRANSPORTADORA,
          NU_DOC_ERP,
          DS_CLIENTE_ENTREGA,
          CD_CNPJ_CLIENTE_ENTREGA,
          DS_ENDERECO_ENTREGA,
          NU_ENDERECO_ENTREGA,
          DS_COMPLEMENTO_ENTREGA,
          DS_BAIRRO_ENTREGA,
          DS_MUNICIPIO_ENTREGA,
          CD_UF_ENTREGA,
          CD_CEP_ENTREGA,
          NU_TELEFONE_ENTREGA,
          VL_NOTA,
          DT_ENTREGA,
          CD_AGENDA,
          NU_SEQ_ENTREGA,
          NU_PEDIDO,
          CD_CANAL,
          DS_CANAL,
          CD_ROTA,
          DS_ROTA,
          ID_SOLICITA_CONTROLE,
          DT_FATURAMENTO,
          DT_ENTRADA,
          NU_OBJETO_POSTAGEM,
          DS_OBSERVACAO,
          CD_MUNICIPIO_IBGE,
          TP_FRETE,
          ID_CONTRIBUINTE_ICMS,
          CD_PRODUTO_CATEGORIA,
          VLR_FRETE_RECEBER,
          CD_TIPO_ENTREGA,
          FILLER_1,
          FILLER_2,
          FILLER_3,
          FILLER_4,
          FILLER_5,
          DS_PONTUACAO_CLIENTE,
          CD_FILIAL_VENDA,
          DS_MODAL_FRETE,
          NU_VOLUME_TRANSPORTE,
          QT_PEDIDOS_CARGA,
          NU_ETIQUETA_MASTER,
          NU_ORDEM_COMPRA,
          TP_SERVICO_ENTREGA,
          DT_PAGAMENTO_PEDIDO,
          DS_PLACA,
          DS_PROGRAM_DIARIA_SERVICO)
      VALUES
         (P_REC_CPS.NU_SEQ,
          P_REC_CPS.CD_EMPRESA,
          P_REC_CPS.CD_DEPOSITO,
          P_REC_CPS.NU_PEDIDO_ORIGEM,
          P_REC_CPS.CD_CLIENTE,
          P_REC_CPS.CD_CNPJ_CLIENTE,
          P_REC_CPS.DS_CLIENTE,
          P_REC_CPS.CD_CARGA,
          NVL(P_REC_CPS.CD_SITUACAO, 1),
          P_REC_CPS.TP_PEDIDO,
          P_REC_CPS.DS_TPPEDIDO,
          P_REC_CPS.CD_PORTA,
          P_REC_CPS.CD_TRANSPORTADORA,
          P_REC_CPS.CD_CNPJ_TRANSPORTADORA,
          P_REC_CPS.DS_TRANSPORTADORA,
          P_REC_CPS.NU_DOC_ERP,
          P_REC_CPS.DS_CLIENTE_ENTREGA,
          P_REC_CPS.CD_CNPJ_CLIENTE_ENTREGA,
          P_REC_CPS.DS_ENDERECO_ENTREGA,
          P_REC_CPS.NU_ENDERECO_ENTREGA,
          P_REC_CPS.DS_COMPLEMENTO_ENTREGA,
          P_REC_CPS.DS_BAIRRO_ENTREGA,
          P_REC_CPS.DS_MUNICIPIO_ENTREGA,
          P_REC_CPS.CD_UF_ENTREGA,
          P_REC_CPS.CD_CEP_ENTREGA,
          P_REC_CPS.NU_TELEFONE_ENTREGA,
          P_REC_CPS.VL_NOTA,
          P_REC_CPS.DT_ENTREGA,
          P_REC_CPS.CD_AGENDA,
          P_REC_CPS.NU_SEQ_ENTREGA,
          P_REC_CPS.NU_PEDIDO,
          P_REC_CPS.CD_CANAL,
          P_REC_CPS.DS_CANAL,
          P_REC_CPS.CD_ROTA,
          P_REC_CPS.DS_ROTA,
          P_REC_CPS.ID_SOLICITA_CONTROLE,
          P_REC_CPS.DT_FATURAMENTO,
          P_REC_CPS.DT_ENTRADA,
          P_REC_CPS.NU_OBJETO_POSTAGEM,
          P_REC_CPS.DS_OBSERVACAO,
          P_REC_CPS.CD_MUNICIPIO_IBGE,
          P_REC_CPS.TP_FRETE,
          P_REC_CPS.ID_CONTRIBUINTE_ICMS,
          P_REC_CPS.CD_PRODUTO_CATEGORIA,
          P_REC_CPS.VLR_FRETE_RECEBER,
          P_REC_CPS.CD_TIPO_ENTREGA,
          P_REC_CPS.FILLER_1,
          P_REC_CPS.FILLER_2,
          P_REC_CPS.FILLER_3,
          P_REC_CPS.FILLER_4,
          P_REC_CPS.FILLER_5,
          P_REC_CPS.DS_PONTUACAO_CLIENTE,
          P_REC_CPS.CD_FILIAL_VENDA,
          P_REC_CPS.DS_MODAL_FRETE,
          P_REC_CPS.NU_VOLUME_TRANSPORTE,
          P_REC_CPS.QT_PEDIDOS_CARGA,
          P_REC_CPS.NU_ETIQUETA_MASTER,
          P_REC_CPS.NU_ORDEM_COMPRA,
          P_REC_CPS.TP_SERVICO_ENTREGA,
          P_REC_CPS.DT_PAGAMENTO_PEDIDO,
          P_REC_CPS.DS_PLACA,
          P_REC_CPS.DS_PROGRAM_DIARIA_SERVICO);
   END PR_INS_CAB_PEDIDO_SAIDA;
   --
   PROCEDURE PR_INS_DET_PEDIDO_SAIDA(P_REC_DPS IN WMS.INT_E_DET_PEDIDO_SAIDA%ROWTYPE) IS
   BEGIN
      INSERT INTO INT_E_DET_PEDIDO_SAIDA
         (NU_SEQ,
          CD_EMPRESA,
          CD_DEPOSITO,
          NU_PEDIDO_ORIGEM,
          CD_CLIENTE,
          CD_PRODUTO,
          NU_ITEM_CORP,
          QT_SEPARAR,
          CD_SITUACAO,
          NU_LOTE,
          NU_NOTA,
          NU_SERIE_NOTA,
          CFOP,
          DT_NOTA_FISCAL,
          NU_PEDIDO,
          ID_EMBALAGEM_PRESENTE,
          CAMPANHA,
          CD_CHAVE_DANFE,
          DS_AREA_ERP,
          FILLER_1,
          FILLER_2,
          FILLER_3,
          FILLER_4,
          FILLER_5,
          CD_CARGA,
          NU_ETIQUETA_MASTER,
          DS_PRODUTO_PERSONALIZADO,
          DS_OBSERVACAO,
          NU_CTRL_ITEM)
      VALUES
         (P_REC_DPS.NU_SEQ,
          P_REC_DPS.CD_EMPRESA,
          P_REC_DPS.CD_DEPOSITO,
          P_REC_DPS.NU_PEDIDO_ORIGEM,
          P_REC_DPS.CD_CLIENTE,
          P_REC_DPS.CD_PRODUTO,
          P_REC_DPS.NU_ITEM_CORP,
          P_REC_DPS.QT_SEPARAR,
          NVL(P_REC_DPS.CD_SITUACAO, 1),
          P_REC_DPS.NU_LOTE,
          P_REC_DPS.NU_NOTA,
          P_REC_DPS.NU_SERIE_NOTA,
          P_REC_DPS.CFOP,
          P_REC_DPS.DT_NOTA_FISCAL,
          P_REC_DPS.NU_PEDIDO,
          NVL(P_REC_DPS.ID_EMBALAGEM_PRESENTE, 'N'),
          P_REC_DPS.CAMPANHA,
          P_REC_DPS.CD_CHAVE_DANFE,
          P_REC_DPS.DS_AREA_ERP,
          P_REC_DPS.FILLER_1,
          P_REC_DPS.FILLER_2,
          P_REC_DPS.FILLER_3,
          P_REC_DPS.FILLER_4,
          P_REC_DPS.FILLER_5,
          P_REC_DPS.CD_CARGA,
          P_REC_DPS.NU_ETIQUETA_MASTER,
          P_REC_DPS.DS_PRODUTO_PERSONALIZADO,
          P_REC_DPS.DS_OBSERVACAO,
          P_REC_DPS.NU_CTRL_ITEM);
   END PR_INS_DET_PEDIDO_SAIDA;
   --
   PROCEDURE PR_INS_AJUSTE_ESTOQUE(P_REC_AJUSTE_ESTQ IN WMS.INT_E_AJUSTE_ESTOQUE%ROWTYPE) IS
      V_NU_SEQ WMS.INT_E_AJUSTE_ESTOQUE.NU_SEQ%TYPE;
   BEGIN
      -- Busca a sequence da PK das tabelas de entrada
      V_NU_SEQ := WMS.PCK_INTERFACE_WMS.FC_SEQ_ENTRADA;
      --
      INSERT INTO WMS.INT_E_AJUSTE_ESTOQUE
         (NU_SEQ,
          CD_EMPRESA,
          CD_DEPOSITO,
          CD_PRODUTO,
          QT_MOVIMENTO,
          DT_MOVIMENTO,
          DS_AREA_ERP_ORIGEM,
          DS_AREA_ERP_DESTINO,
          NU_LOTE,
          NU_DOC_ERP,
          CD_SITUACAO,
          FILLER_1,
          FILLER_2,
          FILLER_3,
          FILLER_4,
          FILLER_5,
          DT_LIB_QUARENTENA,
          CD_AREA_ARMAZ_ORIGEM,
          CD_AREA_ARMAZ_DESTINO,
          NU_NOTA,
          NU_SERIE_NOTA,
          CD_FORNECEDOR)
      VALUES
         (V_NU_SEQ,
          P_REC_AJUSTE_ESTQ.CD_EMPRESA,
          P_REC_AJUSTE_ESTQ.CD_DEPOSITO,
          P_REC_AJUSTE_ESTQ.CD_PRODUTO,
          P_REC_AJUSTE_ESTQ.QT_MOVIMENTO,
          P_REC_AJUSTE_ESTQ.DT_MOVIMENTO,
          P_REC_AJUSTE_ESTQ.DS_AREA_ERP_ORIGEM,
          P_REC_AJUSTE_ESTQ.DS_AREA_ERP_DESTINO,
          P_REC_AJUSTE_ESTQ.NU_LOTE,
          P_REC_AJUSTE_ESTQ.NU_DOC_ERP,
          P_REC_AJUSTE_ESTQ.CD_SITUACAO,
          P_REC_AJUSTE_ESTQ.FILLER_1,
          P_REC_AJUSTE_ESTQ.FILLER_2,
          P_REC_AJUSTE_ESTQ.FILLER_3,
          P_REC_AJUSTE_ESTQ.FILLER_4,
          P_REC_AJUSTE_ESTQ.FILLER_5,
          P_REC_AJUSTE_ESTQ.DT_LIB_QUARENTENA,
          P_REC_AJUSTE_ESTQ.CD_AREA_ARMAZ_ORIGEM,
          P_REC_AJUSTE_ESTQ.CD_AREA_ARMAZ_DESTINO,
          P_REC_AJUSTE_ESTQ.NU_NOTA,
          P_REC_AJUSTE_ESTQ.NU_SERIE_NOTA,
          P_REC_AJUSTE_ESTQ.CD_FORNECEDOR);
   END PR_INS_AJUSTE_ESTOQUE;
   --
   PROCEDURE PR_INS_ALTERA_PEDIDO(P_REC_ALTPED IN WMS.INT_E_ALTERA_DADOS_PEDIDO%ROWTYPE) IS
      V_NU_SEQ WMS.INT_E_ALTERA_DADOS_PEDIDO.NU_SEQ%TYPE;
   BEGIN
      -- Busca a sequence da PK das tabelas de entrada
      V_NU_SEQ := WMS.PCK_INTERFACE_WMS.FC_SEQ_ENTRADA;
      --
      INSERT INTO WMS.INT_E_ALTERA_DADOS_PEDIDO
         (NU_SEQ,
          CD_EMPRESA,
          CD_DEPOSITO,
          NU_PEDIDO_ORIGEM,
          CD_CLIENTE,
          DS_CLIENTE_ENTREGA,
          DS_ENDERECO_ENTREGA,
          NU_ENDERECO_ENTREGA,
          DS_COMPLEMENTO_ENTREGA,
          DS_BAIRRO_ENTREGA,
          DS_MUNICIPIO_ENTREGA,
          CD_UF_ENTREGA,
          CD_CEP_ENTREGA)
      VALUES
         (V_NU_SEQ,
          P_REC_ALTPED.CD_EMPRESA,
          P_REC_ALTPED.CD_DEPOSITO,
          P_REC_ALTPED.NU_PEDIDO_ORIGEM,
          P_REC_ALTPED.CD_CLIENTE,
          P_REC_ALTPED.DS_CLIENTE_ENTREGA,
          P_REC_ALTPED.DS_ENDERECO_ENTREGA,
          P_REC_ALTPED.NU_ENDERECO_ENTREGA,
          P_REC_ALTPED.DS_COMPLEMENTO_ENTREGA,
          P_REC_ALTPED.DS_BAIRRO_ENTREGA,
          P_REC_ALTPED.DS_MUNICIPIO_ENTREGA,
          P_REC_ALTPED.CD_UF_ENTREGA,
          P_REC_ALTPED.CD_CEP_ENTREGA);
   END PR_INS_ALTERA_PEDIDO;
   --
   PROCEDURE PR_INS_TRANSP_ROTA(P_REC_TRANSP_ROTA IN WMS.INT_E_TRANSPORTADORA_ROTA%ROWTYPE) IS
      V_NU_SEQ WMS.INT_E_TRANSPORTADORA_ROTA.NU_SEQ%TYPE;
   BEGIN
      -- Busca a sequence da PK das tabelas de entrada
      V_NU_SEQ := WMS.PCK_INTERFACE_WMS.FC_SEQ_ENTRADA;
      --
      INSERT INTO WMS.INT_E_TRANSPORTADORA_ROTA
         (NU_SEQ,
          CD_SEQ,
          CD_EMPRESA,
          CD_DEPOSITO,
          CD_TRANSPORTADORA,
          CD_UF,
          DS_MUNICIPIO,
          CD_ROTA,
          DS_ROTA,
          DS_SIGLA_ROTEIRIZADOR)
      VALUES
         (V_NU_SEQ,
          P_REC_TRANSP_ROTA.CD_SEQ,
          P_REC_TRANSP_ROTA.CD_EMPRESA,
          P_REC_TRANSP_ROTA.CD_DEPOSITO,
          P_REC_TRANSP_ROTA.CD_TRANSPORTADORA,
          P_REC_TRANSP_ROTA.CD_UF,
          P_REC_TRANSP_ROTA.DS_MUNICIPIO,
          P_REC_TRANSP_ROTA.CD_ROTA,
          P_REC_TRANSP_ROTA.DS_ROTA,
          P_REC_TRANSP_ROTA.DS_SIGLA_ROTEIRIZADOR);
   END PR_INS_TRANSP_ROTA;
   --
END PCK_GERAR_INTERF_WMS;
/
