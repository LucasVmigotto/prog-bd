/* ######################################################## */
/*  FATEC Ipiranga - Análise e Desenvolvimento de Sistemas  */
/*  Programação para Banco de Dados - Projeto P2            */
/*                                                          */
/*  Nome: Lucas Vidor Migotto                               */
/* ######################################################## */

/* parametros de configuracao da sessao */
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';
ALTER SESSION SET NLS_LANGUAGE = PORTUGUESE;
SELECT SESSIONTIMEZONE, CURRENT_TIMESTAMP FROM DUAL;

/* ####################### */
/* Atividade P2 - Parte #1 */
/* ####################### */
-- 1    Importe os dados para
--      o Oracle utilizando o
--      SQL Developer ou SQL
--      Loader pela linha de
--      comando.

-- 2    Monte o script completo
--      para tratar os dados com
--      as seguintes caraterísticas:

-- 2.1  Tabela para os locais(cidade +
--      UF + latitude e longitude)
DROP TABLE uf CASCADE CONSTRAINTS;
CREATE TABLE uf (
    cod_uf INTEGER PRIMARY KEY,
    sigla CHAR(2) NOT NULL
);

INSERT INTO uf (sigla) VALUES (UPPER('AC'));
INSERT INTO uf (sigla) VALUES (UPPER('AL'));
INSERT INTO uf (sigla) VALUES (UPPER('AP'));
INSERT INTO uf (sigla) VALUES (UPPER('AM'));
INSERT INTO uf (sigla) VALUES (UPPER('BA'));
INSERT INTO uf (sigla) VALUES (UPPER('CE'));
INSERT INTO uf (sigla) VALUES (UPPER('DF'));
INSERT INTO uf (sigla) VALUES (UPPER('ES'));
INSERT INTO uf (sigla) VALUES (UPPER('GO'));
INSERT INTO uf (sigla) VALUES (UPPER('MA'));
INSERT INTO uf (sigla) VALUES (UPPER('MT'));
INSERT INTO uf (sigla) VALUES (UPPER('MS'));
INSERT INTO uf (sigla) VALUES (UPPER('MG'));
INSERT INTO uf (sigla) VALUES (UPPER('PA'));
INSERT INTO uf (sigla) VALUES (UPPER('PB'));
INSERT INTO uf (sigla) VALUES (UPPER('PR'));
INSERT INTO uf (sigla) VALUES (UPPER('PE'));
INSERT INTO uf (sigla) VALUES (UPPER('PI'));
INSERT INTO uf (sigla) VALUES (UPPER('RJ'));
INSERT INTO uf (sigla) VALUES (UPPER('RN'));
INSERT INTO uf (sigla) VALUES (UPPER('RS'));
INSERT INTO uf (sigla) VALUES (UPPER('RO'));
INSERT INTO uf (sigla) VALUES (UPPER('RR'));
INSERT INTO uf (sigla) VALUES (UPPER('SC'));
INSERT INTO uf (sigla) VALUES (UPPER('SP'));
INSERT INTO uf (sigla) VALUES (UPPER('SE'));
INSERT INTO uf (sigla) VALUES (UPPER('TO'));

DROP TABLE local CASCADE CONSTRAINTS;
CREATE TABLE local (
    cod_local INTEGER PRIMARY KEY,
    cidade VARCHAR2(40) UNIQUE NOT NULL,
    uf INTEGER NOT NULL,
    latitude NUMBER(8,5) NOT NULL,
    longitude NUMBER(8,5) NOT NULL,
    FOREIGN KEY (uf)
        REFERENCES uf(sigla)
);

-- 2.2  Tabela para linha de viagem e
--      seus respectivos dados (
--      identificador da linha, empresa,
--      referências aos respectivos
--      identificadores de origem e
--      destino, etc.)
DROP TABLE linha_viagem CASCADE CONSTRAINTS;
CREATE TABLE linha_viagem (
    cod_linha_viagem PRIMARY KEY,
    empresa VARCHAR2(20) NOT NULL,
    cod_local_origem INTEGER NOT NULL,
    cod_local_destino INTEGER NOT NULL,
    sentido_linha VARCHAR(5) NOT NULL,
    tipo_viagem VARCHAR(7) NOT NULL,
    FOREIGN KEY (cod_local_origem)
        REFERENCES local(cod_local)
        ON DELETE CASCADE,
    FOREIGN KEY (cod_local_destino)
        REFERENCES local(cod_local)
        ON DELETE CASCADE
);

