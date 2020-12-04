/* ######################################################## */
/*  FATEC Ipiranga - Análise e Desenvolvimento de Sistemas  */
/*  Programação para Banco de Dados - Projeto P2            */
/*                                                          */
/*  Nome: Lucas Vidor Migotto                               */
/* ######################################################## */

-- Parâmetros de configuração da sessão
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS=',.';
ALTER SESSION SET NLS_LANGUAGE = PORTUGUESE;
ALTER TABLESPACE SYSTEM
    ADD DATAFILE '\oraclexe\app\oracle\oradata\XE\system16.dbf' SIZE 500 M;

/* ####################### */
/* Atividade P2 - Parte #1 */
/* ####################### */
-- 1    Importe os dados para
--      o Oracle utilizando o
--      SQL Developer ou SQL
--      Loader pela linha de
--      comando.

-- Tabela base
DROP TABLE base CASCADE CONSTRAINTS;
CREATE TABLE base (
    codigo_viagem VARCHAR2(30),
    empresa VARCHAR2(30),
    num_linha VARCHAR2(30),
    onibus VARCHAR2(30),
    tipo_viagem VARCHAR2(30),
    sentido_linha VARCHAR2(30),
    in_transbordo VARCHAR2(30),
    origem_cidade VARCHAR2(50),
    origem_uf VARCHAR2(30),
    destino_cidade VARCHAR2(50),
    destino_uf VARCHAR2(30),
    latitude VARCHAR2(30),
    longitude VARCHAR2(30),
    pdop VARCHAR2(30),
    data_viagem_programada VARCHAR2(30),
    data_inicio_viagem VARCHAR2(30),
    data_fim_viagem VARCHAR2(30)
);
-- TRUNCATE TABLE base;

-- 2    Monte o script completo
--      para tratar os dados com
--      as seguintes caraterísticas:

-- 2.1  Tabela para os locais(cidade +
--      UF + latitude e longitude)

-- Tabela origem
CREATE TABLE origem AS
    SELECT
        DISTINCT
            origem_cidade,
            origem_uf
        FROM base
        ORDER BY 1;

-- Tabela destino
CREATE TABLE destino AS
    SELECT
        DISTINCT
            destino_cidade,
            destino_uf
        FROM base
        ORDER BY 1;

-- Tabela localidade
CREATE TABLE localidade AS
    SELECT
        origem_cidade AS cidade,
        origem_uf AS uf
        FROM origem
        UNION
            SELECT
                destino_cidade AS cidade,
                destino_uf AS uf
            FROM destino;

-- Ajustes
DELETE FROM localidade WHERE cidade IN ('destino','origem');

-- Definindo primary key
ALTER TABLE localidade
    ADD id_local SMALLINT;

CREATE SEQUENCE seq_local START WITH 1;

UPDATE localidade SET
    id_local = seq_local.nextval;

ALTER TABLE localidade
    ADD CONSTRAINT pk_local
        PRIMARY KEY(id_local);

-- 2.2  Tabela para linha de viagem e
--      seus respectivos dados (
--      identificador da linha, empresa,
--      referências aos respectivos
--      identificadores de origem e
--      destino, etc.)

-- Tabela linha_viagem
CREATE TABLE linha_viagem AS
    SELECT
        DISTINCT
            num_linha AS numero_Linha,
            empresa,
            origem_cidade,
            origem_uf,
            destino_cidade,
            destino_uf
        FROM base
        ORDER BY empresa;

DELETE FROM linha_viagem
    WHERE empresa = 'empresa';

-- Alterando origem e destino para foreign key localidade
ALTER TABLE linha_viagem
    ADD (
        id_origem SMALLINT,
        id_destino SMALLINT
    );

-- origem
UPDATE linha_viagem lv SET
    lv.id_origem=(
        SELECT l.id_local
            FROM localidade l
            WHERE TRIM(UPPER(lv.origem_cidade))=TRIM(l.cidade)
                AND TRIM(UPPER(lv.origem_uf))=TRIM(l.uf)
    );

-- destino
UPDATE linha_viagem lv SET
    lv.id_destino=(
        SELECT l.id_local
            FROM localidade l
                WHERE TRIM(UPPER(lv.destino_cidade))=TRIM(l.cidade)
                    AND TRIM(UPPER(lv.destino_uf))=TRIM(l.uf)
    );

