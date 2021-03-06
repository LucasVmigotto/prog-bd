/* Setup de Ambiente */
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';
ALTER SESSION SET NLS_LANGUAGE = PORTUGUESE;
SELECT SESSIONTIMEZONE, CURRENT_TIMESTAMP FROM DUAL;

/* Sequências */
-- Pedido
DROP SEQUENCE pedido_seq;
CREATE SEQUENCE pedido_seq MINVALUE 1 MAXVALUE 9999999 INCREMENT BY 1 START WITH 2020;

-- Produto
DROP SEQUENCE produto_seq;
CREATE SEQUENCE produto_seq MINVALUE 1 MAXVALUE 9999999 INCREMENT BY 1 START WITH 5000;

/* Tabela Região */
-- Criação
DROP TABLE regiao CASCADE CONSTRAINTS;
CREATE TABLE regiao (
    cod_regiao NUMBER(2),
    nome_regiao VARCHAR2(50)
    CONSTRAINT reg_nome_nn NOT NULL,
    CONSTRAINT reg_cod_pk PRIMARY KEY (cod_regiao),
    CONSTRAINT reg_nome_uk UNIQUE (nome_regiao)
);
-- Inserts
INSERT INTO regiao VALUES (1, 'America do Norte');
INSERT INTO regiao VALUES (2, 'America do Sul');
INSERT INTO regiao VALUES (3, 'America Central');
INSERT INTO regiao VALUES (4, 'Africa');
INSERT INTO regiao VALUES (5, 'Asia');
INSERT INTO regiao VALUES (6, 'Europa');

/* Tabela Cliente */
-- Criação
DROP TABLE cliente CASCADE CONSTRAINTS;
CREATE TABLE cliente (
    cod_cli INTEGER,
    limite_credito NUMBER(12,2),
    endereco_cli VARCHAR2(400),
    fone_cli CHAR(15),
    situacao_cli CHAR(20),
    tipo_cli CHAR(20),
    cod_regiao NUMBER(2) REFERENCES regiao,
    CONSTRAINT cliente_cod_pk PRIMARY KEY (cod_cli)
);
-- Alterações
ALTER TABLE cliente
 ADD CONSTRAINT chk_tp_cli CHECK ( tipo_cli IN ('PF', 'PJ'));

/* Tabela Cliente Pessoa Física */
-- Criação
DROP TABLE cliente_pf CASCADE CONSTRAINTS;
CREATE TABLE cliente_pf (
    cod_cli_pf INTEGER REFERENCES cliente ON DELETE CASCADE,
    nome_fantasia VARCHAR2(50) CONSTRAINT cliente_nome_nn NOT NULL,
    cpf_cli CHAR(11) not null UNIQUE,
    sexo_cli CHAR(1) not null CHECK (sexo_cli IN ('M', 'F')),
    profissao_cli CHAR(15),
    CONSTRAINT cli_pf_pk PRIMARY KEY (cod_cli_pf)
);

/* Tabela Cliente Jurídica */
-- Criação
DROP TABLE cliente_pj CASCADE CONSTRAINTS;
CREATE TABLE cliente_pj (
    cod_cli_pj INTEGER REFERENCES cliente ON DELETE CASCADE,
    razao_social_cli VARCHAR2(50) CONSTRAINT cliente_rzsoc_nn NOT NULL,
    cnpj_cli CHAR(14) not null UNIQUE,
    ramo_atividade_cli CHAR(15),
    CONSTRAINT cli_pj_pk PRIMARY KEY (cod_cli_pj)
);

/* Tabela Funcionário */
-- Criação
DROP TABLE funcionario CASCADE CONSTRAINTS;
CREATE TABLE funcionario (
    cod_func NUMBER(7),
    nome_func VARCHAR2(25) CONSTRAINT func_nome_nn NOT NULL,
    end_func VARCHAR2(80) NOT NULL,
    sexo_func CHAR(1) CHECK ( sexo_func IN ('M', 'F')),
    dt_admissao DATE,
    cargo CHAR(20) NOT NULL,
    depto CHAR(20) NOT NULL,
    cod_regiao INTEGER NOT NULL REFERENCES regiao,
    CONSTRAINT func_pk PRIMARY KEY (cod_func)
);

/* Tabela Deposito */
-- Criação
DROP TABLE deposito CASCADE CONSTRAINTS;
CREATE TABLE deposito (
    cod_depo NUMBER(3) CONSTRAINT deposito_cod_pk PRIMARY KEY ,
    nome_depo VARCHAR2(30) NOT NULL,
    end_depo VARCHAR2(100),
    cidade_depo VARCHAR2(30),
    pais_depo CHAR(20),
    cod_regiao INTEGER NOT NULL REFERENCES regiao,
    cod_func_gerente_depo NUMBER(7) REFERENCES funcionario
);

/* Tabela Produto */
-- Criação
DROP TABLE produto CASCADE CONSTRAINTS;
CREATE TABLE produto (
    cod_prod NUMBER(7) CONSTRAINT prod_cod_pk PRIMARY KEY,
    nome_prod VARCHAR2(50) CONSTRAINT prod_nome_nn NOT NULL,
    descr_prod VARCHAR2(255),
    categ_esporte CHAR(20),
    preco_venda NUMBER(11, 2),
    preco_custo NUMBER(11, 2),
    peso NUMBER(5,2),
    marca CHAR(15) NOT NULL,
    CONSTRAINT prod_nome_uq UNIQUE (nome_prod)
);
-- Alterações
ALTER TABLE produto ADD tamanho CHAR(3);

/* Tabela Pedido */
-- Criação
DROP TABLE pedido CASCADE CONSTRAINTS;
CREATE TABLE pedido (
    num_ped INTEGER CONSTRAINT ped_cod_pk PRIMARY KEY,
    dt_hora_ped TIMESTAMP NOT NULL,
    tp_atendimento CHAR(10),
    vl_total_ped NUMBER(11, 2),
    vl_descto_ped NUMBER(11, 2),
    vl_frete_ped NUMBER(11, 2),
    end_entrega VARCHAR2(80),
    forma_pgto CHAR(20),
    cod_cli INTEGER NOT NULL REFERENCES cliente,
    cod_func_vendedor NUMBER(7) REFERENCES funcionario
);

/* Tabela Armazenamento */
-- Criação
DROP TABLE armazenamento CASCADE CONSTRAINTS;
CREATE TABLE armazenamento (
    cod_depo NUMBER(3) NOT NULL REFERENCES deposito ON DELETE CASCADE,
    cod_prod NUMBER(7) NOT NULL REFERENCES produto ON DELETE CASCADE,
    qtde_estoque NUMBER(5),
    end_estoque VARCHAR2(25),
    CONSTRAINT armazenamento_pk PRIMARY KEY (cod_depo, cod_prod)
);

/* Tabela Items Pedido */
-- Criação
DROP TABLE itens_pedido CASCADE CONSTRAINTS;
CREATE TABLE itens_pedido (
    num_ped INTEGER REFERENCES pedido (num_ped) ON DELETE CASCADE,
    cod_prod NUMBER(7) REFERENCES produto (cod_prod) ON DELETE CASCADE,
    qtde_itens_pedido NUMBER(3),
    descto_itens_pedido NUMBER(5,2) ,
    CONSTRAINT itemped_pk PRIMARY KEY (num_ped, cod_prod)
);

/* Tabela País */
-- Criação
DROP TABLE pais CASCADE CONSTRAINTS;
CREATE TABLE pais (
    sigla_pais CHAR(3) PRIMARY KEY,
    nome_pais VARCHAR2(50) NOT NULL
);
-- Inserts
INSERT INTO pais VALUES ( 'BRA' , 'Brasil');
INSERT INTO pais VALUES ( 'EUA' , 'Estados Unidos da America');
INSERT INTO pais VALUES ( 'JAP' , 'Japao');
INSERT INTO pais VALUES ( 'ALE' , 'Alemanha');
INSERT INTO pais VALUES ( 'GBR' , 'Gra-Bretanha');
INSERT INTO pais VALUES ( 'IND' , 'India');
INSERT INTO pais VALUES ( 'CHI' , 'China');
INSERT INTO pais VALUES ( 'FRA' , 'Franca');
INSERT INTO pais VALUES ( 'ESP' , 'Espanha');
INSERT INTO pais VALUES ( 'ARG' , 'Argentina');
INSERT INTO pais VALUES ( 'URU' , 'Uruguai');
INSERT INTO pais VALUES ( 'POR' , 'Portugal');
INSERT INTO pais VALUES ( 'ITA' , 'Italia');
INSERT INTO pais VALUES ( 'COR' , 'Coreia do Sul');
INSERT INTO pais VALUES ( 'CAN' , 'Canada');

/* Tabela Marca */
-- Criação
DROP TABLE marca cascade constraints;
CREATE TABLE marca (
    sigla_marca CHAR(3) NOT NULL constraint fabr_sigla_pk PRIMARY KEY,
    nome_marca VARCHAR2(30) NOT NULL,
    pais_marca CHAR(3) NOT NULL REFERENCES pais (sigla_pais)
);
-- Inserts
INSERT INTO marca VALUES ('NIK' , 'NIKE' , 'EUA');
INSERT INTO marca VALUES ('MZN' , 'MIZUNO' , 'JAP');
INSERT INTO marca VALUES ('ADI' , 'ADIDAS' , 'ALE');
INSERT INTO marca VALUES ('RBK' , 'REBOOK' , 'EUA');
INSERT INTO marca VALUES ('PUM' , 'PUMA' , 'ALE');
INSERT INTO marca VALUES ('TIM' , 'TIMBERLAND' , 'EUA');
INSERT INTO marca VALUES ('WLS' , 'WILSON' , 'EUA');
INSERT INTO marca VALUES ('UMB' , 'UMBRO' , 'GBR');
INSERT INTO marca VALUES ('ASI' , 'ASICS' , 'JAP');
INSERT INTO marca VALUES ('PEN' , 'PENALTY' , 'BRA');
INSERT INTO marca VALUES ('UAR' , 'UNDER ARMOUR' , 'EUA');
INSERT INTO marca VALUES ('LOT' , 'LOTO' , 'ITA');
-- Alterações
ALTER TABLE produto MODIFY marca CHAR(3) REFERENCES marca ( sigla_marca);

