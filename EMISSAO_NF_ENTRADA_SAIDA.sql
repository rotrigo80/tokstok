CREATE OR REPLACE PROCEDURE GC.EMISSAO_NF_ENTRADA_SAIDA
                            ---------------------------
(
  P_SNS              IN OUT GC.SOLICITA_NF_SAIDA_ENTRADA%ROWTYPE
 ,P_ID_AGRUPADOR_PDS IN VARCHAR2 DEFAULT 'N' -- JEAN JEYME COSTA DEBTIL LOG-288
) IS
--
 P_PVD        GC.PEDIDO_VENDA%ROWTYPE;
 P_AIS        GC.ACAO_ITEM_SERVICO_POS_VENDA%ROWTYPE;
 --
 D_RETORNO    VARCHAR2(4000);
 D_CD_MOTIV   GC.ACAO_ITEM_SERVICO_POS_VENDA.CD_MOTIV%TYPE;
 D_EXISTE     NUMBER;
 D_ID_RSGV    GC.ROM_SEP_GERADO_GRUPO_VENDA.ID_RSGV%TYPE;
 D_ID_QRSG    GC.ROM_SEP_GRUPO_VENDA.ID_QRSG%TYPE;
 D_NR_PROX    GC.ACAO_ITEM_SERVICO_POS_VENDA.NR_ACAO%TYPE;
 --
 D_TXT_EMAIL  GC.GC_MSG.TX_OCOR%TYPE;
 --
 D_ERRO       VARCHAR2(2000);
 D_REQUERENTE VARCHAR2(2000);
 --
 D_NF_RET             VARCHAR2(4000);
 D_TEXTO_EMAIL_POE    VARCHAR2(4000);
 D_EMAIL              VARCHAR2(100);
 D_EMAIL_CC           VARCHAR2(100);
 --
 ---
 ---Cursor com as informações do PDS a ser faturado quando não for FATURAROE
 ---
 CURSOR C_RSGP
 (
   PC1_CD_FIL_RSD           GC.ROMANEIO_SEPARACAO.CD_FIL%TYPE
  ,PC1_ID_ROM_RSD           GC.ROMANEIO_SEPARACAO.ID_ROM%TYPE
  ,PC1_DS_PLACA             GC.EMBARQUE.DS_PLACA%TYPE
 ) IS
   SELECT A.ID_PDS
     FROM (SELECT RSGP.ID_PDS
             FROM GC.ROM_SEP_GRUPO_PDS       RSGP
                 ,GC.GRUPO_PDS_ROM_SEPARACAO GPRS
                 ,FILIAL_DEPOSITO_SECUNDARIO FDPS
            WHERE GPRS.CD_FIL                =  PC1_CD_FIL_RSD
              AND GPRS.ID_ROM                =  PC1_ID_ROM_RSD
              AND GPRS.ID_GRUPO_PDS          =  RSGP.ID_GRUPO_PDS
              AND GPRS.CD_FIL                =  FDPS.CD_FIL_DS
              AND FDPS.IN_INTERFACE_WMS      IS NULL
              AND RSGP.IN_EXIGE_DETALHE_PDS  IS NULL
            UNION
           SELECT RSGP.ID_PDS
             FROM GC.ROM_SEP_GRUPO_PDS       RSGP
                 ,GC.GRUPO_PDS_ROM_SEPARACAO GPRS
                 ,GC.PDS                     PDS
            WHERE GPRS.CD_FIL       =  PC1_CD_FIL_RSD
              AND GPRS.ID_ROM       =  PC1_ID_ROM_RSD
              AND GPRS.ID_GRUPO_PDS =  RSGP.ID_GRUPO_PDS
              AND RSGP.IN_EXIGE_DETALHE_PDS IS NULL
              AND RSGP.ID_PDS       =  PDS.ID_PDS
              AND ((NVL(P_ID_AGRUPADOR_PDS,'N') = 'N' AND NVL(PDS.NR_PLACA,PDS.NR_PLACA_TS) = PC1_DS_PLACA) OR
                   (NVL(P_ID_AGRUPADOR_PDS,'N') = 'S' AND
                    EXISTS (SELECT 1 
                              FROM GC.ITEM_EMBQ_IPS_PRODUTO IEIP
                             WHERE IEIP.CD_FIL_RSD = PC1_CD_FIL_RSD
                               AND IEIP.ID_ROM_RSD = PC1_ID_ROM_RSD
                               AND IEIP.DS_PLACA   = PC1_DS_PLACA
                               AND IEIP.ID_PDS     = PDS.ID_PDS
                               AND IEIP.QT_EMBQ > IEIP.QT_FAT 
                             UNION
                            SELECT 1 
                              FROM GC.ITEM_EMBQ_IPS_PRD_MULT IEIPM
                             WHERE IEIPM.CD_FIL_RSD = PC1_CD_FIL_RSD
                               AND IEIPM.ID_ROM_RSD = PC1_ID_ROM_RSD
                               AND IEIPM.DS_PLACA   = PC1_DS_PLACA
                               AND IEIPM.ID_PDS     = PDS.ID_PDS
                               AND IEIPM.QT_EMBQ > IEIPM.QT_FAT )))
           UNION
           SELECT RSGP.ID_PDS
             FROM GC.PDS                     PDS
                 ,GC.ROM_SEP_GRUPO_PDS       RSGP
                 ,GC.GRUPO_PDS_ROM_SEPARACAO GPRS
            WHERE GPRS.CD_FIL       =  PC1_CD_FIL_RSD
              AND GPRS.ID_ROM       =  PC1_ID_ROM_RSD
              AND GPRS.ID_GRUPO_PDS =  RSGP.ID_GRUPO_PDS
              AND NVL(RSGP.IN_EXIGE_DETALHE_PDS,'N') = 'S'
              AND RSGP.ID_PDS       =  PDS.ID_PDS
              AND ((NVL(P_ID_AGRUPADOR_PDS,'N') = 'N' AND NVL(PDS.NR_PLACA,PDS.NR_PLACA_TS) = PC1_DS_PLACA) OR
                   (NVL(P_ID_AGRUPADOR_PDS,'N') = 'S' AND
                    EXISTS (SELECT 1 
                              FROM GC.ITEM_EMBQ_IPS_PRODUTO IEIP
                             WHERE IEIP.CD_FIL_RSD = PC1_CD_FIL_RSD
                               AND IEIP.ID_ROM_RSD = PC1_ID_ROM_RSD
                               AND IEIP.DS_PLACA   = PC1_DS_PLACA
                               AND IEIP.ID_PDS     = PDS.ID_PDS
                               AND IEIP.QT_EMBQ > IEIP.QT_FAT 
                             UNION
                            SELECT 1 
                              FROM GC.ITEM_EMBQ_IPS_PRD_MULT IEIPM
                             WHERE IEIPM.CD_FIL_RSD = PC1_CD_FIL_RSD
                               AND IEIPM.ID_ROM_RSD = PC1_ID_ROM_RSD
                               AND IEIPM.DS_PLACA   = PC1_DS_PLACA
                               AND IEIPM.ID_PDS     = PDS.ID_PDS
                               AND IEIPM.QT_EMBQ > IEIPM.QT_FAT )))) A 
    WHERE (EXISTS (SELECT 'X'
                     FROM GC.ITEM_PDS                IPS
                         ,GC.ITEM_PDS_FILIAL_RESERVA IPFR
                         ,GC.CLIENTE_RESERVA_ESTOQUE CLR
                    WHERE IPS.ID_PDS      = A.ID_PDS
                      AND IPS.IN_FAT_ANT IS NULL
                      AND IPFR.ID_PDS     = IPS.ID_PDS
                      AND CLR.ID_RESV_CLI = IPFR.ID_RESV_CLI
                      AND CLR.CD_FIL_RESV = PC1_CD_FIL_RSD)
       OR  EXISTS (SELECT 'X'
                     FROM ITEM_PDS IPS
                    WHERE IPS.ID_PDS     = A.ID_PDS
                      AND IPS.CD_FIL_IPX IS NOT NULL
                      AND IPS.NR_PED_IPX IS NOT NULL))
   ORDER BY A.ID_PDS;
 --
 R_C_RSGP  C_RSGP%ROWTYPE;
 --
 -- Cursor com os dados do POE gerado para a geração da NFE
 CURSOR C_POE IS
   SELECT DISTINCT
          POE.CD_FIL
         ,POE.NR_PED
     FROM GC.PED_OUTRA_ENTRADA POE
    WHERE EXISTS (SELECT 'X'
                    FROM GC.ITEM_PED_OUT_ENTR_PRD IPE
                        ,GC.NF_SAIDA NFS
                   WHERE NFS.ID_SESSAO      = PCK_1.G_ID_SESSAO_GTSNS2
                     AND IPE.CD_FIL_ISP     = NFS.CD_FIL
                     AND IPE.DT_EMIS_ISP    = NFS.DT_EMIS
                     AND IPE.NR_NF_ISP      = NFS.NR_NF
                     AND IPE.DS_SER_ISP     = NFS.DS_SER
                     AND IPE.NR_SUBSER_ISP  = NFS.NR_SUBSER
                     AND IPE.NR_ACAO_AIS   IS NOT NULL
                     AND IPE.CD_FIL         = POE.CD_FIL
                     AND IPE.NR_PED         = POE.NR_PED);
 --
 R_POE         C_POE%ROWTYPE;
 --
 -- Cursor com os dados da NFE gerada para geração da AQP
 CURSOR C_NFE
 (
   PC3_NR_PED IN GC.ITEM_PED_OUT_ENTR_PRD.NR_PED%TYPE
  ,PC3_CD_FIL IN GC.ITEM_PED_OUT_ENTR_PRD.CD_FIL%TYPE
 ) IS
   SELECT IPE.NR_ACAO_AIS
         ,INE.CD_FIL
         ,INE.DT_EMIS
         ,INE.NR_NF
         ,INE.DS_SER
         ,INE.NR_SUBSER
         ,INE.NR_ITEM
         ,INE.ID_PROD
         ,INE.QT_ITEM
     FROM GC.ITEM_PED_OUT_ENTR_PRD IPE
         ,GC.ITEM_NF_ENTR_PRODUTO  INE
    WHERE IPE.NR_PED      = PC3_NR_PED
      AND IPE.CD_FIL      = PC3_CD_FIL
      AND INE.CD_FIL_IPE  = IPE.CD_FIL
      AND INE.NR_PED_IPE  = IPE.NR_PED
      AND INE.NR_ITEM_IPE = IPE.NR_ITEM;
 --
 R_NFE  C_NFE%ROWTYPE;
 --
 CURSOR C_IPS
 (
   PC4_ID_PDS GC.ITEM_PDS.ID_PDS%TYPE
 ) IS
   SELECT IPS.*
     FROM GC.ITEM_PDS IPS
    WHERE IPS.ID_PDS      = PC4_ID_PDS
      AND IPS.QT_ITEM     > 0
      AND IPS.IN_FAT_ANT IS NULL
      AND NOT EXISTS (SELECT 'X'
                        FROM GC.ITEM_PDS_FILIAL_RESERVA IPFR
                       WHERE IPFR.ID_PDS  = IPS.ID_PDS
                         AND IPFR.NR_ITEM = IPS.NR_ITEM)
    ORDER BY IPS.ID_PDS
            ,IPS.NR_ITEM;
 --
 -- Cursor com os dados dos POE gerados de retirada de mercadoria para a geração da NFE
 CURSOR C_POE_RET
 (
   PC5_CD_FIL   GC.PED_OUTRA_ENTRADA.CD_FIL%TYPE
  ,PC5_ID_PDS   GC.PDS.ID_PDS%TYPE
 ) IS
   SELECT DISTINCT
          POE.CD_FIL
         ,POE.NR_PED
     FROM GC.PED_OUTRA_ENTRADA     POE
         ,GC.ITEM_PED_OUT_ENTR_PRD IPE
         ,GC.ITEM_PDS              IPS
    WHERE POE.CD_FIL                                 = PC5_CD_FIL
      AND IPE.CD_FIL                                 = POE.CD_FIL
      AND IPE.NR_PED                                 = POE.NR_PED
      AND (IPE.QT_ITEM - IPE.QT_CANC - IPE.QT_ATEND) > 0
      AND IPE.NR_ACAO_AIS                            = IPS.NR_ACAO_AIS
      AND IPS.ID_PDS                                 = PC5_ID_PDS
    UNION
   SELECT DISTINCT
          POE.CD_FIL
         ,POE.NR_PED
     FROM GC.PED_OUTRA_ENTRADA     POE
         ,GC.ITEM_PED_OUT_ENTR_PRD IPE
         ,GC.ITEM_PDS              IPS
    WHERE POE.CD_FIL                                <> PC5_CD_FIL
      AND GC.FIL_AB_QUALIF (POE.CD_FIL) IN ('DP', 'DS')
      AND IPE.CD_FIL                                 = POE.CD_FIL
      AND IPE.NR_PED                                 = POE.NR_PED
      AND (IPE.QT_ITEM - IPE.QT_CANC - IPE.QT_ATEND) > 0
      AND IPE.NR_ACAO_AIS                            = IPS.NR_ACAO_AIS
      AND IPS.ID_PDS                                 = PC5_ID_PDS
      AND NOT EXISTS (SELECT 1
                        FROM ROM_SEP_GRUPO_PDS RSGP
                            ,ROM_SEP_GRUPO_PDS RSGP2
                            ,GRUPO_PDS_ROM_SEPARACAO GPRS
                       WHERE RSGP.ID_PDS = IPS.ID_PDS
                         AND RSGP.ID_SQ_USR = RSGP2.ID_SQ_USR
                         AND RSGP2.ID_GRUPO_PDS = GPRS.ID_GRUPO_PDS
                         AND GPRS.CD_FIL = POE.CD_FIL)
      ORDER BY 1,2;
 --
 R_POE_RET         C_POE_RET%ROWTYPE;
 --
 CURSOR C_RGVI
 (
   PC6_CD_FIL_RSD   GC.ROM_SEP_GERADO_GRUPO_VENDA.CD_FIL_RSD%TYPE
  ,PC6_ID_ROM_RSD   GC.ROM_SEP_GERADO_GRUPO_VENDA.ID_ROM_RSD%TYPE
 ) IS
    SELECT DISTINCT
           RGVI.DT_EMIS_IPV
          ,RGVI.CD_FIL_IPV
          ,RGVI.NR_PV_IPV
      FROM GC.ROM_SEP_GERADO_GRUPO_VENDA RSGG
          ,GC.ROM_SEP_GRUPO_VENDA        RSGV
          ,GC.ROM_SEP_GRUPO_VENDA_ITEM   RGVI
          ,GC.ITEM_PED_VENDA             IPV
          ,GC.CLIENTE_RESERVA_ESTOQUE    CLR
     WHERE RSGG.ID_ROM_RSD = PC6_ID_ROM_RSD
       AND RSGG.CD_FIL_RSD = PC6_CD_FIL_RSD
        --
       AND RSGV.ID_RSGV    = RSGG.ID_RSGV
        --
       AND RGVI.ID_RSGV    = RSGV.ID_RSGV
        --
       AND IPV.NR_ITEM     = RGVI.NR_ITEM_IPV
       AND IPV.DT_EMIS     = RGVI.DT_EMIS_IPV
       AND IPV.CD_FIL      = RGVI.CD_FIL_IPV
       AND IPV.NR_PV       = RGVI.NR_PV_IPV
       AND IPV.ID_PROD     = RGVI.ID_PROD_IPV
       AND IPV.QT_PROGR    > 0
        --
       AND CLR.CD_FIL_IPV  = IPV.CD_FIL
       AND CLR.NR_PV_IPV   = IPV.NR_PV
       AND CLR.DT_EMIS_IPV = IPV.DT_EMIS
       AND CLR.NR_ITEM_IPV = IPV.NR_ITEM
       AND CLR.ID_PROD     = IPV.ID_PROD
       AND CLR.CD_FIL_RESV = RSGG.CD_FIL_RSD
    ORDER BY RGVI.DT_EMIS_IPV
            ,RGVI.CD_FIL_IPV
            ,RGVI.NR_PV_IPV;
 --
 R_C_RGVI      C_RGVI%ROWTYPE;
 --
 CURSOR C_POE_RGVI
 (
   PC7_CD_FIL    GC.PED_OUTRA_ENTRADA.CD_FIL%TYPE
  ,PC7_ID_RSGV   GC.ROM_SEP_GRUPO_VENDA.ID_RSGV%TYPE
 ) IS
   SELECT DISTINCT
          POE.CD_FIL
         ,POE.NR_PED
     FROM GC.PED_OUTRA_ENTRADA     POE
         ,GC.ITEM_PED_OUT_ENTR_PRD IPE
         ,GC.ROM_SEP_GRUPO_VENDA_ITEM  RGVI
    WHERE POE.CD_FIL                                 = PC7_CD_FIL
      AND IPE.CD_FIL                                 = POE.CD_FIL
      AND IPE.NR_PED                                 = POE.NR_PED
      AND (IPE.QT_ITEM - IPE.QT_CANC - IPE.QT_ATEND) > 0
      AND IPE.NR_ACAO_AIS                            = RGVI.NR_ACAO_AIS
      AND RGVI.ID_RSGV                               = PC7_ID_RSGV
   UNION
   SELECT DISTINCT
          POE.CD_FIL
         ,POE.NR_PED
     FROM GC.PED_OUTRA_ENTRADA     POE
         ,GC.ITEM_PED_OUT_ENTR_PRD IPE
         ,GC.ROM_SEP_GRUPO_VENDA_ITEM  RGVI
    WHERE POE.CD_FIL                                 <> PC7_CD_FIL
      AND GC.FIL_AB_QUALIF (POE.CD_FIL) IN ('DP', 'DS')
      AND IPE.CD_FIL                                 = POE.CD_FIL
      AND IPE.NR_PED                                 = POE.NR_PED
      AND (IPE.QT_ITEM - IPE.QT_CANC - IPE.QT_ATEND) > 0
      AND IPE.NR_ACAO_AIS                            = RGVI.NR_ACAO_AIS
      AND RGVI.ID_RSGV                               = PC7_ID_RSGV
      AND NOT EXISTS (SELECT 1
                        FROM ROM_SEP_GERADO_GRUPO_VENDA RSGG
                       WHERE RSGG.ID_RSGV    = RGVI.ID_RSGV
                         AND RSGG.CD_FIL_RSD = POE.CD_FIL);
 --
 R_POE_RGVI         C_POE_RGVI%ROWTYPE;
 --
 -->>Pedido de venda da guia de embacotamento do site
 --
 CURSOR C_GES
 (
   PC8_ID_GES                GC.GUIA_EMPACOTAMENTO_SITE.ID_GES%TYPE
 ) IS
  SELECT GES.DT_EMIS_PVD
        ,GES.CD_FIL_PVD
        ,GES.NR_PV_PVD
    FROM GC.GUIA_EMPACOTAMENTO_SITE GES
   WHERE GES.ID_GES = PC8_ID_GES;
 --
 R_C_GES                     C_GES%ROWTYPE;
 --
 -- HD 19618: VARIAVEL PARA CONTROLAR A EXISTENCIA DE ITENS NO AGRUPAMENTO DE VENDAS
 --
 D_EXISTE_ITEM               VARCHAR2(01);
 D_EXISTE_ITEM_SPV           VARCHAR2(01);
 --