-- Definindo foreign keys
ALTER TABLE linha_viagem
    ADD CONSTRAINT fk_origem
        FOREIGN KEY(id_origem)
            REFERENCES localidade(id_local);

ALTER TABLE linha_viagem
    ADD CONSTRAINT fk_destino
        FOREIGN KEY(id_destino)
            REFERENCES localidade(id_local);

-- 2.3  Tabela para a viagem(identificador da
--      viagem, linha, datas e horários e o
--      veículo utilizado)

DELETE FROM base WHERE codigo_viagem = 'codigo_viagem';

-- Tabela viagem
CREATE TABLE viagem AS
    SELECT
        DISTINCT
            codigo_viagem AS id_viagem,
            num_linha AS numero_linha,
            tipo_viagem,
            sentido_linha,
            data_viagem_programada AS dthora_programada,
            data_inicio_viagem AS dthora_inicio,
            data_fim_viagem AS dthora_termino
        FROM base
        ORDER BY
            data_viagem_programada,
            data_inicio_viagem;

-- 2.4  Converta todos os identificadores
--      hexadecimais em decimais

-- Linha de viagem
ALTER TABLE linha_viagem
    ADD id_empresa INTEGER;

UPDATE linha_viagem SET
    id_empresa=TO_NUMBER(empresa,'XXXXXXXXXX');

ALTER TABLE linha_viagem
    ADD id_linha INTEGER;

UPDATE linha_viagem SET
    id_linha=TO_NUMBER(numero_linha,'XXXXXXXXXX');

-- Viagem
ALTER TABLE viagem
    ADD id_linha INTEGER;

UPDATE viagem SET
    id_linha=TO_NUMBER(numero_linha,'XXXXXXXXXX');

-- Criar relacionamento Viagem e Linha
ALTER TABLE linha_viagem
    ADD CONSTRAINT pk_linha
        PRIMARY KEY (id_linha);

ALTER TABLE viagem
    ADD CONSTRAINT fk_linha
        FOREIGN KEY(id_linha)
            REFERENCES linha_viagem(id_linha)
            ON DELETE CASCADE;

-- Exclusão dos hexadecimais
ALTER TABLE viagem
    DROP COLUMN numero_linha;

ALTER TABLE linha_viagem
    DROP COLUMN numero_linha;

-- ID Viagem
ALTER TABLE viagem
    ADD num_viagem INTEGER;

UPDATE viagem SET
    num_viagem=TO_NUMBER(id_viagem,'XXXXXXXXXX');

ALTER TABLE viagem
    ADD CONSTRAINT pk_viagem
        PRIMARY KEY(num_viagem);

ALTER TABLE viagem
    DROP COLUMN id_viagem;

/* ####################### */
/* Atividade P2 - Parte #2 */
/* ####################### */
-- Definição de função converte_datahora
CREATE OR REPLACE FUNCTION converte_datahora (
    vdata IN VARCHAR2
) RETURN TIMESTAMP IS vdthora TIMESTAMP;
    vdia CHAR(2) := SUBSTR(vdata,9,2);
    vmes CHAR(2) := SUBSTR(vdata,6,2);
    vano CHAR(4) := SUBSTR(vdata,1,4);
    vhora CHAR(2) := SUBSTR(vdata,12,2);
    vmin CHAR(2) := SUBSTR(vdata,15,2);
    vseg CHAR(2) := SUBSTR(vdata,18,2);
    BEGIN
        SELECT
            TO_TIMESTAMP(
                vdia ||
                '-' ||
                vmes ||
                '-' ||
                vano ||
                ' ' ||
                vhora ||
                ':' ||
                vmin ||
                ':' ||
                vseg,
                'DD-MM-YYYY HH24:MI:SS'
            )
            INTO vdthora
            FROM dual;
        RETURN vdthora;
    END;

-- Ajuste tabela Viagem
ALTER TABLE viagem
    ADD (
        dt_hora_programada TIMESTAMP,
        dt_hora_inicio TIMESTAMP,
        dt_hora_termino TIMESTAMP
    );

-- Criação índices
CREATE INDEX idx_programada
    ON viagem(dthora_programada);
CREATE INDEX idx_inicio
    ON viagem(dthora_inicio);
CREATE INDEX idx_termino
    ON viagem(dthora_termino);

-- Atualização tabela Viagem
UPDATE viagem SET
    dt_hora_programada = converte_datahora(dthora_programada);