/* Tabela Categorai Esportiva */
-- Criação
DROP TABLE categ_esporte cascade constraints;
CREATE TABLE categ_esporte (
    categ_esporte CHAR(4) NOT NULL constraint mod_tp_pk PRIMARY KEY,
    nome_esporte VARCHAR2(30) NOT NULL
);
-- Inserts
INSERT INTO categ_esporte VALUES ('FUTB' , 'Futebol de campo');
INSERT INTO categ_esporte VALUES ('BASQ' , 'Basquetebol');
INSERT INTO categ_esporte VALUES ('VOLQ' , 'Voleibol de quadra');
INSERT INTO categ_esporte VALUES ('CORR' , 'Corrida e Caminhada');
INSERT INTO categ_esporte VALUES ('TENQ' , 'Tenis de quadra');
INSERT INTO categ_esporte VALUES ('MARC' , 'Artes Marciais');
INSERT INTO categ_esporte VALUES ('CASU' , 'Casual');
INSERT INTO categ_esporte VALUES ('SKAT' , 'Skate');
-- Alterações
ALTER TABLE produto MODIFY categ_esporte CHAR(4) REFERENCES categ_esporte ( categ_esporte);
ALTER TABLE produto MODIFY categ_esporte NOT NULL;

/* Tabela Cargo */
-- Criação
DROP TABLE cargo CASCADE CONSTRAINTS;
CREATE TABLE cargo (
    cod_cargo NUMBER(2) CONSTRAINT cargo_cargo_pk PRIMARY KEY,
    nome_cargo VARCHAR2(25)
);
-- Inserts
INSERT INTO cargo VALUES (01, 'Presidente');
INSERT INTO cargo VALUES (02, 'Vendedor');
INSERT INTO cargo VALUES (03, 'Operador de Estoque');
INSERT INTO cargo VALUES (04, 'VP, Administracao');
INSERT INTO cargo VALUES (05, 'VP, Financeiro');
INSERT INTO cargo VALUES (06, 'Auxiliar Administrativo');
INSERT INTO cargo VALUES (07, 'Atendente');
INSERT INTO cargo VALUES (08, 'Gerente de Deposito');
INSERT INTO cargo VALUES (09, 'Gerente de Vendas');
INSERT INTO cargo VALUES (10, 'Gerente Financeiro');
INSERT INTO cargo VALUES (11, 'Gerente Tecnologia');
INSERT INTO cargo VALUES (12, 'Analista Suporte');
INSERT INTO cargo VALUES (13, 'Desenvolvedor');
-- Alterações
ALTER TABLE funcionario MODIFY cargo NUMBER(2) REFERENCES cargo;
ALTER TABLE funcionario RENAME COLUMN cargo TO cod_cargo;

/* Tabela Departamento */
-- Criação
DROP TABLE departamento CASCADE CONSTRAINTS;
CREATE TABLE departamento (
    cod_depto NUMBER(7),
    nome_depto VARCHAR2(30) CONSTRAINT depto_nome_nn NOT NULL,
    cod_regiao NUMBER(2) REFERENCES regiao (cod_regiao),
    CONSTRAINT depto_cod_pk PRIMARY KEY (cod_depto)
);
-- Inserts
INSERT INTO departamento VALUES (10, 'Financeiro', 1);
INSERT INTO departamento VALUES (11, 'Financeiro', 2);
INSERT INTO departamento VALUES (12, 'Financeiro', 3);
INSERT INTO departamento VALUES (13, 'Financeiro', 4);
INSERT INTO departamento VALUES (14, 'Financeiro', 5);
INSERT INTO departamento VALUES (31, 'Vendas', 1);
INSERT INTO departamento VALUES (32, 'Vendas', 2);
INSERT INTO departamento VALUES (33, 'Vendas', 3);
INSERT INTO departamento VALUES (34, 'Vendas', 4);
INSERT INTO departamento VALUES (35, 'Vendas', 5);
INSERT INTO departamento VALUES (36, 'Vendas', 6);
INSERT INTO departamento VALUES (41, 'Estoque', 1);
INSERT INTO departamento VALUES (42, 'Estoque', 2);
INSERT INTO departamento VALUES (43, 'Estoque', 3);
INSERT INTO departamento VALUES (44, 'Estoque', 4);
INSERT INTO departamento VALUES (45, 'Estoque', 5);
INSERT INTO departamento VALUES (50, 'Administracao', 1);
INSERT INTO departamento VALUES (51, 'Administracao', 2);
INSERT INTO departamento VALUES (22, 'Tecnologia da Informacao', 1);
INSERT INTO departamento VALUES (23, 'Tecnologia da Informacao', 2);
-- Alterações
ALTER TABLE funcionario MODIFY depto NUMBER(7) REFERENCES departamento;
ALTER TABLE funcionario RENAME COLUMN depto TO cod_depto;

/* Tabela Forma de Pagamento */
-- Criação
DROP TABLE forma_pgto CASCADE CONSTRAINTS;
CREATE TABLE forma_pgto (
    cod_forma CHAR(6) PRIMARY KEY,
    descr_forma_pgto VARCHAR2(30)
);

-- Inserts
INSERT INTO forma_pgto VALUES ( 'DIN', 'Dinheiro');
INSERT INTO forma_pgto VALUES ( 'CTCRED', 'Cartao de Credito');
INSERT INTO forma_pgto VALUES ( 'TICKET', 'Vale refeicao');
INSERT INTO forma_pgto VALUES ( 'DEBITO', 'Debito em conta');

-- Alterações (pedido)
ALTER TABLE pedido MODIFY forma_pgto CHAR(6) REFERENCES forma_pgto;
ALTER TABLE pedido MODIFY forma_pgto NOT NULL;

-- Alterações (funcionario)
ALTER TABLE funcionario
 ADD cod_func_gerente NUMBER(7) REFERENCES funcionario (cod_func);

-- Alterações (deposito)
ALTER TABLE deposito MODIFY pais_depo CHAR(3) REFERENCES pais;

-- Alterações (pedido)
ALTER TABLE pedido ADD situacao_ped CHAR(15) CHECK
( situacao_ped IN ('APROVADO', 'REJEITADO', 'EM SEPARACAO', 'DESPACHADO', 'ENTREGUE', 'CANCELADO'));

-- Alterações (cliente)
ALTER TABLE cliente ADD pais_cli CHAR(3) REFERENCES pais;
ALTER TABLE funcionario ADD pais_func CHAR(3) REFERENCES pais;

-- Verificação de Constraints
ALTER TABLE cliente ADD CHECK ( situacao_cli IN ('ATIVO', 'INATIVO', 'SUSPENSO'));

-- Preço maior ou igual a preço de custo
ALTER TABLE produto ADD CHECK ( preco_venda >= preco_custo);

-- Valores e quantidades nunca com valor negativo
ALTER TABLE produto ADD CHECK ( preco_venda >= 0);
ALTER TABLE produto ADD CHECK ( preco_custo >= 0);
ALTER TABLE pedido ADD CHECK ( vl_total_ped >= 0);
ALTER TABLE pedido ADD CHECK ( vl_descto_ped >= 0);
ALTER TABLE pedido ADD CHECK ( vl_frete_ped >= 0);
ALTER TABLE itens_pedido ADD CHECK ( qtde_itens_pedido > 0);

-- Renomeando coluna
ALTER TABLE itens_pedido RENAME COLUMN qtde_itens_pedido to qtde_pedida;
ALTER TABLE itens_pedido RENAME COLUMN descto_itens_pedido to descto_item;

-- Coluna CHAR para VARCHAR;
ALTER TABLE cliente_pf MODIFY profissao_cli VARCHAR2(20);

-- Valores default para todas as colunas que indiquem Valor e para a data e hora do pedido.
ALTER TABLE pedido MODIFY vl_descto_ped DEFAULT 0.0;

/* Massa de dados */
-- Clientes
INSERT INTO cliente VALUES ( 200, 1000, '72 Via Bahia', '123456', 'ATIVO', 'PF', 2, 'BRA');
INSERT INTO cliente VALUES ( 201, 2000, '6741 Takashi Blvd.', '81-20101','ATIVO','PJ', 5, 'JAP');
INSERT INTO cliente VALUES ( 202, 5000, '11368 Chanakya', '91-10351', 'ATIVO','PJ', 5, 'IND');
INSERT INTO cliente VALUES ( 203, 2500, '281 King Street', '1-206-104-0103', 'ATIVO','PJ', 1,'EUA');
INSERT INTO cliente VALUES ( 204, 3000, '15 Henessey Road', '852-3692888','ATIVO','PJ', 5,'CHI' );
INSERT INTO cliente VALUES ( 205, 4000, '172 Rue de Rivoli', '33-2257201', 'ATIVO','PJ', 6,'FRA');
INSERT INTO cliente VALUES ( 206, 1800, '6 Saint Antoine', '234-6036201', 'ATIVO','PJ', 6,'FRA');
INSERT INTO cliente VALUES ( 207, 3800, '435 Gruenestrasse', '49-527454','ATIVO','PJ', 6,'ALE');
INSERT INTO cliente VALUES ( 208, 6000, '792 Playa Del Mar','809-352689', 'ATIVO','PJ', 6,'ESP');
INSERT INTO cliente VALUES ( 209, 3000, '3 Via Saguaro', '52-404562', 'ATIVO','PF', 6,'ESP');
INSERT INTO cliente VALUES ( 210, 3500, '7 Modrany', '42-111292','ATIVO','PF', 6,'ALE' );
INSERT INTO cliente VALUES ( 211, 5500, '2130 Granville', '52-1876292','ATIVO','PJ', 1,'CAN' );
INSERT INTO cliente VALUES ( 212, 4200, 'Via Rosso 677', '72-2311292','ATIVO','PF', 6,'ITA' );
INSERT INTO cliente VALUES ( 213, 3200, 'Libertad 400', '97-311543','ATIVO','PF', 2,'ARG' );
INSERT INTO cliente VALUES ( 214, 2100, 'Maldonado 120', '96-352943','ATIVO','PJ', 2,'URU' );

