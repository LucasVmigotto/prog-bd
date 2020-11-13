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