UPDATE viagem SET
    dt_hora_inicio = converte_datahora(dthora_inicio);
UPDATE viagem SET
    dt_hora_termino = converte_datahora(dthora_termino);

-- Definição de função duracao_minutos
CREATE OR REPLACE FUNCTION duracao_minutos (
    vtime_ini IN TIMESTAMP,
    vtime_fim IN TIMESTAMP
) RETURN INTEGER IS vduracao INTEGER;
    vdias SMALLINT := 0;
    vhoras SMALLINT := 0;
    vminutos SMALLINT := 0;
    BEGIN
        SELECT
            TO_NUMBER(
                EXTRACT(DAY FROM (vtime_fim - vtime_ini))
            ),
            TO_NUMBER(
                EXTRACT(HOUR FROM (vtime_fim - vtime_ini))
            ),
            TO_NUMBER(
                EXTRACT(MINUTE FROM (vtime_fim - vtime_ini))
            )
            INTO
                vdias,
                vhoras,
                vminutos
            FROM dual;
        vduracao := vdias * 24 * 60 + vhoras * 60 + vminutos;
        IF vduracao < 0 THEN
            vduracao := 12 * 60 + vduracao;
        END IF;
        RETURN vduracao;
    END;

-- Alteração tabela Viagem
ALTER TABLE viagem
    ADD duracao_min INTEGER;

-- Atualização tabela Viagem
UPDATE viagem SET
    duracao_min = duracao_minutos(dt_hora_inicio, dt_hora_termino);

-- Definição de função mostra_horas
CREATE OR REPLACE FUNCTION mostra_horas (
    vmin IN INTEGER
) RETURN CHAR IS vhoras CHAR(15);
    BEGIN
        SELECT
            TO_CHAR(TRUNC(vmin/60), '00') ||
                'h' ||
                TO_CHAR(MOD(vmin,60),'00') ||
                'min'
            INTO vhoras FROM dual;
        RETURN vhoras;
    END;

-- 3    Importe os dados do
--      arquivo brasil.csv
--      (municípios com latitude
--      e longitude) para o
--      Oracle. A partir deste
--      arquivo atualize os
--      dados de latitude e
--      longitude de cada
--      localidade criada em
--      2.1 acima
DROP TABLE consolidado CASCADE CONSTRAINTS;
CREATE TABLE consolidado (
  ibge INTEGER,
  municipio VARCHAR2(40),
  latitude VARCHAR2(10),
  longitude VARCHAR2(10),
  cod_estado INTEGER,
  estado VARCHAR2(40),
  uf VARCHAR2(40),
  regiao VARCHAR2(40),
  capital INTEGER
);
-- TRUNCATE TABLE consolidado;

-- Localidade
ALTER TABLE localidade
    ADD (
        latitude VARCHAR2(30),
        longitude VARCHAR2(30)
    );

UPDATE localidade l SET
    l.latitude = (
        SELECT
            c.latitude
            FROM consolidado c
            WHERE TRIM(UPPER(c.municipio)) = TRIM(l.cidade)
                AND TRIM(UPPER(c.uf)) = TRIM(l.uf)
    );

UPDATE localidade l SET
    l.longitude = (
        SELECT
            c.longitude
            FROM consolidado c
            WHERE TRIM(UPPER(c.municipio)) = TRIM(l.cidade)
                AND TRIM(UPPER(c.uf)) = TRIM(l.uf)
    );

-- 4    Utilizando a linguagem
--      SQL responda à seguintes
--      consultas:

-- 4.1  Mostre um ranking das
--      cidades destino das
--      viagens: Cidade Destino
--      – Qtde Viagens - Posição
SELECT
    ldest.cidade AS cidade_destino,
    COUNT(v.num_viagem) AS qtde_viagens,
    RANK() OVER (
        ORDER BY COUNT(v.num_viagem) DESC
    ) AS rkg
    FROM viagem v
    JOIN linha_viagem lv
        ON (v.id_linha = lv.id_linha)
    JOIN localidade ldest
        ON (lv.id_destino = ldest.id_local)
    GROUP BY ldest.cidade;