BEGIN
--
-- ARQUIVO...: EMISSAO_NF_ENTRADA_SAIDA (antigo GP325.sql)
-- OBJETIVO..: APOS A GERACAO DAS NOTAS, ATUALIZA A COLUNA
--             IN_LANCTO_CCC (INDICADOR DE LANCAMENTO NO CCC) COM 'S',
--             PARA TODAS AS NOTAS GERADAS POR ESTA SOLICITACAO
--             E IN_LANCTO_CCF PARA NFS;
--             O GATILHO GTNFE1 IRA FAZER O LANCAMENTO NO CONTAS CORRENTES
--             DE CLIENTE QUANDO INFORMADA A DT_REC;
--
-- AUTOR/DATA: EROCHA+ACARLOS 29/04/96
-- ALTERACOES: ANOTE AQUI O MOTIVO DAS ALTERACOES
-- ERM.29/09/97 - PASSAR COMO PARAMETRO CHAVE ESTRANGEIRA DO EMBARQUE
--                PARA OS OBJETOS QUE GERAM NF SAIDA. ASSIM EM TODAS
--                AS NF SAIDA PODEREMOS CONHECER EM QUAL VEICULO E
--                PARA QUAL ROMANEIO FORAM EMITIDAS.
-- BIRA/TALENT, 12/12/2000 - CHAMADA PROCEDURE DE EMISSAO NFS CUPOM FISCAL
-- MARCO, 27/04/2001 - INCLUSÃO DO CONCEITO AGRUPAMENTO DE PDS PARA UNICO ROMANEIO.
-- Carlos, 19/10/2001 - Foi retirado o comando de confirmação automática da NFE para as filiais.
--                      A confirmação da NFE será feita pelo usuário, com base na avaliação
--                      de qualidade dos produtos integrantes da mesma.
--
-- AMELLO,17/07/2003 - NA CHAMADA DO PROCEDIMENTO GERAR_NFS_PEDIDO_VENDA FOI COLOCADO O PARAMETRO
--                     DE ENTRADA 'P_SNS.IN_RET_ENTRG', ANTES ESTAVA FIXO 'R'
--
-- AMELLO,11/09/2006 - APD 1437_2, CARIMBAR DATA DE SAIDA NA NOTA FISCAL DE SAIDA
--
-- AUTOR/DATA: SSANTOS, 05/07/2007
-- ALTERACOES: Inclusão da rotina de geração de notas ficais de entrada e a rotina de geração de
--             AQP's de POE's referentes à SPV's. APD-1563
--
-- AUTOR/DATA: SSILVA, 29/07/2021
-- ALTERACOES: Inclusão do primeiro select no CURSOR C_RSGP, para atender entrega própria da filial 40
--             já existia na versão 79 de 2015 da rotina, foi retirada e agora volta a existir. LOG-848.
 --
 --Funcao retorna <S> quando RSD tem requerente unico, do contrario suspende a execucao
 --
 IF   P_SNS.CD_FIL_RSD_EBQ IS NOT NULL
  AND P_SNS.ID_ROM_EBQ     IS NOT NULL
  THEN
  IF NVL(GC.RSD_TEM_REQUER_UNICO( P_SNS.CD_FIL_RSD_EBQ
                                 ,P_SNS.ID_ROM_EBQ),'N') = 'S'
   THEN
   NULL;
  END IF;
 END IF;
 --
 -->>>TRATAMENTO DE AGRUPAMENTO DE PDS em RSGP
 --
 IF   P_SNS.CD_FIL_RSD_EBQ IS NOT NULL
  AND P_SNS.ID_ROM_EBQ     IS NOT NULL
  THEN
  IF NVL(GC.RET_RSD_GRUPO_PDS( P_SNS.CD_FIL_RSD_EBQ
                              ,P_SNS.ID_ROM_EBQ),'N') = 'S'
   THEN
   --
   IF C_RSGP%ISOPEN
    THEN
    CLOSE C_RSGP;
   END IF;
   --
   OPEN C_RSGP( P_SNS.CD_FIL_RSD_EBQ
               ,P_SNS.ID_ROM_EBQ
               ,P_SNS.DS_PLACA_EBQ );
   LOOP
     FETCH C_RSGP
      INTO R_C_RSGP;
     ---
     EXIT WHEN C_RSGP%NOTFOUND;
     ---
     --- REFAZ LINHAS DA IPFR PARA EVITAR A SAÍDA DE MERCADORIAS EM NOTA FISCAL
     --- LSANTOS EM 21/10/2008
     ---
     FOR R_IPS IN C_IPS(R_C_RSGP.ID_PDS)
     LOOP
      --
      GC.IPFR_VINCULA_IPS_CLR_PARA_RSD(P_IPS    => R_IPS
                                      ,P_CD_FIL => P_SNS.CD_FIL);
      --
     END LOOP;
     ---
     P_SNS.ID_PDS               :=  R_C_RSGP.ID_PDS;
     --
     GC.PCK_TM_LOG.G_NM_FUNCAO  :=  GC.PCK_TM_1.G_OPERACAO_CORRENTE;   ---ERM.28/02/2000
     GC.PCK_TM_LOG.G_DT_INIC    :=  SYSDATE;                        ---ERM.28/02/2000
     GC.PCK_TM_LOG.G_ID_TRANS   :=  NULL;                           ---ERM.28/02/2000
     GC.PCK_TM_LOG.G_ID_ETAPA   :=  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')||'01-GP69,';
     --
     GC.SOLICITAR_NFS_ITEM_PDS ( P_SNS.CD_FIL
                                ,P_SNS.ID_PDS
                                ,'E'  -----P_SNS.IN_RET_ENTRG   ---ERM.02/04/97
                                ,P_SNS.IN_TRANSP
                                ,P_SNS.ID_PESSOA_TRANSP
                                ,P_SNS.CD_FIL_RSD_EBQ
                                ,P_SNS.ID_ROM_EBQ
                                ,P_SNS.DS_PLACA_EBQ
                                ,P_SNS.DS_PLACA_PLV
                                ,P_SNS.SG_UF_PLACA
                                ,P_ID_AGRUPADOR_PDS );
     --
     PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                                 TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '75-GP69,';
     --
     P_SNS.ID_PDS := NULL;
     --
   END LOOP;
   --
   D_NF_RET := NULL;
   --
   FOR D_RET IN ( SELECT DISTINCT RSGP2.ID_PDS
                    FROM GC.ROM_SEP_GRUPO_PDS RSGP
                        ,GC.ROM_SEP_GRUPO_PDS RSGP2
                        ,GC.GRUPO_PDS_ROM_SEPARACAO GPRS
                   WHERE GPRS.CD_FIL       = P_SNS.CD_FIL_RSD_EBQ
                     AND GPRS.ID_ROM       = P_SNS.ID_ROM_EBQ
                     AND GPRS.ID_GRUPO_PDS = RSGP.ID_GRUPO_PDS
                     AND RSGP.ID_SQ_USR    = RSGP2.ID_SQ_USR
                   ORDER BY 1)
   LOOP
    --
    IF C_POE_RET%ISOPEN
     THEN
     CLOSE C_POE_RET;
    END IF;
    --
    OPEN C_POE_RET (P_SNS.CD_FIL_RSD_EBQ
                   ,D_RET.ID_PDS);
    LOOP
     --
     FETCH C_POE_RET INTO R_POE_RET;
     EXIT WHEN C_POE_RET%NOTFOUND;
     --
     GC.GERAR_NFE_PED_OUTRA_ENTRADA( R_POE_RET.CD_FIL
                                    ,R_POE_RET.CD_FIL
                                    ,R_POE_RET.NR_PED );
     --
     IF  R_POE_RET.CD_FIL <>  P_SNS.CD_FIL_RSD_EBQ
      THEN
        FOR C IN (SELECT DISTINCT INP.CD_FIL
                        ,INP.NR_NF
                    FROM GC.ITEM_NF_ENTR_PRODUTO INP
                   WHERE INP.CD_FIL_IPE = R_POE_RET.CD_FIL
                     AND INP.NR_PED_IPE = R_POE_RET.NR_PED
                     AND INP.NFE_DT_CANC IS NULL)
           LOOP
             D_NF_RET :=  D_NF_RET || C.CD_FIL||'-'|| C.NR_NF||', ';
           END LOOP;
     END IF;
     --
    END LOOP;
    --
   END LOOP;
   --
   -- ENVIA E-MAIL QUANDO POE DE OUTRA FILIAL É FATURADO POR NÃO HAVER RSD
   --
   IF D_NF_RET IS NOT NULL
     THEN
       D_TEXTO_EMAIL_POE := 'NFEs FATURADAS < ' || D_NF_RET             || '> ' ||
                            'PELA FILIAL <'     || P_SNS.CD_FIL_RSD_EBQ || '> ' ||
                            'RSD <'             || P_SNS.ID_ROM_EBQ     || '> ' ||
                            'NÃO HAVIA RSD PARA A FILIAL DE ORIGEM DO POE!';
       --
       D_EMAIL       := GC.FNC_LE_GC_PARAMETRO(NULL, 'EMAIL_FATURAMENTO_POE_RETIRA');
       --
       IF GC.FNC_LE_GC_PARAMETRO(NULL, 'EMAIL_FATURAMENTO_POE_RETIRA_CC') <> 'N'
         THEN
          D_EMAIL_CC := GC.FNC_LE_GC_PARAMETRO(NULL, 'EMAIL_FATURAMENTO_POE_RETIRA_CC');
         ELSE
          D_EMAIL_CC := NULL;
       END IF;
       --
       IF NVL(D_EMAIL, 'N') <> 'N'
        THEN
        --
        GC.PCK_WEB_GLOBAL.ENVIAEMAILJAVA( P_FROM       => 'operacao@tokstok.com.br'
                                         ,P_REPLY      => NULL
                                         ,P_TO         => D_EMAIL
                                         ,P_CC         => D_EMAIL_CC
                                         ,P_BCC        => NULL
                                         ,P_SUBJECT    => 'POE DE RETIRA - FATURAMENTO POR OUTRA FILIAL'
                                         ,P_MESSAGE    => D_TEXTO_EMAIL_POE
                                         ,P_TYPE       => 'text/plain'
                                         ,P_SMTPSERVER => GC.FNC_LE_GC_PARAMETRO(P_DS_PAR => 'IP_SERVIDOR_EMAIL')
                                         ,P_ATTACH     => NULL);
       END IF;
   --
   END IF;
   --
  END IF;
  --
 END IF;
 --
 -->>>TRATAMENTO DE AGRUPAMENTO DE REQUISICAO EM RSGR
 --
 IF   P_SNS.CD_FIL_RSD_EBQ IS NOT NULL
  AND P_SNS.ID_ROM_EBQ     IS NOT NULL
  THEN
  IF NVL(GC.RET_RSD_GRUPO_REQUISICAO( P_SNS.CD_FIL_RSD_EBQ
                                     ,P_SNS.ID_ROM_EBQ),'N') = 'S'
   THEN
   PCK_IL.G_IN_NF_TRANSF_EBQ  :=  'NOVO';
   GC.GERAR_NFS_TRANSF_NOVO( P_SNS.CD_FIL_RSD_EBQ
                            ,P_SNS.ID_ROM_EBQ
                            ,P_SNS.DS_PLACA_EBQ
                            ,P_SNS.IN_TRANSP
                            ,P_SNS.ID_PESSOA_TRANSP
                            ,P_SNS.DS_PLACA_PLV
                            ,P_SNS.SG_UF_PLACA );
   PCK_IL.G_IN_NF_TRANSF_EBQ  :=  NULL;
   P_SNS.CD_FIL_RUC           :=  NULL;
   P_SNS.CD_CCO_RUC           :=  NULL;
   P_SNS.NR_REQ_RUC           :=  NULL;
   P_SNS.CD_FIL_REQ           :=  NULL;
   P_SNS.NR_REQ_REQ           :=  NULL;
  END IF;
 END IF;
 --
 -- TRATAMENTO DE AGRUPAMENTO DE VENDAS EM RSGV
 --
 IF   P_SNS.CD_FIL_RSD_EBQ IS NOT NULL
  AND P_SNS.ID_ROM_EBQ     IS NOT NULL
  AND P_SNS.ID_GES         IS     NULL   -->>não é um faturamento de guia de embacotamento do SITE
  THEN
  --
  IF GC.RET_SE_RSD_DE_GRUPO_VENDA (P_SNS.CD_FIL_RSD_EBQ
                                  ,P_SNS.ID_ROM_EBQ
                                  ,D_ID_RSGV) = 'S'
   THEN
   --
   GC.PCK_TM_LOG.G_NM_FUNCAO  :=  GC.PCK_TM_1.G_OPERACAO_CORRENTE; ---ERM.28/02/2000
   GC.PCK_TM_LOG.G_DT_INIC    :=  SYSDATE;                         ---ERM.28/02/2000
   GC.PCK_TM_LOG.G_ID_TRANS   :=  NULL;                            ---ERM.28/02/2000
   GC.PCK_TM_LOG.G_ID_ETAPA   :=  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '01-GP64,';
   --
   D_EXISTE_ITEM := 'N';
   --
   OPEN C_RGVI( P_SNS.CD_FIL_RSD_EBQ
               ,P_SNS.ID_ROM_EBQ );
   LOOP
    --
    FETCH C_RGVI INTO R_C_RGVI;
    --
    EXIT WHEN C_RGVI%NOTFOUND;
    --
    D_REQUERENTE := 'PVD: CD_FIL<' || R_C_RGVI.CD_FIL_IPV  || '> ' ||
                    'NR_PV<'       || R_C_RGVI.NR_PV_IPV   || '> ' ||
                    'DT_EMIS<'     || R_C_RGVI.DT_EMIS_IPV || '> ';
    --
    -- VERIFICA SE O PV DEVE SER FATURADO PARA TRANSFERENCIA EM FUNCAO DA UF DE DESTINO
    --
    SELECT RSGV.ID_QRSG
      INTO D_ID_QRSG
      FROM GC.ROM_SEP_GRUPO_VENDA RSGV
     WHERE RSGV.ID_RSGV = D_ID_RSGV;
    --
    --
    D_EXISTE_ITEM := 'S';
    --
    -- A CADA PEDIDO FATURADO, GRAVA OS DADOS PARA LIBERAR E EVITAR LOCKS
    --
    COMMIT;
    --
   END LOOP;
   --
   CLOSE C_RGVI;
   --
   GC.PCK_TM_LOG.G_ID_ETAPA   :=  GC.PCK_TM_LOG.G_ID_ETAPA            ||
                                  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS') || '75-GP64,';
   --
   -- GERA NFE E AQP PARA SPV EM AGRUPAMENTO
   --
   D_NF_RET          := NULL;
   D_EXISTE_ITEM_SPV := 'N';
   --
   OPEN C_POE_RGVI(P_SNS.CD_FIL_RSD_EBQ
                  ,D_ID_RSGV);
   --
   LOOP
    FETCH C_POE_RGVI INTO R_POE_RGVI;
    EXIT WHEN C_POE_RGVI%NOTFOUND;
     --
     D_RETORNO         := GC.PKG_SERVICO_POS_VENDA.FNC_GERAR_NFE_POE_SPV (P_NR_PED => R_POE_RGVI.NR_PED
                                                                         ,P_CD_FIL => R_POE_RGVI.CD_FIL);
     D_EXISTE_ITEM_SPV := 'S';
     --
     -- executa ação de faturamento
     --
     OPEN C_NFE (R_POE_RGVI.NR_PED
                ,R_POE_RGVI.CD_FIL);
     FETCH C_NFE INTO R_NFE;
     CLOSE C_NFE;
     --
     IF  R_POE_RGVI.CD_FIL <> P_SNS.CD_FIL_RSD_EBQ
      THEN
        --
        D_NF_RET :=  D_NF_RET || R_NFE.CD_FIL||'-'|| R_NFE.NR_NF||', ';
        --
     END IF;
     --
     P_AIS         := NULL;
     P_AIS.NR_ACAO := R_NFE.NR_ACAO_AIS;
     --
     GC.PKG_SERVICO_POS_VENDA.PRC_LE_AIS_1(P_AIS);
     --
    SELECT NR_ACAO
      INTO D_NR_PROX
      FROM GC.ACAO_ITEM_SERVICO_POS_VENDA
     WHERE NR_SOLIC_ISV     =  P_AIS.NR_SOLIC_ISV
       AND NR_SEQ_ITEM_ISV  =  P_AIS.NR_SEQ_ITEM_ISV
       AND NR_SEQ_EXEC      >  P_AIS.NR_SEQ_EXEC
       AND DT_EXEC         IS  NULL
       AND DT_CANC         IS  NULL
       AND ROWNUM = 1
     ORDER BY NR_SEQ_EXEC;
     --
     IF GC.PKG_SERVICO_POS_VENDA.FNC_ENCERRA_SERVICO_POS_VENDA(P_AIS.NR_SOLIC_ISV) THEN
        --
        UPDATE GC.SERVICO_POS_VENDA
           SET DT_ENCERRA = SYSDATE
         WHERE NR_SOLIC = P_AIS.NR_SOLIC_ISV;
           --
     END IF;
     --
   END LOOP;
   --
   IF   NVL(D_EXISTE_ITEM    , 'N') = 'N'
    AND NVL(D_EXISTE_ITEM_SPV, 'N') = 'N'
    THEN
    --
    RAISE_APPLICATION_ERROR (-20001
                            ,'ID_RSGV<'        || D_ID_RSGV            || '> ' ||
                             'CD_FIL_RSD_EBQ<' || P_SNS.CD_FIL_RSD_EBQ || '> ' ||
                             'ID_ROM_EBQ<'     || P_SNS.ID_ROM_EBQ     || '> ' ||
                             'DS_PLACA_EBQ<'   || P_SNS.DS_PLACA_EBQ   || '> ' ||
                             'AGRUPAMENTO DE VENDAS SEM ITENS (PVD/SPV) PARA FATURAR !');
    --
   END IF;
   --
   -- ENVIA E-MAIL QUANDO POE DE OUTRA FILIAL É FATURADO POR NÃO HAVER RSD
   --
   IF D_NF_RET IS NOT NULL
    THEN
    D_TEXTO_EMAIL_POE := 'NFEs FATURADAS < ' || D_NF_RET             || '> ' ||
                         'PELA FILIAL <'     || P_SNS.CD_FIL_RSD_EBQ || '> ' ||
                         'RSD <'             || P_SNS.ID_ROM_EBQ     || '> ' ||
                         'NÃO HAVIA RSD PARA A FILIAL DE ORIGEM DO POE!';
    --
    D_EMAIL       := GC.FNC_LE_GC_PARAMETRO(NULL, 'EMAIL_FATURAMENTO_POE_RETIRA');
    --
    IF GC.FNC_LE_GC_PARAMETRO(NULL, 'EMAIL_FATURAMENTO_POE_RETIRA_CC') <> 'N'
     THEN
     D_EMAIL_CC := GC.FNC_LE_GC_PARAMETRO(NULL, 'EMAIL_FATURAMENTO_POE_RETIRA_CC');
    ELSE
     D_EMAIL_CC := NULL;
    END IF;
    --
    IF NVL(D_EMAIL, 'N') <> 'N'
     THEN
     --
     GC.PCK_WEB_GLOBAL.ENVIAEMAILJAVA( P_FROM       => 'operacao@tokstok.com.br'
                                      ,P_REPLY      => NULL
                                      ,P_TO         => D_EMAIL
                                      ,P_CC         => D_EMAIL_CC
                                      ,P_BCC        => NULL
                                      ,P_SUBJECT    => 'POE DE RETIRA POR PARCEIRO LOGISTICO - FATURAMENTO POR OUTRA FILIAL'
                                      ,P_MESSAGE    => D_TEXTO_EMAIL_POE
                                      ,P_TYPE       => 'text/plain'
                                      ,P_SMTPSERVER => GC.FNC_LE_GC_PARAMETRO(P_DS_PAR => 'IP_SERVIDOR_EMAIL')
                                      ,P_ATTACH     => NULL);
    END IF;
   --
   END IF;
   --
   -- SPVS PJ
   --
   FOR C IN (SELECT AIS.NR_SOLIC_ISV
                   ,AIS.NR_SEQ_ITEM_ISV
                   ,AIS.NR_SEQ_EXEC
               FROM GC.ROM_SEP_GRUPO_VENDA_ITEM RGVI
                   ,GC.ACAO_ITEM_SERVICO_POS_VENDA AIS
                   ,GC.SERVICO_POS_VENDA SPV
              WHERE RGVI.ID_RSGV = D_ID_RSGV
                AND RGVI.NR_ACAO_AIS = AIS.NR_ACAO
                AND AIS.NR_SOLIC_ISV = SPV.NR_SOLIC
                AND (INSTR(GC.FNC_LE_GC_PARAMETRO(NULL,'SPVS_RETIRA_PARCEIRO_PJ'), SPV.ID_SERVICO )) > 0)
   LOOP
    --
    D_NR_PROX := NULL;
    --
    SELECT NR_ACAO
      INTO D_NR_PROX
      FROM GC.ACAO_ITEM_SERVICO_POS_VENDA
     WHERE NR_SOLIC_ISV     =  C.NR_SOLIC_ISV
       AND NR_SEQ_ITEM_ISV  =  C.NR_SEQ_ITEM_ISV
       AND NR_SEQ_EXEC      >  C.NR_SEQ_EXEC
       AND DT_EXEC         IS  NULL
       AND DT_CANC         IS  NULL
       AND ROWNUM = 1
     ORDER BY NR_SEQ_EXEC;
    --
    IF GC.PKG_SERVICO_POS_VENDA.FNC_ENCERRA_SERVICO_POS_VENDA(C.NR_SOLIC_ISV)
     THEN
     --
     UPDATE GC.SERVICO_POS_VENDA
        SET DT_ENCERRA = SYSDATE
      WHERE NR_SOLIC = C.NR_SOLIC_ISV;
     --
    END IF;
    --
   END LOOP;
   --
  END IF;
  --
 END IF;
 --
 -- TRATAMENTO DE FATURAMENTO DE VENDA POR GUIA DE EMBACOTAMENTO DO SITE
 --
 IF   P_SNS.CD_FIL_RSD_EBQ IS NOT NULL
  AND P_SNS.ID_ROM_EBQ     IS NOT NULL
  AND P_SNS.ID_GES         IS NOT NULL
  THEN
  --
  GC.PCK_TM_LOG.G_NM_FUNCAO  :=  GC.PCK_TM_1.G_OPERACAO_CORRENTE;
  GC.PCK_TM_LOG.G_DT_INIC    :=  SYSDATE;
  GC.PCK_TM_LOG.G_ID_TRANS   :=  NULL;
  GC.PCK_TM_LOG.G_ID_ETAPA   :=  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '01-FATURA GES,';
  --
  D_EXISTE_ITEM := 'N';
  --
  OPEN C_GES ( P_SNS.ID_GES );
  LOOP
   --
   FETCH C_GES INTO R_C_GES;
   --
   EXIT WHEN C_GES%NOTFOUND;
   --
   D_REQUERENTE := 'PVD: CD_FIL<' || R_C_GES.CD_FIL_PVD  || '> ' ||
                   'NR_PV<'       || R_C_GES.NR_PV_PVD   || '> ' ||
                   'DT_EMIS<'     || R_C_GES.DT_EMIS_PVD || '> ';
   --
   GC.GERAR_NFS_PEDIDO_VENDA( P_CD_FIL_ESTQ        =>  P_SNS.CD_FIL  ---ERM.30/09/98
                             ,P_CD_FIL             =>  R_C_GES.CD_FIL_PVD
                             ,P_DT_EMIS            =>  R_C_GES.DT_EMIS_PVD
                             ,P_NR_PV              =>  R_C_GES.NR_PV_PVD
                             ,P_ID_PDS             =>  P_SNS.ID_PDS
                             ,P_IN_RET_ENTRG       =>  P_SNS.IN_RET_ENTRG   ---ERM.02/04/97 -- AMELLO,17/07/2003
                             ,P_IN_TRANSP          =>  P_SNS.IN_TRANSP
                             ,P_ID_PESSOA_TRANSP   =>  P_SNS.ID_PESSOA_TRANSP
                             ,P_CD_FIL_RSD         =>  P_SNS.CD_FIL_RSD_EBQ
                             ,P_ID_ROM_RSD         =>  P_SNS.ID_ROM_EBQ
                             ,P_DS_PLACA           =>  P_SNS.DS_PLACA_EBQ
                             ,P_DS_PLACA_PLV       =>  P_SNS.DS_PLACA_PLV
                             ,P_SG_UF_PLACA        =>  P_SNS.SG_UF_PLACA
                             ,P_ID_GES             =>  P_SNS.ID_GES 
                             ,P_ID_AGRUPADOR_PDS   =>  P_ID_AGRUPADOR_PDS
                             ,P_ID_TGE             =>  P_SNS.ID_TGE);
                             
   --
   D_EXISTE_ITEM := 'S';
   --
   -- A CADA PEDIDO FATURADO, GRAVA OS DADOS PARA LIBERAR E EVITAR LOCKS
   --
   COMMIT;
   --
  END LOOP;
  --
  CLOSE C_GES;
  --
  GC.PCK_TM_LOG.G_ID_ETAPA   :=  GC.PCK_TM_LOG.G_ID_ETAPA            ||
                                 TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS') || '75-FATURA GES,';
  --
 END IF;
 --
 IF P_SNS.ID_PDS IS NOT NULL
  THEN
  --
  GC.PCK_TM_LOG.G_NM_FUNCAO  :=  GC.PCK_TM_1.G_OPERACAO_CORRENTE;   ---ERM.28/02/2000
  GC.PCK_TM_LOG.G_DT_INIC    :=  SYSDATE;                        ---ERM.28/02/2000
  GC.PCK_TM_LOG.G_ID_TRANS   :=  NULL;                           ---ERM.28/02/2000
  GC.PCK_TM_LOG.G_ID_ETAPA   :=  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '01-GP69,';
  ---
  --- REFAZ LINHAS DA IPFR PARA EVITAR A SAÍDA DE MERCADORIAS EM NOTA FISCAL
  --- LSANTOS EM 21/01/2009
  ---
  FOR R_IPS IN C_IPS(P_SNS.ID_PDS)
  LOOP
   --
   GC.IPFR_VINCULA_IPS_CLR_PARA_RSD(P_IPS    => R_IPS
                                   ,P_CD_FIL => P_SNS.CD_FIL);
   --
  END LOOP;
  ---
  GC.SOLICITAR_NFS_ITEM_PDS ( P_SNS.CD_FIL
                             ,P_SNS.ID_PDS
                             ,'E'  -----P_SNS.IN_RET_ENTRG   ---ERM.02/04/97
                             ,P_SNS.IN_TRANSP
                             ,P_SNS.ID_PESSOA_TRANSP
                             ,P_SNS.CD_FIL_RSD_EBQ
                             ,P_SNS.ID_ROM_EBQ
                             ,P_SNS.DS_PLACA_EBQ
                             ,P_SNS.DS_PLACA_PLV
                             ,P_SNS.SG_UF_PLACA
                             ,P_ID_AGRUPADOR_PDS );
  --
  GC.PCK_TM_LOG.G_ID_ETAPA   :=  GC.PCK_TM_LOG.G_ID_ETAPA           ||
                                 TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '75-GP69,';
  --
  IF C_POE_RET%ISOPEN
   THEN
   CLOSE C_POE_RET;
  END IF;
  --
  OPEN C_POE_RET (P_SNS.CD_FIL
                 ,P_SNS.ID_PDS);
  LOOP
   --
   FETCH C_POE_RET INTO R_POE_RET;
   EXIT WHEN C_POE_RET%NOTFOUND;
   --
   GC.GERAR_NFE_PED_OUTRA_ENTRADA( R_POE_RET.CD_FIL
                                  ,R_POE_RET.CD_FIL
                                  ,R_POE_RET.NR_PED );
   --
   -- A CADA PEDIDO FATURADO, GRAVA OS DADOS PARA LIBERAR E EVITAR LOCKS
   --
   COMMIT;
   --
  END LOOP;
  --
 END IF;
