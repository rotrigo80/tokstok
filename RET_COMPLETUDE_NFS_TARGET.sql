CREATE OR REPLACE FUNCTION GC.RET_COMPLETUDE_NFS_TARGET (P_CD_FIL_RSD    GC.NF_SAIDA.CD_FIL_RSD_EBQ%TYPE,
                            P_ID_ROM_RSD    GC.NF_SAIDA.ID_ROM_RSD_EBQ%TYPE,
                            P_DS_PLACA      GC.NF_SAIDA.DS_PLACA_EBQ%TYPE,
                            P_ID_AGRUPADOR  WMS.T_RELACIONA_PEDIDO_GC_WMS.ID_AGRUPADOR%TYPE,
                            P_TP_AGRUPADOR  WMS.T_RELACIONA_PEDIDO_GC_WMS.TP_AGRUPADOR%TYPE,
                            P_TP_PEDIDO_WMS WMS.T_RELACIONA_PEDIDO_GC_WMS.TP_PEDIDO_WMS%TYPE,
                            P_TP_DOCTO      WMS.T_RELACIONA_PEDIDO_GC_WMS.TP_DOCTO%TYPE,
                            P_CD_FIL_DOCTO  WMS.T_RELACIONA_PEDIDO_GC_WMS.CD_FIL_DOCTO%TYPE,
                            P_NR_DOCTO      WMS.T_RELACIONA_PEDIDO_GC_WMS.NR_DOCTO%TYPE,
                            P_DT_EMIS_DOCTO WMS.T_RELACIONA_PEDIDO_GC_WMS.DT_EMIS_DOCTO%TYPE,
                            P_CD_CCO           WMS.T_RELACIONA_PEDIDO_GC_WMS.CD_CCO%TYPE,
                            P_NU_PEDIDO_ORIGEM WMS.INT_S_CAB_PEDIDO_SAIDA.NU_PEDIDO_ORIGEM%TYPE,
                            P_NU_SEQ           WMS.INT_S_CAB_PEDIDO_SAIDA.NU_SEQ%TYPE) RETURN VARCHAR2 IS