-- Pessoa Física
INSERT INTO cliente_pf VALUES ( 200, 'Joao Avila', 033123, 'M', 'Arquiteto');
INSERT INTO cliente_pf VALUES ( 209, 'Katrina Shultz', 173623, 'F', 'Medica');
INSERT INTO cliente_pf VALUES ( 210, 'Gunter Schwintz', 826363, 'M', 'Professor');
INSERT INTO cliente_pf VALUES ( 212, 'Luigi Forlani', 876521, 'M', 'Maestro');
INSERT INTO cliente_pf VALUES ( 213, 'Sabrina Lescano', 562378, 'F', 'Designer');

-- Pessoa Jurídica
INSERT INTO cliente_pj VALUES ( 201, 'Hamses Distribuidora SC', 7654321, 'Distribuidora');
INSERT INTO cliente_pj VALUES ( 202, 'Ementhal Comercio Ltda', 9876321, 'Comercio');
INSERT INTO cliente_pj VALUES ( 203, 'Picture Bow', 9865411, 'Comercio');
INSERT INTO cliente_pj VALUES ( 204, 'Saturn Sports INC', 73634646, 'Comercio');
INSERT INTO cliente_pj VALUES ( 205, 'Ping Tong Sam', 35352656, 'Comercio');
INSERT INTO cliente_pj VALUES ( 206, 'Pasadena Esportes', 73657126, 'Comercio');
INSERT INTO cliente_pj VALUES ( 207, 'Weltashung Sportif', 187908098, 'Comercio');
INSERT INTO cliente_pj VALUES ( 208, 'Random Realey Company', 76325943, 'Comercio');
INSERT INTO cliente_pj VALUES ( 211, 'London Drugs', 16721563, 'Comercio');
INSERT INTO cliente_pj VALUES ( 214, 'Empanadas con Vino', 90312876, 'Distribuidora');

-- ALterações (cliente)
ALTER TABLE cliente ADD nome_fantasia VARCHAR2(30);

UPDATE cliente c
    SET c.nome_fantasia = (
        SELECT SUBSTR(nome_fantasia, 1, INSTR(nome_fantasia,' ')- 1)
        FROM cliente_pf
        WHERE cod_cli_pf = c.cod_cli
    )
    WHERE c.tipo_cli = 'PF';

UPDATE cliente c
    SET c.nome_fantasia = (
        SELECT SUBSTR(razao_social_cli, 1, INSTR(razao_social_cli,' ')- 1)
        FROM cliente_pj
        WHERE cod_cli_pj = c.cod_cli
    )
    WHERE c.tipo_cli = 'PJ';

-- Alterações (funcionario)
ALTER TABLE funcionario ADD salario NUMBER(10,2);

-- Funionário
INSERT INTO funcionario VALUES ( 1, 'Alessandra Mariano', 'Rua A,10', 'F', '03-03-2000', 11,12, 3, null, 'BRA', 2100);
INSERT INTO funcionario VALUES ( 2, 'James Smith', 'Rua B,20', 'M', '08-03-2000', 10, 12, 3, null, 'EUA', 6000);
INSERT INTO funcionario VALUES ( 3, 'Kraus Schumann', 'Rua C,100','M', '17-06-2000', 10, 36, 6, 2, 'ALE',4200 );
INSERT INTO funcionario VALUES ( 4, 'Kurota Issa', 'Rua D,23', 'F','07-04-2000', 2, 35, 5 , null, 'JAP',6450);
INSERT INTO funcionario VALUES ( 5, 'Cristina Moreira', 'Rua Abc,34', 'F','04-03-2000', 3, 35, 5, 4, 'BRA', 4000);
INSERT INTO funcionario VALUES ( 6, 'Jose Silva', 'Av. Sete, 10', 'M','18-01-2001', 12, 41,3, NULL, 'BRA', 3200);
INSERT INTO funcionario VALUES ( 7, 'Roberta Pereira', 'Largo batata, 200', 'F','14-05-2000', 12, 33, 3, 1, 'EUA', 5300);
INSERT INTO funcionario VALUES ( 8, 'Alex Alves', 'Rua Dabliu, 10','M','07-04-2000', 2, 12, 1, 3, 'BRA', 2900);
INSERT INTO funcionario VALUES ( 9, 'Isabela Matos', 'Rua Ipsilone, 20', 'F','09-02-2001',2, 42, 6,4, 'EUA', 3200);
INSERT INTO funcionario VALUES (10, 'Matheus De Matos','Av. Beira-Mar, 300', 'M','27-02-2001', 2, 51,5,2, 'ESP',4000);
INSERT INTO funcionario VALUES (11, 'Wilson Borga', 'Travessa Circular', 'M','14-05-2000', 2, 33, 3,3,'BRA', 3150);
INSERT INTO funcionario VALUES (12, 'Marco Rodrigues', 'Rua Beta, 20', 'M', '18-01-2000', 8, 43, 1, 1, 'URU', 3400);
INSERT INTO funcionario VALUES (13, 'Javier Hernandez', 'Calle Sur, 20','M', '18-02-2000', 3, 51, 3, 3, 'ARG', 4210);
INSERT INTO funcionario VALUES (14, 'Chang Shung Dao', 'Dai Kai, 300', 'F', '22-01-2001', 10, 12, 2, 2, 'CHI', 3980);
INSERT INTO funcionario VALUES (15, 'Simon Holowitz', '19th Street','M', '09-10-2001',3, 14, 6, 6, 'GBR', 5460);
INSERT INTO funcionario VALUES (16, 'Penelope Xavier', 'Calle Paraguay, 20', 'F', '12-11-2003', 8, 43, 1, 1, 'URU', 2400);
INSERT INTO funcionario VALUES (17, 'Esmeralda Soriano', 'Calle Peru, 40','F', '18-12-2006', 3, 51, 3, 3, 'ARG', 4710);
INSERT INTO funcionario VALUES (18, 'Ari Gato Sam', 'Yakisoba, 300', 'M', '21-01-2011', 10, 12, 2, 2, 'CHI', 1980);
INSERT INTO funcionario VALUES (19, 'Hannah Arendt', '22th South Avenue','F', '19-11-2011',3, 14, 6, 6, 'CAN', 4460);

-- Deposito
INSERT INTO deposito VALUES ( 101, 'Warehouse Bull', '283 King Street', 'Seattle', 'EUA', 1, 1);
INSERT INTO deposito VALUES ( 105, 'Deutsch Store','Friederisch Strasse', 'Berlim','ALE',6, 3);
INSERT INTO deposito VALUES ( 201, 'Santao','68 Via Anchieta', 'Sao Paulo', 'BRA', 2, 7);
INSERT INTO deposito VALUES ( 301, 'NorthWare', '6921 King Way', 'Nova Iorque', 'EUA', 1, 8);
INSERT INTO deposito VALUES ( 401, 'Daiso Han', '86 Chu Street', 'Tokio', 'JAP', 5, 9);
INSERT INTO deposito VALUES ( 302, 'RailStore', '234 Richards', 'Vancouver', 'CAN', 1, 8);
INSERT INTO deposito VALUES ( 402, 'Daiwu Son', 'Heyjunka 200', 'Seul', 'COR', 5, 9);