-- 4.2  Refaça a consulta 4.1
--      acima incluindo o mês-ano
--      e limitando aos 5 primeiros
--      destinos em cada mês
SELECT *
    FROM (
        SELECT
            TO_CHAR(v.dt_hora_termino, 'MM-YYYY') AS mes_ano,
            ldest.cidade AS cidade_destino,
            COUNT(v.num_viagem) AS qtde_viagens,
            DENSE_RANK() OVER (
                PARTITION BY TO_CHAR(v.dt_hora_termino, 'MM-YYYY')
                ORDER BY COUNT(v.num_viagem) DESC
            ) AS rkg,
            ROW_NUMBER() OVER (
                PARTITION BY TO_CHAR(v.dt_hora_termino, 'MM-YYYY')
                ORDER BY COUNT(v.num_viagem) DESC
            ) AS ordem
            FROM viagem v
            JOIN linha_viagem lv
                ON (v.id_linha = lv.id_linha)
            JOIN localidade ldest
                ON (lv.id_destino = ldest.id_local)
            GROUP BY
                TO_CHAR(v.dt_hora_termino, 'MM-YYYY'),
                ldest.cidade
    ) rkgmes
    WHERE rkgmes.ordem <= 5;

-- 4.3  Monte um ranking da quantidade
--      de viagens por cidade e UF de
--      origem acada mês-ano, mostrando
--      o total por mês, cidade e UF
--      (ou seja, de onde mais
--      saem viagens)
SELECT
    lorig.uf AS uf_origem,
    lorig.cidade AS cidade_origem,
    TO_CHAR(v.dt_hora_inicio, 'MM-YYYY') AS mes_ano,
    COUNT(v.num_viagem) AS qtde_viagens,
    DENSE_RANK() OVER (
        ORDER BY COUNT(v.num_viagem) DESC
    ) AS rkg
    FROM viagem v
    JOIN linha_viagem lv
        ON (v.id_linha = lv.id_linha)
    JOIN localidade lorig
        ON (lv.id_origem = lorig.id_local)
    GROUP BY ROLLUP(
            lorig.uf,
            lorig.cidade,
            TO_CHAR(v.dt_hora_inicio, 'MM-YYYY')
        );

-- 4.4  Mostre um ranking das viagens
--      com média de duração mais
--      demoradas: Origem-destino -
--      Duração Média em horas,
--      exibindo também a próxima
--      e a anterior
SELECT
    v.id_linha AS linha,
    lorig.cidade ||
        '-' ||
        lorig.uf AS cidade_origem,
    ldest.cidade ||
        '-' ||
        ldest.uf AS cidade_destino,
    mostra_horas(
        ROUND(AVG(v.duracao_min)/60,1)
    ) AS Duracao_media,
    LEAD (v.id_linha, 1, null)
        OVER (
            ORDER BY AVG(v.duracao_min) DESC
        ) proximo,
    LAG (v.id_linha, 1, null)
        OVER (
            ORDER BY AVG(v.duracao_min) DESC
        ) anterior
    FROM viagem v
    JOIN linha_viagem lv
        ON (v.id_linha = lv.id_linha)
    JOIN localidade lorig
        ON (lv.id_origem = lorig.id_local)
    JOIN localidade ldest
        ON (lv.id_destino = ldest.id_local)
    GROUP BY
        v.id_linha,
        lorig.cidade ||
            '-' ||
            lorig.uf,
        ldest.cidade ||
            '-' ||
            ldest.uf;

SELECT
    v.id_linha AS linha,
    lorig.cidade AS origem,
    ldest.cidade AS destino,
    COUNT(*)
    FROM viagem v
    JOIN linha_viagem lv
        ON (v.id_linha = lv.id_linha)
    JOIN localidade lorig
        ON (lv.id_origem = lorig.id_local)
    JOIN localidade ldest
        ON (lv.id_destino = ldest.id_local)
    GROUP BY
        v.id_linha,
        lorig.cidade,
        ldest.cidade
    ORDER BY 4 DESC;

SELECT
    v.id_linha AS linha,
    lorig.cidade AS origem,
    ldest.cidade AS destino,
    v.duracao_min,
    v.dt_hora_inicio,
    v.dt_hora_termino
    FROM viagem v
    JOIN linha_viagem lv
        ON (v.id_linha = lv.id_linha)
    JOIN localidade lorig
        ON (lv.id_origem = lorig.id_local)
    JOIN localidade ldest
        ON (lv.id_destino = ldest.id_local)
    WHERE lv.id_linha=1042736092
    ORDER BY 4 DESC;