-- 2.3  Tabela para a viagem(identificador da
--      viagem, linha, datas e horários e o
--      veículo utilizado)
DROP TABLE viagem CASCADE CONSTRAINTS;
CREATE TABLE viagem (
    cod_viagem PRIMARY KEY,
    cod_linha_viagem INTEGER NOT NULL,
    num_veiculo INTEGER NOT NULL,
    dt_programada TIMESTAMP NOT NULL,
    dt_inicio_viagem TIMESTAMP NOT NULL,
    dt_fim_viagem TIMESTAMP NOT,
    FOREIGN KEY (cod_linha_viagem)
        REFERENCES viagem(cod_linha_viagem)
        ON DELETE CASCADE
);

-- Popula a tabela de locais
DECLARE
    arv_data UTL_FILE.FILE_TYPE;
    arv_linha VARCHAR2(32767);
    cont_cidade NUMBER;
    BEGIN
        arv_data := UTL_FILE.FOPEN('EXT_DIR', 'road-transport-brazil.csv', 'R', 32767);

    LOOP
        UTL_FILE.GET_LINE(arv_data, arv_linha, 32767);

        SELECT COUNT(cod_local)
            INTO cont_cidade
            FROM local
            WHERE cidade=UPPER(REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 10));

        IF cont_cidade = 0 THEN
            INSERT INTO local (
                cidade,
                uf,
                latitude,
                longitude
            ) VALUES (
                REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 10),
                (SELECT cod_uf
                    FROM uf
                    WHERE sigla=UPPER(
                        REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 11)
                    )
                ),
                REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 12),
                REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 13),
            );
        END IF;

    END LOOP;

    UTL_FILE.FCLOSE(arv_data);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        null;
    END;

-- Popula a tabela de linhas de viagem
DECLARE
    arv_data UTL_FILE.FILE_TYPE;
    arv_linha VARCHAR2(32767);
    BEGIN
        arv_data := UTL_FILE.FOPEN('EXT_DIR', 'road-transport-brazil.csv', 'R', 32767);

    LOOP
        UTL_FILE.GET_LINE(arv_data, arv_linha, 32767);

        INSERT INTO linha_viagem (
            empresa,
            cod_local_origem,
            cod_local_destino,
            sentido_linha,
            tipo_viagem
        ) VALUES (
            REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 2),
            (SELECT cod_local
                FROM local
                WHERE cidade=UPPER(
                    REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 8)
                )
            ),
            (SELECT cod_local
                FROM local
                WHERE cidade=UPPER(
                    REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 10)
                )
            ),
            REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 6),
            REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 5)
        );

    END LOOP;

    UTL_FILE.FCLOSE(arv_data);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        null;
    END;

-- Popula a tabela de viagem
DECLARE
    arv_data UTL_FILE.FILE_TYPE;
    arv_linha VARCHAR2(32767);
    cod_fk_linha_viagem linha_viagem.cod_linha_viagem%TYPE;
    cod_fk_origem local.cod_local%TYPE;
    cod_fk_destino local.cod_local%TYPE;
    BEGIN
        arv_data := UTL_FILE.FOPEN('EXT_DIR', 'road-transport-brazil.csv', 'R', 32767);

    LOOP
        UTL_FILE.GET_LINE(arv_data, arv_linha, 32767);

        SELECT cod_local
            INTO cod_fk_origem
            FROM local
            WHERE cidade=UPPER(
                REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 8)
            );

        SELECT cod_local
            INTO cod_fk_destino
            FROM local
            WHERE cidade=UPPER(
                REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 10)
            );

        SELECT cod_linha_viagem
            INTO cod_fk_linha_viagem
            FROM linha_viagem
            WHERE cod_local_origem=cod_fk_origem
                AND cod_local_destino=cod_fk_destino;

        INSERT INTO viagem (
            cod_linha_viagem,
            num_veiculo,
            dt_programada,
            dt_inicio_viagem,
            dt_fim_viagem
        ) VALUES (
            cod_fk_linha_viagem,
            REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 4),
            REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 15),
            REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 16),
            REGEXP_SUBSTR(arv_linha, '[^,]+', 1, 17)
        );

    END LOOP;

    UTL_FILE.FCLOSE(arv_data);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        null;
    END;

-- 2.4  Converta todos os identificadores
--      hexadecimais em decimais