-- Produto
INSERT INTO produto VALUES (produto_seq.nextval, 'Chuteira Total 90', 'Chuteira Total 90 Shoot TF', 'FUTB', 169, 132, 290,'NIK', null);
INSERT INTO produto VALUES (produto_seq.nextval, 'Chuteira Absolado TRX', 'Chuteira Absolado TRX FG', 'FUTB',279,210,321, 'ADI', null );
INSERT INTO produto VALUES (produto_seq.nextval, 'Agasalho Total 90', 'Agasalho Total 90', 'FUTB',199,121,420, 'NIK', null);
INSERT INTO produto VALUES (produto_seq.nextval, 'Bola Copa do Mundo', 'Bola Futebol Copa do Mundo Oficial 2006', 'FUTB',56.25,32,390, 'ADI', null );
INSERT INTO produto VALUES (produto_seq.nextval, 'Camisa Real Madrid', 'Camisa Oficial Real Madrid I Ronaldinho', 'FUTB',99.95,62, 190,'ADI', null );
INSERT INTO produto VALUES (produto_seq.nextval, 'Meia Drift 3/4', 'Meia Esportiva', 'CORR', 22.95,16, 160, 'NIK', null);
INSERT INTO produto VALUES (produto_seq.nextval, 'T-Shirt Run Power', 'Camiseta Dry Fit', 'CORR', 69, 51, 145,'MZN','M');
INSERT INTO produto VALUES (produto_seq.nextval, 'Calcao Dighton', 'Calcao Running Dighton','CORR', 38, 27, 100, 'MZN','P');
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Stratus 2.1','Tenis Corrida Stratus 2.1', 'CORR', 293,242, 258, 'ASI','42');
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Actual', 'Tenis Actual Alto Impacto', 'CORR', 399, 320, 278,'RBK',null );
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Advantage Court III', 'Tenis Advantage Court III', 'CASU', 98, 70, 241, 'WLS', '40');
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Slim Racer Woman', 'Tenis Corrida Feminino Slim Racer', 'CORR', 199, 165, 189, 'RBK', '37' );
INSERT INTO produto VALUES (produto_seq.nextval , 'Caneleira F50 Replique 2008', 'Caneleira Futebol F50 Replique 2008','FUTB', 49, 37, 120, 'ADI','U' );
INSERT INTO produto VALUES (produto_seq.nextval, 'Luvas F50 Training', 'Luvas Adidas F50 Training', 'FUTB', 69, 52.78, 85, 'ADI', 'U' );
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Asics Gel Kambarra III', 'Tenis Corrida Gel Kambarra III Masculino',  'CORR', 199,143, 210, 'ASI',41);
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Asics Gel Maverick 2', 'Tenis Corrida Gel Maverick 2',  'CORR', 159,129.90, 206, 'ASI','42');
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Puma Elevation II', 'Tenis Puma Elevation II Feminino',  'CASU', 129, 98.75, 230, 'PUM', '42');
INSERT INTO produto VALUES (produto_seq.nextval , 'Blusao Adidas F50 Formotion', 'Blusao Adidas F50 Formotion', 'FUTB', 199, 159.90, 320, 'ADI', 'XG');
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Puma Alacron II','Tenis Puma Alacron II' ,  'CASU', 165, 128.55, 210, 'PUM', '43');
INSERT INTO produto VALUES (produto_seq.nextval , 'Tenis Aventura RG Hike', 'Tenis Aventura RG Hike', 'CORR', 269, 201.55, 240,  'TIM', '42');
INSERT INTO produto VALUES (produto_seq.nextval , 'Tenis Aventura Gorge C2', 'Tenis Aventura Gorge C2',  'CORR', 229, 175.24, 198,  'TIM', '41');
INSERT INTO produto VALUES (produto_seq.nextval, 'Bola Varsity', 'Bola Varsity', 'BASQ', 22, 15.75, 265, 'WLS', 'u');
INSERT INTO produto VALUES (produto_seq.nextval , 'Camiseta U40', 'Camiseta U40', 'SKAT', 75, 62.30, 320, 'LOT', 'G');
INSERT INTO produto VALUES (produto_seq.nextval, 'Bermuda Corrida','Bermuda Corrida DriFit' ,  'CORR', 105, 90.55, 210, 'UAR', 'M');
INSERT INTO produto VALUES (produto_seq.nextval , 'Camiseta Regata NBA', 'Camiseta Regata NBA', 'BASQ', 169, 101.35, 240,  'NIK', 'G');
INSERT INTO produto VALUES (produto_seq.nextval , 'Truck 5pol', 'Truck 5 polegadas LongBoard',  'SKAT', 129, 85.24, 198,  'ADI', 'u');
INSERT INTO produto VALUES (produto_seq.nextval, 'Bola NBA', 'Bola NBA', 'BASQ', 72,  65.75, 265, 'NIK', 'u');

-- Armazenamento
INSERT INTO armazenamento VALUES (101, 5001, 650, 'A0123');
INSERT INTO armazenamento VALUES (101, 5002, 150, 'B0123');
INSERT INTO armazenamento VALUES (101, 5003, 650, 'C0123');
INSERT INTO armazenamento VALUES (101, 5004, 650, 'D0123');
INSERT INTO armazenamento VALUES (101, 5005, 610, 'E0123');
INSERT INTO armazenamento VALUES (101, 5006, 650, 'F0123');
INSERT INTO armazenamento VALUES (101, 5007, 250, 'G0123');
INSERT INTO armazenamento VALUES (101, 5008, 650, 'H0123');
INSERT INTO armazenamento VALUES (101, 5009, 650, 'I0123');
INSERT INTO armazenamento VALUES (101, 5010, 650, 'J0123');
INSERT INTO armazenamento VALUES (101, 5015, 50, 'J0123');
INSERT INTO armazenamento VALUES (101, 5016, 50, 'W0113');
INSERT INTO armazenamento VALUES (101, 5017, 50, 'U0123');
INSERT INTO armazenamento VALUES (101, 5018, 150, 'A0143');
INSERT INTO armazenamento VALUES (105, 5001, 650, 'A0123');
INSERT INTO armazenamento VALUES (105, 5002, 150, 'B0123');
INSERT INTO armazenamento VALUES (105, 5003, 650, 'C0123');
INSERT INTO armazenamento VALUES (105, 5004, 650, 'D0123');
INSERT INTO armazenamento VALUES (105, 5005, 610, 'E0123');
INSERT INTO armazenamento VALUES (105, 5006, 650, 'F0123');
INSERT INTO armazenamento VALUES (105, 5007, 250, 'G0123');
INSERT INTO armazenamento VALUES (105, 5008, 650, 'H0123');
INSERT INTO armazenamento VALUES (105, 5009, 650, 'I0123');
INSERT INTO armazenamento VALUES (105, 5010, 650, 'J0123');
INSERT INTO armazenamento VALUES (105, 5011, 650, 'K0123');
INSERT INTO armazenamento VALUES (105, 5017, 50, 'G0223');
INSERT INTO armazenamento VALUES (105, 5018, 50, 'H0323');
INSERT INTO armazenamento VALUES (105, 5019, 50, 'I0423');
INSERT INTO armazenamento VALUES (105, 5020, 50, 'J0323');
INSERT INTO armazenamento VALUES (105, 5021, 50, 'K0223');

-- Pedido
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 130,'FONE' , 200, 0, 5, 'O MESMO', 'CTCRED', 200, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 100,'FONE' , 200, 0, 5, 'O MESMO', 'CTCRED', 211, 4,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 90,'FONE' , 300, 0, 5, 'O MESMO', 'CTCRED', 201, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 80,'FONE' , 400, 0, 5, 'O MESMO', 'DEBITO', 202, 10,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 70,'FONE' , 210, 0, 5, 'O MESMO', 'CTCRED', 203, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 60,'FONE' , 600, 0, 5, 'O MESMO', 'CTCRED', 204, 4,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 55,'FONE' , 280, 0, 5, 'O MESMO', 'DEBITO', 214, 11,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 50,'FONE' , 280, 0, 5, 'O MESMO', 'CTCRED', 208, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 40,'FONE' , 1200, 0, 5, 'O MESMO', 'DEBITO', 201, 11,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 30,'FONE' , 230, 0, 5, 'O MESMO', 'CTCRED', 203, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 20,'FONE' , 2200, 0, 5, 'O MESMO', 'CTCRED', 204,11,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 10,'FONE' , 4200, 0, 5, 'O MESMO', 'CTCRED', 209, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 1,'FONE' , 208, 0, 5, 'O MESMO', 'CTCRED', 210, 9,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp ,'FONE' , 208, 0, 5, 'O MESMO', 'DIN', 202, 9,'EM SEPARACAO');
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp ,'FONE' , 208, 0, 5, 'O MESMO', 'DIN', 205, 9,'EM SEPARACAO');

-- Items pedido
INSERT INTO itens_pedido VALUES (2020,5001,1 , 5);
INSERT INTO itens_pedido VALUES (2020, 5002, 2, 15);
INSERT INTO itens_pedido VALUES (2020, 5003,3 , 7 );
INSERT INTO itens_pedido VALUES (2020, 5004,4 , 5);
INSERT INTO itens_pedido VALUES (2020, 5005,4 , 10);
INSERT INTO itens_pedido VALUES (2020, 5006,3, 15);
INSERT INTO itens_pedido VALUES (2020, 5007,2 , 5);
INSERT INTO itens_pedido VALUES (2021, 5001,1 , 3);
INSERT INTO itens_pedido VALUES (2021, 5002, 1, 5);
INSERT INTO itens_pedido VALUES (2021, 5003,8 , 5);
INSERT INTO itens_pedido VALUES (2021, 5004,4 , 5);
INSERT INTO itens_pedido VALUES (2021, 5005,2 , 5);
INSERT INTO itens_pedido VALUES (2021, 5006,3 , 35);
INSERT INTO itens_pedido VALUES (2021, 5007,6, 30);
INSERT INTO itens_pedido VALUES (2022, 5001,9 , 5);
INSERT INTO itens_pedido VALUES (2022, 5002,11 ,5);
INSERT INTO itens_pedido VALUES (2023, 5001,1 , 15);
INSERT INTO itens_pedido VALUES (2023, 5002,3, 11);
INSERT INTO itens_pedido VALUES (2024, 5001,7, 6);
INSERT INTO itens_pedido VALUES (2024, 5002,9 , 30);
INSERT INTO itens_pedido VALUES (2024, 5003,15 , 12);
INSERT INTO itens_pedido VALUES (2024, 5004,20 , 19);
INSERT INTO itens_pedido VALUES (2025, 5001,30, 16);
INSERT INTO itens_pedido VALUES (2025, 5003,30 , 22);
INSERT INTO itens_pedido VALUES (2025, 5002, 10, 12);
INSERT INTO itens_pedido VALUES (2026, 5001,15 , 16);
INSERT INTO itens_pedido VALUES (2026, 5002,24 , 15);
INSERT INTO itens_pedido VALUES (2026, 5003,12 , 18);
INSERT INTO itens_pedido VALUES (2026, 5004,6 , 27);
INSERT INTO itens_pedido VALUES (2026, 5006,6, 5);
INSERT INTO itens_pedido VALUES (2026, 5005, 3, 12);
INSERT INTO itens_pedido VALUES (2027, 5010, 2, 5);
INSERT INTO itens_pedido VALUES (2027, 5002, 1, 11);
INSERT INTO itens_pedido VALUES (2027, 5003, 16, 5);
INSERT INTO itens_pedido VALUES (2027, 5004, 9, 5);
INSERT INTO itens_pedido VALUES (2027, 5005, 8, 0);
INSERT INTO itens_pedido VALUES (2028, 5001, 9, 0);
INSERT INTO itens_pedido VALUES (2028, 5006, 35, 50);
INSERT INTO itens_pedido VALUES (2028, 5007, 5, 0);
INSERT INTO itens_pedido VALUES (2028, 5005, 10, 0);
INSERT INTO itens_pedido VALUES (2028, 5002, 8, 0);
INSERT INTO itens_pedido VALUES (2028, 5004, 7, 0);
INSERT INTO itens_pedido VALUES (2028, 5003, 9,10);
INSERT INTO itens_pedido VALUES (2029, 5011, 5, 20);
INSERT INTO itens_pedido VALUES (2029, 5005, 5,30);
INSERT INTO itens_pedido VALUES (2029, 5007, 5, 10);
INSERT INTO itens_pedido VALUES (2029, 5006, 4, 0);
INSERT INTO itens_pedido VALUES (2029, 5004, 12, 30);
INSERT INTO itens_pedido VALUES (2029, 5002, 5, 20);
INSERT INTO itens_pedido VALUES (2029, 5003, 5, 15);
INSERT INTO itens_pedido VALUES (2030, 5011, 9, 10);
INSERT INTO itens_pedido VALUES (2030, 5002, 1, 0);
INSERT INTO itens_pedido VALUES (2031, 5021, 5, 20);
INSERT INTO itens_pedido VALUES (2031, 5015, 5,30);
INSERT INTO itens_pedido VALUES (2031, 5017, 5, 10);
INSERT INTO itens_pedido VALUES (2031, 5016, 4, 0);
INSERT INTO itens_pedido VALUES (2031, 5014, 12, 30);
INSERT INTO itens_pedido VALUES (2031, 5012, 5, 20);
INSERT INTO itens_pedido VALUES (2032, 5013, 5, 15);
INSERT INTO itens_pedido VALUES (2032, 5021, 9, 10);
INSERT INTO itens_pedido VALUES (2032, 5019, 1, 0);
INSERT INTO itens_pedido VALUES (2033,5026,1 , 5);
INSERT INTO itens_pedido VALUES (2033, 5022, 2, 15);
INSERT INTO itens_pedido VALUES (2033, 5003,3 , 7 );
INSERT INTO itens_pedido VALUES (2033, 5024,4 , 5);
INSERT INTO itens_pedido VALUES (2033, 5005,4 , 10);
INSERT INTO itens_pedido VALUES (2033, 5006,3, 15);
INSERT INTO itens_pedido VALUES (2033, 5017,2 , 5);
INSERT INTO itens_pedido VALUES (2034, 5026,1 , 3);
INSERT INTO itens_pedido VALUES (2034, 5002, 1, 5);
INSERT INTO itens_pedido VALUES (2034, 5013,8 , 5);
INSERT INTO itens_pedido VALUES (2034, 5024,4 , 5);
INSERT INTO itens_pedido VALUES (2034, 5005,2 , 5);
INSERT INTO itens_pedido VALUES (2034, 5016,3 , 35);
INSERT INTO itens_pedido VALUES (2034, 5007,6, 30);

