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
DROP TABLE local CASCADE CONSTRAINTS;
CREATE TABLE local (
    cod_local INTEGER PRIMARY KEY,
    cidade VARCHAR2(40) NOT NULL,
    uf CHAR(2) NOT NULL,
    latitude NUMBER(8,5) NOT NULL,
    longitude NUMBER(8,5) NOT NULL
);

-- 2.2  Tabela para linha de viagem e
--      seus respectivos dados (
--      identificador da linha, empresa,
--      referências aos respectivos
--      identificadores de origem e
--      destino, etc.)

-- 2.3  Tabela para a viagem(identificador da
--      viagem, linha, datas e horários e o
--      veículo utilizado)

-- 2.4  Converta todos os identificadores
--      hexadecimais em decimais
