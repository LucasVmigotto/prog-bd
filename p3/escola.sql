/* ######################################################## */
/*  FATEC Ipiranga - Análise e Desenvolvimento de Sistemas  */
/*  Programação para Banco de Dados - Prova P3              */
/*                                                          */
/*  Nome: Lucas Vidor Migotto                               */
/* ######################################################## */

-- Parâmetros da sessão
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';
ALTER SESSION SET NLS_LANGUAGE = PORTUGUESE;

-- Tabela disciplina
DROP TABLE disciplina CASCADE CONSTRAINTS;
CREATE TABLE disciplina (
    CodD CHAR(5) primary key,
    DNome VARCHAR2(30) ,
    Carga_horari NUMBER(2),
    CURSO CHAR(5)
);

-- Inserção disciplina
INSERT INTO disciplina VALUES ('CDI1','Calculo I',4, 'EE');
INSERT INTO disciplina VALUES ('CDI2','Calculo II',4, 'EE');
INSERT INTO disciplina VALUES ('CDI3','Calculo III',2, 'EE');
INSERT INTO disciplina VALUES ('AED1','Algoritmos 1',2, 'ADS');
INSERT INTO disciplina VALUES ('AED2','Algoritmos 2',4, 'ADS');
INSERT INTO disciplina VALUES ('AED3','Algoritmos 3',4, 'ADS');
INSERT INTO disciplina VALUES ('AED4','Algoritmos 4',4, 'ADS');
INSERT INTO disciplina VALUES ('BD1','Banco Dados 1',4, 'ADS');
INSERT INTO disciplina VALUES ('BD2','Banco Dados 2',4, 'ADS');
INSERT INTO disciplina VALUES ('CE1','Circuitos Eletricos 1',4, 'EE');
INSERT INTO disciplina VALUES ('ELM1','Eletromagnetismo 1',4, 'EE');
INSERT INTO disciplina VALUES ('ELM2','Eletromagnetismo 2',4, 'EE');
INSERT INTO disciplina VALUES ('LIH','Lab Int Hardware',6,'EGC');
INSERT INTO disciplina VALUES ('CON1','Sistemas de Controle 1',4,'EGC');
INSERT INTO disciplina VALUES ('CON2','Sistemas de Controle 2',4,'EGC');
INSERT INTO disciplina VALUES ('ADM1','Administracao 1',4, 'ADM');
INSERT INTO disciplina VALUES ('ADM2','Administracao 2',4, 'ADM');
INSERT INTO disciplina VALUES ('ADM3','Administracao 3',4, 'ADM');
INSERT INTO disciplina VALUES ('MATF','Matematica Financeira',2, 'ADM');
INSERT INTO disciplina VALUES ('MKT1','Principios de marketing',2, 'ADM');
INSERT INTO disciplina VALUES ('MAT1A','Matematica I',2, 'ADM');
INSERT INTO disciplina VALUES ('MAT1C','Matematica I',2, 'CC');

-- Tabela aluno
DROP TABLE  aluno CASCADE CONSTRAINTS;
CREATE TABLE aluno (
    RA NUMBER(5) PRIMARY KEY,
    ANome VARCHAR2(30),
    Sexo CHAR(1),
    Ano_ingresso CHAR(6),
    curso CHAR(15)
);

- Inserções aluno
INSERT INTO aluno VALUES (08001,'Jo�o Silva','M','2019-2','ADM');
INSERT INTO aluno VALUES (07016,'Maria Souza','F','2018-1','ADS' );
INSERT INTO aluno VALUES (07034,'Ari Santos','M','2018-1','EGC' );
INSERT INTO aluno VALUES (05237,'Rita Pereira','F','2019-1','EE');
INSERT INTO aluno VALUES (07001,'Jorge Silva','M','2018-1','ADM');
INSERT INTO aluno VALUES (05537,'Talita Pereira','F','2017-2','EE');
INSERT INTO aluno VALUES (07588,'WALTER Cruz','M','2018-1','EE');
INSERT INTO aluno VALUES (08002,'Jo�o Souza','M','2020-1','ADM');
INSERT INTO aluno VALUES (07017,'Maria Silva','F','2020-2','ADS' );
INSERT INTO aluno VALUES (07036,'Ari Peres','M','2020-2','EGC' );
INSERT INTO aluno VALUES (05239,'Rita Franca','F','2017-2','EE');
INSERT INTO aluno VALUES (08003,'Pedro Silva','M','2015-2','ADM');
INSERT INTO aluno VALUES (07019,'Carla Souza','F','2015-2','ADS' );
INSERT INTO aluno VALUES (07037,'Aldo Santos','M','2015-2','EGC' );
INSERT INTO aluno VALUES (05238,'Sandra Pereira','F','2017-2','EE');
INSERT INTO aluno VALUES (08004,'Ana Carolina Torres','F','2019-2','ADM');
INSERT INTO aluno VALUES (07021,'Tancredo Neves','M','2020-2','ADS' );
INSERT INTO aluno VALUES (07038,'Roberto Carlos Silva','M','2017-2','EGC' );
INSERT INTO aluno VALUES (05241,'Cristovao Cruz','M','2020-1','EE');