-- Alterações
ALTER TABLE itens_pedido ADD ( preco_item NUMBER(10,2), total_item NUMBER(10,2) );

UPDATE itens_pedido i
    SET i.preco_item = (
        SELECT p.preco_venda*0.995
        FROM produto p
        WHERE p.cod_prod = i.cod_prod
    );

-- Atualizando o total dos pedidos
UPDATE pedido ped
    SET ped.vl_total_ped = (
        SELECT sum(i.qtde_pedida*i.preco_item*(100-i.descto_item)/100)
        FROM itens_pedido i, produto p
        WHERE ped.num_ped = i.num_ped
        AND i.cod_prod = p.cod_prod
    );

-- Confirmar ações
COMMIT;

-- contagem de linhas para cada tabela
SELECT count(*) AS Itens FROM itens_pedido;
SELECT count(*) AS Regiao FROM regiao;
SELECT count(*) AS Produto FROM produto;
SELECT count(*) AS Cliente FROM cliente;
SELECT count(*) AS Pedido FROM pedido;
SELECT count(*) AS Armazenamento FROM armazenamento;
SELECT count(*) AS Funcionario FROM funcionario;
SELECT count(*) AS Depto  FROM departamento;
SELECT count(*) AS Cargo FROM cargo;

-- Recuperar todos os clientes
SELECT cod_cli_pf AS Cod,
    nome_fantasia AS NOME
    FROM cliente_pf
    UNION SELECT cod_cli_pj AS Cod,
        razao_social_cli AS Nome
        FROM cliente_pj;

-- Alterações (pedido)
ALTER TABLE itens_pedido ADD situacao_item CHAR(15)
    CHECK (
        situacao_item IN ( 'SEPARACAO', 'ENTREGUE', 'CANCELADO', 'DESPACHADO')
    );

UPDATE itens_pedido SET situacao_item = 'SEPARACAO';

CREATE OR REPLACE TRIGGER valida_pf
BEFORE INSERT OR UPDATE ON cliente_pf
    FOR EACH ROW
    DECLARE vtipocli cliente.tipo_cli%TYPE;
    BEGIN
        SELECT c.tipo_cli INTO vtipocli
            FROM cliente c
            WHERE c.cod_cli = :NEW.cod_cli_pf;
        IF vtipocli != 'PF' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Cliente de codigo ' ||
                TO_CHAR(:NEW.cod_cli_pf) ||
                ' nao corresponde a Pessoa Fisica');
        END IF;
    END;

CREATE OR REPLACE TRIGGER valida_pj
BEFORE INSERT OR UPDATE ON cliente_pj
    FOR EACH ROW
    DECLARE vtipocli cliente.tipo_cli%TYPE;
    BEGIN
        SELECT c.tipo_cli INTO vtipocli
            FROM cliente c
            WHERE c.cod_cli = :NEW.cod_cli_pj;
        IF vtipocli != 'PJ' THEN
            RAISE_APPLICATION_ERROR(-20002, 'Cliente de codigo ' ||
                TO_CHAR(:NEW.cod_cli_pj) ||
                ' nao corresponde a Pessoa Juridica');
        END IF;
    END;

DROP TABLE auditoria_produto CASCADE CONSTRAINTS;
CREATE TABLE auditoria_produto (
    num_log INTEGER PRIMARY KEY,
    acao CHAR(15) NOT NULL CHECK (
        acao IN ( 'INCLUSAO', 'ATUALIZACAO', 'EXCLUSAO')
    ),
    dt_hora_operacao TIMESTAMP NOT NULL,
    usuario VARCHAR2(32) NOT NULL,
    codprod_antes INTEGER,
    codprod_depois INTEGER,
    preco_vda_antes NUMBER(10,2),
    preco_vda_depois NUMBER(10,2)
);

CREATE SEQUENCE log_produto;
CREATE OR REPLACE TRIGGER gera_log_produto
AFTER INSERT OR UPDATE OR DELETE ON produto
    FOR EACH ROW
    BEGIN
        IF INSERTING THEN
            INSERT INTO auditoria_produto VALUES (
                    log_produto.nextval ,
                    'INCLUSAO',
                    current_timestamp,
                    user,
                    null ,
                    :NEW.cod_prod,
                    null,
                    :NEW.preco_venda
                );
        ELSIF
            UPDATING THEN
            INSERT INTO auditoria_produto VALUES (
                log_produto.nextval ,
                'ATUALIZACAO',
                current_timestamp,
                user,
                :OLD.cod_prod ,
                :NEW.cod_prod,
                :OLD.preco_venda,
                :NEW.preco_venda
            );
        ELSIF
            DELETING THEN
            INSERT INTO auditoria_produto VALUES (
                log_produto.nextval ,
                'EXCLUSAO',
                current_timestamp,
                user,
                :OLD.cod_prod ,
                null ,
                :OLD.preco_venda,
                null
            );
        END IF;
    END;

CREATE OR REPLACE TRIGGER valida_vendedor_pedido
BEFORE INSERT OR UPDATE ON pedido
    FOR EACH ROW
    DECLARE vcargo cargo.nome_cargo%TYPE;
    BEGIN
        SELECT c.nome_cargo INTO vcargo
            FROM cargo c JOIN funcionario f
            ON (c.cod_cargo = f.cod_cargo)
            WHERE f.cod_func = :NEW.cod_func_vendedor;
        IF UPPER(vcargo) NOT LIKE '%VENDEDOR%' THEN
            RAISE_APPLICATION_ERROR (
                -20003,
                'Funcionario ' ||
                TO_CHAR(:NEW.cod_func_vendedor) ||
                ' nao eh Vendedor.'
            );
        END IF;
    END;

/* ###################### */
/*      Atividade #1      */
/* ###################### */
-- 1 - Validar data de admissão de funcionário maior ou igual a data atual
DROP TRIGGER valida_data_admissao;
CREATE OR REPLACE TRIGGER valida_data_admissao
BEFORE INSERT OR UPDATE ON funcionario
    FOR EACH ROW
    BEGIN
        IF :NEW.dt_admissao < current_date THEN
            RAISE_APPLICATION_ERROR (
                -20003,
                'Data de admissão deve ser maior ou igual à data atual.'
            );
        END IF;
    END;

-- 2 - Evitar que o valor do desconto de um pedido seja maior que 20% do valor do pedido
DROP TRIGGER valida_limita_desconto
CREATE OR REPLACE TRIGGER valida_limita_desconto
BEFORE INSERT OR UPDATE OF vl_descto_ped ON pedido
    FOR EACH ROW
    BEGIN
        IF :NEW.vl_descto_ped > (:NEW.vl_total_ped*20)/100 THEN
            RAISE_APPLICATION_ERROR (
                -20004,
                'Valor do desconto ultrapassa 20% do valor do pedido.' ||
                ' Aplique um desconto menor.'

            );
        END IF;
    END;