--
-- versao 13
-- O criterio de verificacao de NFs deve ser o mesmo utilizado na procedure GC.PRC_RETORNAR_NFS_WMS_GC
-- 
CURSOR C_NFS_PEDIDOS IS
SELECT NFS.DT_EMIS
       ,NFS.CD_FIL
       ,NFS.NR_NF
       ,NFS.DS_SER
       ,NFS.NR_SUBSER
       ,NFS.CD_NAT_OPER_NZN
       ,NFS.CD_TIPO_NF_NZN
       ,NFS.VM_LIQ_MERC
       ,SUBSTR(GC.RET_CHAVE_NF_SAIDA(NFS.DT_EMIS,
                                    NFS.CD_FIL,
                                    NFS.NR_NF,
                                    NFS.DS_SER,
                                    NFS.NR_SUBSER,
                                    'S'),
              1,
              50) DANFE
        ,DECODE (NFF.IN_PEND_ARQ_NF_ELETR, NULL, 'S', 'N') CK_STATUS_ARQ_TXT
        ,NFF.NM_ARQ_TXT_NF_ELETR
        ,NFF.TX_OCOR_GERA_ARQ_NF_ELETR
  FROM (SELECT NFS.DT_EMIS,
               NFS.CD_FIL,
               NFS.NR_NF,
               NFS.DS_SER,
               NFS.NR_SUBSER,
               NFS.CD_NAT_OPER_NZN,
               NFS.CD_TIPO_NF_NZN,
               NFS.CD_FIL_RSD_EBQ,
               NFS.ID_ROM_RSD_EBQ,
               NFS.DS_PLACA_EBQ,
               NFS.VM_LIQ_MERC,
               NFS.CD_FIL_PVD,
               NFS.DT_EMIS_PVD,
               NFS.NR_PVD,
               NFS.CD_FIL_PSO,
               NFS.NR_PED_PSO,
               NFS.CD_FIL_REQ,
               NFS.NR_REQ,
               NFS.CD_FIL_RUC,
               NFS.NR_REQ_RUC,
               NFS.CD_CCO_RUC,
               NFS.CD_FIL_PRINC
          FROM GC.NF_SAIDA NFS
         WHERE NFS.DT_EMIS >= ADD_MONTHS(SYSDATE, -6)
           AND NFS.DT_CANC IS NULL) NFS, GC.ROMANEIO_SEPARACAO RSD, GC.NF_FORMULARIO NFF
 WHERE RSD.CD_FIL         = P_CD_FIL_RSD
   AND RSD.ID_ROM         = P_ID_ROM_RSD
   AND NFS.CD_FIL_RSD_EBQ = P_CD_FIL_RSD
   AND NFS.ID_ROM_RSD_EBQ = P_ID_ROM_RSD
   AND NFS.DS_PLACA_EBQ   = P_DS_PLACA
   AND NFF.DT_EMIS        = NFS.DT_EMIS
   AND NFF.CD_FIL         = NFS.CD_FIL
   AND NFF.NR_NF          = NFS.NR_NF
   AND NFF.NR_SUBSER      = NFS.NR_SUBSER
   AND NFF.DS_SER         = NFS.DS_SER
   AND NFF.IN_ENTR_SAIDA  = 'S'
   AND NFS.CD_FIL_PRINC IS NULL --RETORNA SOMENTE A NOTA PRINCIPAL QUANDO FOR REMESSAS A ORDEM/BRINDES/LISTA DE CASAMENTO
   AND ((((P_TP_AGRUPADOR = 'REQ' -- PEDIDOS REQ (REQ E RET)
               AND ((NFS.CD_FIL_REQ = RSD.CD_FIL_REQ AND
               NFS.NR_REQ =P_ID_AGRUPADOR) OR
                     (EXISTS (SELECT 1 FROM WMS.T_RELACIONA_RET_PSO TRRP
               WHERE TRRP.NU_PEDIDO_ORIGEM = P_NU_PEDIDO_ORIGEM
               AND   TRRP.NU_SEQ_ISCPS     = P_NU_SEQ
               AND   TRRP.CD_FIL           = NFS.CD_FIL_PSO
               AND   TRRP.NR_PED           = NFS.NR_PED_PSO)))) OR
       (P_TP_AGRUPADOR   != 'REQ' AND
             ((P_TP_DOCTO = 'PVD' AND NFS.CD_FIL_PVD = P_CD_FIL_DOCTO AND
       NFS.DT_EMIS_PVD = P_DT_EMIS_DOCTO AND NFS.NR_PVD = P_NR_DOCTO) OR
       (P_TP_DOCTO = 'POS' AND NFS.CD_FIL_PSO = P_CD_FIL_DOCTO AND
       NFS.NR_PED_PSO = P_NR_DOCTO) OR
       (P_TP_DOCTO = 'RUC' AND NFS.CD_FIL_RUC = P_CD_FIL_DOCTO AND
       NFS.NR_REQ_RUC = P_NR_DOCTO AND NFS.CD_CCO_RUC = P_CD_CCO) OR
       (P_TP_DOCTO = 'SPV')))) AND NOT EXISTS
        (SELECT 1
            FROM ITEM_PV_FAT_ITEM_NF_TRANSF IPVT
           WHERE IPVT.NR_PV_IPV = P_NR_DOCTO
             AND IPVT.CD_FIL_IPV = P_CD_FIL_DOCTO
             AND IPVT.DT_EMIS_IPV = P_DT_EMIS_DOCTO
             AND 'PVP' = P_TP_PEDIDO_WMS
             AND 'PDS' = P_TP_AGRUPADOR)) OR
       (EXISTS (SELECT 1
                   FROM ITEM_PV_FAT_ITEM_NF_TRANSF IPVT
                  WHERE IPVT.NR_PV_IPV = P_NR_DOCTO
                    AND IPVT.CD_FIL_IPV = P_CD_FIL_DOCTO
                    AND IPVT.DT_EMIS_IPV = P_DT_EMIS_DOCTO
                    AND 'PVP' = P_TP_PEDIDO_WMS
                    AND 'PDS' = P_TP_AGRUPADOR)));