--
 IF  P_SNS.NR_REQ_REQ IS NOT NULL
  OR P_SNS.NR_REQ_RUC IS NOT NULL
  THEN
  PCK_TM_LOG.G_NM_FUNCAO  :=  PCK_TM_1.G_OPERACAO_CORRENTE;   ---ERM.28/02/2000
  PCK_TM_LOG.G_DT_INIC    :=  SYSDATE;                        ---ERM.28/02/2000
  PCK_TM_LOG.G_ID_TRANS   :=  NULL;                           ---ERM.28/02/2000
  PCK_TM_LOG.G_ID_ETAPA   :=  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS') ||
                               '01-GP721<' || P_SNS.ID_ROM_EBQ    ||'> <' ||
                                              P_SNS.DS_PLACA_EBQ  ||'>,';
  -- Verifica faturamento (Transferência ou Franquia)
  IF GC.PES_FRANQUIA(GC.RET_ID_PESSOA_TOK(NVL( P_SNS.CD_FIL_REQ,P_SNS.CD_FIL_RUC))) = 'S'
   THEN
   GC.PRC_GERAR_NFS_FRANQUIA( P_SNS.CD_FIL_RSD_EBQ
                             ,P_SNS.ID_ROM_EBQ
                             ,P_SNS.DS_PLACA_EBQ
                             ,P_SNS.IN_TRANSP
                             ,P_SNS.ID_PESSOA_TRANSP
                             ,P_SNS.DS_PLACA_PLV
                             ,P_SNS.SG_UF_PLACA);
  ELSE
   PCK_IL.G_IN_NF_TRANSF_EBQ  :=  'NOVO';
   GC.GERAR_NFS_TRANSF_NOVO( P_SNS.CD_FIL_RSD_EBQ
                            ,P_SNS.ID_ROM_EBQ
                            ,P_SNS.DS_PLACA_EBQ
                            ,P_SNS.IN_TRANSP
                            ,P_SNS.ID_PESSOA_TRANSP
                            ,P_SNS.DS_PLACA_PLV
                            ,P_SNS.SG_UF_PLACA );
   PCK_IL.G_IN_NF_TRANSF_EBQ  :=  NULL;
  END IF;
  ---
  PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                              TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '75-GP721,';
 END IF;
 --
 IF P_SNS.NR_PV_PVD IS NOT NULL
  THEN
  P_PVD.CD_FIL   :=  P_SNS.CD_FIL_PVD;         ---ERM.06/10/97
  P_PVD.DT_EMIS  :=  P_SNS.DT_EMIS_PVD;
  P_PVD.NR_PV    :=  P_SNS.NR_PV_PVD;
  GC.LE_PVD_1 ( P_PVD );
  --
  D_REQUERENTE := 'PVD: CD_FIL<' || P_SNS.CD_FIL_PVD  || '> ' ||
                  'NR_PV<'       || P_SNS.NR_PV_PVD   || '> ' ||
                  'DT_EMIS<'     || P_SNS.DT_EMIS_PVD || '> ';
  --
  IF   GC.PES_FRANQUIA ( P_PVD.ID_PESSOA_CLI )  = 'S'       ---ERM.06/10/97
   AND P_PVD.IN_DIVERGE                     IS NULL      ---ERM.06/10/97
   THEN
   PCK_TM_LOG.G_NM_FUNCAO  :=  PCK_TM_1.G_OPERACAO_CORRENTE;   ---ERM.28/02/2000
   PCK_TM_LOG.G_DT_INIC    :=  SYSDATE;                        ---ERM.28/02/2000
   PCK_TM_LOG.G_ID_TRANS   :=  NULL;                           ---ERM.28/02/2000
   PCK_TM_LOG.G_ID_ETAPA   :=  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '01-GP426,';
   GC.GERAR_NFS_EBQ_FRANQUIA( P_SNS.CD_FIL_PVD
                             ,P_SNS.DT_EMIS_PVD
                             ,P_SNS.NR_PV_PVD
                             ,P_SNS.ID_PDS
                             ,'R'  -----P_SNS.IN_RET_ENTRG   ---ERM.02/04/97
                             ,P_SNS.IN_TRANSP
                             ,P_SNS.ID_PESSOA_TRANSP
                             ,P_SNS.CD_FIL_RSD_EBQ
                             ,P_SNS.ID_ROM_EBQ
                             ,P_SNS.DS_PLACA_EBQ
                             ,P_SNS.DS_PLACA_PLV
                             ,P_SNS.SG_UF_PLACA );  ---ERM.29/09/97
   PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                               TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '75-GP426,';
  ELSE
   PCK_TM_LOG.G_NM_FUNCAO  :=  PCK_TM_1.G_OPERACAO_CORRENTE;   ---ERM.28/02/2000
   PCK_TM_LOG.G_DT_INIC    :=  SYSDATE;                        ---ERM.28/02/2000
   PCK_TM_LOG.G_ID_TRANS   :=  NULL;                           ---ERM.28/02/2000
   PCK_TM_LOG.G_ID_ETAPA   :=  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '01-GP64,';
   --
   -- VERIFICA SE O PV DEVE SER FATURADO PARA TRANSFERENCIA EM FUNCAO DA UF DE DESTINO
   --
   IF   GC.RET_SE_PVD_EMITE_NF_TRANSF (P_SNS.CD_FIL_PVD
                                      ,P_SNS.NR_PV_PVD
                                      ,P_SNS.DT_EMIS_PVD) = 'S'
    AND GC.FIL_AB_QUALIF(P_SNS.CD_FIL) IN ('DP', 'DS')
    THEN
    --
    GC.GERAR_NFS_TRANSF_PEDIDO_VENDA( P_SNS.CD_FIL  ---ERM.30/09/98
                                     ,P_SNS.CD_FIL_PVD
                                     ,P_SNS.DT_EMIS_PVD
                                     ,P_SNS.NR_PV_PVD
                                     ,P_SNS.ID_PDS
                                     ,P_SNS.IN_RET_ENTRG   ---ERM.02/04/97 -- AMELLO,17/07/2003
                                     ,P_SNS.IN_TRANSP
                                     ,P_SNS.ID_PESSOA_TRANSP
                                     ,P_SNS.CD_FIL_RSD_EBQ
                                     ,P_SNS.ID_ROM_EBQ
                                     ,P_SNS.DS_PLACA_EBQ
                                     ,P_SNS.DS_PLACA_PLV
                                     ,P_SNS.SG_UF_PLACA );  ---ERM.29/09/97
    --
   ELSE
    --
    GC.GERAR_NFS_PEDIDO_VENDA( P_CD_FIL_ESTQ        =>  P_SNS.CD_FIL  ---ERM.30/09/98
                              ,P_CD_FIL             =>  P_SNS.CD_FIL_PVD
                              ,P_DT_EMIS            =>  P_SNS.DT_EMIS_PVD
                              ,P_NR_PV              =>  P_SNS.NR_PV_PVD
                              ,P_ID_PDS             =>  P_SNS.ID_PDS
                              ,P_IN_RET_ENTRG       =>  P_SNS.IN_RET_ENTRG   ---ERM.02/04/97 -- AMELLO,17/07/2003
                              ,P_IN_TRANSP          =>  P_SNS.IN_TRANSP
                              ,P_ID_PESSOA_TRANSP   =>  P_SNS.ID_PESSOA_TRANSP
                              ,P_CD_FIL_RSD         =>  P_SNS.CD_FIL_RSD_EBQ
                              ,P_ID_ROM_RSD         =>  P_SNS.ID_ROM_EBQ
                              ,P_DS_PLACA           =>  P_SNS.DS_PLACA_EBQ
                              ,P_DS_PLACA_PLV       =>  P_SNS.DS_PLACA_PLV
                              ,P_SG_UF_PLACA        =>  P_SNS.SG_UF_PLACA
                              ,P_ID_GES             =>  P_SNS.ID_GES 
                              ,P_ID_AGRUPADOR_PDS   =>  P_ID_AGRUPADOR_PDS
                              ,P_ID_TGE             =>  P_SNS.ID_TGE);  ---ERM.29/09/97
    --
   END IF;
   --
   PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                               TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '75-GP64,';
  END IF;
 END IF;
 --
 IF P_SNS.NR_PAT IS NOT NULL
  THEN
  PCK_TM_LOG.G_NM_FUNCAO  :=  PCK_TM_1.G_OPERACAO_CORRENTE;   ---ERM.28/02/2000
  PCK_TM_LOG.G_DT_INIC    :=  SYSDATE;                        ---ERM.28/02/2000
  PCK_TM_LOG.G_ID_TRANS   :=  NULL;                           ---ERM.28/02/2000
  PCK_TM_LOG.G_ID_ETAPA   :=  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')||
                             '01-GP65,';
  GC.GERAR_NFS_PAT( P_SNS.CD_FIL  ---ERM.30/09/98
                   ,P_SNS.CD_FIL_PAT
                   ,P_SNS.NR_PAT
                   ,P_SNS.ID_PDS
                   ,P_SNS.IN_TRANSP
                   ,P_SNS.ID_PESSOA_TRANSP
                   ,P_SNS.CD_FIL_RSD_EBQ
                   ,P_SNS.ID_ROM_EBQ
                   ,P_SNS.DS_PLACA_EBQ
                   ,P_SNS.DS_PLACA_PLV
                   ,P_SNS.SG_UF_PLACA );  ---ERM.29/09/97
  PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                              TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '75-GP65,';
 END IF;
 --
 IF P_SNS.NR_PED_PSO IS NOT NULL
  THEN
  --
  D_REQUERENTE := 'POS: CD_FIL<' || P_SNS.CD_FIL_PSO || '> ' ||
                  'NR_PED<'      || P_SNS.NR_PED_PSO || '> ';
  --
  PCK_TM_LOG.G_NM_FUNCAO  :=  PCK_TM_1.G_OPERACAO_CORRENTE;   ---ERM.28/02/2000
  PCK_TM_LOG.G_DT_INIC    :=  SYSDATE;                        ---ERM.28/02/2000
  PCK_TM_LOG.G_ID_TRANS   :=  NULL;                           ---ERM.28/02/2000
  PCK_TM_LOG.G_ID_ETAPA   :=  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '01-GP71,';
  GC.GERAR_NFS_PED_OUTRA_SAIDA( P_SNS.CD_FIL  ---ERM.30/09/98
                               ,P_SNS.CD_FIL_PSO
                               ,P_SNS.NR_PED_PSO
                               ,P_SNS.ID_PDS
                               ,P_SNS.IN_TRANSP
                               ,P_SNS.ID_PESSOA_TRANSP
                               ,P_SNS.CD_FIL_RSD_EBQ
                               ,P_SNS.ID_ROM_EBQ
                               ,P_SNS.DS_PLACA_EBQ
                               ,P_SNS.DS_PLACA_PLV
                               ,P_SNS.SG_UF_PLACA );      --ERM.29/09/97
  PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                              TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '75-GP71,';
 END IF;
 --
 IF P_SNS.NR_PED_PSC IS NOT NULL
  THEN
  GC.GERAR_NFS_PED_OUT_SAIDA_COMPL(  P_SNS.CD_FIL  ---ERM.30/09/98
                                    ,P_SNS.CD_FIL_PSC
                                    ,P_SNS.NR_PED_PSC );   -- JS/CACA 04/03/98
 END IF;
 --
 IF P_SNS.NR_PED_POE IS NOT NULL
  THEN
  PCK_TM_LOG.G_NM_FUNCAO  :=  PCK_TM_1.G_OPERACAO_CORRENTE;   ---ERM.28/02/2000
  PCK_TM_LOG.G_DT_INIC    :=  SYSDATE;                        ---ERM.28/02/2000
  PCK_TM_LOG.G_ID_TRANS   :=  NULL;                           ---ERM.28/02/2000
  PCK_TM_LOG.G_ID_ETAPA   :=  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')||
                             '01-GP86,';
  GC.GERAR_NFE_PED_OUTRA_ENTRADA( P_SNS.CD_FIL  ---ERM.30/09/98
                                 ,P_SNS.CD_FIL_POE
                                 ,P_SNS.NR_PED_POE );
  PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                              TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '75-GP86,';
 END IF;
 ---cvpf 03/10/2001
 ---BIRA/TALENT, 12/12/2000 INICIO
 IF   P_SNS.CD_FIL_CFL    IS NOT NULL
  AND P_SNS.NR_CXA_CFL    IS NOT NULL
  AND P_SNS.NR_SEQ_TS_CFL IS NOT NULL
  THEN
  PCK_TM_LOG.G_NM_FUNCAO  :=  PCK_TM_1.G_OPERACAO_CORRENTE;
  PCK_TM_LOG.G_DT_INIC    :=  SYSDATE;
  PCK_TM_LOG.G_ID_TRANS   :=  NULL;
  PCK_TM_LOG.G_ID_ETAPA   :=  TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')||
                             '01-GERAR_NFS_CUPOM,';
  GC.GERAR_NFS_CUPOM_FISCAL   ( P_SNS.CD_FIL_CFL
                               ,P_SNS.NR_CXA_CFL
                               ,P_SNS.NR_SEQ_TS_CFL
                               ,P_SNS.IN_TRANSP
                               ,P_SNS.ID_PESSOA_TRANSP);
  PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                              TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '75-GERAR_NFS_CUPOM,';
 END IF;
 ---BIRA/TALENT, 12/12/2000 FIM
 ---cvpf 03/10/2001
 ---ATUALIZA O IN_LANCTO_CCC E IN_LANTO_CCF
 IF PCK_1.G_ID_SESSAO_GTSNS2 IS NOT NULL
  THEN
  IF   P_SNS.NR_PED_POE IS NOT NULL
   AND P_SNS.CD_FIL_POE IS NOT NULL
   THEN
   PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                               TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '80,';
   UPDATE NFE
      SET IN_RATEIO = 'S'
    WHERE NFE.ID_SESSAO = PCK_1.G_ID_SESSAO_GTSNS2;
   PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                               TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '85,';
   --
   IF   GC.FIL_AB_QUALIF(P_SNS.CD_FIL) = 'LJ'          ---ERM.13/10/98.12:00hs.
    AND P_SNS.CD_FIL <> 15                          ---KK 29/08/2000
    THEN
    PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                                TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '90,';
    --UPDATE NFE
    --   SET NFE.DT_REC = SYSDATE
    -- WHERE NFE.ID_SESSAO = PCK_1.G_ID_SESSAO_GTSNS2; --cvpf 19/10/2001

    PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                                TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '95,';
   END IF;
   ---
   ---O GATILHO GTNFE1 IRA FAZER O LANCAMENTO
   ---NO CONTA_CORRENTE_CLIENTE QUANDO INFORMADA A DT_REC;
   ---
  ELSE
   PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                               TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '80,';
   UPDATE GC.NF_SAIDA NFS
      SET IN_RATEIO = 'S'
    WHERE NFS.ID_SESSAO = PCK_1.G_ID_SESSAO_GTSNS2
      AND (   NFS.VM_FRETE       > 0
           OR NFS.VM_DESP_ACES   > 0
           OR NFS.VM_COMPL_PRECO > 0 );
   PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                               TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '85,';