-- 3 - Gerar log para atualização de status de pedido
DROP TABLE auditoria_item CASCADE CONSTRAINTS;
CREATE TABLE auditoria_item (
    id_log INTEGER PRIMARY KEY,
    acao CHAR(20) CHECK (
        acao IN (
            'INSERCAO','EXCLUSAO','ATUALIZA PRECO', 'ATUALIZA DESCONTO', 'ATUALIZA SITUACAO'
        )
    ) NOT NULL,
    usuario VARCHAR2(30) NOT NULL,
    data_hora_operacao TIMESTAMP NOT NULL,
    produto INTEGER,
    pedido INTEGER,
    old_preco NUMBER(10,2),
    new_preco NUMBER(10,2),
    old_desconto NUMBER(10,2),
    new_desconto NUMBER(10,2),
    old_situacao VARCHAR2(20),
    new_situacao VARCHAR2(20)
);

DROP SEQUENCE log_item;
CREATE sequence log_item start with 1000;

DROP TRIGGER gera_log_item;
CREATE OR REPLACE TRIGGER gera_log_item
    AFTER UPDATE OR INSERT ON itens_pedido
    FOR EACH ROW
    BEGIN
        IF INSERTING THEN
            INSERT INTO auditoria_item VALUES (
                log_item.nextval,
                'INSERCAO',
                USER,
                current_timestamp,
                :NEW.cod_prod,
                :NEW.num_ped,
                null,
                :NEW.preco_item,
                null,
                :NEW.descto_item,
                null,
                :NEW.situacao_item
            );
        ELSIF UPDATING ('preco_item') THEN
            INSERT INTO auditoria_item VALUES (
                log_item.nextval,
                'ATUALIZA PRECO',
                USER,
                current_timestamp,
                :OLD.cod_prod,
                :OLD.num_ped,
                :OLD.preco_item,
                :NEW.preco_item,
                null,
                null,
                null,
                null
            );
        ELSIF UPDATING('descto_item') THEN
            INSERT INTO auditoria_item VALUES (
                log_item.nextval,
                'ATUALIZA DESCONTO',
                USER,
                current_timestamp,
                :OLD.cod_prod,
                :OLD.num_ped,
                null,
                null,
                :OLD.descto_item,
                :NEW.descto_item,
                null,
                null
            );
        ELSIF UPDATING('situacao_item') THEN
            INSERT INTO auditoria_item VALUES (
                log_item.nextval,
                'ATUALIZA SITUACAO',
                USER,
                current_timestamp,
                :OLD.cod_prod,
                :OLD.num_ped,
                null,
                null,
                null,
                null,
                :OLD.situacao_item,
                :NEW.situacao_item
            );
        END IF;
    END gera_log_item;

/* ###################### */
/*      Atividade #2      */
/* ###################### */
-- 1 - Validação para vendedor da mesma região que o cliente para pedidos
CREATE OR REPLACE trigger valida_vendedor_regiao
BEFORE INSERT OR UPDATE ON pedido
    FOR EACH ROW
    DECLARE rvendor regiao.cod_regiao%TYPE;
    DECLARE rcliente regiao.cod_regiao%TYPE;
    BEGIN
        SELECT c.cod_regiao INTO rcliente
            FROM cliente c
            WHERE c.cod_cli =: NEW.cod_cli;
        SELECT f.cod_regiao INTO rvendor
            FROM  funcionario f
            WHERE f.cod_func = :NEW.cod_func_vendedor;
        IF rcliente <> rvendor THEN
            RAISE_APPLICATION_ERROR (
                -20004 ,
                'Vendedor nao pertence à mesma regiao do cliente.'
            );
        END IF;
    END;

-- 2 - Validação para primeiro salário de um novo vendedor não seja o maior
CREATE OR REPLACE TRIGGER valida_salario_cargo
BEFORE INSERT OR UPDATE ON funcionario
    FOR EACH ROW
    DECLARE vmaior_sal funcionario.salario%TYPE;
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        SELECT MAX(f.salario) into vmaior_sal
            FROM funcionario f
            WHERE f.cod_cargo = :NEW.cod_cargo;
        IF :NEW.salario > vmaior_sal THEN
            RAISE_APPLICATION_ERROR  (
                -20038,
                'Salario não pode ultrapassar o teto para o cargo.'
            );
        END IF;
    END;

-- 3 - Validação para o funcionário não ser gerente de outro funcionário quando este primeiro já não for gerente
CREATE OR REPLACE TRIGGER valida_gerente
BEFORE INSERT OR UPDATE ON funcionario
    FOR EACH ROW
    DECLARE vcargo cargo.nome_cargo%TYPE;
    DECLARE vregiao regiao.cod_regiao%TYPE;
    BEGIN
        SELECT nome_cargo, cod_regiao INTO vcargo, vregiao
            FROM funcionario f, cargo c
            WHERE f.cod_cargo = c.cod_cargo
            AND f.cod_func = :NEW.cod_func_gerente;
        IF UPPER(vcargo) NOT LIKE '%GERENTE%' THEN
            RAISE_APPLICATION_ERROR (
                -20035,
                'Empregado gerente não confere com o cargo.'
            );
        ELSIF  vregiao <> :NEW.cod_regiao THEN
            RAISE_APPLICATION_ERROR (
                -20036,
                'Regiao ' ||
                TO_CHAR(vregiao) ||
                ' do gerente é diferente da regiao ' ||
                TO_CHAR(:NEW.cod_regiao) ||
                ' do  funcionário.'
            );
        END IF;
    END;

/* ###################### */
/*      Atividade #3      */
/* ###################### */
-- 1    Elabore uma função que retorne a quantidade
--      e a soma do valor total dos pedidos feitos
--      por um cliente passando como parâmetro o nome
--      ou parte do nome, em um intervalo de tempo.
CREATE OR REPLACE TYPE resultado_cli AS VARRAY(5) OF NUMBER;
CREATE OR REPLACE FUNCTION qtde_pedidos (
    vcli IN cliente.nome_fantasia%TYPE,
    vini IN pedido.dt_hora_ped%TYPE,
    vfim IN pedido.dt_hora_ped%TYPE
) RETURN
    resultado_cli IS vqtde resultado_cli := resultado_cli();
    vargumento cliente.nome_fantasia%TYPE := '%'||UPPER(vcli)||'%';
    vsetem SMALLINT := 0;
    BEGIN
        vqtde.EXTEND(2);
        SELECT COUNT(*) INTO vsetem
            FROM cliente
            WHERE upper(nome_fantasia) LIKE vargumento;
        IF vsetem = 1 THEN
            SELECT COUNT(*), SUM(p.vl_total_ped)  INTO vqtde(1), vqtde(2)
                FROM pedido p, cliente c
                WHERE p.cod_cli = c.cod_cli
                AND UPPER(nome_fantasia) LIKE vargumento
                AND p.dt_hora_ped BETWEEN vini AND vfim;
        ELSIF vsetem > 1 THEN
            RAISE_APPLICATION_ERROR(
               -20011,
               'Existe mais de um cliente com este nome. Seja mais específico.'
            );
        ELSIF vsetem = 0 THEN
            RAISE_APPLICATION_ERROR(
               -20012,
               'Cliente não encontrado.'
            );
        END IF;
        RETURN vqtde;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20029,
                'Cliente não encontrado.'
            );
        END;

-- 2    Elabore uma função que retorne o valor total
--      vendido, calculado em reais, para um determinado
--      Gerente de uma equipe de vendas em um período
--      de tempo, tendo como parâmetros de entrada o
--      código do gerente e as datas de início e término
--      do período, ou seja, quanto foi vendido pelos
--      vendedores que são gerenciados por este gerente.
--      Considere que na tabela de cargo existe o cargo
--      Gerente Vendas. Faça as validações necessárias.
CREATE OR REPLACE FUNCTION total_gerente_vendas (
    vgerente IN funcionario.cod_func%TYPE,
    vini IN pedido.dt_hora_ped%TYPE,
    vfim IN pedido.dt_hora_ped%TYPE
) RETURN NUMBER IS
    vtotal pedido.vl_total_ped%TYPE := 0;
    vsegerente cargo.nome_cargo%TYPE;
    BEGIN
        SELECT c.nome_cargo INTO vsegerente
            FROM funcionario f, cargo c
            WHERE f.cod_cargo = c.cod_cargo
            AND f.cod_func = vgerente;
        IF UPPER (vsegerente) NOT LIKE '%GERENTE DE VENDAS%'  THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Funcionario não é gerente de Vendas>'
            );
        ELSE
            SELECT SUM(p.vl_total_ped) INTO vtotal
                FROM pedido p, funcionario f
                WHERE p.cod_func_vendedor = f.cod_func
                AND f.cod_func_gerente = vgerente
                AND p.dt_hora_ped BETWEEN vini AND vfim;
        END IF;
        RETURN vtotal;
    END;