-- 4.5  Refaça a consulta 4.4 acima
--      mostrando agora por UF e
--      somente para viagens dentro
--      do mesmo estado (estaduais).
SELECT
    v.id_linha AS linha,
    lorig.cidade ||
        '-' ||
        lorig.uf AS cidade_origem,
    ldest.cidade ||
        '-' ||
        ldest.uf AS cidade_destino,
    mostra_horas(
        ROUND(AVG(v.duracao_min)/60,1)
    ) AS duracao_media,
    LEAD (v.id_linha, 1, null)
        OVER (
            ORDER BY  AVG(v.duracao_min) DESC
        ) proximo,
    LAG (v.id_linha, 1, null)
        OVER (
            ORDER BY AVG(v.duracao_min) DESC
        ) anterior
    FROM viagem v
    JOIN linha_viagem lv
        ON (v.id_linha = lv.id_linha)
    JOIN localidade lorig
        ON (lv.id_origem = lorig.id_local)
    JOIN localidade ldest
        ON (lv.id_destino = ldest.id_local)
    WHERE lorig.uf = ldest.uf
    GROUP BY
        v.id_linha,
        lorig.cidade ||
            '-' ||
            lorig.uf,
        ldest.cidade ||
            '-' ||
            ldest.uf;

SELECT
    lorig.cidade ||
        '-' ||
        lorig.uf AS cidade_origem,
    ldest.cidade ||
        '-' ||
        ldest.uf AS cidade_destino
    FROM viagem v
    JOIN linha_viagem lv
        ON (v.id_linha = lv.id_linha)
    JOIN localidade lorig
        ON (lv.id_origem = lorig.id_local)
    JOIN localidade ldest
        ON (lv.id_destino = ldest.id_local)
    WHERE lorig.uf=ldest.uf;

SELECT * FROM linha_viagem;
SELECT * FROM base WHERE origem_uf=destino_uf;

-- 5    Utilizando a linguagem PL/SQL
--      transforme a consulta 4.2
--      acima em uma procedure que
--      permita entrar o período
--      (data inicial e final) e o
--      número de posições no ranking
--      de cada mês
CREATE OR REPLACE PROCEDURE ranking_viagens (
    vini IN DATE,
    vfim IN DATE,
    vrank IN SMALLINT
) IS CURSOR rkg_viagem IS
    SELECT *
        FROM (
            SELECT
                TO_CHAR(v.dt_hora_termino, 'MM-YYYY')
                    AS mes_ano,
                ldest.cidade AS cidade_destino,
                COUNT(v.num_viagem) AS qtde_viagens,
                RANK() OVER (
                    PARTITION BY TO_CHAR(v.dt_hora_termino, 'MM-YYYY')
                    ORDER BY COUNT(v.num_viagem) DESC
                ) AS rkg,
                ROW_NUMBER() OVER (
                    PARTITION BY TO_CHAR(v.dt_hora_termino, 'MM-YYYY')
                    ORDER BY COUNT(v.num_viagem) DESC
                ) AS ordem
                FROM viagem v
                JOIN linha_viagem lv
                    ON (v.id_linha = lv.id_linha)
                JOIN localidade ldest
                    ON (lv.id_destino = ldest.id_local)
                WHERE v.dt_hora_termino
                    BETWEEN vini AND vfim
                GROUP BY
                    TO_CHAR(v.dt_hora_termino, 'MM-YYYY'),
                    ldest.cidade
        ) rkgmes
        WHERE rkgmes.ordem <= vrank;
    BEGIN
        DBMS_OUTPUT.PUT_LINE (
            'Periodo : ' ||
            TO_CHAR(vini) ||
            ' a ' ||
            TO_CHAR(vfim)
        );
        DBMS_OUTPUT.PUT_LINE (
            'Mes-Ano      Destino          Qtde Viagens   Posicao  Ordem'
        );
        DBMS_OUTPUT.PUT_LINE (RPAD('_', 100, '_'));
        FOR k IN rkg_viagem LOOP
            DBMS_OUTPUT.PUT_LINE (
                RPAD(k.Mes_ano, 11, ' ') ||
                '| ' ||
                RPAD(k.cidade_destino, 22, ' ') ||
                '|' ||
                RPAD(TO_CHAR(k.qtde_viagens), 10, ' ') ||
                '|' ||
                RPAD(TO_CHAR(k.rkg),7, ' ') ||
                '|' ||
                TO_CHAR(k.ordem)
            );
            DBMS_OUTPUT.PUT_LINE (RPAD('-', 100, '-'));
        END LOOP;
    END;

