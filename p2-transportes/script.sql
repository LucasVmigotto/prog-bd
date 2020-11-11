DROP SEQUENCE seq_local;
DROP TABLE base CASCADE CONSTRAINTS;
DROP TABLE origem CASCADE CONSTRAINTS;
DROP TABLE destino CASCADE CONSTRAINTS;
DROP TABLE localidade CASCADE CONSTRAINTS;
DROP TABLE linha_viagem CASCADE CONSTRAINTS;
DROP TABLE viagem CASCADE CONSTRAINTS;
DROP TABLE brasil_csv CASCADE CONSTRAINTS;
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
            num_linha AS Numero_Linha,
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
                AND TRIM(UPPER(lv.origem_uf))=TRIM(l.UF)
    );

-- destino
UPDATE linha_viagem lv SET
    lv.id_destino=(
        SELECT l.id_local
            FROM localidade l
                WHERE TRIM(UPPER(lv.destino_cidade))=TRIM(l.cidade)
                    AND TRIM(UPPER(lv.destino_uf))=TRIM(l.UF)
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

-- Tabela brasil_csv
DROP TABLE brasil_csv CASCADE CONSTRAINTS;
CREATE TABLE brasil_csv (
    ibge VARCHAR2(30),
    municipio VARCHAR2(50),
    latitude VARCHAR2(30),
    longitude VARCHAR2(30),
    cod_estado VARCHAR2(30),
    estado VARCHAR2(30),
    uf VARCHAR2(30),
    regiao VARCHAR2(30),
    capital VARCHAR2(30)
);
-- TRUNCATE TABLE brasil_csv;

-- Localidade
ALTER TABLE localidade
    ADD (
        latitude VARCHAR2(30),
        longitude VARCHAR2(30)
    );

UPDATE localidade l SET
    latitude=(
        SELECT bc.latitude
            FROM brasil_csv bc
            WHERE l.cidade=UPPER(bc.municipio)
                AND l.uf=UPPER(bc.uf)
    );

UPDATE localidade l SET
    longitude=(
        SELECT bc.longitude
            FROM brasil_csv bc
            WHERE l.cidade=UPPER(bc.municipio)
                AND l.uf=UPPER(bc.uf)
    );

-- 4    Utilizando a linguagem
--      SQL responda à seguintes
--      consultas:

-- 4.1  Mostre um ranking das
--      cidades destino das
--      viagens: Cidade Destino
--      – Qtde Viagens - Posição


-- 4.2  Refaça a consulta 4.1
--      acima incluindo o mês-ano
--      e limitando aos 5 primeiros
--      destinos em cada mês


-- 4.3  Monte um ranking da quantidade
--      de viagens por cidade e UF de
--      origem acada mês-ano, mostrando
--      o total por mês, cidade e UF
--      (ou seja, de onde mais
--      saem viagens)


-- 4.4  Mostre um ranking das viagens
--      com média de duração mais
--      demoradas: Origem-destino -
--      Duração Média em horas,
--      exibindo também a próxima
--      e a anterior


-- 4.5  Refaça a consulta 4.4 acima
--      mostrando agora por UF e
--      somente para viagens dentro
--      do mesmo estado (estaduais).


-- 5    Utilizando a linguagem PL/SQL
--      transforme a consulta 4.2
--      acima em uma procedure que
--      permita entrar o período
--      (data inicial e final) e o
--      número de posições no ranking
--      de cada mês