-- Tabela aluno_disciplina
DROP TABLE aluno_disciplina;
CREATE TABLE aluno_disciplina (
    RA NUMBER(5) NOT NULL,
    CodD CHARACTER(5) NO NULL,
    periodo_cursado CHARACTER(6) NOT NULL,
    P1 NUMBER(5,2),
    frequencia NUMBER(5,2),
    resultado CHARACTER(15),
    CONSTRAINT CURSA_PKE
        PRIMARY KEY (
            RA,
            CodD,
            periodo_cursado
        ),
    CONSTRAINT cursa_CodD_fkey
        FOREIGN KEY (CodD)
        REFERENCES disciplina(CodD)
        ON DELETE CASCADE,
    CONSTRAINT cursa_ra_fkey
        FOREIGN KEY (RA)
        REFERENCES aluno (RA)
        ON DELETE CASCADE
);

-- Inserções aluno disciplina
INSERT INTO aluno_disciplina VALUES (08001,'CDI1','2019-2',9.0,54,'ReproFalta');
INSERT INTO aluno_disciplina VALUES (07016,'CDI2','2018-1',7.5,83,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07034,'CDI1','2018-1',8.0,79,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (05237,'BD2','2019-1',6.5,89,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (08002,'AED3','2020-1',4.0,83,'ReproNota' );
INSERT INTO aluno_disciplina VALUES (07017,'BD1','2020-2',7.0,92, 'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07036,'CDI2','2020-2',8.0,69,'ReproFalta' );
INSERT INTO aluno_disciplina VALUES (05239,'AED1','2017-2',9.0,95, 'Aprovado');
INSERT INTO aluno_disciplina VALUES (08003,'BD1','2015-2',10.0,92,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07019,'CDI1','2015-2',5.0,67,'ReproFalta' );
INSERT INTO aluno_disciplina VALUES (07037,'AED2','2015-2',6.0,79, 'Aprovado');
INSERT INTO aluno_disciplina VALUES (05238,'CDI2','2017-2',4.5,83,'ReproNota' );
INSERT INTO aluno_disciplina VALUES (08002,'CDI1','2019-2',9.0,67,'ReproFalta');
INSERT INTO aluno_disciplina VALUES (07019,'CDI2','2018-1',7.5,89,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07036,'CDI1','2018-1',8.0,92,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (05238,'BD2','2019-1',6.5,79,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (08001,'AED3','2020-1',4.0,95,'ReproNota' );
INSERT INTO aluno_disciplina VALUES (07017,'BD2','2019-2',7.0,83, 'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07036,'CDI2','2019-2',8.0,54,'ReproFalta' );
INSERT INTO aluno_disciplina VALUES (05237,'AED1','2017-2',9.0,79, 'Aprovado');
INSERT INTO aluno_disciplina VALUES (08003,'BD2','2017-2',10.0,89,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07016,'CDI1','2015-2',5.0,67,'ReproFalta' );
INSERT INTO aluno_disciplina VALUES (07016,'CDI1','2005-1',6.0,92,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07037,'AED3','2017-2',6.0,83, 'Aprovado');
INSERT INTO aluno_disciplina VALUES (05239,'CDI2','2017-2',4.5,79,'ReproNota' );
INSERT INTO aluno_disciplina VALUES (08002,'CDI1','2020-1',9.0,92,'Aprovado');
INSERT INTO aluno_disciplina VALUES (08002,'CDI2','2020-1',9.5,89,'Aprovado');
INSERT INTO aluno_disciplina VALUES (07019,'CDI3','2020-2',7.5,95,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07036,'CDI3','2019-2',8.0,79,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (05238,'AED3','2015-2',6.5,83,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (08002,'BD2','2020-1',4.0,95,'ReproNota' );
INSERT INTO aluno_disciplina VALUES (07017,'AED2','2019-2',7.0,100, 'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07017,'AED3','2020-1',9.0,92, 'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07017,'AED4','2020-2',10.0,79, 'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07036,'CDI2','2020-1',7.0,89,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (05237,'AED3','2020-2',9.0,83, 'Aprovado');
INSERT INTO aluno_disciplina VALUES (08003,'AED2','2017-2',10.0,100,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07016,'CDI1','2019-1',6.0,100,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07037,'AED3','2015-2',3.0,79, 'ReproNota');
INSERT INTO aluno_disciplina VALUES (05239,'CDI2','2018-1',2.5,95,'ReproNota' );
INSERT INTO aluno_disciplina VALUES (07001,'ADM1','2018-1',10.0,89,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07001,'ADM2','2020-2',7.0,83,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07001,'ADM3','2019-2',6.0,92,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (05537,'CE1','2017-2',7.0,79,'Aprovado');
INSERT INTO aluno_disciplina VALUES (05537,'ELM1','2015-2',4.0,100,'ReproNota');
INSERT INTO aluno_disciplina VALUES (05537,'ELM1','2004-2',6.0,100,'Aprovado');
INSERT INTO aluno_disciplina VALUES (05537,'ELM2','2004-2',7.0,100,'Aprovado');
INSERT INTO aluno_disciplina VALUES (05537,'CDI1','2015-2',7.5,83,'Aprovado');
INSERT INTO aluno_disciplina VALUES (05537,'CDI2','2004-2',6.0,79,'ReproNota');
INSERT INTO aluno_disciplina VALUES (05537,'CDI2','2005-1',7.5,89,'Aprovado');
INSERT INTO aluno_disciplina VALUES (05537,'CDI3','2005-1',8.0,92,'Aprovado');
INSERT INTO aluno_disciplina VALUES (07588,'CDI1','2018-1',7.5,95,'Aprovado');
INSERT INTO aluno_disciplina VALUES (07588,'CDI2','2020-2',6.0,100,'ReproNota');
INSERT INTO aluno_disciplina VALUES (07588,'CDI2','2019-2',7.5,79,'Aprovado');
INSERT INTO aluno_disciplina VALUES (07588,'CDI3','2019-2',8.0,83,'Aprovado');
INSERT INTO aluno_disciplina VALUES (08004,'ADM1','2019-2',7.0,89, 'Aprovado');
INSERT INTO aluno_disciplina VALUES (08004,'ADM2','2020-1',5.0,100, 'ReproNota');
INSERT INTO aluno_disciplina VALUES (08004,'MATF','2020-1',2.0,100, 'ReproNota');
INSERT INTO aluno_disciplina VALUES (07021,'AED1','2020-2',6.0,79,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07021,'AED2','2019-2',8.0,83,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07021,'AED3','2017-2',6.5,95,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07021,'BD1','2020-1',6.0,89,'Repronota' );
INSERT INTO aluno_disciplina VALUES (07021,'BD1','2020-2',6.0,92,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07038,'CDI1','2017-2',3.5,79, 'ReproNota' );
INSERT INTO aluno_disciplina VALUES (07038,'CDI1','2018-1',6.5,95, 'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07038,'AED1','2018-1',7.0,83,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07038,'AED2','2020-2',8.0,95,'Aprovado' );
INSERT INTO aluno_disciplina VALUES (07038,'CON1','2020-1',1.0,79,'ReproNota' );
INSERT INTO aluno_disciplina VALUES (07038,'CON1','2020-2',2.0,54,'ReproFalta' );
INSERT INTO aluno_disciplina VALUES (05241,'CDI1','2020-1',6.5,89, 'Aprovado');
INSERT INTO aluno_disciplina VALUES (05241,'AED1','2020-1',7.5,79, 'Aprovado');
INSERT INTO aluno_disciplina VALUES (07001,'MAT1A','2020-2',7.5,79, 'Aprovado');

-- Alterações aluno_disciplina
ALTER TABLE aluno_disciplina
    ADD (
        P2 NUMBER(5,2),
        P3 NUMBER(5,2),
        MEDIA_FINA NUMBER(5,2)
    );

-- Atualizações aluno_disciplina
UPDATE aluno_disciplina
    SET P2 = P1 - 1;

UPDATE aluno_disciplina SET
    RESULTADO = 'Cursando'
    WHERE RTRIM(periodo_cursado) = '2020-2';

UPDATE aluno_disciplina
    SET media_final = (P1 + P2) / 2
    WHERE RTRIM(periodo_cursado) != '2020-2';

UPDATE aluno_disciplina
    SET P2 = media_final + 2
    WHERE RESULTADO = 'Aprovado'
        AND media_final < 6 ;

UPDATE aluno_disciplina
    SET P3 = media_final + 1
    WHERE RESULTADO = 'ReproNota'
        AND media_final < 6 ;

-- 1    Utilizando a linguagem
--      PL/SQL elabore um
--      controle para evitar que
--      um aluno curse uma carga
--      horária superior a 28 h/a
--      num determinado período,
--      ou seja, toda vez que
--      cadastrar um aluno para
--      uma disciplina em um
--      determinado período
--      verificar o total da
--      carga horária já cadastrado
--      no mesmo período e com a
--      nova disciplina para
--      respeitar o limite.

-- Definição de trigger verifica_carga_horaria
CREATE OR REPLACE TRIGGER verifica_carga_horaria
    BEFORE INSERT ON aluno_disciplina
    FOR EACH ROW
    DECLARE
        total_carga_horaria NUMBER(3);
        carga_horaria_disciplina disciplina.carga_horaria%TYPE;
        carga_horaria_atingida EXCEPTION;
    BEGIN
        SELECT
            SUM(d.carga_horaria)
            INTO total_carga_horaria
            FROM
                aluno a,
                disciplina d,
                aluno_disciplina ad
            WHERE ad.ra = a.ra
                AND ad.codd = d.codd
                AND ad.ra = :NEW.ra
                AND ad.periodo_cursado = :NEW.periodo_cursado;
        IF total_carga_horaria = 28 THEN
            RAISE carga_horaria_atingida;
        ELSE
            SELECT carga_horaria
                INTO carga_horaria_disciplina
                FROM disciplina
                WHERE codd = :NEW.codd;
            IF (total_carga_horaria + carga_horaria_disciplina) > 28 THEN
                RAISE carga_horaria_atingida;
            END IF;
        END IF;
        EXCEPTION
            WHEN carga_horaria_atingida THEN
                RAISE_APPLICATION_ERROR(
                    -20001,
                    'Carga horária total de disciplinas já atingida!'
                );
    END;

-- 2    Utilizando a linguagem
--      PL/SQL implemente um
--      controle para atualizar
--      o Resultado depois de
--      inserir ou atualizar as
--      notas P2 ou P3 e a
--      frequência, calculando
--      a média final do aluno
--      em uma disciplina,
--      conforme os seguintes
--      critérios:
--          * Aprovado:
--             MédiaFinal >= 6
--             Frequência >= 75
--          * ReproNota:
--             MédiaFinal < 6
--             Frequência >= 75
--             (no caso de P3 preenchida)
--          * Cursando:
--             MédiaFinal < 6
--             Frequência >= 75
--             (no caso de P3 ainda
--             não preenchida
--             (pode fazer ainda))
--          * ReproFalta:
--              Frequência < 75
--      Obs: Quando se matricula
--      o Resultado fica como
--      Cursando, até as notas
--      e frequência serem atualizadas

-- Definição de trigger atualiza_resultado
CREATE OR REPLACE TRIGGER atualiza_resultado
    BEFORE INSERT OR UPDATE ON aluno_disciplina
    FOR EACH ROW
    DECLARE
        media_final aluno_disciplina.media_final%TYPE;
    BEGIN
        IF :NEW.frequencia IS NOT NULL
            AND :NEW.p1 IS NOT NULL
            AND (:NEW.p2 IS NOT NULL OR :NEW.p3 IS NOT NULL)
        THEN

            IF :NEW.p3 IS NULL THEN
                media_final := (:NEW.p1 + :NEW.p2) / 2;
            ELSIF :NEW.p1 > :NEW.p2 THEN
                media_final := (:NEW.p1 + :NEW.p3) / 2;
            ELSE
                media_final := (:NEW.p2 + :NEW.p3) / 2;
            END IF;

            IF media_final >= 6
                AND :NEW.frequencia >= 75
            THEN
                :NEW.resultado := 'Aprovado';
            ELSIF media_final < 6
                AND :NEW.frequencia >= 75
                AND :NEW.p3 IS NOT NULL
            THEN
                :NEW.resultado := 'ReproNota';
            ELSIF   media_final < 6
                AND :NEW.frequencia >= 75
                AND :NEW.p3 IS  NULL
            THEN
                :NEW.resultado := 'Cursando';
            ELSIF :NEW.frequencia < 75 THEN
                :NEW.resultado := 'ReproFalta';
            END IF;
            :NEW.media_final := media_final;
        ELSE
            :NEW.resultado := 'Cursando';
        END IF;
    END;


-- 3    Utilizando a linguagem
--      PL/SQL e o SQL elabore
--      um controle para mostrar
--      um extrato das notas e
--      frequências de um aluno
--      para as disciplinas cursadas
--      atualmente (semestre atual),
--      passando como parâmetro
--      somente o RA do aluno.

-- Definição de procedure mostra_extrato_aluno
CREATE OR REPLACE PROCEDURE mostra_extrato_aluno (
    cod_ra aluno.ra%TYPE
) IS
    CURSOR dados_aluno(periodo VARCHAR2) IS
        SELECT
            a.ra,
            a.anome,
            a.curso,
            d.dnome,
            ad.p1,
            ad.p2,
            ad.p3,
            ad.frequencia,
            ad.resultado
            FROM aluno a,
                disciplina d,
                aluno_disciplina ad
            WHERE a.ra = ad.ra
                AND ad.codd = d.codd
                AND a.ra = cod_ra
                AND ad.periodo_cursado = periodo;
    ano_atual VARCHAR2(4);
    mes_atual VARCHAR2(2);
    periodo VARCHAR2(8);
    primeiro_loop INTEGER := 0;
    BEGIN
        SELECT
            TO_CHAR(SYSDATE, 'YYYY') ano,
            TO_CHAR(SYSDATE, 'MM') mes
            INTO
                ano_atual,
                mes_atual
            FROM DUAL;
        IF TO_NUMBER(mes_atual) <= 6 THEN
            periodo  := ano_atual || '-1';
        ELSE
            periodo  := ano_atual || '-2';
        END IF;
        FOR x IN dados_aluno(periodo) LOOP
            IF primeiro_loop = 0 THEN
                DBMS_OUTPUT.PUT_LINE(
                    RPAD(
                        'Aluno - ' ||
                            x.ra ||
                            ' - ' ||
                            x.anome,
                        35,
                        ' '
                    ) ||
                    RPAD(
                        'Curso: ' ||
                            x.curso,
                        35,
                        ' '
                    ) ||
                    'Semestre: ' ||
                    periodo
                );
                DBMS_OUTPUT.PUT_LINE(chr(13));
                DBMS_OUTPUT.PUT_LINE(LPAD('-',120, '-'));
                DBMS_OUTPUT.PUT_LINE(
                    RPAD('Disciplina', 35, ' ') ||
                    RPAD('P1 ', 10, ' ') ||
                    RPAD('P2 ', 10, ' ') ||
                    RPAD('P3 ', 10, ' ') ||
                    RPAD('Frequência', 15, ' ') ||
                    'Resultado '
                );
                DBMS_OUTPUT.PUT_LINE(chr(13));
                DBMS_OUTPUT.PUT_LINE(LPAD('-',120, '-'));
                primeiro_loop := 1;
            END IF;
            DBMS_OUTPUT.PUT_LINE(
                RPAD(x.dnome, 35, ' ') ||
                RPAD(x.p1, 10, ' ')  ||
                RPAD(x.p2, 10, ' ') ||
                RPAD(
                    NVL(TO_CHAR(x.p3), '-'),
                    10,
                    ' '
                ) ||
                RPAD(x.frequencia, 15, ' ') ||
                x.resultado
            );
        END LOOP;
    END;

-- 4    Utilizando a linguagem PL/SQL
--      refaça o controle da questão 3)
--      utilizando SQL dinâmico e como
--      saída um cursor de referência
--      para ser utilizado em qualquer
--      bloco anônimo. Como parâmetros
--      de entrada agora parte do nome
--      do aluno, ao invés do RA,
--      a situação da matrícula
--      (resultado). Faça os tratamentos
--      necessários. Mostre na saída
--      o Período cursado além das
--      notas e frequência.

-- Definição de procedure retorna_dados_aluno_din
CREATE OR REPLACE PROCEDURE retorna_dados_aluno_din (
    nome_parcial IN aluno.anome%TYPE,
    atual_resultado IN aluno_disciplina%TYPE
) IS
    TYPE aluno_resp IS REF CURSOR;
    v_aluno_resp aluno_resp;
    sql_din VARCHAR2(4000);
    nome_disciplina disciplina.dNome%TYPE;
    aluno_p1 aluno_disciplina.p1%TYPE;
    aluno_p2 aluno_disciplina.p2%TYPE;
    aluno_p3 aluno_disciplina.p3%TYPE;
    aluno_frequencia aluno_disciplina.frequencia%TYPE;
    aluno_resultado aluno_disciplina.resultado%TYPE;
    ano_atual VARCHAR2(4);
    mes_atual VARCHAR2(2);
    periodo VARCHAR2(8);
    primeiro_loop INTEGER := 0;
    BEGIN
        sql_din := '
            SELECT
                a.ra AS aluno_ra,
                a.anome AS nome_aluno,
                a.curso AS aluno_curso,
                d.dnome AS nome_disciplina,
                ad.p1 AS aluno_p1,
                ad.p2 AS aluno_p2,
                ad.p3 AS aluno_p3,
                ad.frequencia AS aluno_frequencia,
                ad.resultado AS aluno_resultado
                FROM
                    aluno a,
                    disciplina d,
                    aluno_disciplina ad
                WHERE a.anome LIKE %:a%
                    AND ad.resultado = :b
                    AND a.ra = ad.ra
                    AND ad.codd = d.codd';
        SELECT
            TO_CHAR(SYSDATE, 'YYYY') ano,
            TO_CHAR(SYSDATE, 'MM') mes
            INTO
                ano_atual,
                mes_atual
            FROM DUAL;
        IF TO_NUMBER(mes_atual) <= 6 THEN
            periodo  := ano_atual || '-1';
        ELSE
            periodo  := ano_atual || '-2';
        END IF;
        DBMS_OUTPUT.PUT_LINE(
            LPAD('-',120, '-')
        );
        DBMS_OUTPUT.PUT_LINE(
            RPAD('Disciplina', 30, ' ') ||
            RPAD('P1', 10, ' ') ||
            RPAD('P2', 10, ' ') ||
            RPAD('P3', 10, ' ') ||
            RPAD('Frequência', 30, ' ') ||
            RPAD('Resultado', 30, ' ')
        );
        DBMS_OUTPUT.PUT_LINE(
            LPAD('-',120, '-')
        );
        OPEN v_aluno_resp
            FOR sql_din
            USING
                nome_parcial,
                atualiza_resultado;
        LOOP
        FETCH v_aluno_resp
            INTO
                aluno_ra
                nome_aluno
                aluno_curso
                nome_disciplina
                aluno_p1
                aluno_p2
                aluno_p3
                aluno_frequencia
                aluno_resultado;
            EXIT WHEN v_aluno_resp%NOTFOUND;
            IF primeiro_loop = 0 THEN
                DBMS_OUTPUT.PUT_LINE(
                    RPAD(
                        'Aluno - ' ||
                            aluno_ra ||
                            ' - ' ||
                            nome_aluno,
                        35,
                        ' '
                    ) ||
                    RPAD(
                        'Curso: ' ||
                            aluno_curso,
                        35,
                        ' '
                    ) ||
                    'Semestre: ' ||
                    periodo
                );
                DBMS_OUTPUT.PUT_LINE(chr(13));
                DBMS_OUTPUT.PUT_LINE(
                    LPAD('-',120, '-')
                );
                DBMS_OUTPUT.PUT_LINE(
                    RPAD('Disciplina', 35, ' ') ||
                    RPAD('P1 ', 10, ' ') ||
                    RPAD('P2 ', 10, ' ') ||
                    RPAD('P3 ', 10, ' ') ||
                    RPAD('Frequência', 15, ' ') ||
                    'Resultado '
                );
                DBMS_OUTPUT.PUT_LINE(chr(13));
                DBMS_OUTPUT.PUT_LINE(LPAD('-',120, '-'));
                primeiro_loop := 1;
            END IF;
            DBMS_OUTPUT.PUT_LINE(
                RPAD(nome_disciplina, 35, ' ') ||
                RPAD(aluno_p1, 10, ' ') ||
                RPAD(aluno_p2, 10, ' ') ||
                RPAD(aluno_p3, 10, ' ') ||
                RPAD(aluno_frequencia, 15, ' ') ||
                RPAD(aluno_resultado, 30, ' ')
            );
        END LOOP;
        CLOSE v_aluno_resp;
    END;