/* ####################### */
/* Atividade P2 - Parte #3 */
/* ####################### */
-- 6    Altere a estrutura de
--      linha da viagem para
--      incluir a distância
--      (em km) entre a cidade
--      de origem e a cidade
--      de destino, utilizando
--      a latitude e longitude
--      atualizadas no item 3
--      acima. Utilize alguma
--      função pronta em PL/SQL
--      para o cálculo da distância
--      (pesquisar na WEB)

-- Alteração tabela localidade
ALTER TABLE localidade
    ADD (
        nlongitude NUMBER(8,5),
        nlatitude NUMBER(8,5)
    );

-- Atualização localidade (longitude)
UPDATE localidade SET
    longitude = TRIM(longitude) || '000'
    WHERE LENGTH(TRIM(longitude)) = 5;

-- Atualização localidade (latitude)
UPDATE localidade SET
    latitude = TRIM(latitude) || '0'
    WHERE LENGTH(TRIM(latitude)) = 7;

-- Definição de procedure converte_longitude
CREATE OR REPLACE PROCEDURE converte_longitude(
    vin IN INTEGER
) IS
    vlinha ROWID;
    vinteiro INTEGER := 0;
    vdecimal INTEGER := 0;
    vtamint SMALLINT := 0;
    vtamdec SMALLINT := 0;
    vlongitude NUMBER(8,5);
    vsinal SMALLINT := 0;
    CURSOR longlat IS
        SELECT
            lc.*,
            rowid AS linha
            FROM localidade lc
            WHERE longitude IS NOT NULL;
    BEGIN
        FOR j IN longlat LOOP
            vsinal := -1;
            vtamint := LENGTH(
                SUBSTR (
                    j.longitude, 1,
                    INSTR (j.longitude, '.') - 1
                )
            );
            vtamdec := LENGTH(
                SUBSTR (
                    j.longitude,
                    INSTR(j.longitude, '.') + 1,
                    LENGTH(j.longitude)
                )
            );
            vinteiro := TO_NUMBER(
                SUBSTR (
                    j.longitude, 1,
                    INSTR(j.longitude, '.') - 1
                )
            );
            vdecimal := TO_NUMBER(
                SUBSTR(
                    j.longitude,
                    INSTR(j.longitude, '.') + 1,
                    LENGTH(j.longitude)
                )
            );
            IF vinteiro < 0 THEN
                vsinal := -1;
            END IF;
            IF vtamint = 3 THEN
                vlongitude := vsinal * vinteiro + vdecimal / 10000;
            ELSIF vtamint = 2 THEN
                vlongitude := vsinal * vinteiro + vdecimal / 100000;
            END IF;
            vlongitude := vlongitude * vsinal;
            DBMS_OUTPUT.PUT_LINE(
                'Longitude:' ||
                j.longitude ||
                '->' ||
                TO_CHAR(vlongitude)
            );
            vinteiro := 0;
            vdecimal := 0;
            UPDATE localidade lc SET
                lc.nlongitude = vlongitude
                WHERE lc.rowid = j.linha;
        END LOOP;
    END;

-- Execução de procedure converte_longitude
BEGIN
    converte_longitude(1);
END;