--
CURSOR C_TOTAIS_ITENS IS
SELECT ISDPS.CD_PRODUTO SKU,
       SUM(NVL(ISDPS.QT_ISDPS, 0)) QT_ISDPS,
       SUM(NVL(ISP.QT_ISP, 0)) QT_ISP,
       SUM(NVL(ISDPS.QT_ISDPS, 0)) - SUM(NVL(ISP.QT_ISP, 0)) DIF_SKU
  FROM (SELECT ISDPS.CD_PRODUTO,
               SUM(NVL(ISDPS.QT_EXPEDIDA, 0) - NVL(IEDPS.QT_SEPARAR, 0)) QT_ISDPS
          FROM WMS.INT_S_DET_PEDIDO_SAIDA ISDPS,
               WMS.INT_E_DET_PEDIDO_SAIDA IEDPS
         WHERE ISDPS.NU_PEDIDO_ORIGEM = P_NU_PEDIDO_ORIGEM
           AND ISDPS.NU_SEQ = P_NU_SEQ
           AND ISDPS.CD_SITUACAO = 57
           AND ISDPS.NU_PEDIDO_ORIGEM = IEDPS.NU_PEDIDO_ORIGEM(+)
           AND ISDPS.CD_PRODUTO = IEDPS.CD_PRODUTO(+)
           AND 2 = IEDPS.CD_SITUACAO(+)
         GROUP BY ISDPS.CD_PRODUTO) ISDPS,
         (SELECT ISP.ID_PROD ID_PROD,
                                                  SUM(NVL(ISP.QT_ITEM, 0)) QT_ISP
                                             FROM (SELECT NFS.DT_EMIS,
                                                          NFS.CD_FIL,
                                                          NFS.NR_NF,
                                                          NFS.DS_SER,
                                                          NFS.NR_SUBSER,
                                                          NFS.CD_NAT_OPER_NZN,
                                                          NFS.CD_TIPO_NF_NZN,
                                                          NFS.CD_FIL_RSD_EBQ,
                                                          NFS.ID_ROM_RSD_EBQ,
                                                          NFS.DS_PLACA_EBQ,
                                                          NFS.VM_LIQ_MERC,
                                                          NFS.CD_FIL_PVD,
                                                          NFS.DT_EMIS_PVD,
                                                          NFS.NR_PVD,
                                                          NFS.CD_FIL_PSO,
                                                          NFS.NR_PED_PSO,
                                                          NFS.CD_FIL_REQ,
                                                          NFS.NR_REQ,
                                                          NFS.CD_FIL_RUC,
                                                          NFS.NR_REQ_RUC,
                                                          NFS.CD_CCO_RUC,
                                                          NFS.CD_FIL_PRINC
                                                     FROM GC.NF_SAIDA NFS
                                                    WHERE NFS.DT_EMIS >=
                                                          ADD_MONTHS(SYSDATE,
                                                                     -6)
                                                      AND NFS.DT_CANC IS NULL) NFS,
                                                  GC.ROMANEIO_SEPARACAO RSD,
                                                  GC.NF_FORMULARIO NFF,
                                                  GC.ITEM_NF_SAIDA_PRODUTO ISP
                                            WHERE RSD.CD_FIL = P_CD_FIL_RSD
                                              AND RSD.ID_ROM = P_ID_ROM_RSD
                                              AND NFS.CD_FIL_RSD_EBQ =
                                                  P_CD_FIL_RSD
                                              AND NFS.ID_ROM_RSD_EBQ =
                                                  P_ID_ROM_RSD
                                              AND NFS.DS_PLACA_EBQ =
                                                  P_DS_PLACA
                                              AND NFF.DT_EMIS = NFS.DT_EMIS
                                              AND NFF.CD_FIL = NFS.CD_FIL
                                              AND NFF.NR_NF = NFS.NR_NF
                                              AND NFF.NR_SUBSER =
                                                  NFS.NR_SUBSER
                                              AND NFF.DS_SER = NFS.DS_SER
                                              AND NFF.IN_ENTR_SAIDA = 'S'
                                              AND NFS.CD_FIL_PRINC IS NULL --RETORNA SOMENTE A NOTA PRINCIPAL QUANDO FOR REMESSAS A ORDEM/BRINDES/LISTA DE CASAMENTO
                                              AND NFS.DT_EMIS = ISP.DT_EMIS
                                              AND NFS.CD_FIL = ISP.CD_FIL
                                              AND NFS.NR_NF = ISP.NR_NF
                                              AND NFS.DS_SER = ISP.DS_SER
                                              AND NFS.NR_SUBSER =
                                                  ISP.NR_SUBSER
                                              AND ((((P_TP_AGRUPADOR = 'REQ' -- PEDIDOS REQ (REQ E RET)
                                                  AND ((NFS.CD_FIL_REQ = RSD.CD_FIL_REQ AND
                                                        NFS.NR_REQ =P_ID_AGRUPADOR) OR
                                                       (EXISTS (SELECT 1 FROM WMS.T_RELACIONA_RET_PSO TRRP
                                                   WHERE TRRP.NU_PEDIDO_ORIGEM = P_NU_PEDIDO_ORIGEM
                                                   AND   TRRP.NU_SEQ_ISCPS     = P_NU_SEQ
                                                   AND   TRRP.CD_FIL           = NFS.CD_FIL_PSO
                                                   AND   TRRP.NR_PED           = NFS.NR_PED_PSO)))) OR
                                                  (P_TP_AGRUPADOR !=
                                                  'REQ' AND
                                                  ((P_TP_DOCTO = 'PVD' AND
                                                  NFS.CD_FIL_PVD =
                                                  P_CD_FIL_DOCTO AND
                                                  NFS.DT_EMIS_PVD =
                                                  P_DT_EMIS_DOCTO AND
                                                  NFS.NR_PVD =
                                                  P_NR_DOCTO) OR
                                                  (P_TP_DOCTO = 'POS' AND
                                                  NFS.CD_FIL_PSO =
                                                  P_CD_FIL_DOCTO AND
                                                  NFS.NR_PED_PSO =
                                                  P_NR_DOCTO) OR
                                                  (P_TP_DOCTO = 'RUC' AND
                                                  NFS.CD_FIL_RUC =
                                                  P_CD_FIL_DOCTO AND
                                                  NFS.NR_REQ_RUC =
                                                  P_NR_DOCTO AND
                                                  NFS.CD_CCO_RUC =
                                                  P_CD_CCO) OR
                                                  (P_TP_DOCTO = 'SPV')))) AND
                                                  NOT EXISTS
                                                   (SELECT 1
                                                       FROM ITEM_PV_FAT_ITEM_NF_TRANSF IPVT
                                                      WHERE IPVT.NR_PV_IPV =
                                                            P_NR_DOCTO
                                                        AND IPVT.CD_FIL_IPV =
                                                            P_CD_FIL_DOCTO
                                                        AND IPVT.DT_EMIS_IPV =
                                                            P_DT_EMIS_DOCTO
                                                        AND 'PVP' =
                                                            P_TP_PEDIDO_WMS
                                                        AND 'PDS' =
                                                            P_TP_AGRUPADOR)) OR
                                                  (EXISTS
                                                   (SELECT 1
                                                       FROM ITEM_PV_FAT_ITEM_NF_TRANSF IPVT
                                                      WHERE IPVT.NR_PV_IPV =
                                                            P_NR_DOCTO
                                                        AND IPVT.CD_FIL_IPV =
                                                            P_CD_FIL_DOCTO
                                                        AND IPVT.DT_EMIS_IPV =
                                                            P_DT_EMIS_DOCTO
                                                        AND 'PVP' =
                                                            P_TP_PEDIDO_WMS
                                                        AND 'PDS' =
                                                            P_TP_AGRUPADOR)))
                                            GROUP BY ISP.ID_PROD) ISP
 WHERE ISDPS.CD_PRODUTO = ISP.ID_PROD(+)
 GROUP BY ISDPS.CD_PRODUTO