-- 3    Elabore uma função que retorne o valor calculado,
--      em reais, da comissão de um vendedor para um
--      determinado período de tempo, tendo como parâmetros
--      de entrada o código do vendedor, as datas de início
--      e término do período, e o percentual de comissão
--      (esse dado não tem o banco), ou seja, o total das
--      comissões baseado nos pedidos de um período de tempo.
--      Faça as seguintes validações :
--      I) comissão não pode ser negativa nem passar de 100%;
--      II) data final maior ou igual à data inicial do período
--          e não podem ser nulas (se forem nulas considere a
--          data final como a data atual e a data inicial 1
--          mês atrás – comissão dos últimos 30 dias);
--      III) se o código do vendedor é de um vendedor mesmo.
CREATE OR REPLACE FUNCTION comissao_vendedor (
    vvendor IN pedido.cod_func_vendedor%TYPE,
    vini IN pedido.dt_hora_ped%TYPE,
    vfim IN pedido.dt_hora_ped%TYPE,
    vcomissao IN NUMBER
) RETURN NUMBER IS
    vtotal_comissao pedido.vl_total_ped%TYPE;
    vcargo cargo.nome_cargo%TYPE;
    vinicial pedido.dt_hora_ped%TYPE;
    vfinal pedido.dt_hora_ped%TYPE;
    BEGIN
        IF vcomissao IS NULL OR vcomissao NOT BETWEEN 0 AND 100 THEN
            RAISE_APPLICATION_ERROR(
                -20100,
                'Percentual da comissão é obrigatório e deve estar entre 0 e 100.'
            );
        END IF;
        IF vfim IS NULL OR vini IS NULL THEN
            vinicial := current_date - 30;
            vfinal := current_date;
        ELSIF vini IS NOT NULL AND vfim IS NOT NULL THEN
            IF vfim < vini THEN
                RAISE_APPLICATION_ERROR(
                    -20104,
                    'Datas são obrigatórias e data final deve ser maior que a inicial.'
                );
            END IF;
            vinicial := vini;
            vfinal := vfim;
        END IF;
        SELECT UPPER(c.nome_cargo) INTO vcargo
            FROM cargo c JOIN funcionario f
            ON (c.cod_cargo = f.cod_cargo)
            WHERE f.cod_func = vvendor;
        IF vcargo NOT LIKE '%VENDE%' THEN
            RAISE_APPLICATION_ERROR(
                -20101,
                'Funcionário ' ||
                TO_CHAR(vvendor) ||
                ' é ' ||
                vcargo
            );
        END IF;
        SELECT SUM ( p.vl_total_ped * vcomissao) / 100 INTO vtotal_comissao
            FROM pedido p
            WHERE p.cod_func_vendedor = vvendor
            AND p.dt_hora_ped BETWEEN vinicial AND vfinal;
        RETURN NVL(vtotal_comissao,0);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20102,
                'Dados não encontrados.'
            );
        END;

/* ###################### */
/*      Atividade #4      */
/* ###################### */
-- 1    Modifique a trigger composta realizada
--      em aula  - atualizar a situação do
--      pedido - para tratar a situação de um
--      novo pedido em que ainda não foram
--      cadastrados os itens. Estenda o tratamento
--      para qualquer alteração na situação do
--      pedido se refletir também nos itens,
--      por exemplo, se cancelar o pedido cancela
--      os itens também. Para tanto as restrições
--      de verificação nas duas tabelas para a
--      situação tem que ser iguais (mesmo texto).
ALTER TABLE itens_pedido
    DROP CONSTRAINT chk_situacao_item;
UPDATE itens_pedido
    SET situacao_item = 'EM SEPARACAO'
    WHERE situacao_item = 'SEPARACAO';
ALTER TABLE itens_pedido
    ADD CONSTRAINT chk_situacao_item
    CHECK (
        situacao_item IN (
            'APROVADO', 'REJEITADO', 'EM SEPARACAO', 'DESPACHADO', 'ENTREGUE', 'CANCELADO'
        )
    );

CREATE OR REPLACE TRIGGER atualiza_situacao_pedido
    FOR INSERT OR UPDATE OF situacao_ped, dt_hora_entrega ON pedido
    COMPOUND TRIGGER
        linha_alterada rowid;
        vsitu_nova pedido.situacao_ped%TYPE;
        vsitu_antes pedido.situacao_ped%TYPE;
    AFTER EACH ROW IS  -- declaração de disparo em nível de linha
    BEGIN
        linha_alterada := :NEW.rowid;
        vsitu_antes := :OLD.situacao_ped;
        vsitu_nova := NVL(:NEW.situacao_ped, 'EM SEPARACAO');
        DBMS_OUTPUT.PUT_LINE ('situação antes '||vsitu_antes||' nova '||vsitu_nova );
        IF :NEW.dt_hora_entrega IS NOT NULL AND :OLD.dt_hora_entrega IS NULL THEN
            vsitu_nova := 'ENTREGUE';
        END IF;
        END AFTER EACH ROW;
    AFTER STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE (
            'No túnel para chamar a procedure : ' ||
            linha_alterada ||
            '-' ||
            'situação antes ' ||
            vsitu_antes ||
            ' nova ' ||
            vsitu_nova
        );
        atualiza_situacao_pedido_proc(linha_alterada, vsitu_nova, vsitu_antes);
    END AFTER STATEMENT;
END;

CREATE OR REPLACE PROCEDURE atualiza_situacao_pedido_proc (
    vlinha IN VARCHAR2,
    vsituacao IN pedido.situacao_ped%TYPE,
    vantes IN pedido.situacao_ped%TYPE
) IS vpedido pedido.num_ped%TYPE;
    CURSOR c_itens IS SELECT * FROM itens_Pedido  WHERE num_ped = vpedido;
    vitens SMALLINT := 0;
    linhaitem c_itens%ROWTYPE;
    BEGIN
        SELECT num_ped INTO vpedido FROM pedido WHERE rowid = vlinha;
        DBMS_OUTPUT.PUT_LINE(
            'Antes de testar se situacao mudou -> situação antes ' ||
            vantes ||
            ' nova ' ||
            vsituacao
        );
        IF vsituacao <> vantes THEN
            DBMS_OUTPUT.PUT_LINE (
                'situacao mudou, atualizando o pedido ' ||
                vpedido
            );
            UPDATE pedido SET situacao_ped = vsituacao
                WHERE rowid = vlinha;
        END IF;
        OPEN  c_itens;
        LOOP
            FETCH c_itens INTO linhaitem;
            EXIT WHEN c_itens%NOTFOUND;
            IF (c_itens%FOUND) THEN
                DBMS_OUTPUT.PUT_LINE('Existem itens para esse pedido');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Ainda NAO existem itens para esse pedido');
                EXIT;
            END IF;
            DBMS_OUTPUT.PUT_LINE ('abriu o cursor dos itens...');
            IF  linhaitem.situacao_item <> 'CANCELADO' AND linhaitem.situacao_item <> vsituacao THEN
                UPDATE itens_pedido i  SET i.situacao_item = vsituacao
                    WHERE linhaitem.num_ped = vpedido
                    AND linhaitem.cod_prod = i.cod_prod;
                vitens := vitens  + 1;
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE ('itens atualizados '||vitens);
        CLOSE c_itens;
    END;

-- 2    Elabore uma procedure para mostrar
--      os dados de venda de um produto em
--      um intervalo de tempo, passando o
--      nome ou parte do nome do produto.
--      Faça TODAS as validações necessárias.
CREATE OR REPLACE PROCEDURE vendas_produto_intervalo (
    vprod IN produto.nome_prod%TYPE,
    vini IN pedido.dt_hora_ped%TYPE,
    vfim IN pedido.dt_hora_ped%TYPE, listagem OUT SYS_REFCURSOR
) IS
    acumulado pedido.vl_total_ped%TYPE := 0d;
    vbusca produto.nome_prod%TYPE := '%'||UPPER(vprod)||'%';
    vexiste SMALLINT := 0d;
    BEGIN
        SELECT COUNT(*)
            INTO vexiste
            FROM produto
            WHERE UPPER(nome_prod) LIKE vbuscad;
        IF vexiste = 0 THEN
            RAISE_APPLICATION_ERROR (
                -20100,
                ' Produto não localizado'
            );
        ELSIF vexiste > 1 THEN
            RAISE_APPLICATION_ERROR (
                -20101,
                ' Mais de um produto com esse nome! Refine sua busca'
            );
        END IF;
        OPEN listagem FOR
            SELECT p.num_ped AS Pedido,
                c.nome_fantasia AS Cliente,
                p.dt_hora_ped AS Dtpedido,
                i.qtde_pedida AS Qtde,
                i.preco_item AS Preco,
                i.descto_item AS Descto,
                (i.qtde_pedida * i.preco_item * (100 - i.descto_item)/100) AS Totalitem
                FROM pedido p
                JOIN cliente c ON (p.cod_cli = c.cod_cli)
                JOIN itens_pedido i ON (i.num_ped = p.num_ped)
                JOIN produto pr ON ( pr.cod_prod = i.cod_prod)
                WHERE UPPER(pr.nome_prod) LIKE vbusca
                    AND p.dt_hora_ped BETWEEN vini
                    AND vfim
                ORDER BY p.num_pedd;
        END;
        CREATE TABLE vendas_produto_proc AS
            SELECT p.num_ped AS Pedido,
                c.nome_fantasia AS Cliente,
                p.dt_hora_ped AS Dtpedido,
                i.qtde_pedida AS Qtde,
                i.preco_item AS Preco,
                i.descto_item AS Descto,
                (i.qtde_pedida*i.preco_item*(100 - i.descto_item)/100) AS Totalitem
                FROM pedido p JOIN cliente c ON ( p.cod_cli = c.cod_cli)
                JOIN itens_pedido i ON (i.num_ped = p.num_ped)
                JOIN produto pr ON ( pr.cod_prod = i.cod_prod);
        DECLARE
            vacumulado pedido.vl_total_ped%TYPE := 0;
            vendas_produto SYS_REFCURSOR;
            linha_prod vendas_produto_proc%ROWTYPE;
            vcabecalho VARCHAR2(100) := 'Pedido     Cliente      Data    Qtde Pedida   Preço Item   Desconto    Total Item    Total Vendas';
            BEGIN
                vendas_produto_intervalo('mundo', current_date - 500, current_date, vendas_produto);
                DBMS_OUTPUT.PUT_LINE (vcabecalho);
                LOOP
                    FETCH vendas_produto INTO linha_prodd;
                    EXIT WHEN vendas_produto%NOTFOUNDd;
                    vacumulado := vacumulado + linha_prod.Totalitemd;
                    DBMS_OUTPUT.PUT_LINE (
                        RPAD(TO_CHAR(linha_prod.Pedido), 8, ' ') ||
                        RPAD(linha_prod.Cliente, 14, ' ') ||
                        RPAD ( TO_CHAR ( linha_prod.Dtpedido, 'DD/MON'),14,' ') ||
                        RPAD ( TO_CHAR ( linha_prod.Qtde),11,' ') ||
                        RPAD ( TO_CHAR ( linha_prod.Preco, '$9999D99'),15,' ') ||
                        RPAD ( TO_CHAR ( linha_prod.Descto, '999D99'),10,' ') ||
                        RPAD ( TO_CHAR ( linha_prod.Totalitem, '$99999D99'),14, ' ') ||
                        TO_CHAR ( vacumulado, '$99999D99')
                    );
                END LOOP;
        CLOSE vendas_produtod;
    END;