-- Definição de procedure converte_latitude
CREATE OR REPLACE PROCEDURE converte_latitude (
    vin IN INTEGER
) IS
    vinteiro INTEGER := 0;
    vdecimal INTEGER := 0;
    vtamint SMALLINT := 0;
    vtamdec SMALLINT := 0;
    vlatitude NUMBER(8,5);
    vsinal SMALLINT := 0;
    CURSOR clat IS
        SELECT
            lc.*,
            rowid AS linha
            FROM localidade lc
            WHERE latitude IS NOT NULL;
    BEGIN
        FOR j IN clat LOOP
            vsinal := -1;
            vtamint := LENGTH(
                SUBSTR(
                    j.latitude,
                    1,
                    INSTR(j.latitude, '.') - 1
                )
            );
            vtamdec := LENGTH(
                SUBSTR(
                    j.latitude,
                    INSTR(j.latitude, '.') + 1,
                    LENGTH(j.latitude)
                )
            );
            vinteiro := TO_NUMBER(
                SUBSTR(
                    j.latitude,
                    1,
                    INSTR(j.latitude, '.') - 1
                )
            );
            vdecimal := TO_NUMBER(
                SUBSTR(
                    j.latitude,
                    INSTR(j.latitude, '.') + 1,
                    LENGTH(j.latitude)
                )
            );
            IF vinteiro >= 0 THEN
                vsinal := 1;
            END IF;
            IF vtamint = 3 THEN
                vlatitude := vsinal * vinteiro + vdecimal / 10000;
            ELSIF vtamint = 2 THEN
                vlatitude := vsinal * vinteiro + vdecimal / 100000;
            ELSIF vtamint = 1 THEN
                vlatitude := vsinal * vinteiro + vdecimal / 1000000;
            END IF;
            vlatitude := vlatitude * vsinal;
            DBMS_OUTPUT.PUT_LINE(
                'Latitude:' ||
                j.latitude ||
                '->' ||
                TO_CHAR(vlatitude)
            );
            vinteiro := 0;
            vdecimal := 0;
            UPDATE localidade lc SET
                lc.nlatitude = vlatitude
                WHERE lc.rowid = j.linha;
        END LOOP;
    END;

-- Execução de procedure converte_latitude
BEGIN
converte_latitude(1);
END;

-- Definição de function distancia
CREATE OR REPLACE FUNCTION distancia (
    Lat1 IN NUMBER,
    Lon1 IN NUMBER,
    Lat2 IN NUMBER,
    Lon2 IN NUMBER,
    Radius IN NUMBER DEFAULT 6387.7
) RETURN NUMBER IS
    Grau_para_Radiano NUMBER := 57.29577951;
    BEGIN
        RETURN(
            NVL(Radius,0) *
            ACOS((
                    sin(NVL(Lat1,0) / Grau_para_Radiano) *
                    SIN(NVL(Lat2,0) / Grau_para_Radiano)
                ) +
                (
                    COS(NVL(Lat1,0) / Grau_para_Radiano) *
                    COS(NVL(Lat2,0) / Grau_para_Radiano) *
                    COS(
                        NVL(Lon2,0) /
                        Grau_para_Radiano -
                        NVL(Lon1,0) /
                        Grau_para_Radiano
                    )
                )
            )
        );
END;

-- Altreação viagem
ALTER TABLE viagem
    ADD (
        velocidade NUMBER(10,3),
        confiavel CHAR(1)
    );

-- Atualização viagen
UPDATE viagem SET
    confiavel = 'N'
    WHERE duracao_min > 5000;

UPDATE viagem SET
    confiavel = 'S'
    WHERE confiavel IS NULL;

-- Alteração linha viagem
ALTER TABLE linha_viagem
    ADD distancia_km NUMBER(4,1);

ALTER TABLE linha_viagem
    MODIFY distancia_km INTEGER;

-- Atualizacao linha viagem
UPDATE linha_viagem lvo
    SET lvo.distancia_km = (
        SELECT
            TRUNC(
                distancia(
                    lorig.nlatitude,
                    lorig.nlongitude,
                    ldest.nlatitude,
                    ldest.nlongitude
                )) * 1.2
        FROM linha_viagem lv
            JOIN localidade lorig
                ON (lv.id_origem = lorig.id_local)
            JOIN localidade ldest
                ON (lv.id_destino = ldest.id_local)
        WHERE lorig.nlatitude IS NOT NULL
            AND  ldest.nlatitude IS NOT NULL
            AND lvo.id_linha = lv.id_linha
    );

-- Aplicação de velocidade
DECLARE
    vspeed linha_viagem.distancia_km%TYPE;
    CURSOR c_velo IS
        SELECT
            v.rowid AS vRow,
            v.id_linha,
            lv.distancia_km AS Distancia,
            v.duracao_min AS Duracao
            FROM viagem v
            JOIN linha_viagem lv
                ON (v.id_linha = lv.id_linha)
            JOIN localidade lorig
                ON (lv.id_origem = lorig.id_local)
            JOIN localidade ldest
                ON (lv.id_destino = ldest.id_local)
            WHERE v.confiavel = 'S'
                AND lv.distancia_km IS NOT NULL;