HAVING SUM(NVL(ISDPS.QT_ISDPS, 0)) - SUM(NVL(ISP.QT_ISP, 0)) <> 0;
--
R_NFS_PEDIDOS C_NFS_PEDIDOS%ROWTYPE;
V_QTDE_NFS       NUMBER := 0;
V_QTDE_SEM_DANFE NUMBER := 0;
V_QTDE_ITENS_DIF NUMBER := 0;
V_RETORNO        VARCHAR2(01) := 'N';
--
-- variaveis utilizadas para verificacao de status da NFe
--
V_NM_ARQ_TXT_NF_ELETR     GC.NF_FORMULARIO.NM_ARQ_TXT_NF_ELETR%TYPE;
V_DS_PROTOCOLO            NF_ELETR.TNFE_HEADER.NFE_PROTOCOLO%TYPE;
V_DT_ENVIO                NF_ELETR.TNFE_HEADER.NFE_DATA_RECRET%TYPE;
V_DS_CHAVE_ACESSO     	  NF_ELETR.TNFE_HEADER.NFE_CHAVE%TYPE;
V_CD_STATUS_NF_ELETR  	  NF_ELETR.TNFE_HEADER.NFE_REG_CODIGO%TYPE;
V_DS_STATUS_NF_ELETR  	  NF_ELETR.NFE_REGRA_SW.REG_DESCRICAO%TYPE;
V_TX_ERRO             	  VARCHAR2(4000);
--
BEGIN
  --
  -- OBJETIVO..: REALIZAR A VERIFICAÇÃO DE EXISTENCIA DE NFS DE ACORDO COM DADOS DO PEDIDO/EMBARQUE WMS GC
  -- AUTOR/DATA: JEAN JEYME COSTA DEBTIL, 26/10/2020
  -- ALTERACOES: O intuito da completude eh identificar se todas as NFs associadas ao pedido existem,
  -- se foram validadas no SEFAZ e contem uma DANFE na target e inclusive verifica se o status eh valido
  --
  V_QTDE_NFS := 0;
  V_QTDE_SEM_DANFE := 0;
  V_RETORNO := 'N';
  FOR R_NFS_PEDIDOS IN C_NFS_PEDIDOS LOOP
    V_QTDE_NFS := V_QTDE_NFS + 1;
    -- verificacao de status nfe
    GC.PCK_NF_ELETR.LER_STATUS_NF_ELETR ( P_DT_EMIS             => R_NFS_PEDIDOS.DT_EMIS
                                         ,P_CD_FIL              => R_NFS_PEDIDOS.CD_FIL
                                         ,P_NR_NF               => R_NFS_PEDIDOS.NR_NF
                                         ,P_DS_SER              => R_NFS_PEDIDOS.DS_SER
                                         ,P_NR_SUBSER           => R_NFS_PEDIDOS.NR_SUBSER
                                         ,P_IN_ENTR_SAIDA       => 'S'
                                         ,P_NM_ARQ_TXT_NF_ELETR => R_NFS_PEDIDOS.NM_ARQ_TXT_NF_ELETR
                                         ,P_DS_PROTOCOLO        => V_DS_PROTOCOLO
                                         ,P_DT_ENVIO            => V_DT_ENVIO
                                         ,P_DS_CHAVE_ACESSO     => V_DS_CHAVE_ACESSO
                                         ,P_CD_STATUS_NF_ELETR  => V_CD_STATUS_NF_ELETR
                                         ,P_DS_STATUS_NF_ELETR  => V_DS_STATUS_NF_ELETR
                                         ,P_TX_ERRO             => V_TX_ERRO);

    IF V_CD_STATUS_NF_ELETR NOT IN (100,150) OR 
       R_NFS_PEDIDOS.DANFE IS NULL THEN
       V_QTDE_SEM_DANFE := V_QTDE_SEM_DANFE + 1;
    END IF;
  END LOOP;
  --
  -- SE TODAS AS NFS POSSUEM DANFE VERIFICA-SE SE TODOS OS ITENS ESTÃO RELACIONADOS/ASSOCIADOS
  -- E SE AS QUANTIDADES EXPEDIDAS ESTAO DE ACORDO COM AS QUANTIDADES FATURADAS
  --
  IF V_QTDE_NFS > 0 AND V_QTDE_SEM_DANFE = 0 THEN 
    V_QTDE_ITENS_DIF := 0;
    BEGIN
      FOR R_TOTAIS_ITENS IN C_TOTAIS_ITENS LOOP
        V_QTDE_ITENS_DIF := V_QTDE_ITENS_DIF + 1;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        V_QTDE_ITENS_DIF := -1;
    END;
    IF V_QTDE_ITENS_DIF = 0 THEN
       V_RETORNO := 'S';
    END IF;
  END IF;
  RETURN (V_RETORNO);
END RET_COMPLETUDE_NFS_TARGET;
/
CREATE OR REPLACE PUBLIC SYNONYM RET_COMPLETUDE_NFS_TARGET FOR GC.RET_COMPLETUDE_NFS_TARGET;
/
GRANT EXECUTE ON GC.RET_COMPLETUDE_NFS_TARGET TO GC_LOJA;
/
GRANT EXECUTE ON GC.RET_COMPLETUDE_NFS_TARGET TO SICA_RL_GC_GERAL;
/
GRANT EXECUTE ON GC.RET_COMPLETUDE_NFS_TARGET TO RL_GC_DTI;
/
GRANT EXECUTE ON GC.RET_COMPLETUDE_NFS_TARGET TO RL_EXEC_GC;
/
GRANT EXECUTE ON GC.RET_COMPLETUDE_NFS_TARGET TO RL_CONS_GC;
/
GRANT EXECUTE ON GC.RET_COMPLETUDE_NFS_TARGET TO OMS_LINX;
/
