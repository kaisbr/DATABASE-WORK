create database BD_OLAP;

use BD_OLAP;

-- criação de tabelas feito sem ajuda de IA apenas com pesquisas!!
create table dim_produto(
id int auto_increment primary key,
nome_produto varchar(255),
categoria varchar(255)
);
create table dim_funcionario(
id int auto_increment primary key,
nome_funcionario varchar(255)
);
create table dim_local(
id int auto_increment primary key,
estado varchar(255),
cidade varchar(255)
);
create table dim_tempo(
id int auto_increment primary key,
data date,
ano int,
mes int,
dia int
);
create table dim_cliente(
id int auto_increment primary key,
nome_cliente varchar(255)
);
create table vendas_fato(
id int auto_increment primary key,
tempo_id int,
produto_id int,
cliente_id int,
funcionario_id int,
local_id int,
quantidade int,
valor decimal(10, 2),
foreign key (tempo_id) references dim_tempo(id),
foreign key (produto_id) references dim_produto(id),
foreign key (cliente_id) references dim_cliente(id),
foreign key (funcionario_id) references dim_funcionario(id),
foreign key (local_id) references dim_local(id)

);

-- inserção de valores apenas com os valores gerados por IA, sendo alguns modificados manualmente!!
INSERT INTO dim_tempo (data, ano, mes, dia)
VALUES 
('2023-09-15', 2023, 9, 15),
('2023-02-20', 2023, 2, 20),
('2023-07-25', 2023, 7, 25);

INSERT INTO dim_produto (nome_produto, categoria)
VALUES 
('Produto A', 'Categoria 1'),
('Produto B', 'Categoria 2'),
('Produto C', 'Categoria 3');

INSERT INTO dim_local (estado, cidade)
VALUES 
('SP','São Paulo'),
('PE','Camaragibe'),
('MG','Monte Santo');

INSERT INTO dim_cliente (nome_cliente)
VALUES 
('Cliente 1'),
('Cliente 2'),
('Cliente 3');

INSERT INTO dim_funcionario (nome_funcionario)
VALUES 
('Vendedor A'),
('Vendedor B'),
('Vendedor C');

INSERT INTO vendas_fato (tempo_id, produto_id, local_id, cliente_id, funcionario_id, quantidade, valor)
VALUES 
(1, 1, 1, 1, 1, 100, 6891.00),
(2, 2, 2, 2, 2, 150, 1240.50),
(3, 3, 3, 3, 3, 200, 2010.75);

-- 
select 
v.id, v.quantidade, t.ano, p.nome_produto, c.nome_cliente, f.nome_funcionario, l.cidade, sum(v.valor) as total_vendas
from
vendas_fato v
join dim_tempo t on tempo_id = t.id
join dim_produto p on produto_id = p.id
join dim_cliente c on cliente_id = c.id
join dim_funcionario f on funcionario_id = f.id
join dim_local l on local_id = l.id
group by
v.id, t.ano, c.nome_cliente, f.nome_funcionario, l.cidade, p.nome_produto, v.quantidade;