--   UPDATE GC.NF_SAIDA NFS     -- AMELLO, 24/02/2006, APD 1437_1
--      SET IN_LANCTO_CCC = 'S'
--         ,IN_LANCTO_CCF = 'S'
--    WHERE NFS.ID_SESSAO = PCK_1.G_ID_SESSAO_GTSNS2;
   --
   -- CARIMBAR DATA DE FINALIZACAO E IMPRESSÃO DA NOTA FISCAL
   -- MRLIMA APD 1619
   --
   UPDATE GC.NF_SAIDA NFS
      SET DT_SAIDA = SYSDATE
    WHERE NFS.ID_SESSAO = GC.PCK_1.G_ID_SESSAO_GTSNS2
      AND NFS.DT_SAIDA IS NULL;
   --
   PCK_TM_LOG.G_ID_ETAPA   :=  PCK_TM_LOG.G_ID_ETAPA              ||
                               TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')|| '90,';
  END IF;
 END IF;
 --
 IF   P_SNS.DS_PLACA_EBQ          IS NOT NULL
  AND PCK_2.G_IN_ATLZ_EBQ_NFS_ETR IS NULL
  AND P_SNS.ID_GES                IS NULL -->>quando for faturamento de guia de empacotamento nao se deve encerrar o embarque
  THEN
  UPDATE GC.EMBARQUE EBQ
     SET EBQ.DT_FAT = P_SNS.DT_SOLIC
   WHERE EBQ.CD_FIL_RSD = P_SNS.CD_FIL_RSD_EBQ
     AND EBQ.ID_ROM_RSD = P_SNS.ID_ROM_EBQ
     AND EBQ.DS_PLACA   = P_SNS.DS_PLACA_EBQ;
     --AND EBQ.DT_FAT    IS NULL; --Visa manter o CE_NFS_EBQ.Ha uma chamada recursiva de SNS_FATURA.--ERM.09/03/2007
  IF SQL%ROWCOUNT = 1
   THEN
   NULL;
  ELSE
   RAISE_APPLICATION_ERROR(-20001,
    'ERRO AO ATUALIZAR NO EMBARQUE A DATA DO FATURAMENTO.'||
    'CD_FIL_RSD<' || P_SNS.CD_FIL_RSD_EBQ ||'> '||
    'ID_ROM_RSD<' || P_SNS.ID_ROM_EBQ     ||'> '||
    'DS_PLACA<'   || P_SNS.DS_PLACA_EBQ   ||'> '||
    'ROWCOUNT<'   || SQL%ROWCOUNT         ||'> '||
    'INCORRETO. ESPERADO ROWCOUNT = 1');
  END IF;
  --
  --ETR PROVISORIAS (DE PAPELAO, NUMERACAO DE ETR NAO REUTILIZAVEL), NUMERACAO SUPERIOR A 100.000
  --NAO SE FAZ REGISTRO DE RETORNO, PORTANTO, A DATA DE RETORNO SERA A DATA DO FATURAMENTO DO CARRO
  --ERM/AC.03/03/2000 - 09.00h
  --
  UPDATE GC.ETR_ITEM_ROM_SEP IET
     SET DT_RET = P_SNS.DT_SOLIC
   WHERE CD_FIL_RSD_EBQ = P_SNS.CD_FIL_RSD_EBQ
     AND ID_ROM_RSD_EBQ = P_SNS.ID_ROM_EBQ
     AND DS_PLACA_EBQ   = P_SNS.DS_PLACA_EBQ
     AND NR_ETR IN (SELECT NR_ETR FROM ETR
                       WHERE ETR.NR_ETR = IET.NR_ETR
                         AND ETR.ID_TET IN (SELECT ID_TET FROM TIPO_EMB_TRANSPORTE TET
                                             WHERE TET.ID_TET = ETR.ID_TET
                                               AND TET.IN_DESCARTE = 'S'
                                            )
                     )
     --AND NR_ETR         > 100000
     AND DT_RET        IS NULL;
  --
  --
  UPDATE GC.ROMANEIO_SEPARACAO RSD
     SET RSD.DT_FAT = P_SNS.DT_SOLIC
   WHERE RSD.CD_FIL = P_SNS.CD_FIL_RSD_EBQ
     AND RSD.ID_ROM = P_SNS.ID_ROM_EBQ;
  IF SQL%ROWCOUNT = 1
   THEN
   NULL;
  ELSE
   RAISE_APPLICATION_ERROR(-20001,
    'ERRO AO ATUALIZAR NO ROMANEIO A DATA DO FATURAMENTO.'||
    'CD_FIL_RSD<' || P_SNS.CD_FIL_RSD_EBQ ||'> '||
    'ID_ROM_RSD<' || P_SNS.ID_ROM_EBQ     ||'> '||
    'ROWCOUNT<'   || SQL%ROWCOUNT         ||'> '||
    'INCORRETO. ESPERADO ROWCOUNT = 1');
  END IF;
  --
 END IF;