BEGIN
    FOR k IN c_velo LOOP
        vspeed := ROUND(( k.Distancia/ k.duracao) * 60, 1);
        IF vspeed <= 120 THEN
            UPDATE viagem vg SET
                vg.velocidade = vspeed
                WHERE vg.rowid = k.vRow;
        ELSE
            UPDATE viagem vg SET
                vg.confiavel = 'N'
                WHERE vg.rowid = k.vRow;
        END IF;
    END LOOP;
END;

-- 7    Elabore uma procedure
--      com SQL dinâmica que
--      mostre um ranking das
--      linhas de viagens com
--      velocidade máxima,
--      mínima ou média para uma
--      determinada cidade de
--      origem, passando como
--      parâmetro parte do nome
--      dessacidade, a função
--      que será utilizada:
--      MIN, MAX ou AVG, o
--      número de ranqueadose
--      se vai usar RANK() ou
--      DENSE-RANK(). Por exemplo:
--      ranking das linhas com
--      as 10 maiores velocidades
--      tendo como origem São Paulo
--      e o ranking contínuo.
--      Mostrar o número da linha,
--      cidade destino, velocidade(
--      que poderão ser as maiores,
--      menores ou a média), posição
--      e ordem no ranking.

-- Definição de procedure ranking_linha_velocidade_din
CREATE OR REPLACE PROCEDURE ranking_linha_velocidade_din (
    vorigem IN VARCHAR2,
    vfuncao IN CHAR,
    vrank IN SMALLINT,
    vfuncaorank IN VARCHAR2,
    vorder IN CHAR
) IS TYPE vrkg_speed IS REF CURSOR;
    vCursor_speed vrkg_speed;
    vSQLdin VARCHAR2(1000);
    vaux1 VARCHAR2(50);
    vaux2uf VARCHAR2(10);
    vaux2 VARCHAR2(50);
    vaux3 VARCHAR2(10);
    vaux4 VARCHAR2(10);
    vaux5 VARCHAR2(10);
    BEGIN
        vSQLDin := '
            SELECT
                *
                FROM (
                    SELECT
                        lv.id_linha AS Linhavg,
                        ldest.cidade AS Cidade,
                        ldest.UF AS UF,
                        TRUNC(' || vfuncao || '(v.velocidade)) AS Velocidade,
                        ' || vfuncaorank || '() OVER (
                                ORDER BY ' || vfuncao || '(v.velocidade) ' || vorder || '
                            ) AS rkg,
                        ROW_NUMBER() OVER (
                            ORDER BY ' || vfuncao || '(v.velocidade) ' || vorder || ') AS ordem
                        FROM viagem v
                        JOIN linha_viagem lv
                            ON (v.id_linha = lv.id_linha)
                        JOIN localidade lorig
                            ON (lv.id_origem = lorig.id_local)
                        JOIN localidade ldest
                            ON (lv.id_destino = ldest.id_local)
                        WHERE UPPER(lorig.cidade) LIKE ' || q '['%]' || UPPER(vorigem) || q' [% ']' || '
                            AND v.velocidade IS NOT NULL
                        GROUP BY
                            lv.id_linha,
                            ldest.cidade,
                            ldest.UF
                ) rkg_speed
            WHERE rkg_speed.ordem <= ' || vrank;
        DBMS_OUTPUT.PUT_LINE(vSQLdin);
        DBMS_OUTPUT.PUT_LINE('Origem : ' || vorigem);
        DBMS_OUTPUT.PUT_LINE('Linha             Destino          Velocidade   Posicao  Ordem');
        DBMS_OUTPUT.PUT_LINE (RPAD('_', 100, '_'));
        OPEN vCursor_speed FOR vSQLdin;
        LOOP
        FETCH vCursor_speed INTO
            vaux1,
            vaux2,
            vaux2uf,
            vaux3,
            vaux4,
            vaux5;
        EXIT WHEN vCursor_speed%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(
                RPAD(vaux1, 15, ' ') ||
                '| ' ||
                RPAD(vaux2 || '-' || vaux2uf, 25, ' ') ||
                '|' ||
                RPAD(vaux3, 10, ' ') ||
                '|' ||
                RPAD(vaux4, 7, ' ') ||
                '|' ||
                vaux5
            );
            DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));
        END LOOP;
        CLOSE vCursor_speed;
    END;

-- Execução de procedure ranking_linha_velocidade_din
BEGIN
    ranking_linha_velocidade_din ('sao paulo', 'AVG', 30, 'RANK', 'DESC');
END;