/* ###################### */
/*      Atividade #5      */
/* ###################### */
-- 1    Construa um log de auditoria para
--      reajuste de salário dos funcionários
--      utilizando gatilho composto. Suponha
--      que o salário é reajustado por um
--      determinado índice para cada região de
--      vendas - ou seja, nem sempre uma região
--      terá reajuste junto com as outras. Registre
--      o nome do funcionário, o nome da região e o
--      salário anterior e o reajustado (novo),
--      além de outros dados relevantes para o controle.
DROP TABLE salario_log CASCADE CONSTRAINTS;
CREATE TABLE salario_log (
    log_id INTEGER,
    funcionario INTEGER,
    usuario VARCHAR2(32) ,
    salario_antes NUMBER(10,2),
    salario_depois NUMBER(10,2) ,
    regiao VARCHAR2(50),
    dt_reajuste TIMESTAMP
);

DROP SEQUENCE salario_log_seq;
CREATE SEQUENCE salario_log_seq;

CREATE OR REPLACE TRIGGER compound_salario_reajuste
    FOR UPDATE OF salario ON funcionario
    COMPOUND TRIGGER
    linhaalterada ROWID;
    TYPE salario_registro IS RECORD (
        log_id              salario_log.log_id%TYPE,
        funcionario     salario_log.funcionario%TYPE,
        usuario            salario_log.usuario%TYPE ,
        salario_antes   salario_log.salario_antes%TYPE,
        salario_depois salario_log.salario_depois%TYPE ,
        regiao             salario_log.regiao%TYPE,
        dt_reajuste      salario_log.dt_reajuste%TYPE
    );
    TYPE salario_lista IS TABLE OF salario_registro;
    salario_updates salario_lista := salario_lista();
    AFTER EACH ROW IS p NUMBER;
    usuario_id VARCHAR2(32);
    nomeregiao VARCHAR2(50);
    BEGIN
        linhaalterada := :NEW.rowid;
        SELECT user
            INTO usuario_id
            FROM dual;
        SELECT get_regiao (linhaalterada)
            INTO nomeregiao
            FROM dual;
        salario_updates.EXTEND;
        p := salario_updates.LAST;
        salario_updates(p).log_id := salario_log_seq.nextval;
        salario_updates(p).funcionario := :OLD.cod_func;
        salario_updates(p).usuario := usuario_id;
        salario_updates(p).salario_antes := :OLD.salario;
        salario_updates(p).salario_depois := :NEW.salario;
        salario_updates(p).regiao := nomeregiao;
        salario_updates(p).dt_reajuste := current_timestamp;
        END AFTER EACH ROW;
        AFTER STATEMENT IS
        BEGIN
            FORALL i IN salario_updates.FIRST..salario_updates.LAST
            INSERT INTO salario_log VALUES (
                salario_updates(i).log_id ,
                salario_updates(i).funcionario,
                salario_updates(i).usuario,
                salario_updates(i).salario_antes ,
                salario_updates(i).salario_depois,
                salario_updates(i).regiao,
                salario_updates(i).dt_reajuste
            );
        END AFTER STATEMENT;
    END;

CREATE OR REPLACE FUNCTION get_regiao (
    vlinha IN VARCHAR2
) RETURN VARCHAR2 IS vregiao regiao.nome_regiao%TYPE;
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        SELECT r.nome_regiao
            INTO vregiao
            FROM regiao r
            JOIN funcionario f ON (f.cod_regiao = r.cod_regiao)
            WHERE f.rowid = vlinha;
        RETURN vregiao;
    END;

-- 2    Reescreva a procedure da SQL Dinâmica,
--      realizada em aula- para consultas com
--      duas tabelas, para permitir agora utilizar
--      três tabelas com dois filtros.
CREATE OR REPLACE PROCEDURE lista_dinamica_3tabelas (
    vtabela1 IN VARCHAR2,
    vcoluna1 IN VARCHAR2,
    vcol_juncao12 IN VARCHAR2,
    vtabela2 IN VARCHAR2,
    vcoluna2 IN VARCHAR2,
    vcol_juncao21 IN VARCHAR2,
    vcol_juncao23 IN VARCHAR2,
    vtabela3 IN VARCHAR2,
    vcoluna3 IN VARCHAR2,
    vcol_juncao32 IN VARCHAR2,
    vfiltro1 IN VARCHAR2,
    vcompara1 IN VARCHAR2,
    vvalor1 IN INTEGER,
    voperador IN VARCHAR2,
    vfiltro2 IN VARCHAR2,
    vcompara2 IN VARCHAR2,
    vvalor2 IN INTEGER
) IS TYPE vteste IS REF CURSOR;
    vCursor_tabelas3 vteste;
    vSQLdin VARCHAR2(500);
    vaux1 VARCHAR2(50);
    vaux2 VARCHAR2(50);
    vaux3 VARCHAR2(50);
    BEGIN
        vSQLdin :=
            'SELECT ' ||
            vtabela1 ||
            '.' ||
            vcoluna1 ||
            ' , ' ||
            vtabela2 ||
            '.' ||
            vcoluna2 ||
            ' , ' ||
            vtabela3 ||
            '.' ||
            vcoluna3 ||
            'FROM ' ||
            vtabela1 ||
            ' JOIN ' ||
            vtabela2 ||
            'ON ' ||
            vtabela1 ||
            '.' ||
            vcol_juncao12 ||
            '=' ||
            vtabela2 ||
            '.' ||
            vcol_juncao21 ||
            'JOIN ' ||
            vtabela3 ||
            'ON ' ||
            vtabela2 ||
            '.' ||
            vcol_juncao23 ||
            '=' ||
            vtabela3 ||
            '.' ||
            vcol_juncao32 ||
            'WHERE ' ||
            vfiltro1 ||
            ' ' ||
            vcompara1 ||
            ' :1 ' ||
            voperador ||
            ' ' ||
            vfiltro2 ||
            ' ' ||
            vcompara2 ||
            ' :2 ';
        DBMS_OUTPUT.PUT_LINE ( vSQLdin);
        OPEN vCursor_tabelas3 FOR vSQLdin USING vvalor1, vvalor2;
        LOOP
            FETCH vCursor_tabelas3
                INTO vaux1, vaux2, vaux3;
            EXIT WHEN vCursor_tabelas3%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE ( RPAD(TRIM (vaux1), 40, ' ' )||RPAD(TRIM(vaux2), 40, ' ')||RPAD(TRIM(vaux3), 40, ' ') );
        END LOOP;
        CLOSE vCursor_tabelas3;
    END;
    BEGIN
        lista_dinamica_3tabelas (
            'cliente',
            'nome_fantasia',
            'cod_cli',
            'pedido',
            'vl_total_ped',
            'cod_cli',
            'forma_pgto',
            'forma_pgto',
            'descr_forma_pgto',
            'cod_forma',
            'vl_total_ped',
            '<=',
            1000,
            'AND',
            'limite_credito',
            '>',
            1000
        );
    END;

-- 3    Crie uma nova tabela para Tamanho usando
--      SQL Dinâmica e popule os dados com os valores
--      distintos a partir da tabela de origem PRODUTO.
--      Tudo em uma única procedure, função ou bloco
--      anônimo. Posteriormente resolva com SQL estático
--      o relacionamento entre as duas tabelas.
SELECT DISTINCT TRIM(
    UPPER(TO_CHAR(NVL(tamanho,'TAM')))
    ) FROM produto;

DROP SEQUENCE tam_seq;
CREATE SEQUENCE tam_seq;
DROP TABLE tamanho CASCADE CONSTRAINTS;

CREATE OR REPLACE PROCEDURE gera_tamanho
    AUTHID CURRENT_USER IS TYPE vtamanho IS REF CURSOR;
    vCursortam vtamanho;
    vdinSelect VARCHAR2(4000);
    vdinCreate VARCHAR2(4000) :=
        'CREATE TABLE tamanho ( cod_tam SMALLINT PRIMARY KEY, tamanho VARCHAR2(30))';
    vdinInsert VARCHAR2(4000);
    vtam CHAR(3);
    vseq INTEGER;
    BEGIN
        vdinSelect := 'SELECT DISTINCT TRIM ( UPPER (TO_CHAR (tamanho) ) ) FROM produto';
        EXECUTE IMMEDIATE vdinCreate;
        OPEN vCursortam FOR vdinSelect;
        LOOP
            FETCH vCursortam INTO vtam;
            EXIT WHEN vCursortam%NOTFOUND;
            IF vtam IS NULL THEN
                vtam := 'TAM';
            END IF;
            SELECT tam_seq.nextval
                INTO vseq
                FROM dual;
		    vdinInsert := 'INSERT INTO tamanho VALUES ( :1, :2)';
            EXECUTE IMMEDIATE vdinInsert USING vseq, vtam;
        END LOOP;
        CLOSE vCursortam;
    END;

    BEGIN
        gera_tamanho;
    END;

ALTER TABLE produto ADD cod_tamanho SMALLINT;
UPDATE produto p
    SET p.cod_tamanho = (
        SELECT t.cod_tam
            FROM tamanho t
            WHERE  TRIM(UPPER(p.tamanho)) = TRIM(UPPER(t.tamanho))
    );

UPDATE produto p
    SET p.cod_tamanho = (
        SELECT t.cod_tam
            FROM tamanho t
            WHERE t.tamanho = 'TAM'
    )
    WHERE p.tamanho IS NULL;

ALTER TABLE produto
    ADD FOREIGN KEY (cod_tamanho)
    REFERENCES tamanho (cod_tam);
ALTER TABLE produto
    MODIFY cod_tamanho NOT NULL;