--
--
-- APD1619
--
   UPDATE GC.NF_SAIDA NFS
      SET DT_SAIDA_IMPR = GC.PCK_TM_8.G_DT_SAIDA_IMPR
    WHERE NFS.ID_SESSAO = GC.PCK_1.G_ID_SESSAO_GTSNS2;

--ATUALIZAR PESOS E VOLUMES NAS NOTAS DE SAIDAS             JSOUZA-06/11/2001

 GC.ATLZ_VOLUME_PESO_NOTA(PCK_1.G_ID_SESSAO_GTSNS2);
--
--
--->>> APD-1563
--
-- LENDO OS POEs GERADOS A PARTIR DOS SPVs ACIMA
--
 OPEN C_POE;
 --
 LOOP
  FETCH C_POE INTO R_POE;
  EXIT WHEN C_POE%NOTFOUND;
  --
  SELECT COUNT(*)
    INTO D_EXISTE
    FROM GC.ITEM_PED_OUT_ENTR_PRD IPE
   WHERE IPE.CD_FIL = R_POE.CD_FIL
     AND IPE.NR_PED = R_POE.NR_PED
     AND (IPE.QT_ITEM - IPE.QT_CANC - IPE.QT_ATEND) > 0;
  --
  IF D_EXISTE > 0
   THEN
   --
   D_RETORNO := GC.PKG_SERVICO_POS_VENDA.FNC_GERAR_NFE_POE_SPV(P_NR_PED => R_POE.NR_PED
                                                              ,P_CD_FIL => R_POE.CD_FIL);
   --
   OPEN C_NFE (R_POE.NR_PED
              ,R_POE.CD_FIL);
   FETCH C_NFE INTO R_NFE;
   CLOSE C_NFE;
   --
   P_AIS         := NULL;
   P_AIS.NR_ACAO := R_NFE.NR_ACAO_AIS;
   --
   GC.PKG_SERVICO_POS_VENDA.PRC_LE_AIS_1(P_AIS);
   --
   BEGIN
    --
    SELECT AIS.CD_MOTIV
      INTO D_CD_MOTIV
      FROM GC.ACAO_ITEM_SERVICO_POS_VENDA AIS
     WHERE ((   AIS.NR_SOLIC_SPV = P_AIS.NR_SOLIC_SPV)
		 		        OR (    AIS.NR_SOLIC_ISV    = P_AIS.NR_SOLIC_ISV
                 AND AIS.NR_SEQ_ITEM_ISV = P_AIS.NR_SEQ_ITEM_ISV)
             OR (    AIS.NR_SOLIC_PSV    = P_AIS.NR_SOLIC_PSV
                 AND AIS.NR_SEQ_PRD_PSV  = P_AIS.NR_SEQ_PRD_PSV))
       AND AIS.NR_SEQ_EXEC  < P_AIS.NR_SEQ_EXEC
       AND AIS.CD_MOTIV    IS NOT NULL
       AND ROWNUM          <= 1;
    --
    GC.GERAR_CDM_ITEM_NF_ENTRADA (R_NFE.CD_FIL
                                 ,R_NFE.DT_EMIS
                                 ,R_NFE.NR_NF
                                 ,R_NFE.DS_SER
                                 ,R_NFE.NR_SUBSER
                                 ,R_NFE.NR_ITEM
                                 ,R_NFE.ID_PROD
                                 ,R_NFE.QT_ITEM
                                 ,D_CD_MOTIV
                                 ,0
                                 ,'S'
                                 ,NULL);
    --
    -- Rotina de Impressão das AQPs geradas
    --
   EXCEPTION
    WHEN OTHERS
     THEN
     --
     --RAISE_APPLICATION_ERROR(-20001,'NAO FOI GERADA A CDM DAS NOTAS DE ENTRADAS REFENTES AO SPV.VERIFIQUE');
     --
     D_TXT_EMAIL := SUBSTR(SQLERRM, 1, 2000);
     --
     GC.PCK_WEB_GLOBAL.ENVIAEMAILJAVA (P_FROM       => 'operacao@tokstok.com.br'
                                      ,P_REPLY      => NULL
                                      ,P_TO         => GC.FNC_LE_GC_PARAMETRO(NULL, 'EMAIL_SITUACOES_CRITICAS_GC')
                                      ,P_CC         => NULL
                                      ,P_BCC        => NULL
                                      ,P_SUBJECT    => 'ERRO NA GERACAO DA CDM NO FATURAMENTO DA SESSAO ' || GC.PCK_1.G_ID_SESSAO_GTSNS2
                                      ,P_MESSAGE    => D_TXT_EMAIL
                                      ,P_TYPE       => 'text/plain'
                                      ,P_SMTPSERVER => GC.FNC_LE_GC_PARAMETRO(P_DS_PAR => 'IP_SERVIDOR_EMAIL')
                                      ,P_ATTACH     => NULL);
     --
   END;
   --
  END IF;
  --
 END LOOP;
 --
EXCEPTION
 WHEN OTHERS
  THEN
  --
  D_ERRO := SQLERRM;
  --
  RAISE_APPLICATION_ERROR (-20001,
                           D_REQUERENTE ||
                           'ERRO<'      || D_ERRO   || '>.');
  --
END EMISSAO_NF_ENTRADA_SAIDA;
/
CREATE OR REPLACE PUBLIC SYNONYM EMISSAO_NF_ENTRADA_SAIDA FOR GC.EMISSAO_NF_ENTRADA_SAIDA
/
GRANT EXECUTE ON GC.EMISSAO_NF_ENTRADA_SAIDA TO GC_LOJA
/
GRANT EXECUTE ON GC.EMISSAO_NF_ENTRADA_SAIDA TO SICA_RL_GC_GERAL
/
